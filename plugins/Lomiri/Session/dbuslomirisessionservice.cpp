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
#include "dbuslomirisessionservice.h"

// system
#include <grp.h>
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

// Glib
#include <glib.h>

#define LOGIN1_SERVICE QStringLiteral("org.freedesktop.login1")
#define LOGIN1_PATH QStringLiteral("/org/freedesktop/login1")
#define LOGIN1_IFACE QStringLiteral("org.freedesktop.login1.Manager")
#define LOGIN1_SESSION_IFACE QStringLiteral("org.freedesktop.login1.Session")

#define ACTIVE_KEY QStringLiteral("Active")
#define IDLE_SINCE_KEY QStringLiteral("IdleSinceHint")

// TODO: migrate defines to constant variables in the future.
static const QString LOGIN1_USER_SELF_PATH =
        QStringLiteral("/org/freedesktop/login1/user/self");
static const QString LOGIN1_USER_IFACE =
        QStringLiteral("org.freedesktop.login1.User");
static const QString DBUS_PROPERTIES_IFACE =
        QStringLiteral("org.freedesktop.DBus.Properties");

static const QString DISPLAY_KEY = QStringLiteral("Display");

class DBusLomiriSessionServicePrivate: public QObject
{
    Q_OBJECT
public:
    QString logindSessionPath;
    bool isSessionActive = true;
    QElapsedTimer screensaverActiveTimer;
    QDBusUnixFileDescriptor m_systemdInhibitFd;

    DBusLomiriSessionServicePrivate(): QObject() {
        init();
        checkActive();
    }

    QString determineLogindSessionPath() {
        // Simple case: environment variable.
        auto sessionEnv = qgetenv("XDG_SESSION_ID");
        if (!sessionEnv.isEmpty()) {
            QDBusMessage msg = QDBusMessage::createMethodCall(
                                LOGIN1_SERVICE,
                                LOGIN1_PATH,
                                LOGIN1_IFACE,
                                QStringLiteral("GetSession"));
            // Can't use QByteArray as-is; QDbus will interpret it as 'ay'
            msg << QString::fromLocal8Bit(sessionEnv);
            QDBusReply<QDBusObjectPath> reply = QDBusConnection::SM_BUSNAME().call(msg);

            if (reply.isValid()) {
                return reply.value().path();
            } else {
                qWarning() << "Failed to get logind session path for"
                           << sessionEnv << ":"
                           << reply.error().message();
            }
        }

        // We're not under the session. If we're running as a systemd user unit,
        // use the user's Display session, which is what gnome-shell does.
        // Care must be taken to check if this is actually the case, otherwise
        // any invocation of Lomiri will become session-like.

        if (qEnvironmentVariableIsSet("LOMIRI_AS_SYSTEMD_UNIT")) {
            QDBusMessage msg = QDBusMessage::createMethodCall(
                                LOGIN1_SERVICE,
                                LOGIN1_USER_SELF_PATH,
                                DBUS_PROPERTIES_IFACE,
                                QStringLiteral("Get"));
            msg << LOGIN1_USER_IFACE;
            msg << DISPLAY_KEY;

            // org.freedesktop.DBus.Properties.Get returns DBus variant.
            QDBusReply<QDBusVariant> reply = QDBusConnection::SM_BUSNAME().call(msg);

            if (reply.isValid()) {
                // We're the only callsite, so it's not worth writing full
                // C++ struct (un-)marshaling. Let's just un-marshall here.
                QString sessionName;
                QDBusObjectPath sessionPath;

                QVariant variant = reply.value().variant();
                const QDBusArgument arg = variant.value<QDBusArgument>();

                arg.beginStructure();
                arg >> sessionName >> sessionPath;
                arg.endStructure();

                return sessionPath.path();
            } else {
                qWarning() << "Failed to get user's Display session:"
                           << reply.error().message();
            }
        }

        // Can't find anything, return empty QString.
        return QString();
    }

