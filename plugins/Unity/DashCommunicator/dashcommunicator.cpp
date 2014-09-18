/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "dashcommunicator.h"

#include <unity/shell/application/ApplicationInfoInterface.h>
#include <unity/shell/application/ApplicationManagerInterface.h>

#include <QObject>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDebug>
#include <QDBusPendingCall>

using namespace unity::shell::application;

DashCommunicator::DashCommunicator(QObject *parent):
    QObject(parent),
    m_dashInterface(nullptr),
    m_applicationManager(nullptr),
    m_dash(nullptr)
{
}

DashCommunicator::~DashCommunicator()
{
}

void DashCommunicator::setCurrentScope(const QString &scopeId, bool animate, bool isSwipe)
{
    // Connection not up... Try to connect
    if (!m_dashInterface || !m_dashInterface->isValid()) {
        connectToDash();
    }

    if (m_dashInterface && m_dashInterface->isValid()) {
        m_dashInterface->asyncCall("SetCurrentScope", scopeId, animate, isSwipe);
    }
}

void DashCommunicator::connectToDash()
{
    if (m_dashInterface) {
        m_dashInterface->deleteLater();
        m_dashInterface = nullptr;
    }

    if (m_applicationManager) {
        ApplicationInfoInterface *dash = m_applicationManager->findApplication("unity8-dash");
        if (dash && dash->state() == ApplicationInfoInterface::Running) {
            QDBusConnection connection = QDBusConnection::sessionBus();
            m_dashInterface = new QDBusInterface("com.canonical.UnityDash",
                                    "/com/canonical/UnityDash",
                                    "",
                                    connection);
        } else {
            qWarning() << "Dash is suspended or not running. Can't connect.";
        }
    }
}

unity::shell::application::ApplicationManagerInterface* DashCommunicator::applicationManager() const
{
    return m_applicationManager;
}

void DashCommunicator::setApplicationManager(unity::shell::application::ApplicationManagerInterface *appManager)
{
    if (m_applicationManager != appManager) {
        m_applicationManager = appManager;
        Q_EMIT applicationManagerChanged();

        connect(m_applicationManager, &unity::shell::application::ApplicationManagerInterface::applicationAdded, this, &DashCommunicator::applicationAdded);
        connect(m_applicationManager, &unity::shell::application::ApplicationManagerInterface::applicationRemoved, this, &DashCommunicator::applicationRemoved);
        
        if (m_applicationManager->findApplication("unity8-dash")) {
            applicationAdded("unity8-dash");
        }
    }
}

void DashCommunicator::applicationAdded(const QString &appId)
{
    if (appId != "unity8-dash") {
        return;
    }
    ApplicationInfoInterface *app = m_applicationManager->findApplication(appId);
    if (!app) {
        qWarning() << "DashCommunicator received an applicationAdded signal for dash, but there's no dash!";
        return;
    }
    connectToDash();
}

void DashCommunicator::applicationRemoved(const QString &appId)
{
    if (appId != "unity8-dash") {
        return;
    }
    m_dashInterface->deleteLater();
    m_dashInterface = nullptr;
}
