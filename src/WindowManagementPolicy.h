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
#include "wmpolicyinterface.h"

#include <unordered_set>

class Q_DECL_EXPORT WindowManagementPolicy : public qtmir::WindowManagementPolicy,
                                             public WMPolicyInterface
{
public:
    WindowManagementPolicy(const miral::WindowManagerTools &tools, std::shared_ptr<qtmir::WindowManagementPolicyPrivate> dd);

    void advise_new_window(miral::WindowInfo const& window_info) override;

    // From WMPolicyInterface
    std::shared_ptr<miral::Workspace> createWorkspace() override;

    void releaseWorkspace(const std::shared_ptr<miral::Workspace> &workspace) override;

    void setActiveWorkspace(const std::shared_ptr<miral::Workspace> &workspace) override;

private:
    std::weak_ptr<miral::Workspace> m_activeWorkspace;

    std::unordered_set<std::shared_ptr<miral::Workspace>> m_workspaces;
    const std::shared_ptr<miral::Workspace> m_dummyWorkspace;
};

#endif // UNITY_WINDOWMANAGEMENTPOLICY_H
