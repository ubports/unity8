/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include "WindowManagerObjects.h"

WindowManagerObjects::WindowManagerObjects(QObject *parent)
    : QObject(parent)
    , m_surfaceManager(nullptr)
    , m_applicationManager(nullptr)
{
}

WindowManagerObjects *WindowManagerObjects::instance()
{
    static WindowManagerObjects* objects(new WindowManagerObjects());
    return objects;
}


void WindowManagerObjects::setSurfaceManager(lomiri::shell::application::SurfaceManagerInterface *surfaceManager)
{
    if (m_surfaceManager == surfaceManager) return;

    m_surfaceManager = surfaceManager;
    Q_EMIT surfaceManagerChanged(surfaceManager);
}

void WindowManagerObjects::setApplicationManager(lomiri::shell::application::ApplicationManagerInterface *applicationManager)
{
    if (m_applicationManager == applicationManager) return;

    m_applicationManager = applicationManager;
    Q_EMIT applicationManagerChanged(applicationManager);
}
