/*
 * Copyright (C) 2013-2017 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "Greeter.h"
#include "GreeterPrivate.h"
#include <QCoreApplication>
#include <libintl.h>

static Greeter *singleton = nullptr;

GreeterPrivate::GreeterPrivate(Greeter* parent)
  : m_greeter(new QLightDM::Greeter(parent)),
    m_active(false),
    responded(false),
    everResponded(false),
    q_ptr(parent)
{
}

Greeter::Greeter(QObject* parent)
  : QObject(parent),
    d_ptr(new GreeterPrivate(this))
{
    Q_D(Greeter);

    connect(d->m_greeter, &QLightDM::Greeter::showMessage,
            this, &Greeter::showMessageFilter);
    connect(d->m_greeter, &QLightDM::Greeter::showPrompt,
            this, &Greeter::showPromptFilter);
    connect(d->m_greeter, &QLightDM::Greeter::authenticationComplete,
            this, &Greeter::authenticationCompleteFilter);

    // Don't get stuck waiting for PAM as we shut down.
    connect(QCoreApplication::instance(), &QCoreApplication::aboutToQuit,
            d->m_greeter, &QLightDM::Greeter::cancelAuthentication);

    d->m_greeter->connectSync();
}

Greeter::~Greeter()
{
    singleton = nullptr;
}

Greeter *Greeter::instance()
{
    if (!singleton) {
        singleton = new Greeter;
    }
    return singleton;
}

PromptsModel *Greeter::promptsModel()
{
    Q_D(Greeter);
    return &d->prompts;
}

bool Greeter::isActive() const
{
    Q_D(const Greeter);
    return d->m_active;
}

void Greeter::setIsActive(bool active)
{
    Q_D(Greeter);
    if (d->m_active != active) {
        d->m_active = active;
        Q_EMIT isActiveChanged();
    }
}

bool Greeter::isAuthenticated() const
{
    Q_D(const Greeter);
    return d->m_greeter->isAuthenticated();
}

QString Greeter::authenticationUser() const
{
    Q_D(const Greeter);
    return d->cachedAuthUser;
}

void Greeter::checkAuthenticationUser()
{
    Q_D(Greeter);
    if (d->cachedAuthUser != d->m_greeter->authenticationUser()) {
        d->cachedAuthUser = d->m_greeter->authenticationUser();
        Q_EMIT authenticationUserChanged();
    }
}

QString Greeter::defaultSessionHint() const
{
    Q_D(const Greeter);
    return d->m_greeter->defaultSessionHint();
}

QString Greeter::selectUser() const
{
    Q_D(const Greeter);
    if (hasGuestAccount() && d->m_greeter->selectGuestHint()) {
        return QStringLiteral("*guest");
    } else {
        return d->m_greeter->selectUserHint();
    }
}

bool Greeter::hasGuestAccount() const
{
    Q_D(const Greeter);
    return d->m_greeter->hasGuestAccountHint();
}

bool Greeter::showManualLoginHint() const
{
    Q_D(const Greeter);
    return d->m_greeter->showManualLoginHint();
}

bool Greeter::hideUsersHint() const
{
    Q_D(const Greeter);
    return d->m_greeter->hideUsersHint();
}

void Greeter::authenticate(const QString &username)
{
    Q_D(Greeter);
    d->prompts.clear();
    d->responded = false;
    d->everResponded = false;

    if (authenticationUser() == username) {
        d->prompts = d->leftovers;
    }
    d->leftovers.clear();

    if (username == QStringLiteral("*guest")) {
        d->m_greeter->authenticateAsGuest();
    } else if (username == QStringLiteral("*other")) {
        d->m_greeter->authenticate(nullptr);
    } else {
        d->m_greeter->authenticate(username);
    }

    Q_EMIT authenticationStarted();
    Q_EMIT isAuthenticatedChanged();
    checkAuthenticationUser();
}

void Greeter::respond(const QString &response)
{
    Q_D(Greeter);
    d->responded = true;
    d->everResponded = true;
    d->m_greeter->respond(response);
}

bool Greeter::startSessionSync(const QString &session)
{
    Q_D(Greeter);
    return d->m_greeter->startSessionSync(session);
}

void Greeter::showPromptFilter(const QString &text, QLightDM::Greeter::PromptType type)
{
    Q_D(Greeter);

    checkAuthenticationUser(); // may have changed in liblightdm

    bool isDefaultPrompt = (text == dgettext("Linux-PAM", "Password: "));
    bool isSecret = type == QLightDM::Greeter::PromptTypeSecret;

    QString trimmedText;
    if (!isDefaultPrompt)
        trimmedText = text.trimmed();

    // Strip prompt of any colons at the end
    if (trimmedText.endsWith(':') || trimmedText.endsWith(QStringLiteral("："))) {
        trimmedText.chop(1);
    }

    if (trimmedText == "login") {
        // 'login' is provided untranslated by LightDM when asking for a manual
        // login username.
        trimmedText = gettext("Username");
    }

    if (d->responded) {
        d->prompts.clear();
        d->responded = false;
    }

    d->prompts.append(trimmedText, isSecret ? PromptsModel::Secret : PromptsModel::Question);
}

void Greeter::showMessageFilter(const QString &text, QLightDM::Greeter::MessageType type)
{
    Q_D(Greeter);

    checkAuthenticationUser(); // may have changed in liblightdm

    bool isError = type == QLightDM::Greeter::MessageTypeError;

    if (d->responded) {
        d->prompts.clear();
        d->responded = false;
    }
    d->prompts.append(text, isError? PromptsModel::Error : PromptsModel::Message);
}

void Greeter::authenticationCompleteFilter()
{
    Q_D(Greeter);

    Q_EMIT isAuthenticatedChanged();

    bool automatic = !d->everResponded;
    bool pamHasLeftoverMessages = !d->prompts.hasPrompt() && d->prompts.rowCount() > 0;

    if (!isAuthenticated()) {
        if (pamHasLeftoverMessages) {
            d->leftovers = d->prompts; // Prefer PAM's messages
        } else if (automatic) {
            d->leftovers.append(gettext("Failed to authenticate"), PromptsModel::Error);
        } else {
            d->leftovers.append(gettext("Invalid password, please try again"), PromptsModel::Error);
        }
    } else if (pamHasLeftoverMessages) {
        automatic = true; // treat this successful login as automatic, so user sees message
        d->leftovers = d->prompts;
    }

    if (automatic) {
        d->prompts = d->leftovers; // OK, we'll just use these now
        d->leftovers.clear();
        d->prompts.append(isAuthenticated() ? gettext("Log In") : gettext("Retry"),
                          PromptsModel::Button);
    }

    if (isAuthenticated()) {
        Q_EMIT loginSuccess(automatic);
    } else {
        Q_EMIT loginError(automatic);
    }
}
