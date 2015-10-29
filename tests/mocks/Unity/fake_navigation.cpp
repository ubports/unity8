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

#include "fake_navigation.h"

#include "fake_scope.h"

#include <QDebug>
#include <QTimer>

Navigation::Navigation(const QString& navigationId, const QString& label, const QString& allLabel, const QString& parentId, const QString& parentLabel, Scope* scope)
 : m_navigationId(navigationId)
 , m_label(label)
 , m_allLabel(allLabel)
 , m_parentId(parentId)
 , m_parentLabel(parentLabel)
 , m_loaded(false)
 , m_scope(scope)
{
    QTimer::singleShot(1500, this, &Navigation::slotLoaded);
    connect(scope, &Scope::currentNavigationIdChanged, this, &Navigation::slotCurrentNavigationChanged);
}

QString Navigation::navigationId() const
{
    return m_navigationId;
}

QString Navigation::label() const
{
    return m_label;
}

QString Navigation::allLabel() const
{
    return m_allLabel;
}

QString Navigation::parentNavigationId() const
{
    return m_parentId;
}

QString Navigation::parentLabel() const
{
    return m_parentLabel;
}

void Navigation::slotLoaded()
{
    m_loaded = true;
    Q_EMIT loadedChanged();
}

bool Navigation::loaded() const
{
    return m_loaded;
}

int Navigation::count() const
{
    return rowCount();
}

bool Navigation::isRoot() const
{
    return m_navigationId == "root";
}

bool Navigation::hidden() const
{
    return false;
}

int Navigation::rowCount(const QModelIndex & /*parent*/) const
{
    if (!m_loaded ||(m_navigationId.startsWith("child") && !m_navigationId.startsWith("childmiddle4")) || m_navigationId == "middle3")
        return 0;
    else
        return 8;
}

QVariant Navigation::data(const QModelIndex &index, int role) const
{
    switch (role) {
        case RoleNavigationId:
            if (m_navigationId == "root")
                return QString("middle%1").arg(index.row());
            else if (m_navigationId.startsWith("middle"))
                return QString("child%1%2").arg(m_navigationId).arg(index.row());
            else if (m_navigationId.startsWith("childmiddle"))
                return QString("grandchild%1%2").arg(m_navigationId).arg(index.row());
        case RoleLabel:
            return QString("%1Child%2").arg(m_navigationId).arg(index.row());
        case RoleAllLabel:
            return QString("all%1Child%2").arg(m_navigationId).arg(index.row());
        case RoleHasChildren:
            return (m_navigationId == "root" && index.row() != 3) || (m_navigationId == "middle4");
        case RoleIsActive:
            return m_scope->currentNavigationId() == data(index, RoleNavigationId);
    }
    return QVariant();
}

void Navigation::slotCurrentNavigationChanged()
{
    // This is wasteful, should only emit it if really something changed in this
    // deparment, but this is a mock, so no need to optimize
    Q_EMIT dataChanged(index(0, 0), index(rowCount() - 1, 0), QVector<int>() << RoleIsActive);
}
