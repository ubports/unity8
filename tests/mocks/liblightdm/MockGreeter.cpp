/*
 * Copyright (C) 2014-2017 Canonical, Ltd.
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
 */

#include "MockController.h"
#include "MockGreeter.h"
#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QTimer>

namespace QLightDM
{

class GreeterPrivate
{
public:
    bool authenticated = false;
    QString authenticationUser;
    bool twoFactorDone = false;
    QTimer authCallbackTimer;
};

Greeter::Greeter(QObject *parent)
  : QObject(parent)
  , d_ptr(new GreeterPrivate)
{
    Q_D(Greeter);

    d->authCallbackTimer.setSingleShot(true);
    connect(&d->authCallbackTimer, &QTimer::timeout,
            this, &QLightDM::Greeter::handleAuthenticate);
}

Greeter::~Greeter()
{
    delete d_ptr;
}

QString Greeter::authenticationUser() const
{
    Q_D(const Greeter);

    return d->authenticationUser;
}

bool Greeter::hasGuestAccountHint() const
{
    return MockController::instance()->hasGuestAccountHint();
}

QString Greeter::getHint(const QString &name) const
{
    Q_UNUSED(name)
    return "";
}

QString Greeter::defaultSessionHint() const
{
    return QStringLiteral("ubuntu");
}

bool Greeter::hideUsersHint() const
{
    return MockController::instance()->hideUsersHint();
}

bool Greeter::showManualLoginHint() const
{
    return MockController::instance()->showManualLoginHint();
}

bool Greeter::showRemoteLoginHint() const
{
    return false;
}

QString Greeter::selectUserHint() const
{
    return MockController::instance()->selectUserHint();
}

bool Greeter::selectGuestHint() const
{
    return MockController::instance()->selectGuestHint();
}

QString Greeter::autologinUserHint() const
{
    return "";
}

bool Greeter::autologinGuestHint() const
{
    return false;
}

int Greeter::autologinTimeoutHint() const
{
    return 0;
}

bool Greeter::inAuthentication() const
{
    return false;
}

QString Greeter::hostname() const
{
    return "hostname1";
}

bool Greeter::isAuthenticated() const
{
    Q_D(const Greeter);

    return d->authenticated;
}

bool Greeter::connectSync()
{
    return true;
}

void Greeter::authenticate(const QString &username)
{
    Q_D(Greeter);

    d->authenticated = false;
    d->authenticationUser = username;
    d->twoFactorDone = false;
    d->authCallbackTimer.start();
}

void Greeter::handleAuthenticate()
{
    Q_D(Greeter);

    if (d->authenticated) {
        // This can happen from the guest authentication flow
        Q_EMIT authenticationComplete();
        return;
    }

    if (d->authenticationUser.isEmpty()) {
        Q_EMIT showPrompt("Username: ", Greeter::PromptTypeQuestion);
        return;
    }

    // Send out any messages we need to
    if (d->authenticationUser == "info-prompt")
        Q_EMIT showMessage("Welcome to Unity Greeter", Greeter::MessageTypeInfo);
    else if (d->authenticationUser == "wide-info-prompt")
        Q_EMIT showMessage("Welcome to Unity Greeter, the greeteriest greeter that ever did appear in these fine lands", Greeter::MessageTypeInfo);
    else if (d->authenticationUser == "html-info-prompt")
        Q_EMIT showMessage("<b>&</b>", Greeter::MessageTypeInfo);
    else if (d->authenticationUser == "long-info-prompt")
        Q_EMIT showMessage("Welcome to Unity Greeter\n\nWe like to annoy you with super ridiculously long messages.\nLike this one\n\nThis is the last line of a multiple line message.", Greeter::MessageTypeInfo);
    else if (d->authenticationUser == "multi-info-prompt") {
        Q_EMIT showMessage("Welcome to Unity Greeter", Greeter::MessageTypeInfo);
        Q_EMIT showMessage("This is an error", Greeter::MessageTypeError);
        Q_EMIT showMessage("You should have seen three messages", Greeter::MessageTypeInfo);
    }

    // OK, now actually do the prompt
    if (d->authenticationUser == "no-password") {
        d->authenticated = true;
        Q_EMIT authenticationComplete();
    } else if (d->authenticationUser == "has-pin") {
        Q_EMIT showPrompt("Password: ", Greeter::PromptTypeSecret);
    } else if (d->authenticationUser == "auth-error") {
        d->authenticated = false;
        Q_EMIT authenticationComplete();
    } else if (d->authenticationUser == "different-prompt") {
        Q_EMIT showPrompt("Secret word： ", Greeter::PromptTypeSecret);
    } else if (d->authenticationUser == "question-prompt") {
        Q_EMIT showPrompt("Favorite Color (blue): ", Greeter::PromptTypeQuestion);
    } else if (d->authenticationUser == "two-prompts") {
        Q_EMIT showPrompt("Favorite Color (blue):", Greeter::PromptTypeQuestion);
        Q_EMIT showPrompt("Password: ", Greeter::PromptTypeSecret);
    } else if (d->authenticationUser == "wacky-prompts") {
        Q_EMIT showMessage("First message", Greeter::MessageTypeInfo);
        Q_EMIT showPrompt("Favorite Color (blue)", Greeter::PromptTypeQuestion);
        Q_EMIT showMessage("Second message", Greeter::MessageTypeError);
        Q_EMIT showPrompt("Password: ", Greeter::PromptTypeSecret);
        Q_EMIT showMessage("Last message", Greeter::MessageTypeInfo);
    } else {
        Q_EMIT showPrompt("Password: ", Greeter::PromptTypeSecret);
    }
}

void Greeter::authenticateAsGuest()
{
    Q_D(Greeter);

    d->authenticated = true;
    d->authenticationUser = QString(); // this is what the real liblightdm does
    d->twoFactorDone = false;
    d->authCallbackTimer.start();
}

void Greeter::authenticateAutologin()
{}

void Greeter::authenticateRemote(const QString &session, const QString &username)
{
    Q_UNUSED(session)
    Q_UNUSED(username)
}

void Greeter::cancelAuthentication()
{
    Q_D(Greeter);
    d->authCallbackTimer.stop();
}

void Greeter::setLanguage (const QString &language)
{
    Q_UNUSED(language)
}

bool Greeter::startSessionSync(const QString &session)
{
    Q_UNUSED(session)

    // Send a request to hide the greeter.  This is normally done by logind,
    // but when testing, we don't want the bother of mocking that out. Instead,
    // just send the request directly ourselves.
    QDBusInterface iface("com.canonical.UnityGreeter",
                         "/",
                         "com.canonical.UnityGreeter",
                         QDBusConnection::sessionBus());
    iface.asyncCall("HideGreeter");

    return true;
}

void Greeter::respond(const QString &response)
{
    Q_D(Greeter);

    if (d->authenticationUser.isEmpty()) {
        // A manual login, our first question was which username
        d->authenticationUser = response;
        handleAuthenticate();
        return;
    }

    if (d->authenticationUser == "no-response") {
        return;
    } else if (d->authenticationUser == "locked") {
        Q_EMIT showMessage("Account is locked", Greeter::MessageTypeError);
        sendAuthenticationComplete();
        return;
    } else if (d->authenticationUser == "two-factor") {
        if (!d->twoFactorDone) {
            if (response == "password") {
                d->twoFactorDone = true;
                Q_EMIT showPrompt("otp", Greeter::PromptTypeQuestion);
            } else {
                d->authenticated = false;
                sendAuthenticationComplete();
            }
        } else {
            d->authenticated = (response == "otp");
            sendAuthenticationComplete();
        }
        return;
    } else if (d->authenticationUser == "two-prompts" || d->authenticationUser == "wacky-prompts") {
        if (!d->twoFactorDone) {
            d->authenticated = (response == "blue");
            d->twoFactorDone = true;
        } else {
            d->authenticated = d->authenticated && (response == "password");
            sendAuthenticationComplete();
        }
        return;
    }

    if (d->authenticationUser == "has-pin") {
        d->authenticated = (response == "1234");
    } else if (d->authenticationUser == "question-prompt") {
        d->authenticated = (response == "blue");
    } else {
        d->authenticated = (response == "password");
    }

    if (d->authenticationUser == "info-after-login" && d->authenticated) {
        Q_EMIT showMessage("Congratulations on logging in!", Greeter::MessageTypeInfo);
    }

    sendAuthenticationComplete();
}

void Greeter::sendAuthenticationComplete()
{
    if (qEnvironmentVariableIsEmpty("UNITY_TESTING")) {
        // simulate PAM's delay
        QTimer::singleShot(1000, this, &Greeter::authenticationComplete);
    } else {
        Q_EMIT authenticationComplete();
    }
}

}
