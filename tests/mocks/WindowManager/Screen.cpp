/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include "Screen.h"
#include "WorkspaceModel.h"
#include "WorkspaceManager.h"
#include "Workspace.h"

Screen::Screen()
    : m_workspaces(new WorkspaceModel)
{
    WorkspaceManager::instance()->createWorkspace()->assign(m_workspaces.data());
    WorkspaceManager::instance()->createWorkspace()->assign(m_workspaces.data());
}

QQmlListProperty<qtmir::ScreenMode> Screen::availableModes()
{
    return QQmlListProperty<qtmir::ScreenMode>(this, m_sizes);
}

qtmir::ScreenConfiguration *Screen::beginConfiguration() const
{
    auto config = new qtmir::ScreenConfiguration;
    config->valid = true;
    config->id = m_id;
    config->used = m_used;
    config->topLeft = m_position;
    config->currentModeIndex = m_currentModeIndex;
    config->powerMode = m_powerMode;
    config->scale = m_scale;
    config->formFactor = m_formFactor;
    return config;
}

bool Screen::applyConfiguration(qtmir::ScreenConfiguration *configuration)
{
    m_used = configuration->used;
    m_position = configuration->topLeft;
    m_currentModeIndex = configuration->currentModeIndex;
    m_powerMode = configuration->powerMode;
    m_scale = configuration->scale;
    m_formFactor = configuration->formFactor;

//    m_orientation = configuration->orientation;
    return true;
}

void Screen::setActive(bool active)
{
    m_active = active;
    Q_EMIT activeChanged(active);
}
