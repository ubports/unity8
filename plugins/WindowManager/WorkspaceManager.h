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

class Workspace;

class WorkspaceManager : public WorkspaceModel
{
    Q_OBJECT
public:
    static WorkspaceManager* instance();

private:
    WorkspaceManager();

public Q_SLOTS:
    Workspace* createWorkspace();
    void destroyWorkspace(Workspace* workspace);

private:
    QVector<Workspace*> m_allWorkspaces;
};

#endif // WORKSPACEMANAGER_H
