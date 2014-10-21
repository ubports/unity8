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

#include <paths.h>

AccountsService::AccountsService(QObject* parent)
  : QObject(parent),
    m_enableLauncherWhileLocked(true),
    m_enableIndicatorsWhileLocked(true),
    m_backgroundFile(qmlDirectory() + "graphics/phone_background.jpg"),
    m_statsWelcomeScreen(true),
    m_failedLogins(0),
    m_demoEdges(false)
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
    return m_backgroundFile;
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
    if (m_user == "has-pin")
        return PasswordDisplayHint::Numeric;
    else
        return PasswordDisplayHint::Keyboard;
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
