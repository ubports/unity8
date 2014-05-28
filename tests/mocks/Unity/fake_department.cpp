/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "fake_department.h"

#include "fake_scope.h"

#include <QTimer>

Department::Department(const QString& departmentId, const QString& label, const QString& allLabel, const QString& parentId, const QString& parentLabel, Scope* scope)
 : QAbstractListModel()
 , m_departmentId(departmentId)
 , m_label(label)
 , m_allLabel(allLabel)
 , m_parentId(parentId)
 , m_parentLabel(parentLabel)
 , m_loaded(false)
 , m_scope(scope)
{
    QTimer::singleShot(1500, this, SLOT(slotLoaded()));
    connect(scope, SIGNAL(currentDepartmentChanged(QString)), this, SLOT(slotCurrentDepartmentChanged()));
}

QString Department::departmentId() const
{
    return m_departmentId;
}

QString Department::label() const
{
    return m_label;
}

QString Department::allLabel() const
{
    return m_allLabel;
}

QString Department::parentId() const
{
    return m_parentId;
}

QString Department::parentLabel() const
{
    return m_parentLabel;
}

void Department::slotLoaded()
{
    m_loaded = true;
    Q_EMIT loadedChanged(m_loaded);
}

bool Department::loaded() const
{
    return m_loaded;
}

int Department::count() const
{
    return rowCount();
}

bool Department::isRoot() const
{
    return m_departmentId == "root";
}

int Department::rowCount(const QModelIndex & /*parent*/) const
{
    if (m_departmentId.startsWith("child"))
        return 0;
    else
        return 8;
}

QHash<int, QByteArray> Department::roleNames() const
{
    QHash<int, QByteArray> res;
    res[RoleDepartmentId] = "departmentId";
    res[RoleLabel] = "label";
    res[RoleHasChildren] = "hasChildren";
    res[RoleIsActive] = "isActive";
    return res;
}

QVariant Department::data(const QModelIndex &index, int role) const
{
    switch (role) {
        case RoleDepartmentId:
            if (m_departmentId == "root")
                return QString("middle%1").arg(index.row());
            else if (m_departmentId.startsWith("middle"))
                return QString("child%1%2").arg(m_departmentId).arg(index.row());
            break;
        case RoleLabel:
            return QString("%1Child%2").arg(m_departmentId).arg(index.row());
            break;
        case RoleHasChildren:
            return m_departmentId == "root";
            break;
        case RoleIsActive:
            return m_scope->currentDepartment() == data(index, RoleDepartmentId);
            break;
    }
    return QVariant();
}

void Department::slotCurrentDepartmentChanged()
{
    // This is wasteful, should only emit it if really something changed in this
    // deparment, but this is a mock, so no need to optimize
    Q_EMIT dataChanged(index(0, 0), index(rowCount() - 1, 0), QVector<int>() << RoleIsActive);
}
