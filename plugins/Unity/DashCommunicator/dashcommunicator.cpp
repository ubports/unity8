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


#include <QObject>
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>
#include <QDebug>
#include <QDBusPendingCall>

DashCommunicator::DashCommunicator(QObject *parent):
    QThread(parent),
    m_dashService(nullptr)
{
    start();
}

void DashCommunicator::setCurrentScope(const QString &scopeId, bool animate, bool isSwipe)
{
    m_dashService->dbusInterface()->asyncCall("SetCurrentScope", scopeId, animate, isSwipe);
}

void DashCommunicator::run()
{
    m_dashService = new AbstractDBusServiceMonitor("com.canonical.UnityDash",
                                 "/com/canonical/UnityDash",
                                 "", AbstractDBusServiceMonitor::SessionBus, this);

    exec();
}
