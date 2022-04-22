/*
 * Copyright (C) 2013, 2015 Canonical, Ltd.
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
#include "UsersModel.h"

#include <QLightDM/UsersModel>
#include <paths.h>

AccountsService::AccountsService(QObject* parent)
  : QObject(parent),
    m_enableFingerprintIdentification(true),
    m_enableLauncherWhileLocked(true),
    m_enableIndicatorsWhileLocked(true),
    m_backgroundFile(),
    m_statsWelcomeScreen(true),
    m_failedLogins(0),
    m_failedFingerprintLogins(0),
    m_demoEdges(false),
    m_demoEdgesCompleted(),
    m_usersModel(new UsersModel(this)),
    m_pinCodePromptManager("PinPrompt.qml")
{
}

QString AccountsService::user() const
{
    return m_user;
}

void AccountsService::setUser(const QString &user)
{
    m_user = user;
    Q_EMIT userChanged();
    Q_EMIT passwordDisplayHintChanged();
    Q_EMIT backgroundFileChanged();
    Q_EMIT pinCodePromptManagerChanged();
}

bool AccountsService::demoEdges() const
{
    return m_demoEdges;
}

void AccountsService::setDemoEdges(bool demoEdges)
{
    m_demoEdges = demoEdges;
    Q_EMIT demoEdgesChanged();
}

QStringList AccountsService::demoEdgesCompleted() const
{
    return m_demoEdgesCompleted;
}

void AccountsService::markDemoEdgeCompleted(const QString &edge)
{
    if (!m_demoEdgesCompleted.contains(edge)) {
        m_demoEdgesCompleted << edge;
        Q_EMIT demoEdgesCompletedChanged();
    }
}

void AccountsService::setDemoEdgesCompleted(const QStringList &demoEdgesCompleted)
{
    m_demoEdgesCompleted = demoEdgesCompleted;
    Q_EMIT demoEdgesCompletedChanged();
}

bool AccountsService::enableFingerprintIdentification() const
{
    return m_enableFingerprintIdentification;
}

void AccountsService::setEnableFingerprintIdentification(bool enableFingerprintIdentification)
{
    m_enableFingerprintIdentification = enableFingerprintIdentification;
    Q_EMIT enableFingerprintIdentificationChanged();
}

bool AccountsService::enableLauncherWhileLocked() const
{
    return m_enableLauncherWhileLocked;
}

void AccountsService::setEnableLauncherWhileLocked(bool enableLauncherWhileLocked)
{
    m_enableLauncherWhileLocked = enableLauncherWhileLocked;
    Q_EMIT enableLauncherWhileLockedChanged();
}

bool AccountsService::enableIndicatorsWhileLocked() const
{
    return m_enableIndicatorsWhileLocked;
}

void AccountsService::setEnableIndicatorsWhileLocked(bool enableIndicatorsWhileLocked)
{
    m_enableIndicatorsWhileLocked = enableIndicatorsWhileLocked;
    Q_EMIT enableIndicatorsWhileLockedChanged();
}

QString AccountsService::backgroundFile() const
{
    if (!m_backgroundFile.isEmpty()) {
        return m_backgroundFile;
    }

    // Check if our mock user has a background set in liblightdm
    for (int i = 0; i < m_usersModel->count(); i++) {
        if (m_usersModel->data(i, QLightDM::UsersModel::NameRole) == m_user) {
            return m_usersModel->data(i, QLightDM::UsersModel::BackgroundPathRole).toString();
        }
    }

    return QString();
}

void AccountsService::setBackgroundFile(const QString &backgroundFile)
{
    m_backgroundFile = backgroundFile;
    backgroundFileChanged();
}

bool AccountsService::statsWelcomeScreen() const
{
    return m_statsWelcomeScreen;
}

void AccountsService::setStatsWelcomeScreen(bool statsWelcomeScreen)
{
    m_statsWelcomeScreen = statsWelcomeScreen;
    statsWelcomeScreenChanged();
}

AccountsService::PasswordDisplayHint AccountsService::passwordDisplayHint() const
{
    if (m_user == "has-pin" || m_user == "has-pin-clock")
        return PasswordDisplayHint::Numeric;
    else
        return PasswordDisplayHint::Keyboard;
}

QString AccountsService::pinCodePromptManager() const
{
    if (m_user == "has-pin-clock") {
        return "ClockPinPrompt.qml";
    } else {
        return m_pinCodePromptManager;
    }
}

QString AccountsService::defaultPinCodePromptManager() const
{
    return "PinPrompt.qml";
}

void AccountsService::setPinCodePromptManager(const QString pinCodePromptManager)
{
    m_pinCodePromptManager = pinCodePromptManager;
    Q_EMIT pinCodePromptManagerChanged();
}

uint AccountsService::failedLogins() const
{
    return m_failedLogins;
}

void AccountsService::setFailedLogins(uint failedLogins)
{
    m_failedLogins = failedLogins;
    failedLoginsChanged();
}

uint AccountsService::failedFingerprintLogins() const
{
    return m_failedFingerprintLogins;
}

void AccountsService::setFailedFingerprintLogins(uint failedFingerprintLogins)
{
    m_failedFingerprintLogins = failedFingerprintLogins;
    failedFingerprintLoginsChanged();
}

QString AccountsService::realName() const
{
    return m_realName;
}

void AccountsService::setRealName(const QString &realName)
{
    m_realName = realName;
    Q_EMIT realNameChanged();
}

QString AccountsService::email() const
{
    return m_email;
}

void AccountsService::setEmail(const QString &email)
{
    m_email = email;
    Q_EMIT emailChanged();
}

QStringList AccountsService::keymaps() const
{
    if (!m_kbdMap.isEmpty()) {
        return m_kbdMap;
    }

    return {QStringLiteral("us")};
}

void AccountsService::setKeymaps(const QStringList &keymaps)
{
    if (keymaps != m_kbdMap) {
        m_kbdMap = keymaps;
        Q_EMIT keymapsChanged();
    }
}
