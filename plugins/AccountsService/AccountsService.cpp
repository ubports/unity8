/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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

#include "AccountsService.h"
#include "AccountsServiceDBusAdaptor.h"

#include <QDBusInterface>
#include <QFile>
#include <QStringList>
#include <QDebug>

#include <glib.h>

#define IFACE_ACCOUNTS_USER          QStringLiteral("org.freedesktop.Accounts.User")
#define IFACE_LOCATION_HERE          QStringLiteral("com.ubuntu.location.providers.here.AccountsService")
#define IFACE_UBUNTU_INPUT           QStringLiteral("com.ubuntu.AccountsService.Input")
#define IFACE_UBUNTU_SECURITY        QStringLiteral("com.ubuntu.AccountsService.SecurityPrivacy")
#define IFACE_UBUNTU_SECURITY_OLD    QStringLiteral("com.ubuntu.touch.AccountsService.SecurityPrivacy")
#define IFACE_UNITY                  QStringLiteral("com.canonical.unity.AccountsService")
#define IFACE_UNITY_PRIVATE          QStringLiteral("com.canonical.unity.AccountsService.Private")

#define PROP_BACKGROUND_FILE                   QStringLiteral("BackgroundFile")
#define PROP_DEMO_EDGES                        QStringLiteral("demo-edges")
#define PROP_DEMO_EDGES_COMPLETED              QStringLiteral("DemoEdgesCompleted")
#define PROP_EMAIL                             QStringLiteral("Email")
#define PROP_ENABLE_FINGERPRINT_IDENTIFICATION QStringLiteral("EnableFingerprintIdentification")
#define PROP_ENABLE_INDICATORS_WHILE_LOCKED    QStringLiteral("EnableIndicatorsWhileLocked")
#define PROP_ENABLE_LAUNCHER_WHILE_LOCKED      QStringLiteral("EnableLauncherWhileLocked")
#define PROP_FAILED_FINGERPRINT_LOGINS         QStringLiteral("FailedFingerprintLogins")
#define PROP_FAILED_LOGINS                     QStringLiteral("FailedLogins")
#define PROP_INPUT_SOURCES                     QStringLiteral("InputSources")
#define PROP_LICENSE_ACCEPTED                  QStringLiteral("LicenseAccepted")
#define PROP_LICENSE_BASE_PATH                 QStringLiteral("LicenseBasePath")
#define PROP_MOUSE_CURSOR_SPEED                QStringLiteral("MouseCursorSpeed")
#define PROP_MOUSE_DOUBLE_CLICK_SPEED          QStringLiteral("MouseDoubleClickSpeed")
#define PROP_MOUSE_PRIMARY_BUTTON              QStringLiteral("MousePrimaryButton")
#define PROP_MOUSE_SCROLL_SPEED                QStringLiteral("MouseScrollSpeed")
#define PROP_PASSWORD_DISPLAY_HINT             QStringLiteral("PasswordDisplayHint")
#define PROP_REAL_NAME                         QStringLiteral("RealName")
#define PROP_STATS_WELCOME_SCREEN              QStringLiteral("StatsWelcomeScreen")
#define PROP_TOUCHPAD_CURSOR_SPEED             QStringLiteral("TouchpadCursorSpeed")
#define PROP_TOUCHPAD_DISABLE_WHILE_TYPING     QStringLiteral("TouchpadDisableWhileTyping")
#define PROP_TOUCHPAD_DISABLE_WITH_MOUSE       QStringLiteral("TouchpadDisableWithMouse")
#define PROP_TOUCHPAD_DOUBLE_CLICK_SPEED       QStringLiteral("TouchpadDoubleClickSpeed")
#define PROP_TOUCHPAD_PRIMARY_BUTTON           QStringLiteral("TouchpadPrimaryButton")
#define PROP_TOUCHPAD_SCROLL_SPEED             QStringLiteral("TouchpadScrollSpeed")
#define PROP_TOUCHPAD_TAP_TO_CLICK             QStringLiteral("TouchpadTapToClick")
#define PROP_TOUCHPAD_TWO_FINGER_SCROLL        QStringLiteral("TouchpadTwoFingerScroll")

