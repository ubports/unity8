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

// system
#include <sys/types.h>
#include <unistd.h>
#include <pwd.h>

// Qt
#include <QDebug>
#include <QDBusPendingCall>
#include <QDBusReply>

#define LOGIN1_SERVICE QStringLiteral("org.freedesktop.login1")
#define LOGIN1_PATH QStringLiteral("/org/freedesktop/login1")
#define LOGIN1_IFACE QStringLiteral("org.freedesktop.login1.Manager")
#define LOGIN1_SESSION_IFACE QStringLiteral("org.freedesktop.login1.Session")

bool checkLogin1Call(const QString &method)
{
    QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE, LOGIN1_PATH, LOGIN1_IFACE, method);
    QDBusReply<QString> reply = QDBusConnection::systemBus().asyncCall(msg);
    const QString retval = reply.value();
    return (retval == QStringLiteral("yes") || retval == QStringLiteral("challenge"));
}

void makeLogin1Call(const QString &method, const QVariantList &args)
{
    QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE,
                                                      LOGIN1_PATH,
                                                      LOGIN1_IFACE,
                                                      method);
    msg.setArguments(args);
    QDBusConnection::systemBus().asyncCall(msg);
}

DBusUnitySessionService::DBusUnitySessionService()
    : UnityDBusObject("/com/canonical/Unity/Session", "com.canonical.Unity")
{
}

void DBusUnitySessionService::Logout()
{
    // TODO ask the apps to quit and then emit the signal
    Q_EMIT LogoutReady();
}

void DBusUnitySessionService::EndSession()
{
    const QDBusMessage msg = QDBusMessage::createMethodCall("com.ubuntu.Upstart",
                                                            "/com/ubuntu/Upstart",
                                                            "com.ubuntu.Upstart0_6",
                                                            "EndSession");
    QDBusConnection::sessionBus().asyncCall(msg);
}

bool DBusUnitySessionService::CanHibernate() const
{
    return checkLogin1Call("CanHibernate");
}

bool DBusUnitySessionService::CanSuspend() const
{
    return checkLogin1Call("CanSuspend");
}

bool DBusUnitySessionService::CanHybridSleep() const
{
    return checkLogin1Call("CanHybridSleep");
}

bool DBusUnitySessionService::CanReboot() const
{
    return checkLogin1Call("CanReboot");
}

bool DBusUnitySessionService::CanShutdown() const
{
    return checkLogin1Call("CanPowerOff");
}

bool DBusUnitySessionService::CanLock() const
{
    return true; // FIXME
}

QString DBusUnitySessionService::UserName() const
{
    struct passwd *p = getpwuid(getuid());
    if (p) {
        return QString::fromUtf8(p->pw_name);
    }

    return QString();
}

QString DBusUnitySessionService::RealName() const
{
    struct passwd *p = getpwuid(getuid());
    if (p) {
        const QString gecos = QString::fromLocal8Bit(p->pw_gecos);
        if (!gecos.isEmpty()) {
            return gecos.split(QLatin1Char(',')).first();
        }
    }

    return QString();
}

QString DBusUnitySessionService::HostName() const
{
    char hostName[512];
    if (gethostname(hostName, sizeof(hostName)) == -1) {
        qWarning() << "Could not determine local hostname";
        return QString();
    }
    hostName[sizeof(hostName) - 1] = '\0';
    return QString::fromLocal8Bit(hostName);
}

void DBusUnitySessionService::PromptLock()
{
    Q_EMIT LockRequested();
}

void DBusUnitySessionService::Lock()
{
    const QString sessionId = QString::fromLocal8Bit(qgetenv("XDG_SESSION_PATH"));
    QDBusMessage msg = QDBusMessage::createMethodCall("org.freedesktop.DisplayManager",
                                                      sessionId,
                                                      "org.freedesktop.DisplayManager.Session",
                                                      "Lock");
    qDebug() << "Locking session" << msg.path();
    QDBusReply<void> reply = QDBusConnection::systemBus().asyncCall(msg);
    if (!reply.isValid()) {
        qWarning() << "Lock call failed" << reply.error().message();
    }
}

void DBusUnitySessionService::RequestLogout()
{
    Q_EMIT LogoutRequested(false);
}

void DBusUnitySessionService::Reboot()
{
    makeLogin1Call("Reboot", {false});
}

void DBusUnitySessionService::RequestReboot()
{
    Q_EMIT RebootRequested(false);
}

void DBusUnitySessionService::Shutdown()
{
    makeLogin1Call("PowerOff", {false});
}

void DBusUnitySessionService::Suspend()
{
    makeLogin1Call("Suspend", {false});
}

void DBusUnitySessionService::Hibernate()
{
    makeLogin1Call("Hibernate", {false});
}

void DBusUnitySessionService::HybridSleep()
{
    makeLogin1Call("HybridSleep", {false});
}

void DBusUnitySessionService::RequestShutdown()
{
    Q_EMIT ShutdownRequested(false);
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
