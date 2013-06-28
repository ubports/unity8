/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michał Sawicz <michal.sawicz@canonical.com>
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

// self
#include "categoryresults.h"

CategoryResults::CategoryResults(QObject* parent)
    : DeeListModel(parent)
    , m_category_index(-1)
{
    m_roles[CategoryResults::RoleUri] = "uri";
    m_roles[CategoryResults::RoleIconHint] = "icon";
    m_roles[CategoryResults::RoleMimetype] = "mimetype";
    m_roles[CategoryResults::RoleTitle] = "title";
    m_roles[CategoryResults::RoleComment] = "comment";
    m_roles[CategoryResults::RoleDndUri] = "dnd_uri";
}

CategoryResults::~CategoryResults()
{
}

int CategoryResults::categoryIndex() const
{
    return m_category_index;
}

void CategoryResults::setCategoryIndex(int index)
{
    if (m_category_index != index) {
        m_category_index = index;
        Q_EMIT categoryIndexChanged(m_category_index);
    }
}

QHash<int, QByteArray>
CategoryResults::roleNames() const
{
    return m_roles;
}

QVariant
CategoryResults::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
        case RoleUri:
            return DeeListModel::data(index, 0);
        case RoleIconHint:
            return DeeListModel::data(index, 1);
        case RoleMimetype:
            return DeeListModel::data(index, 4);
        case RoleTitle:
            return DeeListModel::data(index, 5);
        case RoleComment:
            return DeeListModel::data(index, 6);
        case RoleDndUri:
            return DeeListModel::data(index, 7);
        default:
            return QVariant();
    }
}
