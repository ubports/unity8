/*
 * Copyright 2013-2016 Canonical Ltd.
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
    , m_reentryGuard(false)
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
        updateOtherActions();
        Q_EMIT menuChanged();

        if (wasValid != valid())
            Q_EMIT validChanged();
    }
}

QString ModelActionRootState::secondaryAction() const
{
    return m_secondaryAction;
}

QString ModelActionRootState::scrollAction() const
{
    return m_scrollAction;
}

QString ModelActionRootState::submenuAction() const
{
    return m_submenuAction;
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
        updateOtherActions();
    }
}

void ModelActionRootState::onModelRowsRemoved(const QModelIndex& parent, int start, int end)
{
    Q_UNUSED(parent);
    if (start == 0 && end >= 0) {
        updateActionState();
        updateOtherActions();
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
        updateOtherActions();
    }
}

void ModelActionRootState::reset()
{
    m_menu = nullptr;

    Q_EMIT menuChanged();
    setCurrentState(QVariantMap());

    updateOtherActions();
}

void ModelActionRootState::updateActionState()
{
    if (m_reentryGuard) return;
    m_reentryGuard = true;

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

    m_reentryGuard = false;
}

void ModelActionRootState::updateOtherActions()
{
    if (m_reentryGuard) return;
    m_reentryGuard = true;

    if (m_menu && m_menu->rowCount() > 0) {
        QVariantMap map;
        map[QStringLiteral("submenu-action")] = QStringLiteral("string");
        map[QStringLiteral("x-canonical-scroll-action")] = QStringLiteral("string");
        map[QStringLiteral("x-canonical-secondary-action")] = QStringLiteral("string");
        m_menu->loadExtendedAttributes(0, map);
        QVariantMap extMap = m_menu->get(0, "ext").toMap();

        QString secondaryAction = extMap.value(QStringLiteral("xCanonicalSecondaryAction")).toString();
        if (m_secondaryAction != secondaryAction) {
            m_secondaryAction = secondaryAction;
            Q_EMIT secondaryActionChanged();
        }

        QString scrollAction = extMap.value(QStringLiteral("xCanonicalScrollAction")).toString();
        if (m_scrollAction != scrollAction) {
            m_scrollAction = scrollAction;
            Q_EMIT scrollActionChanged();
        }

        QString submenuAction = extMap.value(QStringLiteral("submenuAction")).toString();
        if (m_submenuAction != submenuAction) {
            m_submenuAction = submenuAction;
            Q_EMIT submenuActionChanged();
        }
    } else {
        if (!m_secondaryAction.isEmpty()) {
            m_secondaryAction.clear();
            Q_EMIT secondaryActionChanged();
        }
        if (!m_scrollAction.isEmpty()) {
            m_scrollAction.clear();
            Q_EMIT scrollActionChanged();
        }
        if (!m_submenuAction.isEmpty()) {
            m_submenuAction.clear();
            Q_EMIT submenuActionChanged();
        }
    }

    m_reentryGuard = false;
}
