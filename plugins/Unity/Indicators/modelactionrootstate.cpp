/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "modelactionrootstate.h"
#include "indicators.h"

#include <unitymenumodel.h>
#include <QVariant>
#include <QIcon>

extern "C" {
#include <glib.h>
#include <gio/gio.h>
}

ModelActionRootState::ModelActionRootState(QObject *parent)
    : RootStateObject(parent),
      m_menu(nullptr)
{
}

ModelActionRootState::~ModelActionRootState()
{
}

UnityMenuModel* ModelActionRootState::menu() const
{
    return m_menu;
}

void ModelActionRootState::setMenu(UnityMenuModel* menu)
{
    if (m_menu != menu) {
        bool wasValid = valid();

        if (m_menu) {
            m_menu->disconnect(this);
        }
        m_menu = menu;

        if (m_menu) {
            connect(m_menu, &UnityMenuModel::rowsInserted, this, &ModelActionRootState::onModelRowsAdded);
            connect(m_menu, &UnityMenuModel::rowsRemoved, this, &ModelActionRootState::onModelRowsRemoved);
            connect(m_menu, &UnityMenuModel::dataChanged, this, &ModelActionRootState::onModelDataChanged);

            connect(m_menu, &UnityMenuModel::destroyed, this, &ModelActionRootState::reset);
        }
        updateActionState();
        Q_EMIT menuChanged();

        if (wasValid != valid())
            Q_EMIT validChanged();
    }
}

bool ModelActionRootState::valid() const
{
    return !currentState().empty();
}

void ModelActionRootState::onModelRowsAdded(const QModelIndex& parent, int start, int end)
{
    Q_UNUSED(parent);
    if (start == 0 && end >= 0) {
        updateActionState();
    }
}

void ModelActionRootState::onModelRowsRemoved(const QModelIndex& parent, int start, int end)
{
    Q_UNUSED(parent);
    if (start == 0 && end >= 0) {
        updateActionState();
    }
}

void ModelActionRootState::onModelDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles)
{
    Q_UNUSED(roles);
    if (!topLeft.isValid() || !bottomRight.isValid()) {
        return;
    }

    if (topLeft.row() <= 0 && bottomRight.row() >= 0) {
        updateActionState();
    }
}

void ModelActionRootState::reset()
{
    m_menu = nullptr;

    Q_EMIT menuChanged();
    setCurrentState(QVariantMap());
}

void ModelActionRootState::updateActionState()
{
    if (m_menu && m_menu->rowCount() > 0) {
        ActionStateParser* oldParser = m_menu->actionStateParser();
        m_menu->setActionStateParser(&m_parser);

        QVariantMap state = m_menu->get(0, "actionState").toMap();

        m_menu->setActionStateParser(oldParser);

        setCurrentState(state);
    } else if (!m_menu) {
        setCurrentState(QVariantMap());
    }
    // else if m_menu->rowCount() == 0, let's leave existing cache in place
    // until the new menu comes in, to avoid flashing the UI empty for a moment
}
