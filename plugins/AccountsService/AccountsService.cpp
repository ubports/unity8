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

#include "AccountsService.h"
#include "AccountsServiceDBusAdaptor.h"

#include <QFile>
#include <QStringList>
#include <QDebug>

AccountsService::AccountsService(QObject* parent)
  : QObject(parent),
    m_service(new AccountsServiceDBusAdaptor(this)),
    m_user(""),
    m_demoEdges(false),
    m_enableLauncherWhileLocked(false),
    m_enableIndicatorsWhileLocked(false),
    m_statsWelcomeScreen(false),
    m_passwordDisplayHint(Keyboard),
    m_failedLogins(0),
    m_hereEnabled(false),
    m_hereLicensePath() // null means not set yet
{
    connect(m_service, SIGNAL(propertiesChanged(const QString &, const QString &, const QStringList &)),
            this, SLOT(propertiesChanged(const QString &, const QString &, const QStringList &)));
    connect(m_service, SIGNAL(maybeChanged(const QString &)),
            this, SLOT(maybeChanged(const QString &)));

    setUser(qgetenv("USER"));
}

QString AccountsService::user() const
{
    return m_user;
}

void AccountsService::setUser(const QString &user)
{
    if (user.isEmpty() || m_user == user)
        return;

    m_user = user;
    Q_EMIT userChanged();

    updateDemoEdges(false);
    updateEnableLauncherWhileLocked(false);
    updateEnableIndicatorsWhileLocked(false);
    updateBackgroundFile(false);
    updateStatsWelcomeScreen(false);
    updatePasswordDisplayHint(false);
    updateFailedLogins(false);
    updateHereEnabled(false);
    updateHereLicensePath(false);
}

bool AccountsService::demoEdges() const
{
    return m_demoEdges;
}

void AccountsService::setDemoEdges(bool demoEdges)
{
    if (m_demoEdges != demoEdges) {
        m_demoEdges = demoEdges;
        m_service->setUserProperty(m_user, "com.canonical.unity.AccountsService", "demo-edges", demoEdges);

        Q_EMIT demoEdgesChanged();
    }
}

bool AccountsService::enableLauncherWhileLocked() const
{
    return m_enableLauncherWhileLocked;
}

bool AccountsService::enableIndicatorsWhileLocked() const
{
    return m_enableIndicatorsWhileLocked;
}

QString AccountsService::backgroundFile() const
{
    return m_backgroundFile;
}

bool AccountsService::statsWelcomeScreen() const
{
    return m_statsWelcomeScreen;
}

AccountsService::PasswordDisplayHint AccountsService::passwordDisplayHint() const
{
    return m_passwordDisplayHint;
}

bool AccountsService::hereEnabled() const
{
    return m_hereEnabled;
}

void AccountsService::setHereEnabled(bool enabled)
{
    if (m_hereEnabled != enabled) {
        m_hereEnabled = enabled;
        m_service->setUserProperty(m_user, "com.ubuntu.location.providers.here.AccountsService", "LicenseAccepted", enabled);

        Q_EMIT hereEnabledChanged();
    }
}

QString AccountsService::hereLicensePath() const
{
    return m_hereLicensePath;
}

bool AccountsService::hereLicensePathValid() const
{
    return !m_hereLicensePath.isNull();
}

void AccountsService::updateDemoEdges(bool async)
{
    QDBusPendingCall pendingReply = m_service->getUserPropertyAsync(m_user,
                                                                    "com.canonical.unity.AccountsService",
                                                                    "demo-edges");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QDBusVariant> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Failed to get 'demo-edges' property - " << reply.error().message();
            watcher->deleteLater();
            return;
        }

        auto demoEdges = reply.value().variant().toBool();
        if (m_demoEdges != demoEdges) {
            m_demoEdges = demoEdges;
            Q_EMIT demoEdgesChanged();
        }
        watcher->deleteLater();
    });
    if (!async) {
        watcher->waitForFinished();
        delete watcher;
    }
}

