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
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "quicklistmodel.h"

QuickListModel::QuickListModel(QObject *parent) :
    QuickListModelInterface(parent)
{

}

QuickListModel::~QuickListModel()
{

}

void QuickListModel::appendAction(const QuickListEntry &entry)
{
    beginInsertRows(QModelIndex(), m_list.count() - 1, m_list.count() -1);
    m_list.append(entry);
    endInsertRows();
}

QuickListEntry QuickListModel::get(int index) const
{
    return m_list.at(index);
}

int QuickListModel::rowCount(const QModelIndex &index) const
{
    Q_UNUSED(index)
    return m_list.count();
}

QVariant QuickListModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleLabel:
        return m_list.at(index.row()).text();
    case RoleIcon:
        return m_list.at(index.row()).icon();
    }
    return QVariant();
}