    void init()
    {
        // get our logind session path
        logindSessionPath = determineLogindSessionPath();

        if (!logindSessionPath.isEmpty()) {
            // start watching the Active property
            QDBusConnection::SM_BUSNAME().connect(LOGIN1_SERVICE, logindSessionPath, QStringLiteral("org.freedesktop.DBus.Properties"), QStringLiteral("PropertiesChanged"),
                                                  this, SLOT(onPropertiesChanged(QString,QVariantMap,QStringList)));

            setupSystemdInhibition();

            // re-enable the inhibition upon resume from sleep
            QDBusConnection::SM_BUSNAME().connect(LOGIN1_SERVICE, LOGIN1_PATH, LOGIN1_IFACE, QStringLiteral("PrepareForSleep"),
                                                  this, SLOT(onResuming(bool)));
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
        msg << "Lomiri"; // who
        msg << "Lomiri handles power events"; // why
        msg << "block"; // mode

        QDBusPendingCall pendingCall = QDBusConnection::SM_BUSNAME().asyncCall(msg);
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
        QDBusReply<QString> reply = QDBusConnection::SM_BUSNAME().call(msg);
        return reply.isValid() && (reply == QStringLiteral("yes") || reply == QStringLiteral("challenge"));
    }

    void makeLogin1Call(const QString &method, const QVariantList &args)
    {
        QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE,
                                                          LOGIN1_PATH,
                                                          LOGIN1_IFACE,
                                                          method);
        msg.setArguments(args);
        QDBusConnection::SM_BUSNAME().asyncCall(msg);
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

        QDBusPendingCall pendingCall = QDBusConnection::SM_BUSNAME().asyncCall(msg);
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

        QDBusReply<QVariant> reply = QDBusConnection::SM_BUSNAME().call(msg);
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
        QDBusConnection::SM_BUSNAME().asyncCall(msg);
    }

    bool isUserInGroup(const QString &user, const QString &groupName) const
    {
        auto group = getgrnam(groupName.toUtf8().data());

        if (group && group->gr_mem)
        {
            for (int i = 0; group->gr_mem[i]; ++i)
            {
                if (g_strcmp0(group->gr_mem[i], user.toUtf8().data()) == 0) {
                    return true;
                }
            }
        }

        return false;
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
        } else {
            Q_EMIT prepareForSleep();
        }
    }

Q_SIGNALS:
    void screensaverActiveChanged(bool active);
    void prepareForSleep();
};

Q_GLOBAL_STATIC(DBusLomiriSessionServicePrivate, d)

DBusLomiriSessionService::DBusLomiriSessionService()
    : LomiriDBusObject(QStringLiteral("/com/lomiri/Shell/Session"), QStringLiteral("com.lomiri.Shell"))
{
    if (!d->logindSessionPath.isEmpty()) {
        // connect our PromptLock() slot to the logind's session Lock() signal
        QDBusConnection::SM_BUSNAME().connect(LOGIN1_SERVICE, d->logindSessionPath, LOGIN1_SESSION_IFACE, QStringLiteral("Lock"), this, SLOT(PromptLock()));
        // ... and our Unlocked() signal to the logind's session Unlock() signal
        // (lightdm handles the unlocking by calling logind's Unlock method which in turn emits this signal we connect to)
        QDBusConnection::SM_BUSNAME().connect(LOGIN1_SERVICE, d->logindSessionPath, LOGIN1_SESSION_IFACE, QStringLiteral("Unlock"), this, SLOT(doUnlock()));
        connect(d, &DBusLomiriSessionServicePrivate::prepareForSleep, this, &DBusLomiriSessionService::PromptLock);
    } else {
        qWarning() << "Failed to connect to logind's session Lock/Unlock signals";
    }
}

void DBusLomiriSessionService::Logout()
{
    // TODO ask the apps to quit and then emit the signal
    Q_EMIT LogoutReady();
    Q_EMIT logoutReady();
}

void DBusLomiriSessionService::EndSession()
{
    const QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("com.lomiri.Upstart"),
                                                            QStringLiteral("/com/lomiri/Upstart"),
                                                            QStringLiteral("com.lomiri.Upstart0_6"),
                                                            QStringLiteral("EndSession"));
    QDBusConnection::sessionBus().asyncCall(msg);
}

bool DBusLomiriSessionService::CanHibernate() const
{
    return d->checkLogin1Call(QStringLiteral("CanHibernate"));
}

bool DBusLomiriSessionService::CanSuspend() const
{
    return d->checkLogin1Call(QStringLiteral("CanSuspend"));
}

bool DBusLomiriSessionService::CanHybridSleep() const
{
    return d->checkLogin1Call(QStringLiteral("CanHybridSleep"));
}

