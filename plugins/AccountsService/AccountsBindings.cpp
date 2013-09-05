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

#include "AccountsBindings.h"
#include "AccountsService.h"

#include <QStringList>

AccountsBindings::AccountsBindings(QObject* parent)
  : QObject(parent),
    m_service(new AccountsService(this)),
    m_user(qgetenv("USER"))
{
    connect(m_service, SIGNAL(propertiesChanged(const QString &, const QString &, const QStringList &)),
            this, SLOT(propertiesChanged(const QString &, const QString &, const QStringList &)));
    connect(m_service, SIGNAL(maybeChanged(const QString &)),
            this, SLOT(maybeChanged(const QString &)));
}

void AccountsBindings::setUser(const QString &user)
{
    m_user = user;
    updateDemoEdges();
    updateBackgroundFile();
    updateStatsWelcomeScreen();
}

bool AccountsBindings::getDemoEdges()
{
    return m_demoEdges;
}

void AccountsBindings::setDemoEdges(bool demoEdges)
{
    m_demoEdges = demoEdges;
    m_service->setUserProperty(m_user, "com.canonical.unity.AccountsService", "demo-edges", demoEdges);
}

QString AccountsBindings::getBackgroundFile()
{
    return m_backgroundFile;
}

bool AccountsBindings::getStatsWelcomeScreen()
{
    return m_statsWelcomeScreen;
}

void AccountsBindings::updateDemoEdges()
{
    auto demoEdges = m_service->getUserProperty(m_user, "com.canonical.unity.AccountsService", "demo-edges").toBool();
    if (m_demoEdges != demoEdges) {
        m_demoEdges = demoEdges;
        Q_EMIT demoEdgesChanged();
    }
}

void AccountsBindings::updateBackgroundFile()
{
    auto backgroundFile = m_service->getUserProperty(m_user, "org.freedesktop.Accounts.User", "BackgroundFile").toString();
    if (m_backgroundFile != backgroundFile) {
        m_backgroundFile = backgroundFile;
        Q_EMIT backgroundFileChanged();
    }
}

void AccountsBindings::updateStatsWelcomeScreen()
{
    auto statsWelcomeScreen = m_service->getUserProperty(m_user, "com.ubuntu.touch.AccountsService.SecurityPrivacy", "StatsWelcomeScreen").toBool();
    if (m_statsWelcomeScreen != statsWelcomeScreen) {
        m_statsWelcomeScreen = statsWelcomeScreen;
        Q_EMIT statsWelcomeScreenChanged();
    }
}

void AccountsBindings::propertiesChanged(const QString &user, const QString &interface, const QStringList &changed)
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
    }
}

void AccountsBindings::maybeChanged(const QString &user)
{
    if (m_user != user) {
        return;
    }

    // Standard properties might have changed
    updateBackgroundFile();
}