void AccountsService::updateEnableLauncherWhileLocked(bool async)
{
    QDBusPendingCall pendingReply = m_service->getUserPropertyAsync(m_user,
                                                                    "com.ubuntu.AccountsService.SecurityPrivacy",
                                                                    "EnableLauncherWhileLocked");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QDBusVariant> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Failed to get 'EnableLauncherWhileLocked' property - " << reply.error().message();
            watcher->deleteLater();
            return;
        }

        auto enableLauncherWhileLocked = reply.value().variant().toBool();
        if (m_enableLauncherWhileLocked != enableLauncherWhileLocked) {
            m_enableLauncherWhileLocked = enableLauncherWhileLocked;
            Q_EMIT enableLauncherWhileLockedChanged();
        }
        watcher->deleteLater();
    });
    if (!async) {
        watcher->waitForFinished();
        delete watcher;
    }
}

void AccountsService::updateEnableIndicatorsWhileLocked(bool async)
{
    QDBusPendingCall pendingReply = m_service->getUserPropertyAsync(m_user,
                                                                    "com.ubuntu.AccountsService.SecurityPrivacy",
                                                                    "EnableIndicatorsWhileLocked");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QDBusVariant> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Failed to get 'EnableIndicatorsWhileLocked' property - " << reply.error().message();
            watcher->deleteLater();
            return;
        }

        auto enableIndicatorsWhileLocked = reply.value().variant().toBool();
        if (m_enableIndicatorsWhileLocked != enableIndicatorsWhileLocked) {
            m_enableIndicatorsWhileLocked = enableIndicatorsWhileLocked;
            Q_EMIT enableIndicatorsWhileLockedChanged();
        }
        watcher->deleteLater();
    });
    if (!async) {
        watcher->waitForFinished();
        delete watcher;
    }
}

void AccountsService::updateBackgroundFile(bool async)
{
    QDBusPendingCall pendingReply = m_service->getUserPropertyAsync(m_user,
                                                                    "org.freedesktop.Accounts.User",
                                                                    "BackgroundFile");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QDBusVariant> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Failed to get 'BackgroundFile' property - " << reply.error().message();
            watcher->deleteLater();
            return;
        }

        auto backgroundFile = reply.value().variant().toString();
        if (m_backgroundFile != backgroundFile) {
            m_backgroundFile = backgroundFile;
            Q_EMIT backgroundFileChanged();
        }
        watcher->deleteLater();
    });
    if (!async) {
        watcher->waitForFinished();
        delete watcher;
    }
}

void AccountsService::updateStatsWelcomeScreen(bool async)
{
    QDBusPendingCall pendingReply = m_service->getUserPropertyAsync(m_user,
                                                                    "com.ubuntu.touch.AccountsService.SecurityPrivacy",
                                                                    "StatsWelcomeScreen");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QDBusVariant> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Failed to get 'StatsWelcomeScreen' property - " << reply.error().message();
            watcher->deleteLater();
            return;
        }

        auto statsWelcomeScreen = reply.value().variant().toBool();
        if (m_statsWelcomeScreen != statsWelcomeScreen) {
            m_statsWelcomeScreen = statsWelcomeScreen;
            Q_EMIT statsWelcomeScreenChanged();
        }
        watcher->deleteLater();
    });
    if (!async) {
        watcher->waitForFinished();
        delete watcher;
    }
}

void AccountsService::updatePasswordDisplayHint(bool async)
{
    QDBusPendingCall pendingReply = m_service->getUserPropertyAsync(m_user,
                                                                    "com.ubuntu.AccountsService.SecurityPrivacy",
                                                                    "PasswordDisplayHint");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QDBusVariant> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Failed to get 'PasswordDisplayHint' property - " << reply.error().message();
            watcher->deleteLater();
            return;
        }

        PasswordDisplayHint passwordDisplayHint = (PasswordDisplayHint)reply.value().variant().toInt();
        if (m_passwordDisplayHint != passwordDisplayHint) {
            m_passwordDisplayHint = passwordDisplayHint;
            Q_EMIT passwordDisplayHintChanged();
        }
        watcher->deleteLater();
    });
    if (!async) {
        watcher->waitForFinished();
        delete watcher;
    }
}