using StringMap = QMap<QString,QString>;
using StringMapList = QList<StringMap>;
Q_DECLARE_METATYPE(StringMapList)


QVariant primaryButtonConverter(const QVariant &value)
{
    QString stringValue = value.toString();
    if (stringValue == "left") {
        return QVariant::fromValue(0);
    } else if (stringValue == "right") {
        return QVariant::fromValue(1); // Mir is less clear on this -- any non-zero value is the same
    } else {
        return QVariant::fromValue(0); // default to left
    }
}

AccountsService::AccountsService(QObject* parent, const QString &user)
    : QObject(parent)
    , m_service(new AccountsServiceDBusAdaptor(this))
{
    m_unityInput = new QDBusInterface(QStringLiteral("com.canonical.Unity.Input"),
                                      QStringLiteral("/com/canonical/Unity/Input"),
                                      QStringLiteral("com.canonical.Unity.Input"),
                                      QDBusConnection::SM_BUSNAME(), this);

    connect(m_service, &AccountsServiceDBusAdaptor::propertiesChanged, this, &AccountsService::onPropertiesChanged);
    connect(m_service, &AccountsServiceDBusAdaptor::maybeChanged, this, &AccountsService::onMaybeChanged);

    registerProperty(IFACE_ACCOUNTS_USER, PROP_BACKGROUND_FILE, QStringLiteral("backgroundFileChanged"));
    registerProperty(IFACE_ACCOUNTS_USER, PROP_EMAIL, QStringLiteral("emailChanged"));
    registerProperty(IFACE_ACCOUNTS_USER, PROP_REAL_NAME, QStringLiteral("realNameChanged"));
    registerProperty(IFACE_ACCOUNTS_USER, PROP_INPUT_SOURCES, QStringLiteral("keymapsChanged"));
    registerProperty(IFACE_LOCATION_HERE, PROP_LICENSE_ACCEPTED, QStringLiteral("hereEnabledChanged"));
    registerProperty(IFACE_LOCATION_HERE, PROP_LICENSE_BASE_PATH, QStringLiteral("hereLicensePathChanged"));
    registerProperty(IFACE_UBUNTU_SECURITY, PROP_ENABLE_FINGERPRINT_IDENTIFICATION, QStringLiteral("enableFingerprintIdentificationChanged"));
    registerProperty(IFACE_UBUNTU_SECURITY, PROP_ENABLE_LAUNCHER_WHILE_LOCKED, QStringLiteral("enableLauncherWhileLockedChanged"));
    registerProperty(IFACE_UBUNTU_SECURITY, PROP_ENABLE_INDICATORS_WHILE_LOCKED, QStringLiteral("enableIndicatorsWhileLockedChanged"));
    registerProperty(IFACE_UBUNTU_SECURITY, PROP_PASSWORD_DISPLAY_HINT, QStringLiteral("passwordDisplayHintChanged"));
    registerProperty(IFACE_UBUNTU_SECURITY_OLD, PROP_STATS_WELCOME_SCREEN, QStringLiteral("statsWelcomeScreenChanged"));
    registerProperty(IFACE_UNITY, PROP_DEMO_EDGES, QStringLiteral("demoEdgesChanged"));
    registerProperty(IFACE_UNITY, PROP_DEMO_EDGES_COMPLETED, QStringLiteral("demoEdgesCompletedChanged"));
    registerProperty(IFACE_UNITY_PRIVATE, PROP_FAILED_FINGERPRINT_LOGINS, QStringLiteral("failedFingerprintLoginsChanged"));
    registerProperty(IFACE_UNITY_PRIVATE, PROP_FAILED_LOGINS, QStringLiteral("failedLoginsChanged"));

    registerProxy(IFACE_UBUNTU_INPUT, PROP_MOUSE_CURSOR_SPEED,
                  m_unityInput, QStringLiteral("setMouseCursorSpeed"));
    registerProxy(IFACE_UBUNTU_INPUT, PROP_MOUSE_DOUBLE_CLICK_SPEED,
                  m_unityInput, QStringLiteral("setMouseDoubleClickSpeed"));
    registerProxy(IFACE_UBUNTU_INPUT, PROP_MOUSE_PRIMARY_BUTTON,
                  m_unityInput, QStringLiteral("setMousePrimaryButton"),
                  primaryButtonConverter);
    registerProxy(IFACE_UBUNTU_INPUT, PROP_MOUSE_SCROLL_SPEED,
                  m_unityInput, QStringLiteral("setMouseScrollSpeed"));
    registerProxy(IFACE_UBUNTU_INPUT, PROP_TOUCHPAD_CURSOR_SPEED,
                  m_unityInput, QStringLiteral("setTouchpadCursorSpeed"));
    registerProxy(IFACE_UBUNTU_INPUT, PROP_TOUCHPAD_SCROLL_SPEED,
                  m_unityInput, QStringLiteral("setTouchpadScrollSpeed"));
    registerProxy(IFACE_UBUNTU_INPUT, PROP_TOUCHPAD_DISABLE_WHILE_TYPING,
                  m_unityInput, QStringLiteral("setTouchpadDisableWhileTyping"));
    registerProxy(IFACE_UBUNTU_INPUT, PROP_TOUCHPAD_DISABLE_WITH_MOUSE,
                  m_unityInput, QStringLiteral("setTouchpadDisableWithMouse"));
    registerProxy(IFACE_UBUNTU_INPUT, PROP_TOUCHPAD_DOUBLE_CLICK_SPEED,
                  m_unityInput, QStringLiteral("setTouchpadDoubleClickSpeed"));
    registerProxy(IFACE_UBUNTU_INPUT, PROP_TOUCHPAD_PRIMARY_BUTTON,
                  m_unityInput, QStringLiteral("setTouchpadPrimaryButton"),
                  primaryButtonConverter);
    registerProxy(IFACE_UBUNTU_INPUT, PROP_TOUCHPAD_TAP_TO_CLICK,
                  m_unityInput, QStringLiteral("setTouchpadTapToClick"));
    registerProxy(IFACE_UBUNTU_INPUT, PROP_TOUCHPAD_TWO_FINGER_SCROLL,
                  m_unityInput, QStringLiteral("setTouchpadTwoFingerScroll"));

    setUser(!user.isEmpty() ? user : QString::fromUtf8(g_get_user_name()));
}

