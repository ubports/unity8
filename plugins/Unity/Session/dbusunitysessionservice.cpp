/*
 * Copyright (C) 2014, 2015 Canonical, Ltd.
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
#include <QElapsedTimer>
#include <QDateTime>

#define LOGIN1_SERVICE QStringLiteral("org.freedesktop.login1")
#define LOGIN1_PATH QStringLiteral("/org/freedesktop/login1")
#define LOGIN1_IFACE QStringLiteral("org.freedesktop.login1.Manager")
#define LOGIN1_SESSION_IFACE QStringLiteral("org.freedesktop.login1.Session")

#define ACTIVE_KEY QStringLiteral("Active")
#define IDLE_SINCE_KEY QStringLiteral("IdleSinceHint")

class DBusUnitySessionServicePrivate: public QObject
{
    Q_OBJECT
public:
    QString logindSessionPath;
    bool isSessionActive = true;
    QElapsedTimer screensaverActiveTimer;

    DBusUnitySessionServicePrivate(): QObject() {
        init();
        checkActive();
    }

    void init()
    {
        // get our logind session path
        QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE,
                                                          LOGIN1_PATH,
                                                          LOGIN1_IFACE,
                                                          "GetSessionByPID");
        msg << (quint32) getpid();

        QDBusReply<QDBusObjectPath> reply = QDBusConnection::systemBus().asyncCall(msg);
        if (reply.isValid()) {
            logindSessionPath = reply.value().path();

            // start watching the Active property
            QDBusConnection::systemBus().connect(LOGIN1_SERVICE, logindSessionPath, "org.freedesktop.DBus.Properties", "PropertiesChanged",
                                                 this, SLOT(onPropertiesChanged(QString,QVariantMap,QStringList)));
        } else {
            qWarning() << "Failed to get logind session path" << reply.error().message();
        }
    }

    bool checkLogin1Call(const QString &method) const
    {
        QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE, LOGIN1_PATH, LOGIN1_IFACE, method);
        QDBusReply<QString> reply = QDBusConnection::systemBus().asyncCall(msg);
        return reply.isValid() && (reply == QStringLiteral("yes") || reply == QStringLiteral("challenge"));
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

    void checkActive()
    {
        if (logindSessionPath.isEmpty()) {
            qWarning() << "Invalid session path";
            return;
        }

        QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE,
                                                          logindSessionPath,
                                                          "org.freedesktop.DBus.Properties",
                                                          "Get");
        msg << LOGIN1_SESSION_IFACE;
        msg << ACTIVE_KEY;

        QDBusReply<QVariant> reply = QDBusConnection::systemBus().asyncCall(msg);
        if (reply.isValid()) {
            isSessionActive = reply.value().toBool();
            qDebug() << "Session" << logindSessionPath << "is active:" << isSessionActive;
        } else {
            qWarning() << "Failed to get Active property" << reply.error().message();
        }
    }

    quint32 screensaverActiveTime() const
    {
        if (!isSessionActive && screensaverActiveTimer.isValid()) {
            return screensaverActiveTimer.elapsed() / 1000;
        }

        return 0;
    }

    quint64 idleSinceUSecTimestamp() const
    {
        QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE,
                                                          logindSessionPath,
                                                          "org.freedesktop.DBus.Properties",
                                                          "Get");
        msg << LOGIN1_SESSION_IFACE;
        msg << IDLE_SINCE_KEY;

        QDBusReply<QVariant> reply = QDBusConnection::systemBus().asyncCall(msg);
        if (reply.isValid()) {
            return reply.value().value<quint64>();
        } else {
            qWarning() << "Failed to get IdleSinceHint property" << reply.error().message();
        }

        return 0;
    }

    void setIdleHint(bool idle)
    {
        QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE,
                                                          logindSessionPath,
                                                          LOGIN1_SESSION_IFACE,
                                                          "SetIdleHint");
        msg << idle;
        QDBusConnection::systemBus().asyncCall(msg);
    }

private Q_SLOTS:
    void onPropertiesChanged(const QString &iface, const QVariantMap &changedProps, const QStringList &invalidatedProps)
    {
        Q_UNUSED(iface)

        if (changedProps.contains(ACTIVE_KEY) || invalidatedProps.contains(ACTIVE_KEY)) {
            if (changedProps.value(ACTIVE_KEY).isValid()) {
                isSessionActive = changedProps.value(ACTIVE_KEY).toBool();
            } else {
                checkActive();
            }

            Q_EMIT screensaverActiveChanged(!isSessionActive);

            if (isSessionActive) {
                screensaverActiveTimer.invalidate();
                setIdleHint(false);
            } else {
                screensaverActiveTimer.start();
                setIdleHint(true);
            }
        }
    }

Q_SIGNALS:
    void screensaverActiveChanged(bool active);
};

Q_GLOBAL_STATIC(DBusUnitySessionServicePrivate, d)

DBusUnitySessionService::DBusUnitySessionService()
    : UnityDBusObject("/com/canonical/Unity/Session", "com.canonical.Unity")
{
    if (!d->logindSessionPath.isEmpty()) {
        // connect our Lock() slot to the logind's session Lock() signal
        QDBusConnection::systemBus().connect(LOGIN1_SERVICE, d->logindSessionPath, LOGIN1_SESSION_IFACE, "Lock", this, SLOT(Lock()));
        // ... and our Unlocked() signal to the logind's session Unlock() signal
        // (lightdm handles the unlocking by calling logind's Unlock method which in turn emits this signal we connect to)
        QDBusConnection::systemBus().connect(LOGIN1_SERVICE, d->logindSessionPath, LOGIN1_SESSION_IFACE, "Unlock", this, SIGNAL(Unlocked()));
    } else {
        qWarning() << "Failed to connect to logind's session Lock/Unlock signals";
    }
}

void DBusUnitySessionService::Logout()
{
    // TODO ask the apps to quit and then emit the signal
    Q_EMIT LogoutReady();
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

bool DBusUnitySessionService::CanHibernate() const
{
    return d->checkLogin1Call("CanHibernate");
}

bool DBusUnitySessionService::CanSuspend() const
{
    return d->checkLogin1Call("CanSuspend");
}

bool DBusUnitySessionService::CanHybridSleep() const
{
    return d->checkLogin1Call("CanHybridSleep");
}

bool DBusUnitySessionService::CanReboot() const
{
    return d->checkLogin1Call("CanReboot");
}

bool DBusUnitySessionService::CanShutdown() const
{
    return d->checkLogin1Call("CanPowerOff");
}

bool DBusUnitySessionService::CanLock() const
{
    return true; // FIXME
}

QString DBusUnitySessionService::UserName() const
{
    struct passwd *p = getpwuid(geteuid());
    if (p) {
        return QString::fromUtf8(p->pw_name);
    }

    return QString();
}

QString DBusUnitySessionService::RealName() const
{
    struct passwd *p = getpwuid(geteuid());
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
    Q_EMIT lockRequested();
}

void DBusUnitySessionService::Lock()
{
    // lock the session using the org.freedesktop.DisplayManager system DBUS service
    const QString sessionPath = QString::fromLocal8Bit(qgetenv("XDG_SESSION_PATH"));
    QDBusMessage msg = QDBusMessage::createMethodCall("org.freedesktop.DisplayManager",
                                                      sessionPath,
                                                      "org.freedesktop.DisplayManager.Session",
                                                      "Lock");
    qDebug() << "Locking session" << msg.path();
    QDBusReply<void> reply = QDBusConnection::systemBus().asyncCall(msg);
    if (!reply.isValid()) {
        qWarning() << "Lock call failed" << reply.error().message();
    } else {
        // emit Locked when the call succeeds
        Q_EMIT Locked();
    }
}

bool DBusUnitySessionService::IsLocked() const
{
    return !d->isSessionActive;
}

void DBusUnitySessionService::RequestLogout()
{
    Q_EMIT LogoutRequested(false);
    Q_EMIT logoutRequested(false);
}

void DBusUnitySessionService::Reboot()
{
    d->makeLogin1Call("Reboot", {false});
}

void DBusUnitySessionService::RequestReboot()
{
    Q_EMIT RebootRequested(false);
    Q_EMIT rebootRequested(false);
}

void DBusUnitySessionService::Shutdown()
{
    d->makeLogin1Call("PowerOff", {false});
}

void DBusUnitySessionService::Suspend()
{
    d->makeLogin1Call("Suspend", {false});
}

void DBusUnitySessionService::Hibernate()
{
    d->makeLogin1Call("Hibernate", {false});
}

void DBusUnitySessionService::HybridSleep()
{
    d->makeLogin1Call("HybridSleep", {false});
}

void DBusUnitySessionService::RequestShutdown()
{
    Q_EMIT ShutdownRequested(false);
    Q_EMIT shutdownRequested(false);
}

enum class Action : unsigned
{
    LOGOUT = 0,
    SHUTDOWN,
    REBOOT,
    NONE
};


void performAsyncUnityCall(const QString &method)
{
    const QDBusMessage msg = QDBusMessage::createMethodCall("com.canonical.Unity",
                                                            "/com/canonical/Unity/Session",
                                                            "com.canonical.Unity.Session",
                                                            method);
    QDBusConnection::sessionBus().asyncCall(msg);
}


DBusGnomeSessionManagerWrapper::DBusGnomeSessionManagerWrapper()
    : UnityDBusObject("/org/gnome/SessionManager/EndSessionDialog", "com.canonical.Unity")
{
}

void DBusGnomeSessionManagerWrapper::Open(const unsigned type, const unsigned arg_1, const unsigned max_wait, const QList<QDBusObjectPath> &inhibitors)
{
    Q_UNUSED(arg_1);
    Q_UNUSED(max_wait);
    Q_UNUSED(inhibitors);

    switch (static_cast<Action>(type))
    {
    case Action::LOGOUT:
        performAsyncUnityCall("RequestLogout");
        break;

    case Action::REBOOT:
        performAsyncUnityCall("RequestReboot");
        break;

    case Action::SHUTDOWN:
        performAsyncUnityCall("RequestShutdown");
        break;

    default:
        break;
    }
}


DBusGnomeScreensaverWrapper::DBusGnomeScreensaverWrapper()
    : UnityDBusObject("/org/gnome/ScreenSaver", "org.gnome.ScreenSaver")
{
    connect(d, &DBusUnitySessionServicePrivate::screensaverActiveChanged, this, &DBusGnomeScreensaverWrapper::ActiveChanged);
}

bool DBusGnomeScreensaverWrapper::GetActive() const
{
    return !d->isSessionActive; // return whether the session is not active
}

void DBusGnomeScreensaverWrapper::SetActive(bool lock)
{
    if (lock) {
        Lock();
    }
}

void DBusGnomeScreensaverWrapper::Lock()
{
    performAsyncUnityCall("Lock");
}

quint32 DBusGnomeScreensaverWrapper::GetActiveTime() const
{
    return d->screensaverActiveTime();
}

void DBusGnomeScreensaverWrapper::SimulateUserActivity()
{
    d->setIdleHint(false);
}


DBusScreensaverWrapper::DBusScreensaverWrapper()
    : UnityDBusObject("/org/freedesktop/ScreenSaver", "org.freedesktop.ScreenSaver")
{
    QDBusConnection::sessionBus().registerObject("/ScreenSaver", this, QDBusConnection::ExportScriptableContents); // compat path, also register here
    connect(d, &DBusUnitySessionServicePrivate::screensaverActiveChanged, this, &DBusScreensaverWrapper::ActiveChanged);
}

bool DBusScreensaverWrapper::GetActive() const
{
    return !d->isSessionActive; // return whether the session is not active
}

bool DBusScreensaverWrapper::SetActive(bool lock)
{
    if (lock) {
        Lock();
        return true;
    }
    return false;
}

void DBusScreensaverWrapper::Lock()
{
    performAsyncUnityCall("Lock");
}

quint32 DBusScreensaverWrapper::GetActiveTime() const
{
    return d->screensaverActiveTime();
}

quint32 DBusScreensaverWrapper::GetSessionIdleTime() const
{
    return QDateTime::fromMSecsSinceEpoch(d->idleSinceUSecTimestamp()/1000).secsTo(QDateTime::currentDateTime());
}

void DBusScreensaverWrapper::SimulateUserActivity()
{
    d->setIdleHint(false);
}

#include "dbusunitysessionservice.moc"
