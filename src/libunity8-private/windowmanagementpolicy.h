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

#ifndef UNITY_WINDOWMANAGEMENTPOLICY_H
#define UNITY_WINDOWMANAGEMENTPOLICY_H

#include <qtmir/windowmanagementpolicy.h>

#include <unordered_set>

class Q_DECL_EXPORT WindowManagementPolicy : public qtmir::WindowManagementPolicy
{
public:
    WindowManagementPolicy(const miral::WindowManagerTools &tools, qtmir::WindowManagementPolicyPrivate& dd);

    static WindowManagementPolicy *instance();

    void advise_new_window(miral::WindowInfo const& window_info) override;

    std::shared_ptr<miral::Workspace> createWorkspace();
    void releaseWorkspace(const std::shared_ptr<miral::Workspace> &workspace);

    void forEachWindowInWorkspace(
        std::shared_ptr<miral::Workspace> const& workspace,
        std::function<void(miral::Window const& window)> const& callback);

    void moveWorkspaceContentToWorkspace(const std::shared_ptr<miral::Workspace> &toWorkspace,
                                         const std::shared_ptr<miral::Workspace> &fromWorkspace);

    void setActiveWorkspace(const std::shared_ptr<miral::Workspace>& workspace);

private:
    static WindowManagementPolicy* m_self;
    std::weak_ptr<miral::Workspace> m_activeWorkspace;

    std::unordered_set<std::shared_ptr<miral::Workspace>> m_workspaces;
    const std::shared_ptr<miral::Workspace> m_dummyWorkspace;
};

#endif // UNITY_WINDOWMANAGEMENTPOLICY_H
