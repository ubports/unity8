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

int nextWorkspace = 0;

Workspace::Workspace(QObject *parent)
    : QObject(parent)
    , m_workspace(WindowManagementPolicy::instance()->createWorkspace())
    , m_uid(QString("W%1").arg(nextWorkspace++))
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

Workspace::Workspace(const Workspace &other)
    : QObject(nullptr)
    , m_workspace(other.m_workspace)
    , m_uid(other.m_uid)
    , m_model(nullptr)
    , m_active(other.m_active)
{
    connect(&other, &Workspace::activeChanged, this, [this](bool active) {
        m_active = active;
        Q_EMIT activeChanged(m_active);
    });
}

Workspace::~Workspace()
{
    if (m_model) {
        m_model->remove(this);
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

void Workspace::assign(WorkspaceModel *model, const QVariant& vIndex)
{
    if (m_model == model) return;

    if (m_model) {
        disconnect(m_model, 0, this, 0);
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
            Q_EMIT unassigned();
        });
        Q_EMIT assigned();
    } else {
        Q_EMIT unassigned();
    }
}

void Workspace::unassign()
{
    assign(nullptr);
}

void Workspace::release()
{
    WindowManagementPolicy::instance()->releaseWorkspace(m_workspace);
    deleteLater();
}

bool Workspace::isAssigned() const
{
    return m_model != nullptr;
}

WorkspaceProxy::WorkspaceProxy(Workspace * const workspace)
    : Workspace(*workspace)
    , m_original(workspace)
{
}

void WorkspaceProxy::assign(WorkspaceModel *model, const QVariant &index)
{
    Workspace::assign(model, index);
}

void WorkspaceProxy::unassign()
{
    Workspace::unassign();
}

bool WorkspaceProxy::isActive() const
{
    return m_original ? m_original->isActive() : false;
}

void WorkspaceProxy::activate()
{
    if (m_original) m_original->activate();
}
