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
    , m_model(nullptr)
    , m_windowModel(new TopLevelWindowModel)
    , m_active(false)
{
    connect(WorkspaceManager::instance(), &WorkspaceManager::activeWorkspaceChanged, this, [this]() {
        bool newActive = WorkspaceManager::instance()->activeWorkspace() == this;
        if (newActive != m_active) {
            m_active = newActive;
            Q_EMIT activeChanged(m_active);
        }
    });
    connect(this, &Workspace::activeChanged, m_windowModel.data(), &TopLevelWindowModel::setActive);
}

Workspace::~Workspace()
{
    unassign();
}

void Workspace::assign(WorkspaceModel *model)
{
    if (m_model == model) return;

    if (m_model) {
        disconnect(model);
        m_model->remove(this);
    }

    m_model = model ? model : WorkspaceManager::instance();

    if (m_model) {
        m_model->append(this);

        connect(m_model, &QObject::destroyed, this, [this]() {
            m_model->remove(this);
            m_model = nullptr;
        });
        Q_EMIT assigned();
    }
}

void Workspace::activate()
{
    WorkspaceManager::instance()->setActiveWorkspace(this);
}

void Workspace::unassign()
{
    assign(nullptr);
}

TopLevelWindowModel *Workspace::windowModel() const
{
    return m_windowModel.data();
}
