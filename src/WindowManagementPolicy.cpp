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

WindowManagementPolicy::WindowManagementPolicy(const miral::WindowManagerTools &tools, std::shared_ptr<qtmir::WindowManagementPolicyPrivate> dd)
    : qtmir::WindowManagementPolicy(tools, dd)
    , m_dummyWorkspace(this->tools.create_workspace())
{
    wmPolicyInterface = this;

    // we must always have a active workspace.
    m_activeWorkspace = m_dummyWorkspace;
}

void WindowManagementPolicy::advise_new_window(miral::WindowInfo const& window_info)
{
    qtmir::WindowManagementPolicy::advise_new_window(window_info);

    auto const parent = window_info.parent();

    auto activeWorkspace = m_activeWorkspace.lock();
    if (!parent && activeWorkspace) {
        tools.add_tree_to_workspace(window_info.window(), activeWorkspace);
    }
}

std::shared_ptr<miral::Workspace> WindowManagementPolicy::createWorkspace()
{
    auto workspace = tools.create_workspace();
    m_workspaces.insert(workspace);

    if (m_activeWorkspace.lock() == m_dummyWorkspace) {
        tools.move_workspace_content_to_workspace(workspace, m_dummyWorkspace);
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
        tools.move_workspace_content_to_workspace(m_dummyWorkspace, workspace);
    }
}

void WindowManagementPolicy::setActiveWorkspace(const std::shared_ptr<miral::Workspace> &workspace)
{
    if (m_activeWorkspace.lock() == workspace)
        return;
    m_activeWorkspace = workspace ? workspace : m_dummyWorkspace;
}
