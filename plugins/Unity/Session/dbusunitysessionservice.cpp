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
#include <QDBusPendingCall>

DBusUnitySessionService::DBusUnitySessionService()
    : UnityDBusObject("/com/canonical/Unity/Session", "com.canonical.Unity")
{
}

void DBusUnitySessionService::Logout()
{
    // TODO ask the apps to quit and then emit the signal
    Q_EMIT logoutReady();
}

void DBusUnitySessionService::EndSession()
{
    const QDBusMessage msg = QDBusMessage::createMethodCall("com.ubuntu.Upstart",
                                                            "/com/ubuntu/Upstart",
                                                            "com.ubuntu.Upstart0_6",
                                                            "EndSession");
    QDBusConnection::sessionBus().asyncCall(msg);
}

void DBusUnitySessionService::RequestLogout()
{
    Q_EMIT logoutRequested(false);
}

void DBusUnitySessionService::Reboot()
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.freedesktop.login1",
                                                      "/org/freedesktop/login1",
                                                      "org.freedesktop.login1.Manager",
                                                      "Reboot");
    msg << false;
    QDBusConnection::systemBus().asyncCall(msg);
}

void DBusUnitySessionService::RequestReboot()
{
    Q_EMIT rebootRequested(false);
}

void DBusUnitySessionService::Shutdown()
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.freedesktop.login1",
                                                      "/org/freedesktop/login1",
                                                      "org.freedesktop.login1.Manager",
                                                      "PowerOff");
    msg << false;
    QDBusConnection::systemBus().asyncCall(msg);
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

void DBusGnomeSessionManagerWrapper::performAsyncCall(const QString &method)
{
    const QDBusMessage msg = QDBusMessage::createMethodCall("com.canonical.Unity",
                                                            "/com/canonical/Unity/Session",
                                                            "com.canonical.Unity.Session",
                                                            method);
    QDBusConnection::sessionBus().asyncCall(msg);
}

void DBusGnomeSessionManagerWrapper::Open(const unsigned type, const unsigned arg_1, const unsigned max_wait, const QList<QDBusObjectPath> &inhibitors)
{
    Q_UNUSED(arg_1);
    Q_UNUSED(max_wait);
    Q_UNUSED(inhibitors);

    const Action action = (Action)type;

    switch (action)
    {
    case Action::LOGOUT:
        performAsyncCall("RequestLogout");
        break;

    case Action::REBOOT:
        performAsyncCall("RequestReboot");
        break;

    case Action::SHUTDOWN:
        performAsyncCall("RequestShutdown");
        break;

    default:
        break;
    }
}
