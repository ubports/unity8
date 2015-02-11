/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "Greeter.h"
#include "GreeterPrivate.h"

namespace QLightDM
{

GreeterPrivate::GreeterPrivate(Greeter* parent)
  : authenticated(false),
    authenticationUser(),
    twoFactorDone(false),
    mockMode("single"),
    q_ptr(parent)
{
    char *envMockMode = getenv("LIBLIGHTDM_MOCK_MODE");
    if (envMockMode) {
        mockMode = envMockMode;
    }
}

void GreeterPrivate::handleAuthenticate()
{
    Q_Q(Greeter);

    if (mockMode == "single") {
        authenticated = true;
        Q_EMIT q->authenticationComplete();
    } else if (mockMode == "single-passphrase" || mockMode == "single-pin") {
        Q_EMIT q->showPrompt("Password: ", Greeter::PromptTypeSecret);
    } else if (mockMode == "full") {
        handleAuthenticate_full();
    }
}

void GreeterPrivate::handleAuthenticate_full()
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
        Q_EMIT q->showPrompt("Password: ", Greeter::PromptTypeSecret);
    } else if (authenticationUser == "auth-error") {
        authenticated = false;
        Q_EMIT q->authenticationComplete();
    } else if (authenticationUser == "different-prompt") {
        Q_EMIT q->showPrompt("Secret word： ", Greeter::PromptTypeSecret);
    } else {
        Q_EMIT q->showPrompt("Password: ", Greeter::PromptTypeSecret);
    }
}

void GreeterPrivate::handleRespond(QString const &response)
{
    Q_Q(Greeter);

    if (mockMode == "single") {
        // NOOP
    } else if (mockMode == "single-passphrase") {
        authenticated = (response == "password");
        q->sendAuthenticationComplete();
    } else if (mockMode == "single-pin") {
        authenticated = (response == "1234");
        q->sendAuthenticationComplete();
    } else if (mockMode == "full") {
        handleRespond_full(response);
    }
}

void GreeterPrivate::handleRespond_full(const QString &response)
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
                q->sendAuthenticationComplete();
            }
        } else {
            authenticated = (response == "otp");
            q->sendAuthenticationComplete();
        }
        return;
    }

    if (authenticationUser == "has-pin") {
        authenticated = (response == "1234");
    } else {
        authenticated = (response == "password");
    }
    q->sendAuthenticationComplete();
}

}
