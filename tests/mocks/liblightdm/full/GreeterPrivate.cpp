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
    twoFactorDone(false),
    q_ptr(parent)
{
}

void GreeterPrivate::handleAuthenticate()
{
    Q_Q(Greeter);

    // Send out any messages we need to
    if (authenticationUser == "info-prompt")
        Q_EMIT q->showMessage("Welcome to Unity Greeter", Greeter::MessageTypeInfo);
    else if (authenticationUser == "wide-info-prompt")
        Q_EMIT q->showMessage("Welcome to Unity Greeter, the greeteriest greeter that ever did appear in these fine lands", Greeter::MessageTypeInfo);
    else if (authenticationUser == "html-info-prompt")
        Q_EMIT q->showMessage("<b>&</b>", Greeter::MessageTypeInfo);
    else if (authenticationUser == "long-info-prompt")
        Q_EMIT q->showMessage("Welcome to Unity Greeter\n\nWe like to annoy you with super ridiculously long messages.\nLike this one\n\nThis is the last line of a multiple line message.", Greeter::MessageTypeInfo);
    else if (authenticationUser == "multi-info-prompt") {
        Q_EMIT q->showMessage("Welcome to Unity Greeter", Greeter::MessageTypeInfo);
        Q_EMIT q->showMessage("This is an error", Greeter::MessageTypeError);
        Q_EMIT q->showMessage("You should have seen three messages", Greeter::MessageTypeInfo);
    }

    // OK, now actually do the prompt
    if (authenticationUser == "no-password") {
        authenticated = true;
        Q_EMIT q->authenticationComplete();
    } else if (authenticationUser == "has-pin"){
        Q_EMIT q->showPrompt("PIN", Greeter::PromptTypeSecret);
    } else if (authenticationUser == "auth-error") {
        authenticated = false;
        Q_EMIT q->authenticationComplete();
    } else if (authenticationUser == "different-prompt") {
        Q_EMIT q->showPrompt("Secret word： ", Greeter::PromptTypeSecret);
    } else {
        Q_EMIT q->showPrompt("Password: ", Greeter::PromptTypeSecret);
    }
}

void GreeterPrivate::handleRespond(const QString &response)
{
    Q_Q(Greeter);

    if (authenticationUser == "no-response")
        return;
    else if (authenticationUser == "two-factor") {
        if (!twoFactorDone) {
            if (response == "password") {
                twoFactorDone = true;
                Q_EMIT q->showPrompt("otp", Greeter::PromptTypeQuestion);
            } else {
                authenticated = false;
                Q_EMIT q->authenticationComplete();
            }
        } else {
            authenticated = (response == "otp");
            Q_EMIT q->authenticationComplete();
        }
        return;
    }

    if (authenticationUser == "has-pin") {
        authenticated = (response == "1234");
    } else {
        authenticated = (response == "password");
    }
    Q_EMIT q->authenticationComplete();
}

}
