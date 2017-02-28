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

#include "Workspace.h"
#include "WorkspaceModel.h"
#include "WorkspaceManager.h"
#include "TopLevelWindowModel.h"

#include "windowmanagementpolicy.h"

Workspace::Workspace(QObject *parent)
    : QObject(parent)
    , m_workspace(WindowManagementPolicy::instance()->createWorkspace())
    , m_model(nullptr)
    , m_active(false)
{
    connect(WorkspaceManager::instance(), &WorkspaceManager::activeWorkspaceChanged, this, [this]() {
        bool newActive = WorkspaceManager::instance()->activeWorkspace() == this;
        if (newActive != m_active) {
            m_active = newActive;
            Q_EMIT activeChanged(m_active);

            if (m_active) {
                WindowManagementPolicy::instance()->setActiveWorkspace(m_workspace);
            }
        }
    });
}

Workspace::~Workspace()
{
    WindowManagementPolicy::instance()->destroyWorkspace(m_workspace);
    if (m_model) {
        m_model->remove(this);
    }
}

void Workspace::assign(WorkspaceModel *model, const QVariant& vIndex)
{
    if (m_model == model) return;

    if (m_model) {
        disconnect(model);
        m_model->remove(this);
    }

    m_model = model;

    if (model) {
        int index = m_model->rowCount();
        if (vIndex.isValid() && vIndex.canConvert(QVariant::Int)) {
            index = vIndex.toInt();
        }
        m_model->insert(index, this);

        connect(m_model, &QObject::destroyed, this, [this]() {
            m_model->remove(this);
            m_model = nullptr;
        });
        Q_EMIT assigned();
    }
}

void Workspace::moveWindowsTo(Workspace *workspace)
{
    WindowManagementPolicy::instance()->moveWorkspaceContentToWorkspace(workspace->m_workspace, m_workspace);
}

void Workspace::activate()
{
    WorkspaceManager::instance()->setActiveWorkspace(this);
}

void Workspace::unassign()
{
    assign(WorkspaceManager::instance());
}
