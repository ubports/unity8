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

#include "dashcommunicatorservice.h"

#include <QDebug>

DashCommunicatorService *DashCommunicatorService::m_theCommunicatorService = nullptr;

DashCommunicatorService::DashCommunicatorService(QObject *parent):
    QObject(parent)
{
    if (m_theCommunicatorService) {
        qFatal("There's already a communicator service, this should not happen!");
    }
    m_theCommunicatorService = this;
}


DashCommunicatorService::~DashCommunicatorService()
{

}

DashCommunicatorService *DashCommunicatorService::theCommunicatorService()
{
    return m_theCommunicatorService;
}

void DashCommunicatorService::mockSetCurrentScope(int index, bool animate, bool isSwipe)
{
    Q_EMIT setCurrentScopeRequested(index, animate, isSwipe);
}
