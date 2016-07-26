/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef OBJECTLISTMODEL_H
#define OBJECTLISTMODEL_H

// Qt
#include <QAbstractListModel>

#include <QDebug>

template<class TYPE>
class ObjectListModel : public QAbstractListModel
{
public:
    ObjectListModel(QObject *parent = 0)
    : QAbstractListModel(parent)
    {}

    enum Roles {
        RoleModelData = Qt::UserRole,
    };

    const QList<TYPE*>& list() const { return m_items; }
    bool contains(TYPE* item) const { return m_items.contains(item); }

    void insert(uint index, TYPE* item)
    {
        index = qMin(index, (uint)m_items.count());

        int existingIndex = m_items.indexOf(item);
        if (existingIndex != -1) {
            move(existingIndex, qMin(index, (uint)(m_items.count()-1)));
        } else {
            beginInsertRows(QModelIndex(), index, index);
            m_items.insert(index, item);
            endInsertRows();
        }
    }

    void remove(TYPE* item)
    {
        int existingIndex = m_items.indexOf(item);
        if (existingIndex != -1) {
            beginRemoveRows(QModelIndex(), existingIndex, existingIndex);
            m_items.removeAt(existingIndex);
            endRemoveRows();
        }
    }

    // from QAbstractItemModel
    int rowCount(const QModelIndex& = QModelIndex()) const override
    {
        return m_items.count();
    }

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override
    {
        if (index.row() >= 0 && index.row() < m_items.count()) {
            if (role == RoleModelData) {
                TYPE *item = m_items.at(index.row());
                return QVariant::fromValue(item);
            }
        }
        return QVariant();
    }

    QHash<int, QByteArray> roleNames() const override
    {
        QHash<int, QByteArray> roleNames;
        roleNames.insert(RoleModelData, "modelData");
        return roleNames;
    }

protected:
    void move(int from, int to)
    {
        if (from == to) return;

        if (from >= 0 && from < m_items.size() && to >= 0 && to < m_items.size()) {
            QModelIndex parent;
            /* When moving an item down, the destination index needs to be incremented
               by one, as explained in the documentation:
               http://qt-project.org/doc/qt-5.0/qtcore/qabstractitemmodel.html#beginMoveRows */

            beginMoveRows(parent, from, from, parent, to + (to > from ? 1 : 0));
            m_items.move(from, to);
            endMoveRows();
        }
    }

    QList<TYPE*> m_items;
};

#endif // OBJECTLISTMODEL_H
