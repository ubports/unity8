/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
};

Greeter::Greeter(QObject *parent)
  : QObject(parent)
  , d_ptr(new GreeterPrivate)
{
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
    return false;
}

bool Greeter::showManualLoginHint() const
{
    return true;
}

bool Greeter::showRemoteLoginHint() const
{
    return true;
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
    QTimer::singleShot(0, this, &Greeter::handleAuthenticate);
}

void Greeter::handleAuthenticate()
{
    Q_D(Greeter);

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
    } else if (d->authenticationUser == "has-pin"){
        Q_EMIT showPrompt("Password: ", Greeter::PromptTypeSecret);
    } else if (d->authenticationUser == "auth-error") {
        d->authenticated = false;
        Q_EMIT authenticationComplete();
    } else if (d->authenticationUser == "different-prompt") {
        Q_EMIT showPrompt("Secret word： ", Greeter::PromptTypeSecret);
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
    QTimer::singleShot(0, this, &Greeter::authenticationComplete);
}

void Greeter::authenticateAutologin()
{}

void Greeter::authenticateRemote(const QString &session, const QString &username)
{
    Q_UNUSED(session)
    Q_UNUSED(username)
}

void Greeter::cancelAuthentication()
{}

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

    if (d->authenticationUser == "no-response")
        return;
    else if (d->authenticationUser == "two-factor") {
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
    }

    if (d->authenticationUser == "has-pin") {
        d->authenticated = (response == "1234");
    } else {
        d->authenticated = (response == "password");
    }
    sendAuthenticationComplete();
}

void Greeter::sendAuthenticationComplete()
{
    if (qgetenv("UNITY_TESTING").isEmpty()) {
        // simulate PAM's delay
        QTimer::singleShot(1000, this, &Greeter::authenticationComplete);
    } else {
        Q_EMIT authenticationComplete();
    }
}

QObject *Greeter::mock()
{
    return MockController::instance();
}

}
