/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Pawel Stolowski <pawel.stolowski@canonical.com>
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

#include "genericlistmodel.h"

GenericListModel::GenericListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

QVariant GenericListModel::data(const QModelIndex& index, int /* role */) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    QObject* item = m_list.at(index.row());
    return QVariant::fromValue(item);
}

int GenericListModel::rowCount(const QModelIndex& /* parent */) const
{
    return m_list.count();
}

void GenericListModel::addObject(QObject *option)
{
    int index = m_list.count();
    beginInsertRows(QModelIndex(), index, index);
    m_list.insert(index, option);
    endInsertRows();
}

QList<QObject *>::Iterator GenericListModel::optionsBegin()
{
    return m_list.begin();
}

QList<QObject *>::Iterator GenericListModel::optionsEnd()
{
    return m_list.end();
}
