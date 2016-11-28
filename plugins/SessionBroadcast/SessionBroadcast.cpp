/*
 * Copyright (C) 2013,2016 Canonical, Ltd.
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

#include "SessionBroadcast.h"
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>

#include <glib.h>

SessionBroadcast::SessionBroadcast(QObject* parent)
  : QObject(parent)
{
    m_username = QString::fromUtf8(g_get_user_name());

    auto connection = QDBusConnection::SM_BUSNAME();
    auto interface = connection.interface();
    interface->startService(QStringLiteral("com.canonical.Unity.Greeter.Broadcast"));

    m_broadcaster = new QDBusInterface(QStringLiteral("com.canonical.Unity.Greeter.Broadcast"),
                                       QStringLiteral("/com/canonical/Unity/Greeter/Broadcast"),
                                       QStringLiteral("com.canonical.Unity.Greeter.Broadcast"),
                                       connection, this);

    connect(m_broadcaster, SIGNAL(StartUrl(const QString &, const QString &)),
            this, SLOT(onStartUrl(const QString &, const QString &)));

    connect(m_broadcaster, SIGNAL(ShowHome(const QString &)),
            this, SLOT(onShowHome(const QString &)));
}

void SessionBroadcast::requestUrlStart(const QString &username, const QString &url)
{
    m_broadcaster->asyncCall(QStringLiteral("RequestUrlStart"), username, url);
}

void SessionBroadcast::requestHomeShown(const QString &username)
{
    m_broadcaster->asyncCall(QStringLiteral("RequestHomeShown"), username);
}

void SessionBroadcast::onStartUrl(const QString &username, const QString &url)
{
    // Since this signal is just used for testing, we don't *really* care if
    // username matches, but just in case we do eventually use the signal, we
    // should only listen to our own requests.
    if (username == m_username) {
        Q_EMIT startUrl(url);
    }
}

void SessionBroadcast::onShowHome(const QString &username)
{
    // Only listen to requests meant for us
    if (username == m_username) {
        Q_EMIT showHome();
    }
}
