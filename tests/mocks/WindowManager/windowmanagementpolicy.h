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

#ifndef MOCKWINDOMANAGEMENTPOLICY_H
#define MOCKWINDOMANAGEMENTPOLICY_H

#include <QObject>

namespace miral {
class Window;
class Workspace {};
}

// A Fake window management policy for the mock.
class WindowManagementPolicy : public QObject
{
    Q_OBJECT
public:
    WindowManagementPolicy() {}

    static WindowManagementPolicy *instance() {
        static WindowManagementPolicy* inst(new WindowManagementPolicy());
        return inst;
    }

    std::shared_ptr<miral::Workspace> createWorkspace() { return std::make_shared<miral::Workspace>(); }
    void releaseWorkspace(const std::shared_ptr<miral::Workspace>&) {}

    void forEachWindowInWorkspace(
        std::shared_ptr<miral::Workspace> const&,
        std::function<void(miral::Window const&)> const&) {}

    void moveWorkspaceContentToWorkspace(const std::shared_ptr<miral::Workspace>&,
                                         const std::shared_ptr<miral::Workspace>&)
    {}

public Q_SLOTS:
    void setActiveWorkspace(const std::shared_ptr<miral::Workspace>&) {}
};

#endif // UNITY_WINDOWMANAGEMENTPOLICY_H