QString AccountsService::user() const
{
    return m_user;
}

void AccountsService::setUser(const QString &user)
{
    if (user.isEmpty() || m_user == user)
        return;

    bool wasEmpty = m_user.isEmpty();

    m_user = user;
    Q_EMIT userChanged();

    // Do the first update synchronously, as a cheap way to block rendering
    // until we have the right values on bootup.
    refresh(!wasEmpty);
}

bool AccountsService::demoEdges() const
{
    auto value = getProperty(IFACE_UNITY, PROP_DEMO_EDGES);
    return value.toBool();
}

void AccountsService::setDemoEdges(bool demoEdges)
{
    setProperty(IFACE_UNITY, PROP_DEMO_EDGES, demoEdges);
}

QStringList AccountsService::demoEdgesCompleted() const
{
    auto value = getProperty(IFACE_UNITY, PROP_DEMO_EDGES_COMPLETED);
    return value.toStringList();
}

void AccountsService::markDemoEdgeCompleted(const QString &edge)
{
    auto currentList = demoEdgesCompleted();
    if (!currentList.contains(edge)) {
        setProperty(IFACE_UNITY, PROP_DEMO_EDGES_COMPLETED, currentList << edge);
    }
}

bool AccountsService::enableFingerprintIdentification() const
{
    auto value = getProperty(IFACE_UBUNTU_SECURITY, PROP_ENABLE_FINGERPRINT_IDENTIFICATION);
    return value.toBool();
}

