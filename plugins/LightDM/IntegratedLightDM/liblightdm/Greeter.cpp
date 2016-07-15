/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 * Author: Michael Terry <michael.terry@canonical.com>
 */


/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 * CHANGES MADE HERE MUST BE REFLECTED ON THE MOCK LIB
 * COUNTERPART IN tests/mocks/Lightdm/liblightdm
 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */


#include "Greeter.h"
#include "GreeterPrivate.h"
#include <QtCore/QCoreApplication>
#include <QTimer>

namespace QLightDM
{

Greeter::Greeter(QObject *parent)
  : QObject(parent),
    d_ptr(new GreeterPrivate(this))
{
}

Greeter::~Greeter()
{
}

QString Greeter::authenticationUser() const
{
    Q_D(const Greeter);
    return d->authenticationUser;
}

bool Greeter::hasGuestAccountHint() const
{
    return true;
}

QString Greeter::getHint(const QString &name) const
{
    Q_UNUSED(name)
    return QLatin1String("");
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

bool Greeter::lockHint () const
{
    return false;
}

QString Greeter::selectUserHint() const
{
    return QLatin1String("");
}

bool Greeter::selectGuestHint() const
{
    return false;
}

QString Greeter::autologinUserHint() const
{
    return QLatin1String("");
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
    return QStringLiteral("hostname1");
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
    d->handleAuthenticate();
}

void Greeter::authenticateAsGuest()
{}

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
    return true;
}

void Greeter::respond(const QString &response)
{
    Q_D(Greeter);

    d->handleRespond(response);
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
