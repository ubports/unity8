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
#include <QFileInfo>

SessionBroadcast::SessionBroadcast(QObject* parent)
  : QObject(parent),
    broadcaster(NULL)
{
    auto connection = QDBusConnection::SM_BUSNAME();
    auto interface = connection.interface();
    interface->startService("com.canonical.Unity.Greeter.Broadcast");
    broadcaster = new QDBusInterface("com.canonical.Unity.Greeter.Broadcast",
                                     "/com/canonical/Unity/Greeter/Broadcast",
                                     "com.canonical.Unity.Greeter.Broadcast",
                                     connection, this);

    connection.connect("com.canonical.Unity.Greeter.Broadcast",
                       "/com/canonical/Unity/Greeter/Broadcast",
                       "com.canonical.Unity.Greeter.Broadcast",
                       "StartApplication",
                       this,
                       SLOT(onStartApplication(const QString &, const QString &)));
}

void SessionBroadcast::requestApplicationStart(const QString &username, const QString &appId)
{
    // unity-greeter-session-broadcast deals in short appIds.  That is,
    // desktop file names without the ".desktop".  It doesn't really allow
    // for arbitrary-path desktop files, for security reasons (hard to
    // contain with apparmor and such).  So we need to mangle the names a bit.
    // If incoming appId is random path like /hello/foobar.desktop, then just
    // do our best and ask for foobar.
    QString desktopSuffix = ".desktop";
    QString mangled = appId;
    if (mangled.endsWith(desktopSuffix))
        mangled.chop(desktopSuffix.size());
    mangled = QFileInfo(mangled).fileName(); // chop off path

    broadcaster->asyncCall("RequestApplicationStart", username, mangled);
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
