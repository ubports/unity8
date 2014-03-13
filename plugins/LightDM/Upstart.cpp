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
 */

#include "Upstart.h"

#include <QDBusConnection>
#include <QProcess>
#include <unistd.h>

class URLDispatcher : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.URLDispatcher")

public:
    explicit URLDispatcher(Upstart *parent);

    Q_SCRIPTABLE void DispatchURL(const QString &url);

private:
    Upstart *m_parent;
};

URLDispatcher::URLDispatcher(Upstart *parent)
  : QObject(parent),
    m_parent(parent)
{
}

void URLDispatcher::DispatchURL(const QString &url)
{
    Q_EMIT m_parent->dispatchURL(url);
}

// Normal unity8 sessions are entirely driven by Upstart.  But greeters
// are special.  They need access to the file descriptors that lightdm
// creates for them and don't want to start all the services that a normal
// session would.  So it's inconvenient to live within an upstart session.
// But... we still want to use Upstart for some services.  So rather than being
// spawned *by* Upstart like unity8 is, we spawn *it* instead.
Upstart::Upstart(QObject *parent)
  : QObject(parent)
{
    // This class also manages our url-dispatcher interception, as it's sort of
    // a service provided by Upstart normally.  We intercept url-dispatcher
    // because rather than spawning the handler for the URL in our own session,
    // we want to do notify the user session to do it for us (and start an
    // unlock in the process).
    QDBusConnection connection = QDBusConnection::sessionBus();
    URLDispatcher *dispatcher = new URLDispatcher(this);
    connection.registerObject("/com/canonical/URLDispatcher", dispatcher, QDBusConnection::ExportScriptableContents);
    connection.registerService("com.canonical.URLDispatcher");

    // Start upstart (unless it's already running, like if the user is testing
    // locally on their desktop)
    if (QString(qgetenv("UPSTART_SESSION")).isEmpty())
    {
        QProcess *upstart = new QProcess(this);
        QString command = "/sbin/init --user --startup-event=unity8-greeter-started";
        // in main.cpp, we convert client to server.  Convert back here.
        if (qgetenv("QT_QPA_PLATFORM") == "ubuntumirserver")
            command.prepend("/usr/bin/env QT_QPA_PLATFORM=ubuntumirclient ");
        upstart->start(command);
    }
}

#include "Upstart.moc"
