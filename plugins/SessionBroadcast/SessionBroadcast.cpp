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

#include "SessionBroadcast.h"
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>

SessionBroadcast::SessionBroadcast(QObject* parent)
  : QObject(parent),
    m_broadcaster(NULL)
{
    auto connection = QDBusConnection::SM_BUSNAME();
    auto interface = connection.interface();
    interface->startService("com.canonical.Unity.Greeter.Broadcast");
    m_broadcaster = new QDBusInterface("com.canonical.Unity.Greeter.Broadcast",
                                       "/com/canonical/Unity/Greeter/Broadcast",
                                       "com.canonical.Unity.Greeter.Broadcast",
                                       connection, this);

    connection.connect("com.canonical.Unity.Greeter.Broadcast",
                       "/com/canonical/Unity/Greeter/Broadcast",
                       "com.canonical.Unity.Greeter.Broadcast",
                       "StartApplication",
                       this,
                       SLOT(onStartApplication(const QString &, const QString &)));

    connection.connect("com.canonical.Unity.Greeter.Broadcast",
                       "/com/canonical/Unity/Greeter/Broadcast",
                       "com.canonical.Unity.Greeter.Broadcast",
                       "ShowHome",
                       this,
                       SLOT(onShowHome(const QString &)));
}

void SessionBroadcast::requestApplicationStart(const QString &username, const QString &appId)
{
    m_broadcaster->asyncCall("RequestApplicationStart", username, appId);
}

void SessionBroadcast::onStartApplication(const QString &username, const QString &appId)
{
    // Since this signal is just used for testing, we don't *really* care if
    // username matches, but just in case we do eventually use the signal, we
    // should only listen to our own requests.
    if (username == qgetenv("USER")) {
        Q_EMIT startApplication(appId);
    }
}

void SessionBroadcast::onShowHome(const QString &username)
{
    // Only listen to requests meant for us
    if (username == qgetenv("USER")) {
        Q_EMIT showHome();
    }
}
