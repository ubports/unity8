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

enum class Action : unsigned
{
  LOGOUT = 0,
  SHUTDOWN,
  REBOOT,
  NONE
};

DBusGnomeSessionManagerWrapper::DBusGnomeSessionManagerWrapper()
    : UnityDBusObject("/org/gnome/SessionManager/EndSessionDialog", "com.canonical.Unity")
{
}

DBusGnomeSessionManagerWrapper::~DBusGnomeSessionManagerWrapper()
{
}

void DBusGnomeSessionManagerWrapper::Open(const unsigned type, const unsigned arg_1, const unsigned max_wait, const QList<QDBusObjectPath> &inhibitors)
{
  Q_UNUSED(arg_1);
  Q_UNUSED(max_wait);
  Q_UNUSED(inhibitors);

  QDBusConnection connection = QDBusConnection::sessionBus();
  QDBusInterface iface1 ("com.canonical.Unity",
                         "/com/canonical/Unity/Session",
                         "com.canonical.Unity.Session",
                         connection);

  Action action = (Action)type;

  switch (action)
  {
    case Action::LOGOUT:
      iface1.call("RequestLogout");
      break;

    case Action::REBOOT:
      iface1.call("RequestShutdown");
      break;

    case Action::SHUTDOWN:
      break;

    default:
      break;
  }
}
