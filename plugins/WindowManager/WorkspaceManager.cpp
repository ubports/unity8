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
#include "TopLevelWindowModel.h"

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
    : m_activeWorkspace(nullptr)
{
}

Workspace *WorkspaceManager::createWorkspace()
{
    auto workspace = new Workspace(this);
    QQmlEngine::setObjectOwnership(workspace, QQmlEngine::CppOwnership);
    m_allWorkspaces.insert(workspace);
    workspace->assign(this);

    if (m_allWorkspaces.count() == 0 && m_activeWorkspace) {
        m_activeWorkspace = nullptr;
        Q_EMIT activeWorkspaceChanged();
    } else if (m_allWorkspaces.count() == 1) {
        m_activeWorkspace = workspace;
        Q_EMIT activeWorkspaceChanged();
    }

    return workspace;
}

void WorkspaceManager::destroyWorkspace(Workspace *workspace)
{
    if (!workspace) return;

    m_allWorkspaces.remove(workspace);
    workspace->assign(nullptr);

    if (m_activeWorkspace == workspace) {
        m_activeWorkspace = m_allWorkspaces.count() > 0 ? *m_allWorkspaces.begin() : nullptr;
        if (m_activeWorkspace) {
            workspace->moveWindowsTo(m_activeWorkspace);
        }
    }

    workspace->deleteLater();
}

Workspace *WorkspaceManager::activeWorkspace() const
{
    return m_activeWorkspace;
}

void WorkspaceManager::setActiveWorkspace(Workspace *workspace)
{
    if (workspace != m_activeWorkspace) {
        m_activeWorkspace = workspace;
        Q_EMIT activeWorkspaceChanged();
    }
}
