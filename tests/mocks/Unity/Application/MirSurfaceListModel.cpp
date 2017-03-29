/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
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

#include "MirSurfaceListModel.h"
#include "ApplicationInfo.h"

#include <unity/shell/application/MirSurfaceInterface.h>

#define MIRSURFACELISTMODEL_DEBUG 0

#if MIRSURFACELISTMODEL_DEBUG
#include <QDebug>
#define DEBUG_MSG(params) qDebug().nospace() << "MirSurfaceListModel::" << __func__  <<  params
#else
#define DEBUG_MSG(params) ((void)0)
#endif

using namespace unity::shell::application;

MirSurfaceListModel::MirSurfaceListModel(QObject *parent) :
    MirSurfaceListInterface(parent)
{
}

int MirSurfaceListModel::rowCount(const QModelIndex &parent) const
{
    return !parent.isValid() ? m_surfaceList.size() : 0;
}

QVariant MirSurfaceListModel::data(const QModelIndex& index, int role) const
{
    if (index.row() < 0 || index.row() >= m_surfaceList.size())
        return QVariant();

    if (role == SurfaceRole) {
        MirSurfaceInterface *surface = m_surfaceList.at(index.row());
        return QVariant::fromValue(static_cast<unity::shell::application::MirSurfaceInterface*>(surface));
    } else {
        return QVariant();
    }
}

void MirSurfaceListModel::raise(MirSurfaceInterface *surface)
{
    DEBUG_MSG("(" << surface << ")");
    int i = m_surfaceList.indexOf(surface);
    if (i != -1) {
        moveSurface(i, 0);
    }
}

void MirSurfaceListModel::addSurface(MirSurfaceInterface *surface)
{
    DEBUG_MSG("(" << surface << ")");
    beginInsertRows(QModelIndex(), 0, 0);
    m_surfaceList.prepend(surface);
    connectSurface(surface);
    endInsertRows();
    Q_EMIT countChanged(m_surfaceList.count());
    Q_EMIT firstChanged();
}

void MirSurfaceListModel::connectSurface(MirSurfaceInterface *surface)
{
    connect(surface, &QObject::destroyed, this, [this, surface](){ this->removeSurface(surface); });
    connect(surface, &MirSurfaceInterface::focusedChanged, this, [this, surface](bool surfaceFocused){
        if (surfaceFocused) {
            raise(surface);
        }
    });
}

void MirSurfaceListModel::removeSurface(MirSurfaceInterface *surface)
{
    int i = m_surfaceList.indexOf(surface);
    if (i != -1) {
        beginRemoveRows(QModelIndex(), i, i);
        m_surfaceList.removeAt(i);
        endRemoveRows();
        Q_EMIT countChanged(m_surfaceList.count());
        if (m_surfaceList.count() == 0 || i == 0) {
            Q_EMIT firstChanged();
        }
    }
}

void MirSurfaceListModel::moveSurface(int from, int to)
{
    if (from == to) return;

    if (from >= 0 && from < m_surfaceList.size() && to >= 0 && to < m_surfaceList.size()) {
        QModelIndex parent;
        /* When moving an item down, the destination index needs to be incremented
           by one, as explained in the documentation:
           http://qt-project.org/doc/qt-5.0/qtcore/qabstractitemmodel.html#beginMoveRows */

        beginMoveRows(parent, from, from, parent, to + (to > from ? 1 : 0));
        m_surfaceList.move(from, to);
        endMoveRows();
    }

    if ((from == 0 || to == 0) && m_surfaceList.count() > 1) {
        Q_EMIT firstChanged();
    }
}

MirSurfaceInterface *MirSurfaceListModel::get(int index)
{
    if (index >=0 && index < m_surfaceList.count()) {
        return m_surfaceList[index];
    } else {
        return nullptr;
    }
}

const MirSurfaceInterface *MirSurfaceListModel::get(int index) const
{
    if (index >=0 && index < m_surfaceList.count()) {
        return m_surfaceList.at(index);
    } else {
        return nullptr;
    }
}
