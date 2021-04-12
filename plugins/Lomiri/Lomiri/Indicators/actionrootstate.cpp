/*
 * Copyright 2014 Canonical Ltd.
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
 */

#include "actionrootstate.h"

#include <qdbusactiongroup.h>
#include <QDebug>

ActionRootState::ActionRootState(QObject *parent)
    : RootStateObject(parent)
    , m_actionGroup(nullptr)
{
}

QDBusActionGroup *ActionRootState::actionGroup() const
{
    return m_actionGroup;
}

void ActionRootState::setActionGroup(QDBusActionGroup *actionGroup)
{
    if (m_actionGroup != actionGroup) {
        bool wasValid = valid();

        if (m_actionGroup) {
            disconnect(m_actionGroup, 0, this, 0);
        }
        m_actionGroup = actionGroup;

        if (m_actionGroup) {
            connect(m_actionGroup, &QDBusActionGroup::statusChanged, this, [&](bool) { updateActionState(); });
            connect(m_actionGroup, &QDBusActionGroup::actionAppear, this, [&](const QString&) { updateActionState(); });
            connect(m_actionGroup, &QDBusActionGroup::actionVanish, this, [&](const QString&) { updateActionState(); });
            connect(m_actionGroup, &QDBusActionGroup::actionStateChanged, this, [&](const QVariant&) { updateActionState(); });

            connect(m_actionGroup, &QObject::destroyed, this, [&](QObject*) { updateActionState(); });
        }
        updateActionState();
        Q_EMIT actionGroupChanged();

        if (wasValid != valid()) Q_EMIT validChanged();
    }
}

QString ActionRootState::actionName() const
{
    return m_actionName;
}

void ActionRootState::setActionName(const QString &actionName)
{
    if (m_actionName != actionName) {
        bool wasValid = valid();

        m_actionName = actionName;
        updateActionState();

        Q_EMIT actionNameChanged();

        if (wasValid != valid()) Q_EMIT validChanged();
    }
}

bool ActionRootState::valid() const
{
    return m_actionGroup && m_actionGroup->status() == DBusEnums::Connected &&
           !m_actionName.isEmpty() && m_actionGroup->hasAction(m_actionName);
}

void ActionRootState::updateActionState()
{
    if (valid()) {
        ActionStateParser* oldParser = m_actionGroup->actionStateParser();
        m_actionGroup->setActionStateParser(&m_parser);

        QVariantMap state = m_actionGroup->actionState(m_actionName).toMap();

        m_actionGroup->setActionStateParser(oldParser);

        setCurrentState(state);
    } else {
        setCurrentState(QVariantMap());
    }
}
