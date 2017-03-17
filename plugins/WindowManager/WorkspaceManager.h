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

#ifndef WORKSPACEMANAGER_H
#define WORKSPACEMANAGER_H

#include "WorkspaceModel.h"
#include <QQmlListProperty>

class Workspace;
class ScreensProxy;

namespace unity {
    namespace shell {
        namespace application {
            class MirSurfaceInterface;
            class SurfaceManagerInterface;
        }
    }
}

class WorkspaceManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Workspace* activeWorkspace READ activeWorkspace WRITE setActiveWorkspace2 NOTIFY activeWorkspaceChanged)

public:
    static WorkspaceManager* instance();

    Workspace* activeWorkspace() const;
    void setActiveWorkspace(Workspace* workspace);

    Workspace* createWorkspace();
    void destroyWorkspace(Workspace* workspace);

    QQmlListProperty<Workspace> floatingWorkspaces();
    void destroyFloatingWorkspaces();

    Q_INVOKABLE void moveSurfaceToWorkspace(unity::shell::application::MirSurfaceInterface* surface,
                                            Workspace* workspace);

    Q_INVOKABLE void moveWorkspaceContentToWorkspace(Workspace* from, Workspace* to);

Q_SIGNALS:
    void activeWorkspaceChanged();
    void floatingWorkspacesChanged();

private:
    WorkspaceManager();

    void setActiveWorkspace2(Workspace* workspace);

    QSet<Workspace*> m_allWorkspaces;
    QList<Workspace*> m_floatingWorkspaces;
    Workspace* m_activeWorkspace;
    unity::shell::application::SurfaceManagerInterface* m_surfaceManager;
};

#endif // WORKSPACEMANAGER_H
