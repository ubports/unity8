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
    Q_EMIT q->showPrompt("Password:", Greeter::PromptTypeSecret);
}

void GreeterPrivate::handleRespond(const QString &response)
{
    Q_Q(Greeter);

    authenticated = (response == "password");
    q->sendAuthenticationComplete();
}

}