void AccountsService::updateFailedLogins(bool async)
{
    QDBusPendingCall pendingReply = m_service->getUserPropertyAsync(m_user,
                                                                    "com.canonical.unity.AccountsService.Private",
                                                                    "FailedLogins");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QDBusVariant> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Failed to get 'FailedLogins' property - " << reply.error().message();
            watcher->deleteLater();
            return;
        }

        uint failedLogins = reply.value().variant().toUInt();
        if (m_failedLogins != failedLogins) {
            m_failedLogins = failedLogins;
            Q_EMIT failedLoginsChanged();
        }
        watcher->deleteLater();
    });
    if (!async) {
        watcher->waitForFinished();
        delete watcher;
    }
}

void AccountsService::updateHereEnabled(bool async)
{
    QDBusPendingCall pendingReply = m_service->getUserPropertyAsync(m_user,
                                                                    "com.ubuntu.location.providers.here.AccountsService",
                                                                    "LicenseAccepted");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QDBusVariant> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Failed to get 'LicenseAccepted' property - " << reply.error().message();
            watcher->deleteLater();
            return;
        }

        auto hereEnabled = reply.value().variant().toBool();
        if (m_hereEnabled != hereEnabled) {
            m_hereEnabled = hereEnabled;
            Q_EMIT hereEnabledChanged();
        }
        watcher->deleteLater();
    });
    if (!async) {
        watcher->waitForFinished();
        delete watcher;
    }
}

void AccountsService::updateHereLicensePath(bool async)
{
    QDBusPendingCall pendingReply = m_service->getUserPropertyAsync(m_user,
                                                                    "com.ubuntu.location.providers.here.AccountsService",
                                                                    "LicenseBasePath");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QDBusVariant> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Failed to get 'LicenseBasePath' property - " << reply.error().message();
            watcher->deleteLater();
            return;
        }

        auto hereLicensePath = reply.value().variant().toString();
        if (hereLicensePath.isEmpty() || !QFile::exists(hereLicensePath))
            hereLicensePath = "";

        if (m_hereLicensePath.isNull() || m_hereLicensePath != hereLicensePath) {
            m_hereLicensePath = hereLicensePath;
            Q_EMIT hereLicensePathChanged();
        }
        watcher->deleteLater();
    });
    if (!async) {
        watcher->waitForFinished();
        delete watcher;
    }
}

uint AccountsService::failedLogins() const
{
    return m_failedLogins;
}

void AccountsService::setFailedLogins(uint failedLogins)
{
    if (m_failedLogins != failedLogins) {
        m_failedLogins = failedLogins;
        m_service->setUserProperty(m_user, "com.canonical.unity.AccountsService.Private", "FailedLogins", failedLogins);

        Q_EMIT failedLoginsChanged();
    }
}

void AccountsService::propertiesChanged(const QString &user, const QString &interface, const QStringList &changed)
{
    if (m_user != user) {
        return;
    }

    if (interface == "com.canonical.unity.AccountsService") {
        if (changed.contains("demo-edges")) {
            updateDemoEdges();
        }
    } else if (interface == "com.canonical.unity.AccountsService.Private") {
        if (changed.contains("FailedLogins")) {
            updateFailedLogins();
        }
    } else if (interface == "com.ubuntu.touch.AccountsService.SecurityPrivacy") {
        if (changed.contains("StatsWelcomeScreen")) {
            updateStatsWelcomeScreen();
        }
    } else if (interface == "com.ubuntu.AccountsService.SecurityPrivacy") {
        if (changed.contains("PasswordDisplayHint")) {
            updatePasswordDisplayHint();
        }
        if (changed.contains("EnableLauncherWhileLocked")) {
            updateEnableLauncherWhileLocked();
        }
        if (changed.contains("EnableIndicatorsWhileLocked")) {
            updateEnableIndicatorsWhileLocked();
        }
    } else if (interface == "com.ubuntu.location.providers.here.AccountsService") {
        if (changed.contains("LicenseAccepted")) {
            updateHereEnabled();
        }
        if (changed.contains("LicenseBasePath")) {
            updateHereLicensePath();
        }
    }
}

void AccountsService::maybeChanged(const QString &user)
{
    if (m_user != user) {
        return;
    }

    // Standard properties might have changed
    updateBackgroundFile();
}
