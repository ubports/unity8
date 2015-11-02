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

#include "Greeter.h"
#include "GreeterPrivate.h"
#include <QFuture>
#include <QFutureInterface>
#include <QFutureWatcher>
#include <QQueue>
#include <QtConcurrent>
#include <QVector>
#include <security/pam_appl.h>

namespace QLightDM
{

class GreeterImpl : public QObject
{
    Q_OBJECT

    struct AppData
    {
        GreeterImpl *impl;
        pam_handle *handle;
    };

    typedef QFutureInterface<QString> ResponseFuture;

public:
    explicit GreeterImpl(Greeter *parent, GreeterPrivate *greeterPrivate)
        : QObject(parent),
          greeter(parent),
          greeterPrivate(greeterPrivate),
          pamHandle(nullptr)
    {
        qRegisterMetaType<QLightDM::GreeterImpl::ResponseFuture>("QLightDM::GreeterImpl::ResponseFuture");

        connect(&futureWatcher, &QFutureWatcher<int>::finished, this, &GreeterImpl::finishPam);
        connect(this, SIGNAL(showMessage(pam_handle *, QString, QLightDM::Greeter::MessageType)),
                this, SLOT(handleMessage(pam_handle *, QString, QLightDM::Greeter::MessageType)));
        // This next connect is how we pass ResponseFutures between threads
        connect(this, SIGNAL(showPrompt(pam_handle *, QString, QLightDM::Greeter::PromptType, QLightDM::GreeterImpl::ResponseFuture)),
                this, SLOT(handlePrompt(pam_handle *, QString, QLightDM::Greeter::PromptType, QLightDM::GreeterImpl::ResponseFuture)),
                Qt::BlockingQueuedConnection);
    }

    ~GreeterImpl()
    {
        cancelPam();
    }

    void start(QString username)
    {
        // Clear out any existing PAM interactions first
        cancelPam();
        if (pamHandle != nullptr) {
            // While we were cancelling pam above, we processed Qt events.
            // Which may have allowed someone to call start() on us again.
            // In which case, we'll bail on our current start() call.
            // This isn't racy because it's all in the same thread.
            return;
        }

        AppData *appData = new AppData();
        appData->impl = this;

        // Now actually start a new conversation with PAM
        pam_conv conversation;
        conversation.conv = converseWithPam;
        conversation.appdata_ptr = static_cast<void*>(appData);

        if (pam_start("lightdm", username.toUtf8(), &conversation, &pamHandle) == PAM_SUCCESS) {
            appData->handle = pamHandle;
            futureWatcher.setFuture(QtConcurrent::mapped(QList<pam_handle*>() << pamHandle, authenticateWithPam));
        } else {
            delete appData;
            greeterPrivate->authenticated = false;
            Q_EMIT greeter->showMessage(QStringLiteral("Internal error: could not start PAM authentication"), QLightDM::Greeter::MessageTypeError);
            Q_EMIT greeter->authenticationComplete();
        }
    }

    static int authenticateWithPam(pam_handle* const& pamHandle)
    {
        int pamStatus = pam_authenticate(pamHandle, 0);
        if (pamStatus == PAM_SUCCESS) {
            pamStatus = pam_acct_mgmt(pamHandle, 0);
        }
        if (pamStatus == PAM_NEW_AUTHTOK_REQD) {
            pamStatus = pam_chauthtok(pamHandle, PAM_CHANGE_EXPIRED_AUTHTOK);
        }
        if (pamStatus == PAM_SUCCESS) {
            pam_setcred(pamHandle, PAM_REINITIALIZE_CRED);
        }
        return pamStatus;
    }

