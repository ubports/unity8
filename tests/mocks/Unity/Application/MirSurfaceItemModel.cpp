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

#include <QQmlEngine>

// local
#include "MirSurfaceItemModel.h"
#include "MirSurfaceItem.h"

MirSurfaceItemModel::MirSurfaceItemModel(
        QObject *parent)
    : QAbstractListModel(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

void MirSurfaceItemModel::insertSurface(uint index, MirSurfaceItem* surface)
{
    index = qMin(index, (uint)count());

    int existingSurfaceIndex = m_surfaceItems.indexOf(surface);
    if (existingSurfaceIndex != -1) {
        move(existingSurfaceIndex, index);
    } else {
        beginInsertRows(QModelIndex(), index, index);
        m_surfaceItems.insert(index, surface);
        endInsertRows();
        Q_EMIT countChanged();
    }
}

void MirSurfaceItemModel::removeSurface(MirSurfaceItem* surface)
{
    int existingSurfaceIndex = m_surfaceItems.indexOf(surface);
    if (existingSurfaceIndex != -1) {
        beginRemoveRows(QModelIndex(), existingSurfaceIndex, existingSurfaceIndex);
        m_surfaceItems.removeAt(existingSurfaceIndex);
        endRemoveRows();
        Q_EMIT countChanged();
    }
}

void MirSurfaceItemModel::move(int from, int to)
{
    if (from == to) return;

    if (from >= 0 && from < m_surfaceItems.size() && to >= 0 && to < m_surfaceItems.size()) {
        QModelIndex parent;
        /* When moving an item down, the destination index needs to be incremented
           by one, as explained in the documentation:
           http://qt-project.org/doc/qt-5.0/qtcore/qabstractitemmodel.html#beginMoveRows */

        beginMoveRows(parent, from, from, parent, to + (to > from ? 1 : 0));
        m_surfaceItems.move(from, to);
        endMoveRows();
    }
}

QHash<int, QByteArray> MirSurfaceItemModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames.insert(RoleSurface, "surface");
    return roleNames;
}

int MirSurfaceItemModel::rowCount(const QModelIndex & /*parent*/) const
{
    return m_surfaceItems.count();
}

QVariant MirSurfaceItemModel::data(const QModelIndex & index, int role) const
{
    if (index.row() >= 0 && index.row() < m_surfaceItems.count()) {
        MirSurfaceItem *surfaceItem = m_surfaceItems.at(index.row());
        switch (role) {
            case RoleSurface:
                return QVariant::fromValue(surfaceItem);
            default:
                return QVariant();
        }
    } else {
        return QVariant();
    }
}

MirSurfaceItem* MirSurfaceItemModel::getSurface(int index)
{
    return m_surfaceItems[index];
}
