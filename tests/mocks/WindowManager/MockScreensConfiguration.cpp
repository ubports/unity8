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

#include "ScreensConfiguration.h"
#include "Screen.h"
#include "Workspace.h"
#include "WorkspaceManager.h"

namespace
{
const int DefaultWorkspacesCount = 2;
QHash<QString, int> screensConfig;
}

ScreensConfiguration::ScreensConfiguration()
{
}

ScreensConfiguration::~ScreensConfiguration()
{
}

void ScreensConfiguration::load(Screen *screen)
{
    int workspaces = screensConfig.value(screen->name(), DefaultWorkspacesCount);
    for (int i = 0; i < workspaces; i++) {
        WorkspaceManager::instance()->createWorkspace()->assign(screen->workspaces());
    }
}

void ScreensConfiguration::save(Screen *screen)
{
    screensConfig[screen->name()] = screen->workspaces()->rowCount();
}