bool DBusLomiriSessionService::CanReboot() const
{
    return d->checkLogin1Call(QStringLiteral("CanReboot"));
}

bool DBusLomiriSessionService::CanShutdown() const
{
    return d->checkLogin1Call(QStringLiteral("CanPowerOff"));
}

bool DBusLomiriSessionService::CanLock() const
{
    auto user = UserName();
    if (user.startsWith(QStringLiteral("guest-")) ||
        d->isUserInGroup(user, QStringLiteral("nopasswdlogin"))) {
        return false;
    } else {
        return true;
    }
}

QString DBusLomiriSessionService::UserName() const
{
    return QString::fromUtf8(g_get_user_name());
}

QString DBusLomiriSessionService::RealName() const
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

QString DBusLomiriSessionService::HostName() const
{
    char hostName[512];
    if (gethostname(hostName, sizeof(hostName)) == -1) {
        qWarning() << "Could not determine local hostname";
        return QString();
    }
    hostName[sizeof(hostName) - 1] = '\0';
    return QString::fromLocal8Bit(hostName);
}

void DBusLomiriSessionService::PromptLock()
{
    // Prompt as in quick.  No locking animation needed.  Usually used by
    // indicator-session in combination with a switch to greeter or other
    // user session.
    if (CanLock()) {
        Q_EMIT LockRequested();
        Q_EMIT lockRequested();
    }
}

void DBusLomiriSessionService::Lock()
{
    // Normal lock (with animation, as compared to PromptLock above).  Usually
    // used by indicator-session to lock the session in place.
    //
    // FIXME: We also -- as a bit of a hack around indicator-session not fully
    // supporting a phone profile -- switch to greeter here.  The lomiri7 flow is
    // that the user chooses "Lock/Switch" from the indicator, and then can go
    // to greeter by selecting "Switch" again from the indicator, which is now
    // exposed by the desktop_lockscreen profile.  But since in lomiri, we try
    // to expose most things all the time, we don't use the separate lockscreen
    // profile.  Instead, we just go directly to the greeter the first time
    // a user presses "Lock/Switch".  This isn't what this DBus call is
    // supposed to do, but we can live with it for now.
    //
    // Here's a bug about indicator-session growing a converged Touch profile:
    // https://launchpad.net/bugs/1557716
    //
    // We only do this here in the animated-lock call because that's the only
    // time the indicator locks without also asking the display manager to
    // switch sessions on us.  And since we are switching screens, we also
    // don't bother respecting the animate request, simply doing a PromptLock.
    PromptLock();
    switchToGreeter();
}

void DBusLomiriSessionService::switchToGreeter()
{
    // lock the session using the org.freedesktop.DisplayManager system DBUS service
    const QString sessionPath = QString::fromLocal8Bit(qgetenv("XDG_SESSION_PATH"));
    QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("org.freedesktop.DisplayManager"),
                                                      sessionPath,
                                                      QStringLiteral("org.freedesktop.DisplayManager.Session"),
                                                      QStringLiteral("Lock"));

    QDBusPendingCall pendingCall = QDBusConnection::SM_BUSNAME().asyncCall(msg);
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

void DBusLomiriSessionService::doUnlock()
{
    Q_EMIT Unlocked();
    Q_EMIT unlocked();
}

bool DBusLomiriSessionService::IsLocked() const
{
    return !d->isSessionActive;
}

void DBusLomiriSessionService::RequestLogout()
{
    Q_EMIT LogoutRequested(false);
    Q_EMIT logoutRequested(false);
}

void DBusLomiriSessionService::Reboot()
{
    d->makeLogin1Call(QStringLiteral("Reboot"), {false});
}

void DBusLomiriSessionService::RequestReboot()
{
    Q_EMIT RebootRequested(false);
    Q_EMIT rebootRequested(false);
}

void DBusLomiriSessionService::Shutdown()
{
    d->makeLogin1Call(QStringLiteral("PowerOff"), {false});
}

void DBusLomiriSessionService::Suspend()
{
    PromptLock();
    d->makeLogin1Call(QStringLiteral("Suspend"), {false});
}

void DBusLomiriSessionService::Hibernate()
{
    PromptLock();
    d->makeLogin1Call(QStringLiteral("Hibernate"), {false});
}

