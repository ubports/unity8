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
#include <unity/shell/application/SurfaceManagerInterface.h>

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
    m_floatingWorkspaces.append(workspace);

    connect(workspace, &Workspace::assigned, this, [this, workspace]() {
        m_floatingWorkspaces.removeOne(workspace);
        Q_EMIT floatingWorkspacesChanged();
    });
    connect(workspace, &Workspace::unassigned, this, [this, workspace]() {
        m_floatingWorkspaces.append(workspace);
        Q_EMIT floatingWorkspacesChanged();
    });

    if (m_allWorkspaces.count() == 0 && m_activeWorkspace) {
        setActiveWorkspace(nullptr);
        Q_EMIT activeWorkspaceChanged();
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
    m_floatingWorkspaces.removeOne(workspace);
    m_allWorkspaces.remove(workspace);
    Q_EMIT floatingWorkspacesChanged();

    if (m_activeWorkspace == workspace) {
        Q_ASSERT(false); // Shouldn't happen, should have chosen something by now.
        // just choose anything.
        setActiveWorkspace(m_allWorkspaces.count() ? *m_allWorkspaces.begin() : nullptr);
    }
    if (m_activeWorkspace) {
        moveWorkspaceContentToWorkspace(workspace, m_activeWorkspace);
    }

    disconnect(workspace, 0, this, 0);
    workspace->release();
}

QQmlListProperty<Workspace> WorkspaceManager::floatingWorkspaces()
{
    return QQmlListProperty<Workspace>(this, m_floatingWorkspaces);
}

void WorkspaceManager::destroyFloatingWorkspaces()
{
    QList<Workspace*> dpCpy(m_floatingWorkspaces);
    Q_FOREACH(auto workspace, dpCpy) {
        destroyWorkspace(workspace);
    }
}

void WorkspaceManager::moveSurfaceToWorkspace(unity::shell::application::MirSurfaceInterface *surface, Workspace *workspace)
{
    auto surfaceManager = WindowManagerObjects::instance()->surfaceManager();
    if (surfaceManager) {
        surfaceManager->moveSurfaceToWorkspace(surface, workspace->workspace());
    }
}

void WorkspaceManager::moveWorkspaceContentToWorkspace(Workspace *from, Workspace *to)
{
    auto surfaceManager = WindowManagerObjects::instance()->surfaceManager();
    if (surfaceManager) {
        surfaceManager->moveWorkspaceContentToWorkspace(from->workspace(), to->workspace());
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
        Q_EMIT activeWorkspaceChanged();
    }
}

void WorkspaceManager::setActiveWorkspace2(Workspace *workspace)
{
    if (!workspace) return;
    workspace->activate();
}
