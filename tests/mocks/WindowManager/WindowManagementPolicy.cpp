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

void WindowManagementPolicy::setActiveWorkspace(const std::shared_ptr<miral::Workspace> &workspace)
{
    if (m_activeWorkspace.lock() == workspace)
        return;
    m_activeWorkspace = workspace ? workspace : m_dummyWorkspace;
}

void WindowManagementPolicy::addWindow(const miral::Window &window)
{
    Q_EMIT windowAdded(window);

    auto activeWorkspace = m_activeWorkspace.lock();
    if (activeWorkspace) {
        m_windows.insert(activeWorkspace, window);

        Q_EMIT windowsAddedToWorkspace(activeWorkspace, {window});
    }
}

void WindowManagementPolicy::removeWindow(const miral::Window &window)
{
    WorkspaceWindows::iterator i = m_windows.begin();
    while (i != m_windows.end()) {
        if (i.value() == window) {
            Q_EMIT windowsAboutToBeRemovedFromWorkspace(i.key(), { window });
            i = m_windows.erase(i);
        } else {
            ++i;
        }
    }
    Q_EMIT windowRemoved(window);
}

void WindowManagementPolicy::forEachWindowInWorkspace(const std::shared_ptr<miral::Workspace> &workspace, const std::function<void(const miral::Window &)> &callback)
{
    WorkspaceWindows::iterator i = m_windows.find(workspace);
    while (i != m_windows.end() && i.key() == workspace) {
        callback(i.value());
        ++i;
    }
}

void WindowManagementPolicy::moveWindowToWorkspace(const miral::Window &window, const std::shared_ptr<miral::Workspace> &workspace)
{
    auto from = m_windows.key(window);
    if (from) {
        auto iter = m_windows.find(from, window);
        Q_EMIT windowsAboutToBeRemovedFromWorkspace(from, { window });
        m_windows.erase(iter);
    }

    m_windows.insert(workspace, window);
    Q_EMIT windowsAddedToWorkspace(workspace, { window });
}

void WindowManagementPolicy::moveWorkspaceContentToWorkspace(const std::shared_ptr<miral::Workspace> &to, const std::shared_ptr<miral::Workspace> &from)
{
    std::vector<miral::Window> windows;

    WorkspaceWindows::iterator i = m_windows.find(from);
    while (i != m_windows.end() && i.key() == from) {
        windows.push_back(i.value());
        ++i;
    }
    Q_EMIT windowsAboutToBeRemovedFromWorkspace(from, windows);
    m_windows.remove(from);

    Q_FOREACH(miral::Window window, windows) {
        m_windows.insert(to, window);
    }
    Q_EMIT windowsAddedToWorkspace(to, windows);
}
