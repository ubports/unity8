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

Workspace::Workspace(QObject *parent)
    : QObject(parent)
    , m_model(nullptr)
{

}

Workspace::~Workspace()
{
    unassign();
}

void Workspace::assign(WorkspaceModel *model)
{
    bool wasAssinged = false;
    if (m_model) {
        disconnect(model);
        m_model->remove(this);
        wasAssinged = true;
    }

    m_model = model;
    if (model) {
        model->append(this);

        connect(model, &QObject::destroyed, this, [this]() {
            m_model = nullptr;
            Q_EMIT unassigned();
        });
        Q_EMIT assigned();
    } else if (wasAssinged) {
        Q_EMIT unassigned();
    }
}

void Workspace::unassign()
{
    if (m_model) {
        m_model->remove(this);
        m_model = nullptr;

        Q_EMIT unassigned();
    }
}
