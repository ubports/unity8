/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "MirSurface.h"

#define MIRSURFACELISTMODEL_DEBUG 0

#ifdef MIRSURFACELISTMODEL_DEBUG
#define DEBUG_MSG(params) qDebug().nospace() << "MirSurfaceListModel::" << __func__  << " " << params
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
        MirSurface *surface = m_surfaceList.at(index.row());
        return QVariant::fromValue(static_cast<unity::shell::application::MirSurfaceInterface*>(surface));
    } else {
        return QVariant();
    }
}

void MirSurfaceListModel::raise(MirSurface *surface)
{
    int i = m_surfaceList.indexOf(surface);
    if (i != -1) {
        moveSurface(i, 0);
    }
}

void MirSurfaceListModel::appendSurface(MirSurface *surface)
{
    beginInsertRows(QModelIndex(), m_surfaceList.size(), m_surfaceList.size());
    m_surfaceList.append(surface);
    connectSurface(surface);
    endInsertRows();
    Q_EMIT countChanged();
    if (m_surfaceList.count() == 1) {
        Q_EMIT firstChanged();
    }
}

void MirSurfaceListModel::connectSurface(MirSurface *surface)
{
    connect(surface, &MirSurface::raiseRequested, this, [this, surface](){ this->raise(surface); });
    connect(surface, &QObject::destroyed, this, [this, surface](){ this->removeSurface(surface); });
}

void MirSurfaceListModel::removeSurface(MirSurface *surface)
{
    int i = m_surfaceList.indexOf(surface);
    if (i != -1) {
        beginRemoveRows(QModelIndex(), i, i);
        m_surfaceList.removeAt(i);
        endRemoveRows();
        Q_EMIT countChanged();
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

MirSurfaceInterface *MirSurfaceListModel::createSurface()
{
    QStringList screenshotIds = {"gallery", "map", "facebook", "camera", "browser", "music", "twitter"};
    int i = rand() % screenshotIds.count();

    QUrl screenshotUrl = QString("qrc:///Unity/Application/screenshots/%1@12.png")
            .arg(screenshotIds[i]);

    auto surface = new MirSurface(QString("prompt foo"),
            Mir::NormalType,
            Mir::RestoredState,
            screenshotUrl);

    appendSurface(surface);

    return surface;
}
