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

#include "../Greeter.h"
#include "../GreeterPrivate.h"
#include <QtCore/QDir>
#include <QtCore/QSettings>

namespace QLightDM
{

GreeterPrivate::GreeterPrivate(Greeter* parent)
  : authenticated(false),
    authenticationUser(),
    q_ptr(parent)
{
}

void GreeterPrivate::handleAuthenticate()
{
    Q_Q(Greeter);

    QSettings settings(QDir::homePath() + "/.unity8-greeter-demo", QSettings::NativeFormat);
    settings.beginGroup(authenticationUser);
    QVariant password = settings.value("password", "none");

    if (password == "pin") {
        Q_EMIT q->showPrompt("PIN", Greeter::PromptTypeSecret);
    } else if (password == "keyboard") {
        Q_EMIT q->showPrompt("Password", Greeter::PromptTypeSecret);
    } else {
        authenticated = true;
        Q_EMIT q->authenticationComplete();
    }
}

void GreeterPrivate::handleRespond(const QString &response)
{
    Q_Q(Greeter);

    QSettings settings(QDir::homePath() + "/.unity8-greeter-demo", QSettings::NativeFormat);
    settings.beginGroup(authenticationUser);
    QVariant password = settings.value("password", "none");

    QString passwordValue;
    if (password == "pin") {
        passwordValue = settings.value("passwordValue", "1234").toString();
    } else {
        passwordValue = settings.value("passwordValue", "password").toString();
    }
    authenticated = (response == passwordValue);
    Q_EMIT q->authenticationComplete();
}

}
