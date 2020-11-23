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
#include "Screen.h"

#include "wmpolicyinterface.h"

int nextWorkspace = 0;

Workspace::Workspace(QObject *parent)
    : QObject(parent)
    , m_workspace(WMPolicyInterface::instance()->createWorkspace())
    , m_model(nullptr)
{
    setObjectName((QString("Wks%1").arg(nextWorkspace++)));
}

Workspace::Workspace(const Workspace &other)
    : QObject(nullptr)
    , m_workspace(other.m_workspace)
    , m_model(nullptr)
{
    setObjectName(other.objectName());

    connect(&other, &Workspace::activeChanged, this, &Workspace::activeChanged);
}

Workspace::~Workspace()
{
    if (m_model) {
        m_model->remove(this);
    }
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

bool Workspace::isAssigned() const
{
    return m_model != nullptr;
}

bool Workspace::isSameAs(Workspace *wks) const
{
    if (!wks) return false;
    if (wks == this) return true;
    return wks->workspace() == workspace();
}


ConcreteWorkspace::ConcreteWorkspace(QObject *parent)
    : Workspace(parent)
    , m_active(false)
    , m_windowModel(new TopLevelWindowModel(this))
{
    connect(WorkspaceManager::instance(), &WorkspaceManager::activeWorkspaceChanged, this, [this](Workspace* activeWorkspace) {
        bool newActive = activeWorkspace == this;
        if (newActive != m_active) {
            m_active = newActive;
            Q_EMIT activeChanged(m_active);

            if (m_active) {
                WMPolicyInterface::instance()->setActiveWorkspace(m_workspace);
            }
        }
    });
}

ConcreteWorkspace::~ConcreteWorkspace()
{
    WorkspaceManager::instance()->destroyWorkspace(this);
    WMPolicyInterface::instance()->releaseWorkspace(m_workspace);
}

TopLevelWindowModel *ConcreteWorkspace::windowModel() const
{
    return m_windowModel.data();
}

void ConcreteWorkspace::activate()
{
    WorkspaceManager::instance()->setActiveWorkspace(this);
}

void ConcreteWorkspace::setCurrentOn(Screen *screen)
{
    if (screen) {
        screen->setCurrentWorkspace(this);
    }
}


ProxyWorkspace::ProxyWorkspace(Workspace * const workspace)
    : Workspace(*workspace)
    , m_original(workspace)
{
}

void ProxyWorkspace::assign(WorkspaceModel *model, const QVariant &index)
{
    Workspace::assign(model, index);
}

void ProxyWorkspace::unassign()
{
    Workspace::unassign();
}

bool ProxyWorkspace::isActive() const
{
    return m_original ? m_original->isActive() : false;
}

TopLevelWindowModel *ProxyWorkspace::windowModel() const
{
    return m_original ? m_original->windowModel() : nullptr;
}

void ProxyWorkspace::activate()
{
    if (m_original) {
        m_original->activate();
    }
}

void ProxyWorkspace::setCurrentOn(Screen *screen)
{
    if (screen && m_original) {
        screen->setCurrentWorkspace(m_original);
    }
}