bool AccountsService::enableLauncherWhileLocked() const
{
    auto value = getProperty(IFACE_UBUNTU_SECURITY, PROP_ENABLE_LAUNCHER_WHILE_LOCKED);
    return value.toBool();
}

bool AccountsService::enableIndicatorsWhileLocked() const
{
    auto value = getProperty(IFACE_UBUNTU_SECURITY, PROP_ENABLE_INDICATORS_WHILE_LOCKED);
    return value.toBool();
}

QString AccountsService::backgroundFile() const
{
    auto value = getProperty(IFACE_ACCOUNTS_USER, PROP_BACKGROUND_FILE);
    return value.toString();
}

bool AccountsService::statsWelcomeScreen() const
{
    auto value = getProperty(IFACE_UBUNTU_SECURITY_OLD, PROP_STATS_WELCOME_SCREEN);
    return value.toBool();
}

AccountsService::PasswordDisplayHint AccountsService::passwordDisplayHint() const
{
    auto value = getProperty(IFACE_UBUNTU_SECURITY, PROP_PASSWORD_DISPLAY_HINT);
    return (PasswordDisplayHint)value.toInt();
}

bool AccountsService::hereEnabled() const
{
    auto value = getProperty(IFACE_LOCATION_HERE, PROP_LICENSE_ACCEPTED);
    return value.toBool();
}

void AccountsService::setHereEnabled(bool enabled)
{
    setProperty(IFACE_LOCATION_HERE, PROP_LICENSE_ACCEPTED, enabled);
}

QString AccountsService::hereLicensePath() const
{
    auto value = getProperty(IFACE_LOCATION_HERE, PROP_LICENSE_BASE_PATH);
    QString hereLicensePath = value.toString();
    if (hereLicensePath.isEmpty() || !QFile::exists(hereLicensePath))
        hereLicensePath = QStringLiteral("");
    return hereLicensePath;
}

bool AccountsService::hereLicensePathValid() const
{
    auto value = getProperty(IFACE_LOCATION_HERE, PROP_LICENSE_BASE_PATH);
    return !value.toString().isNull();
}

QString AccountsService::realName() const
{
    auto value = getProperty(IFACE_ACCOUNTS_USER, PROP_REAL_NAME);
    return value.toString();
}

void AccountsService::setRealName(const QString &realName)
{
    setProperty(IFACE_ACCOUNTS_USER, PROP_REAL_NAME, realName);
}

QString AccountsService::email() const
{
    auto value = getProperty(IFACE_ACCOUNTS_USER, PROP_EMAIL);
    return value.toString();
}

void AccountsService::setEmail(const QString &email)
{
    setProperty(IFACE_ACCOUNTS_USER, PROP_EMAIL, email);
}

QStringList AccountsService::keymaps() const
{
    auto value = getProperty(IFACE_ACCOUNTS_USER, PROP_INPUT_SOURCES);
    QDBusArgument arg = value.value<QDBusArgument>();
    StringMapList maps = qdbus_cast<StringMapList>(arg);
    QStringList simplifiedMaps;

    Q_FOREACH(const StringMap &map, maps) {
        Q_FOREACH(const QString &entry, map) {
            simplifiedMaps.append(entry);
        }
    }

    if (!simplifiedMaps.isEmpty()) {
        return simplifiedMaps;
    }

    return {QStringLiteral("us")};
}

uint AccountsService::failedFingerprintLogins() const
{
    return getProperty(IFACE_UNITY_PRIVATE, PROP_FAILED_FINGERPRINT_LOGINS).toUInt();
}

void AccountsService::setFailedFingerprintLogins(uint failedFingerprintLogins)
{
    setProperty(IFACE_UNITY_PRIVATE, PROP_FAILED_FINGERPRINT_LOGINS, failedFingerprintLogins);
}

uint AccountsService::failedLogins() const
{
    return getProperty(IFACE_UNITY_PRIVATE, PROP_FAILED_LOGINS).toUInt();
}

void AccountsService::setFailedLogins(uint failedLogins)
{
    setProperty(IFACE_UNITY_PRIVATE, PROP_FAILED_LOGINS, failedLogins);
}

