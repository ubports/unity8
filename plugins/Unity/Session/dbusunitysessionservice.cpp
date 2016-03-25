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
#include <QDBusUnixFileDescriptor>

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
    QDBusUnixFileDescriptor m_systemdInhibitFd;

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
                                                          QStringLiteral("GetSessionByPID"));
        msg << (quint32) getpid();

        QDBusReply<QDBusObjectPath> reply = QDBusConnection::systemBus().call(msg);
        if (reply.isValid()) {
            logindSessionPath = reply.value().path();

            // start watching the Active property
            QDBusConnection::systemBus().connect(LOGIN1_SERVICE, logindSessionPath, QStringLiteral("org.freedesktop.DBus.Properties"), QStringLiteral("PropertiesChanged"),
                                                 this, SLOT(onPropertiesChanged(QString,QVariantMap,QStringList)));

            setupSystemdInhibition();

            // re-enable the inhibition upon resume from sleep
            QDBusConnection::systemBus().connect(LOGIN1_SERVICE, LOGIN1_PATH, LOGIN1_IFACE, QStringLiteral("PrepareForSleep"),
                                                 this, SLOT(onResuming(bool)));
        } else {
            qWarning() << "Failed to get logind session path" << reply.error().message();
        }
    }

    void setupSystemdInhibition()
    {
        if (m_systemdInhibitFd.isValid())
            return;

        // inhibit systemd handling of power/sleep/hibernate buttons
        // http://www.freedesktop.org/wiki/Software/systemd/inhibit

        QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE, LOGIN1_PATH, LOGIN1_IFACE, QStringLiteral("Inhibit"));
        msg << "handle-power-key:handle-suspend-key:handle-hibernate-key"; // what
        msg << "Unity"; // who
        msg << "Unity8 handles power events"; // why
        msg << "block"; // mode

        QDBusPendingCall pendingCall = QDBusConnection::systemBus().asyncCall(msg);
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingCall, this);
        connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {
            QDBusPendingReply<QDBusUnixFileDescriptor> reply = *watcher;
            watcher->deleteLater();
            if (reply.isError()) {
                qWarning() << "Failed to inhibit systemd powersave handling" << reply.error().message();
                return;
            }

            m_systemdInhibitFd = reply.value();
        });
    }

    bool checkLogin1Call(const QString &method) const
    {
        QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE, LOGIN1_PATH, LOGIN1_IFACE, method);
        QDBusReply<QString> reply = QDBusConnection::systemBus().call(msg);
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

    void setActive(bool active)
    {
        isSessionActive = active;

        Q_EMIT screensaverActiveChanged(!isSessionActive);

        if (isSessionActive) {
            screensaverActiveTimer.invalidate();
            setIdleHint(false);
        } else {
            screensaverActiveTimer.start();
            setIdleHint(true);
        }
    }

    void checkActive()
    {
        if (logindSessionPath.isEmpty()) {
            qWarning() << "Invalid session path";
            return;
        }

        QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE,
                                                          logindSessionPath,
                                                          QStringLiteral("org.freedesktop.DBus.Properties"),
                                                          QStringLiteral("Get"));
        msg << LOGIN1_SESSION_IFACE;
        msg << ACTIVE_KEY;

        QDBusPendingCall pendingCall = QDBusConnection::systemBus().asyncCall(msg);
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingCall, this);
        connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

            QDBusPendingReply<QVariant> reply = *watcher;
            watcher->deleteLater();
            if (reply.isError()) {
                qWarning() << "Failed to get Active property" << reply.error().message();
                return;
            }

            setActive(reply.value().toBool());
        });
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
                                                          QStringLiteral("org.freedesktop.DBus.Properties"),
                                                          QStringLiteral("Get"));
        msg << LOGIN1_SESSION_IFACE;
        msg << IDLE_SINCE_KEY;

        QDBusReply<QVariant> reply = QDBusConnection::systemBus().call(msg);
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
                                                          QStringLiteral("SetIdleHint"));
        msg << idle;
        QDBusConnection::systemBus().asyncCall(msg);
    }

private Q_SLOTS:
    void onPropertiesChanged(const QString &iface, const QVariantMap &changedProps, const QStringList &invalidatedProps)
    {
        Q_UNUSED(iface)

        if (changedProps.contains(ACTIVE_KEY)) {
            setActive(changedProps.value(ACTIVE_KEY).toBool());
        } else if (invalidatedProps.contains(ACTIVE_KEY)) {
            checkActive();
        }
    }

    void onResuming(bool active)
    {
        if (!active) {
            setupSystemdInhibition();
        }
    }

Q_SIGNALS:
    void screensaverActiveChanged(bool active);
};

Q_GLOBAL_STATIC(DBusUnitySessionServicePrivate, d)

