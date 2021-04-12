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
#include "WindowManagerObjects.h"
#include <lomiri/shell/application/SurfaceManagerInterface.h>

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
    : m_activeWorkspace(nullptr),
      m_surfaceManager(nullptr)
{
    connect(WindowManagerObjects::instance(), &WindowManagerObjects::surfaceManagerChanged,
            this, &WorkspaceManager::setSurfaceManager);

    setSurfaceManager(WindowManagerObjects::instance()->surfaceManager());
}

void WorkspaceManager::setSurfaceManager(lomiri::shell::application::SurfaceManagerInterface *surfaceManager)
{
    if (m_surfaceManager == surfaceManager) return;

    if (m_surfaceManager) {
        disconnect(m_surfaceManager, &QObject::destroyed, this, 0);
    }

    m_surfaceManager = surfaceManager;

    if (m_surfaceManager) {
        connect(m_surfaceManager, &QObject::destroyed, this, [this](){
            setSurfaceManager(nullptr);
        });
    }
}

Workspace *WorkspaceManager::createWorkspace()
{
    auto workspace = new ConcreteWorkspace(this);
    QQmlEngine::setObjectOwnership(workspace, QQmlEngine::CppOwnership);
    m_allWorkspaces.insert(workspace);

    if (m_allWorkspaces.count() == 0 && m_activeWorkspace) {
        setActiveWorkspace(nullptr);
    } else if (m_allWorkspaces.count() == 1) {
        setActiveWorkspace(workspace);
    }

    return workspace;
}

void WorkspaceManager::destroyWorkspace(Workspace *workspace)
{
    if (!workspace) return;

    if (workspace->isAssigned()) {
        workspace->unassign();
    }
    m_allWorkspaces.remove(workspace);

    if (m_activeWorkspace == workspace) {
        setActiveWorkspace(m_allWorkspaces.count() ? *m_allWorkspaces.begin() : nullptr);
    }
    if (m_activeWorkspace) {
        moveWorkspaceContentToWorkspace(m_activeWorkspace, workspace);
    }

    disconnect(workspace, 0, this, 0);
}

void WorkspaceManager::moveSurfaceToWorkspace(lomiri::shell::application::MirSurfaceInterface *surface, Workspace *workspace)
{
    if (m_surfaceManager) {
        m_surfaceManager->moveSurfaceToWorkspace(surface, workspace->workspace());
    }
}

void WorkspaceManager::moveWorkspaceContentToWorkspace(Workspace *to, Workspace *from)
{
    if (m_surfaceManager) {
        m_surfaceManager->moveWorkspaceContentToWorkspace(to->workspace(), from->workspace());
    }
}

Workspace *WorkspaceManager::activeWorkspace() const
{
    return m_activeWorkspace;
}

void WorkspaceManager::setActiveWorkspace(Workspace *workspace)
{
    if (workspace != m_activeWorkspace) {
        m_activeWorkspace = workspace;
        Q_EMIT activeWorkspaceChanged(workspace);
    }
}

void WorkspaceManager::setActiveWorkspace2(Workspace *workspace)
{
    if (!workspace) return;
    workspace->activate();
}