// ====================================================
// Everything below this line is generic helper methods
// ====================================================

void AccountsService::emitChangedForProperty(const QString &interface, const QString &property)
{
    QString signalName = m_properties[interface][property].signal;
    QMetaObject::invokeMethod(this, signalName.toUtf8().data());
}

QVariant AccountsService::getProperty(const QString &interface, const QString &property) const
{
    return m_properties[interface][property].value;
}

void AccountsService::setProperty(const QString &interface, const QString &property, const QVariant &value)
{
    if (m_properties[interface][property].value != value) {
        m_properties[interface][property].value = value;
        m_service->setUserPropertyAsync(m_user, interface, property, value);
        emitChangedForProperty(interface, property);
    }
}

void AccountsService::updateCache(const QString &interface, const QString &property, const QVariant &value)
{
    PropertyInfo &info = m_properties[interface][property];

    if (info.proxyInterface) {
        QVariant finalValue;
        if (info.proxyConverter) {
            finalValue = info.proxyConverter(value);
        } else {
            finalValue = value;
        }
        info.proxyInterface->asyncCall(info.proxyMethod, finalValue);
        return; // don't bother saving a copy
    }

    if (info.value != value) {
        info.value = value;
        emitChangedForProperty(interface, property);
    }
}

void AccountsService::updateProperty(const QString &interface, const QString &property)
{
    QDBusPendingCall pendingReply = m_service->getUserPropertyAsync(m_user,
                                                                    interface,
                                                                    property);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this, interface, property](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QVariant> reply = *watcher;
        watcher->deleteLater();
        if (reply.isError()) {
            qWarning() << "Failed to get '" << property << "' property:" << reply.error().message();
            return;
        }

        updateCache(interface, property, reply.value());
    });
}

void AccountsService::updateAllProperties(const QString &interface, bool async)
{
    QDBusPendingCall pendingReply = m_service->getAllPropertiesAsync(m_user,
                                                                     interface);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this, interface](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply< QHash<QString, QVariant> > reply = *watcher;
        watcher->deleteLater();
        if (reply.isError()) {
            qWarning() << "Failed to get all properties for" << interface << ":" << reply.error().message();
            return;
        }

        auto valueHash = reply.value();
        auto i = valueHash.constBegin();
        while (i != valueHash.constEnd()) {
            updateCache(interface, i.key(), i.value());
            ++i;
        }
    });
    if (!async) {
        watcher->waitForFinished();
    }
}

void AccountsService::registerProxy(const QString &interface, const QString &property, QDBusInterface *iface, const QString &method, ProxyConverter converter)
{
    registerProperty(interface, property, nullptr);

    m_properties[interface][property].proxyInterface = iface;
    m_properties[interface][property].proxyMethod = method;
    m_properties[interface][property].proxyConverter = converter;
}

void AccountsService::registerProperty(const QString &interface, const QString &property, const QString &signal)
{
    m_properties[interface][property] = PropertyInfo();
    m_properties[interface][property].signal = signal;
}

void AccountsService::onPropertiesChanged(const QString &user, const QString &interface, const QStringList &changed)
{
    if (m_user != user) {
        return;
    }

    auto propHash = m_properties.value(interface);
    auto i = propHash.constBegin();
    while (i != propHash.constEnd()) {
        if (changed.contains(i.key())) {
            updateProperty(interface, i.key());
        }
        ++i;
    }
}

void AccountsService::onMaybeChanged(const QString &user)
{
    if (m_user != user) {
        return;
    }

    // Any of the standard properties might have changed!
    auto propHash = m_properties.value(IFACE_ACCOUNTS_USER);
    auto i = propHash.constBegin();
    while (i != propHash.constEnd()) {
        updateProperty(IFACE_ACCOUNTS_USER, i.key());
        ++i;
    }
}

void AccountsService::refresh(bool async)
{
    auto i = m_properties.constBegin();
    while (i != m_properties.constEnd()) {
        updateAllProperties(i.key(), async);
        ++i;
    }
}
