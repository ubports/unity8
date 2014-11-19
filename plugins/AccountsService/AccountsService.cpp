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
    m_hereLicensePath(" ") // blank space means not set yet
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

    updateDemoEdges();
    updateEnableLauncherWhileLocked();
    updateEnableIndicatorsWhileLocked();
    updateBackgroundFile();
    updateStatsWelcomeScreen();
    updatePasswordDisplayHint();
    updateFailedLogins();
    updateHereEnabled();
    updateHereLicensePath();
}

bool AccountsService::demoEdges() const
{
    return m_demoEdges;
}

void AccountsService::setDemoEdges(bool demoEdges)
{
    m_demoEdges = demoEdges;
    m_service->setUserProperty(m_user, "com.canonical.unity.AccountsService", "demo-edges", demoEdges);
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
    m_service->setUserProperty(m_user, "com.ubuntu.location.providers.here.AccountsService", "LicenseAccepted", enabled);
}

QString AccountsService::hereLicensePath() const
{
    return m_hereLicensePath;
}

void AccountsService::updateDemoEdges()
{
    auto demoEdges = m_service->getUserProperty(m_user, "com.canonical.unity.AccountsService", "demo-edges").toBool();
    if (m_demoEdges != demoEdges) {
        m_demoEdges = demoEdges;
        Q_EMIT demoEdgesChanged();
    }
}

void AccountsService::updateEnableLauncherWhileLocked()
{
    auto enableLauncherWhileLocked = m_service->getUserProperty(m_user, "com.ubuntu.AccountsService.SecurityPrivacy", "EnableLauncherWhileLocked").toBool();
    if (m_enableLauncherWhileLocked != enableLauncherWhileLocked) {
        m_enableLauncherWhileLocked = enableLauncherWhileLocked;
        Q_EMIT enableLauncherWhileLockedChanged();
    }
}

void AccountsService::updateEnableIndicatorsWhileLocked()
{
    auto enableIndicatorsWhileLocked = m_service->getUserProperty(m_user, "com.ubuntu.AccountsService.SecurityPrivacy", "EnableIndicatorsWhileLocked").toBool();
    if (m_enableIndicatorsWhileLocked != enableIndicatorsWhileLocked) {
        m_enableIndicatorsWhileLocked = enableIndicatorsWhileLocked;
        Q_EMIT enableIndicatorsWhileLockedChanged();
    }
}

void AccountsService::updateBackgroundFile()
{
    auto backgroundFile = m_service->getUserProperty(m_user, "org.freedesktop.Accounts.User", "BackgroundFile").toString();
    if (m_backgroundFile != backgroundFile) {
        m_backgroundFile = backgroundFile;
        Q_EMIT backgroundFileChanged();
    }
}

void AccountsService::updateStatsWelcomeScreen()
{
    bool statsWelcomeScreen = m_service->getUserProperty(m_user, "com.ubuntu.touch.AccountsService.SecurityPrivacy", "StatsWelcomeScreen").toBool();
    if (m_statsWelcomeScreen != statsWelcomeScreen) {
        m_statsWelcomeScreen = statsWelcomeScreen;
        Q_EMIT statsWelcomeScreenChanged();
    }
}

void AccountsService::updatePasswordDisplayHint()
{
    PasswordDisplayHint passwordDisplayHint = (PasswordDisplayHint)m_service->getUserProperty(m_user, "com.ubuntu.AccountsService.SecurityPrivacy", "PasswordDisplayHint").toInt();
    if (m_passwordDisplayHint != passwordDisplayHint) {
        m_passwordDisplayHint = passwordDisplayHint;
        Q_EMIT passwordDisplayHintChanged();
    }
}

void AccountsService::updateFailedLogins()
{
    uint failedLogins = m_service->getUserProperty(m_user, "com.canonical.unity.AccountsService.Private", "FailedLogins").toUInt();
    if (m_failedLogins != failedLogins) {
        m_failedLogins = failedLogins;
        Q_EMIT failedLoginsChanged();
    }
}

void AccountsService::updateHereEnabled()
{
    bool hereEnabled = m_service->getUserProperty(m_user, "com.ubuntu.location.providers.here.AccountsService", "LicenseAccepted").toBool();
    if (m_hereEnabled != hereEnabled) {
        m_hereEnabled = hereEnabled;
        Q_EMIT hereEnabledChanged();
    }
}

void AccountsService::updateHereLicensePath()
{
    QString hereLicensePath = m_service->getUserProperty(m_user, "com.ubuntu.location.providers.here.AccountsService", "LicenseBasePath").toString();

    if (!hereLicensePath.isEmpty() && !QFile::exists(hereLicensePath))
        hereLicensePath = "";

    if (m_hereLicensePath != hereLicensePath) {
        m_hereLicensePath = hereLicensePath;
        Q_EMIT hereLicensePathChanged();
    }
}

uint AccountsService::failedLogins() const
{
    return m_failedLogins;
}

void AccountsService::setFailedLogins(uint failedLogins)
{
    m_failedLogins = failedLogins;
    m_service->setUserProperty(m_user, "com.canonical.unity.AccountsService.Private", "FailedLogins", failedLogins);
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
