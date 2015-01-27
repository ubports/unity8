/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// local
#include "dbusunitysessionservice.h"

// Qt
#include <QDBusConnection>
#include <QDBusInterface>

DBusUnitySessionService::DBusUnitySessionService()
    : UnityDBusObject("/com/canonical/Unity/Session", "com.canonical.Unity")
{
}

DBusUnitySessionService::~DBusUnitySessionService()
{
}

void DBusUnitySessionService::Logout()
{
  Q_EMIT logoutReady();
}

void DBusUnitySessionService::EndSession()
{
  QDBusConnection connection = QDBusConnection::sessionBus();
  QDBusInterface iface1 ("com.ubuntu.Upstart",
                         "/com/ubuntu/Upstart",
                         "com.ubuntu.Upstart0_6",
                         connection);
 
  iface1.call("EndSession");
}

void DBusUnitySessionService::RequestLogout()
{
  Q_EMIT logoutRequested(false);
}

void DBusUnitySessionService::Reboot()
{
  QDBusConnection connection = QDBusConnection::systemBus();
  QDBusInterface iface1 ("org.freedesktop.login1",
                         "/org/freedesktop/login1",
                         "org.freedesktop.login1.Manager",
                         connection);

  iface1.call("Reboot", false);
}

void DBusUnitySessionService::RequestReboot()
{
  Q_EMIT rebootRequested(false);
}

void DBusUnitySessionService::Shutdown()
{
  QDBusConnection connection = QDBusConnection::systemBus();
  QDBusInterface iface1 ("org.freedesktop.login1",
                         "/org/freedesktop/login1",
                         "org.freedesktop.login1.Manager",
                         connection);

  iface1.call("PowerOff", false);
}

void DBusUnitySessionService::RequestShutdown()
{
  Q_EMIT shutdownRequested(false);
}
