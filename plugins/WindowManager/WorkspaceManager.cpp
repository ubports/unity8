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

#include "WorkspaceManager.h"
#include "Workspace.h"

// Qt
#include <QGuiApplication>
#include <QScreen>
#include <QQmlEngine>

WorkspaceManager *WorkspaceManager::instance()
{
    static WorkspaceManager* workspaceManager(new WorkspaceManager());
    return workspaceManager;
}

WorkspaceManager::WorkspaceManager()
{
}
Workspace *WorkspaceManager::createWorkspace()
{
    auto workspace = new Workspace(this);
    QQmlEngine::setObjectOwnership(workspace, QQmlEngine::CppOwnership);
    m_allWorkspaces.append(workspace);
    workspace->assign(this);
    return workspace;
}

void WorkspaceManager::destroyWorkspace(Workspace *workspace)
{
    workspace->deleteLater();
}