void DBusLomiriSessionService::HybridSleep()
{
    PromptLock();
    d->makeLogin1Call(QStringLiteral("HybridSleep"), {false});
}

void DBusLomiriSessionService::RequestShutdown()
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


void performAsyncLomiriCall(const QString &method)
{
    const QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("com.lomiri.Shell"),
                                                            QStringLiteral("/com/lomiri/Shell/Session"),
                                                            QStringLiteral("com.lomiri.Shell.Session"),
                                                            method);
    QDBusConnection::sessionBus().asyncCall(msg);
}


DBusGnomeSessionManagerWrapper::DBusGnomeSessionManagerWrapper()
    : LomiriDBusObject(QStringLiteral("/org/gnome/SessionManager"), QStringLiteral("org.gnome.SessionManager"))
{
}

void DBusGnomeSessionManagerWrapper::Logout(quint32 mode)
{
    auto call = QStringLiteral("RequestLogout");

    // These modes are documented as bitwise flags, not an enum, even though
    // they only ever seem to be used as enums.

    if (mode & 1) // without dialog
        call = QStringLiteral("Logout");
    if (mode & 2) // without dialog, ignoring inhibitors (which we don't have)
        call = QStringLiteral("Logout");

    performAsyncLomiriCall(call);
}

void DBusGnomeSessionManagerWrapper::Reboot()
{
    // GNOME's Reboot means with dialog (they use Request differently than us).
    performAsyncLomiriCall(QStringLiteral("RequestReboot"));
}

void DBusGnomeSessionManagerWrapper::RequestReboot()
{
    // GNOME's RequestReboot means no dialog (they use Request differently than us).
    performAsyncLomiriCall(QStringLiteral("Reboot"));
}

void DBusGnomeSessionManagerWrapper::RequestShutdown()
{
    // GNOME's RequestShutdown means no dialog (they use Request differently than us).
    performAsyncLomiriCall(QStringLiteral("Shutdown"));
}

void DBusGnomeSessionManagerWrapper::Shutdown()
{
    // GNOME's Shutdown means with dialog (they use Request differently than us).
    performAsyncLomiriCall(QStringLiteral("RequestShutdown"));
}


DBusGnomeSessionManagerDialogWrapper::DBusGnomeSessionManagerDialogWrapper()
    : LomiriDBusObject(QStringLiteral("/org/gnome/SessionManager/EndSessionDialog"), QStringLiteral("com.lomiri.Shell"))
{
}

void DBusGnomeSessionManagerDialogWrapper::Open(const unsigned type, const unsigned arg_1, const unsigned max_wait, const QList<QDBusObjectPath> &inhibitors)
{
    Q_UNUSED(arg_1);
    Q_UNUSED(max_wait);
    Q_UNUSED(inhibitors);

    switch (static_cast<Action>(type))
    {
    case Action::LOGOUT:
        performAsyncLomiriCall(QStringLiteral("RequestLogout"));
        break;

    case Action::REBOOT:
        performAsyncLomiriCall(QStringLiteral("RequestReboot"));
        break;

    case Action::SHUTDOWN:
        performAsyncLomiriCall(QStringLiteral("RequestShutdown"));
        break;

    default:
        break;
    }
}


DBusGnomeScreensaverWrapper::DBusGnomeScreensaverWrapper()
    : LomiriDBusObject(QStringLiteral("/org/gnome/ScreenSaver"), QStringLiteral("org.gnome.ScreenSaver"))
{
    connect(d, &DBusLomiriSessionServicePrivate::screensaverActiveChanged, this, &DBusGnomeScreensaverWrapper::ActiveChanged);
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
    performAsyncLomiriCall(QStringLiteral("PromptLock"));
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
    : LomiriDBusObject(QStringLiteral("/org/freedesktop/ScreenSaver"), QStringLiteral("org.freedesktop.ScreenSaver"))
{
    QDBusConnection::sessionBus().registerObject(QStringLiteral("/ScreenSaver"), this, QDBusConnection::ExportScriptableContents); // compat path, also register here
    connect(d, &DBusLomiriSessionServicePrivate::screensaverActiveChanged, this, &DBusScreensaverWrapper::ActiveChanged);
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
    performAsyncLomiriCall(QStringLiteral("PromptLock"));
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

#include "dbuslomirisessionservice.moc"