    static int converseWithPam(int num_msg, const pam_message** msg,
                               pam_response** resp, void* appdata_ptr)
    {
        if (num_msg <= 0)
            return PAM_CONV_ERR;

        auto* tmp_response = static_cast<pam_response*>(calloc(num_msg, sizeof(pam_response)));
        if (!tmp_response)
            return PAM_CONV_ERR;

        AppData *appData = static_cast<AppData*>(appdata_ptr);
        GreeterImpl *impl = appData->impl;
        pam_handle *handle = appData->handle;

        int count;
        QVector<ResponseFuture> responses;

        for (count = 0; count < num_msg; ++count)
        {
            switch (msg[count]->msg_style)
            {
            case PAM_PROMPT_ECHO_ON:
            {
                QString message(msg[count]->msg);
                responses.append(ResponseFuture());
                responses.last().reportStarted();
                Q_EMIT impl->showPrompt(handle, message, Greeter::PromptTypeQuestion, responses.last());
                break;
            }
            case PAM_PROMPT_ECHO_OFF:
            {
                QString message(msg[count]->msg);
                responses.append(ResponseFuture());
                responses.last().reportStarted();
                Q_EMIT impl->showPrompt(handle, message, Greeter::PromptTypeSecret, responses.last());
                break;
            }
            case PAM_TEXT_INFO:
            {
                QString message(msg[count]->msg);
                Q_EMIT impl->showMessage(handle, message, Greeter::MessageTypeInfo);
                break;
            }
            default:
            {
                QString message(msg[count]->msg);
                Q_EMIT impl->showMessage(handle, message, Greeter::MessageTypeError);
                break;
            }
            }
        }

        int i = 0;
        bool raise_error = false;

        for (auto &response : responses)
        {
            pam_response* resp_item = &tmp_response[i++];
            resp_item->resp_retcode = 0;
            resp_item->resp = strdup(response.future().result().toUtf8());

            if (!resp_item->resp)
            {
                raise_error = true;
                break;
            }
        }

        delete appData;

        if (raise_error)
        {
            for (int i = 0; i < count; ++i)
                free(tmp_response[i].resp);

            free(tmp_response);
            return PAM_CONV_ERR;
        }
        else
        {
            *resp = tmp_response;
            return PAM_SUCCESS;
        }
    }

public Q_SLOTS:
    bool respond(QString response)
    {
        if (!futures.isEmpty()) {
            futures.dequeue().reportFinished(&response);
            return true;
        } else {
            return false;
        }
    }

Q_SIGNALS:
    void showMessage(pam_handle *handle, QString text, QLightDM::Greeter::MessageType type);
    void showPrompt(pam_handle *handle, QString text, QLightDM::Greeter::PromptType type, QLightDM::GreeterImpl::ResponseFuture response);

private Q_SLOTS:
    void finishPam()
    {
        if (pamHandle == nullptr) {
            return;
        }

        int pamStatus = futureWatcher.result();

        pam_end(pamHandle, pamStatus);
        pamHandle = nullptr;

        greeterPrivate->authenticated = (pamStatus == PAM_SUCCESS);
        Q_EMIT greeter->authenticationComplete();
    }

    void handleMessage(pam_handle *handle, QString text, QLightDM::Greeter::MessageType type)
    {
        if (handle != pamHandle)
            return;

        Q_EMIT greeter->showMessage(text, type);
    }

    void handlePrompt(pam_handle *handle, QString text, QLightDM::Greeter::PromptType type, QLightDM::GreeterImpl::ResponseFuture future)
    {
        if (handle != pamHandle) {
            future.reportResult(QString());
            future.reportFinished();
            return;
        }

        futures.enqueue(future);
        Q_EMIT greeter->showPrompt(text, type);
    }

private:
    void cancelPam()
    {
        if (pamHandle != nullptr) {
            QFuture<int> pamFuture = futureWatcher.future();
            pam_handle *handle = pamHandle;
            pamHandle = nullptr; // to disable normal finishPam() handling
            pamFuture.cancel();

            // Note the empty loop, we just want to clear the futures queue.
            // Any further prompts from the pam thread will be immediately
            // responded to/dismissed in handlePrompt().
            while (respond(QString()));

            // Now let signal/slot handling happen so the thread can finish
            while (!pamFuture.isFinished()) {
                QCoreApplication::processEvents();
            }

            pam_end(handle, PAM_CONV_ERR);
        }
    }

    Greeter *greeter;
    GreeterPrivate *greeterPrivate;
    pam_handle* pamHandle;
    QFutureWatcher<int> futureWatcher;
    QQueue<ResponseFuture> futures;
};

GreeterPrivate::GreeterPrivate(Greeter* parent)
  : authenticated(false),
    authenticationUser(),
    m_impl(new GreeterImpl(parent, this)),
    q_ptr(parent)
{
}

GreeterPrivate::~GreeterPrivate()
{
    delete m_impl;
}

void GreeterPrivate::handleAuthenticate()
{
    m_impl->start(authenticationUser);
}

void GreeterPrivate::handleRespond(const QString &response)
{
    m_impl->respond(response);
}

}

#include "GreeterPrivate.moc"
