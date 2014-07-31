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

#include <QStringList>

AccountsService::AccountsService(QObject* parent)
  : QObject(parent),
    m_service(new AccountsServiceDBusAdaptor(this)),
    m_user(qgetenv("USER")),
    m_demoEdges(false),
    m_statsWelcomeScreen(false),
    m_passwordDisplayHint(Keyboard)
{
    connect(m_service, SIGNAL(propertiesChanged(const QString &, const QString &, const QStringList &)),
            this, SLOT(propertiesChanged(const QString &, const QString &, const QStringList &)));
    connect(m_service, SIGNAL(maybeChanged(const QString &)),
            this, SLOT(maybeChanged(const QString &)));
}

QString AccountsService::user() const
{
    return m_user;
}

void AccountsService::setUser(const QString &user)
{
    m_user = user;
    Q_EMIT userChanged();

    updateDemoEdges();
    updateBackgroundFile();
    updateStatsWelcomeScreen();
    updatePasswordDisplayHint();
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

void AccountsService::updateDemoEdges()
{
    auto demoEdges = m_service->getUserProperty(m_user, "com.canonical.unity.AccountsService", "demo-edges").toBool();
    if (m_demoEdges != demoEdges) {
        m_demoEdges = demoEdges;
        Q_EMIT demoEdgesChanged();
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

void AccountsService::propertiesChanged(const QString &user, const QString &interface, const QStringList &changed)
{
    if (m_user != user) {
        return;
    }

    if (interface == "com.canonical.unity.AccountsService") {
        if (changed.contains("demo-edges")) {
            updateDemoEdges();
        }
    } else if (interface == "com.ubuntu.touch.AccountsService.SecurityPrivacy") {
        if (changed.contains("StatsWelcomeScreen")) {
            updateStatsWelcomeScreen();
        }
    } else if (interface == "com.ubuntu.AccountsService.SecurityPrivacy") {
        if (changed.contains("PasswordDisplayHint")) {
            updatePasswordDisplayHint();
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
