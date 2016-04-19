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

#include <glib.h>

SessionBroadcast::SessionBroadcast(QObject* parent)
  : QObject(parent)
{
    m_username = QString::fromUtf8(g_get_user_name());

    auto connection = QDBusConnection::SM_BUSNAME();

    connection.connect(QStringLiteral("com.canonical.Unity.Greeter.Broadcast"),
                       QStringLiteral("/com/canonical/Unity/Greeter/Broadcast"),
                       QStringLiteral("com.canonical.Unity.Greeter.Broadcast"),
                       QStringLiteral("ShowHome"),
                       this,
                       SLOT(onShowHome(const QString &)));
}

void SessionBroadcast::onShowHome(const QString &username)
{
    // Only listen to requests meant for us
    if (username == m_username) {
        Q_EMIT showHome();
    }
}