DBusUnitySessionService::DBusUnitySessionService()
    : UnityDBusObject(QStringLiteral("/com/canonical/Unity/Session"), QStringLiteral("com.canonical.Unity"))
{
    if (!d->logindSessionPath.isEmpty()) {
        // connect our Lock() slot to the logind's session Lock() signal
        QDBusConnection::systemBus().connect(LOGIN1_SERVICE, d->logindSessionPath, LOGIN1_SESSION_IFACE, QStringLiteral("Lock"), this, SLOT(Lock()));
        // ... and our Unlocked() signal to the logind's session Unlock() signal
        // (lightdm handles the unlocking by calling logind's Unlock method which in turn emits this signal we connect to)
        QDBusConnection::systemBus().connect(LOGIN1_SERVICE, d->logindSessionPath, LOGIN1_SESSION_IFACE, QStringLiteral("Unlock"), this, SIGNAL(Unlocked()));
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
    const QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("com.ubuntu.Upstart"),
                                                            QStringLiteral("/com/ubuntu/Upstart"),
                                                            QStringLiteral("com.ubuntu.Upstart0_6"),
                                                            QStringLiteral("EndSession"));
    QDBusConnection::sessionBus().asyncCall(msg);
}

bool DBusUnitySessionService::CanHibernate() const
{
    return d->checkLogin1Call(QStringLiteral("CanHibernate"));
}

bool DBusUnitySessionService::CanSuspend() const
{
    return d->checkLogin1Call(QStringLiteral("CanSuspend"));
}

bool DBusUnitySessionService::CanHybridSleep() const
{
    return d->checkLogin1Call(QStringLiteral("CanHybridSleep"));
}

bool DBusUnitySessionService::CanReboot() const
{
    return d->checkLogin1Call(QStringLiteral("CanReboot"));
}

bool DBusUnitySessionService::CanShutdown() const
{
    return d->checkLogin1Call(QStringLiteral("CanPowerOff"));
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
            const QStringList splitGecos = gecos.split(QLatin1Char(','));
            return splitGecos.first();
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
    // signal u8 to show the lockscreen/greeter
    PromptLock();

    // lock the session using the org.freedesktop.DisplayManager system DBUS service
    const QString sessionPath = QString::fromLocal8Bit(qgetenv("XDG_SESSION_PATH"));
    QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("org.freedesktop.DisplayManager"),
                                                      sessionPath,
                                                      QStringLiteral("org.freedesktop.DisplayManager.Session"),
                                                      QStringLiteral("Lock"));

    QDBusPendingCall pendingCall = QDBusConnection::systemBus().asyncCall(msg);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingCall, this);
    connect(watcher, &QDBusPendingCallWatcher::finished,
        this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<void> reply = *watcher;
        watcher->deleteLater();
        if (reply.isError()) {
            qWarning() << "Lock call failed" << reply.error().message();
            return;
        }

        // emit Locked when the call succeeds
        Q_EMIT Locked();
    });
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
    d->makeLogin1Call(QStringLiteral("Reboot"), {false});
}

void DBusUnitySessionService::RequestReboot()
{
    Q_EMIT RebootRequested(false);
    Q_EMIT rebootRequested(false);
}

void DBusUnitySessionService::Shutdown()
{
    d->makeLogin1Call(QStringLiteral("PowerOff"), {false});
}

void DBusUnitySessionService::Suspend()
{
    d->makeLogin1Call(QStringLiteral("Suspend"), {false});
}

void DBusUnitySessionService::Hibernate()
{
    d->makeLogin1Call(QStringLiteral("Hibernate"), {false});
}

void DBusUnitySessionService::HybridSleep()
{
    d->makeLogin1Call(QStringLiteral("HybridSleep"), {false});
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
    const QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("com.canonical.Unity"),
                                                            QStringLiteral("/com/canonical/Unity/Session"),
                                                            QStringLiteral("com.canonical.Unity.Session"),
                                                            method);
    QDBusConnection::sessionBus().asyncCall(msg);
}


DBusGnomeSessionManagerWrapper::DBusGnomeSessionManagerWrapper()
    : UnityDBusObject(QStringLiteral("/org/gnome/SessionManager/EndSessionDialog"), QStringLiteral("com.canonical.Unity"))
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
        performAsyncUnityCall(QStringLiteral("RequestLogout"));
        break;

    case Action::REBOOT:
        performAsyncUnityCall(QStringLiteral("RequestReboot"));
        break;

    case Action::SHUTDOWN:
        performAsyncUnityCall(QStringLiteral("RequestShutdown"));
        break;

    default:
        break;
    }
}


DBusGnomeScreensaverWrapper::DBusGnomeScreensaverWrapper()
    : UnityDBusObject(QStringLiteral("/org/gnome/ScreenSaver"), QStringLiteral("org.gnome.ScreenSaver"))
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
    performAsyncUnityCall(QStringLiteral("Lock"));
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
    : UnityDBusObject(QStringLiteral("/org/freedesktop/ScreenSaver"), QStringLiteral("org.freedesktop.ScreenSaver"))
{
    QDBusConnection::sessionBus().registerObject(QStringLiteral("/ScreenSaver"), this, QDBusConnection::ExportScriptableContents); // compat path, also register here
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
    performAsyncUnityCall(QStringLiteral("Lock"));
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
