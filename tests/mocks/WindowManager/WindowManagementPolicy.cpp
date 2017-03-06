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

#include "WindowManagementPolicy.h"

#include <QDebug>

WindowManagementPolicy::WindowManagementPolicy()
    : m_dummyWorkspace(std::shared_ptr<miral::Workspace>())
{
    wmPolicyInterface = this;
    m_activeWorkspace = m_dummyWorkspace;
}

WindowManagementPolicy *WindowManagementPolicy::instance()
{
    static WindowManagementPolicy* wmPolicy(new WindowManagementPolicy);
    return wmPolicy;
}

std::shared_ptr<miral::Workspace> WindowManagementPolicy::createWorkspace()
{
    auto workspace = std::make_shared<miral::Workspace>();
    m_workspaces.insert(workspace);

    if (m_activeWorkspace.lock() == m_dummyWorkspace) {
        moveWorkspaceContentToWorkspace(workspace, m_dummyWorkspace);
        m_activeWorkspace = workspace;
    }
    return workspace;
}

void WindowManagementPolicy::releaseWorkspace(const std::shared_ptr<miral::Workspace> &workspace)
{
    auto iter = m_workspaces.find(workspace);
    if (iter != m_workspaces.end()) m_workspaces.erase(iter);

    if (m_workspaces.size() == 0) {
        m_activeWorkspace = m_dummyWorkspace;
        moveWorkspaceContentToWorkspace(m_dummyWorkspace, workspace);
    }
}

void WindowManagementPolicy::forEachWindowInWorkspace(const std::shared_ptr<miral::Workspace> &workspace, const std::function<void (const miral::Window &)> &callback)
{
    QMultiMap<miral::Workspace*, miral::Window>::iterator i = m_windows.find(workspace.get());
    while (i != m_windows.end() && i.key() == workspace.get()) {
        callback(i.value());
        ++i;
    }
}

void WindowManagementPolicy::moveWorkspaceContentToWorkspace(const std::shared_ptr<miral::Workspace> &to, const std::shared_ptr<miral::Workspace> &from)
{
    std::vector<miral::Window> windows;

    QMultiMap<miral::Workspace*, miral::Window>::iterator i = m_windows.find(from.get());
    while (i != m_windows.end() && i.key() == from.get()) {
        windows.push_back(i.value());
        ++i;
    }
    Q_EMIT windowsAboutToBeRemovedFromWorkspace(from, windows);
    m_windows.remove(from.get());

    Q_FOREACH(miral::Window window, windows) {
        m_windows.insert(to.get(), window);
    }
    Q_EMIT windowsAddedToWorkspace(to, windows);
}

void WindowManagementPolicy::addWindow(const miral::Window &window)
{
    Q_EMIT windowAdded(window);

    auto activeWorkspace = m_activeWorkspace.lock();
    if (activeWorkspace) {
        m_windows.insert(activeWorkspace.get(), window);

        Q_EMIT windowsAddedToWorkspace(activeWorkspace, {window});
    }
}

void WindowManagementPolicy::setActiveWorkspace(const std::shared_ptr<miral::Workspace> &workspace)
{
    if (m_activeWorkspace.lock() == workspace)
        return;
    m_activeWorkspace = workspace ? workspace : m_dummyWorkspace;
}
