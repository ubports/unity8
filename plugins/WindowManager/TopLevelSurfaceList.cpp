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

#include "TopLevelSurfaceList.h"

// unity-api
#include <unity/shell/application/ApplicationInfoInterface.h>
#include <unity/shell/application/MirSurfaceInterface.h>
#include <unity/shell/application/MirSurfaceListInterface.h>

#include <QMetaObject>

Q_LOGGING_CATEGORY(UNITY_TOPSURFACELIST, "unity.topsurfacelist", QtDebugMsg)

#define DEBUG_MSG qCDebug(UNITY_TOPSURFACELIST).nospace().noquote() << __func__

using namespace unity::shell::application;

TopLevelSurfaceList::TopLevelSurfaceList(QObject *parent) :
    QAbstractListModel(parent)
{
    DEBUG_MSG << "()";
}

TopLevelSurfaceList::~TopLevelSurfaceList()
{
    DEBUG_MSG << "()";
}

int TopLevelSurfaceList::rowCount(const QModelIndex &parent) const
{
    return !parent.isValid() ? m_surfaceList.size() : 0;
}

QVariant TopLevelSurfaceList::data(const QModelIndex& index, int role) const
{
    if (index.row() < 0 || index.row() >= m_surfaceList.size())
        return QVariant();

    if (role == SurfaceRole) {
        MirSurfaceInterface *surface = m_surfaceList.at(index.row()).surface;
        return QVariant::fromValue(surface);
    } else if (role == ApplicationRole) {
        return QVariant::fromValue(m_surfaceList.at(index.row()).application);
    } else if (role == IdRole) {
        return QVariant::fromValue(m_surfaceList.at(index.row()).id);
    } else {
        return QVariant();
    }
}

void TopLevelSurfaceList::raise(MirSurfaceInterface *surface)
{
    if (!surface)
        return;

    DEBUG_MSG << "(MirSurface[" << (void*)surface << "])";

    int i = indexOf(surface);
    if (i != -1) {
        raiseId(m_surfaceList.at(i).id);
    }
}

void TopLevelSurfaceList::appendPlaceholder(ApplicationInfoInterface *application)
{
    DEBUG_MSG << "(" << application->appId() << ")";

    appendSurfaceHelper(nullptr, application);
}

void TopLevelSurfaceList::appendSurface(MirSurfaceInterface *surface, ApplicationInfoInterface *application)
{
    Q_ASSERT(surface != nullptr);

    bool filledPlaceholder = false;
    for (int i = 0; i < m_surfaceList.count() && !filledPlaceholder; ++i) {
        ModelEntry &entry = m_surfaceList[i];
        if (entry.application == application && entry.surface == nullptr) {
            entry.surface = surface;
            connectSurface(surface);
            DEBUG_MSG << " appId=" << application->appId() << " surface=" << surface
                      << ", filling out placeholder. after: " << toString();
            Q_EMIT dataChanged(index(i) /* topLeft */, index(i) /* bottomRight */, QVector<int>() << SurfaceRole);
            filledPlaceholder = true;
        }
    }

    if (!filledPlaceholder) {
        DEBUG_MSG << " appId=" << application->appId() << " surface=" << surface << ", adding new row";
        appendSurfaceHelper(surface, application);
    }
}

void TopLevelSurfaceList::appendSurfaceHelper(MirSurfaceInterface *surface, ApplicationInfoInterface *application)
{
    if (m_modelState == IdleState) {
        m_modelState = InsertingState;
        beginInsertRows(QModelIndex(), m_surfaceList.size() /*first*/, m_surfaceList.size() /*last*/);
    } else {
        Q_ASSERT(m_modelState == ResettingState);
        // No point in signaling anything if we're resetting the whole model
    }

    int id = generateId();
    m_surfaceList.append(ModelEntry(surface, application, id));
    if (surface) {
        connectSurface(surface);
    }

    if (m_modelState == InsertingState) {
        endInsertRows();
        Q_EMIT countChanged();
        Q_EMIT listChanged();
        m_modelState = IdleState;
    }

    DEBUG_MSG << " after " << toString();
}

void TopLevelSurfaceList::connectSurface(MirSurfaceInterface *surface)
{
    connect(surface, &MirSurfaceInterface::focusedChanged, this, [this, surface](bool focused){
            if (focused) {
//                this->raise(surface);
            }
        });
    connect(surface, &MirSurfaceInterface::liveChanged, this, [this, surface](bool live){
            if (!live) {
                onSurfaceDied(surface);
            }
        });
    connect(surface, &QObject::destroyed, this, [this, surface](){ this->onSurfaceDestroyed(surface); });
}

void TopLevelSurfaceList::onSurfaceDied(MirSurfaceInterface *surface)
{
    int i = indexOf(surface);
    if (i == -1) {
        return;
    }

    auto application = m_surfaceList[i].application;

    // can't be starting if it already has a surface
    Q_ASSERT(application->state() != ApplicationInfoInterface::Starting);

    if (application->state() == ApplicationInfoInterface::Running) {
        m_surfaceList[i].removeOnceSurfaceDestroyed = true;
    } else {
        // assume it got killed by the out-of-memory daemon.
        //
        // So leave entry in the model and only remove its surface, so shell can display a screenshot
        // in its place.
        m_surfaceList[i].removeOnceSurfaceDestroyed = false;
    }
}

void TopLevelSurfaceList::onSurfaceDestroyed(MirSurfaceInterface *surface)
{
    int i = indexOf(surface);
    if (i == -1) {
        return;
    }

    if (m_surfaceList[i].removeOnceSurfaceDestroyed) {
        removeAt(i);
    } else {
        m_surfaceList[i].surface = nullptr;
        Q_EMIT dataChanged(index(i) /* topLeft */, index(i) /* bottomRight */, QVector<int>() << SurfaceRole);
        DEBUG_MSG << " Removed surface from entry. After: " << toString();
    }
}

void TopLevelSurfaceList::removeAt(int index)
{
    if (m_modelState == IdleState) {
        beginRemoveRows(QModelIndex(), index, index);
        m_modelState = RemovingState;
    } else {
        Q_ASSERT(m_modelState == ResettingState);
        // No point in signaling anything if we're resetting the whole model
    }

    m_surfaceList.removeAt(index);

    if (m_modelState == RemovingState) {
        endRemoveRows();
        Q_EMIT countChanged();
        Q_EMIT listChanged();
        m_modelState = IdleState;
    }

    DEBUG_MSG << " after " << toString();
}

int TopLevelSurfaceList::indexOf(MirSurfaceInterface *surface)
{
    for (int i = 0; i < m_surfaceList.count(); ++i) {
        if (m_surfaceList.at(i).surface == surface) {
            return i;
        }
    }
    return -1;
}

void TopLevelSurfaceList::move(int from, int to)
{
    if (from == to) return;
    DEBUG_MSG << " from=" << from << " to=" << to;

    if (from >= 0 && from < m_surfaceList.size() && to >= 0 && to < m_surfaceList.size()) {
        QModelIndex parent;
        /* When moving an item down, the destination index needs to be incremented
           by one, as explained in the documentation:
           http://qt-project.org/doc/qt-5.0/qtcore/qabstractitemmodel.html#beginMoveRows */

        Q_ASSERT(m_modelState == IdleState);
        m_modelState = MovingState;

        beginMoveRows(parent, from, from, parent, to + (to > from ? 1 : 0));
        m_surfaceList.move(from, to);
        endMoveRows();
        Q_EMIT listChanged();

        m_modelState = IdleState;

        DEBUG_MSG << " after " << toString();
    }
}

MirSurfaceInterface *TopLevelSurfaceList::surfaceAt(int index) const
{
    if (index >=0 && index < m_surfaceList.count()) {
        return m_surfaceList[index].surface;
    } else {
        return nullptr;
    }
}

ApplicationInfoInterface *TopLevelSurfaceList::applicationAt(int index) const
{
    if (index >=0 && index < m_surfaceList.count()) {
        return m_surfaceList[index].application;
    } else {
        return nullptr;
    }
}

int TopLevelSurfaceList::idAt(int index) const
{
    if (index >=0 && index < m_surfaceList.count()) {
        return m_surfaceList[index].id;
    } else {
        return 0;
    }
}

int TopLevelSurfaceList::indexForId(int id) const
{
    for (int i = 0; i < m_surfaceList.count(); ++i) {
        if (m_surfaceList[i].id == id) {
            return i;
        }
    }
    return -1;
}

void TopLevelSurfaceList::doRaiseId(int id)
{
    int fromIndex = indexForId(id);
    if (fromIndex != -1) {
        move(fromIndex, 0 /* toIndex */);
    }
}

void TopLevelSurfaceList::raiseId(int id)
{
    if (m_modelState == IdleState) {
        DEBUG_MSG << "(id=" << id << ") - do it now.";
        doRaiseId(id);
    } else {
        DEBUG_MSG << "(id=" << id << ") - Model busy (modelState=" << m_modelState << "). Try again in the next event loop.";
        // The model has just signalled some change. If we have a Repeater responding to this update, it will get nuts
        // if we perform yet another model change straight away.
        //
        // A bad sympton of this problem is a Repeater.itemAt(index) call returning null event though Repeater.count says
        // the index is definitely within bounds.
        QMetaObject::invokeMethod(this, "raiseId", Qt::QueuedConnection, Q_ARG(int, id));
    }
}

int TopLevelSurfaceList::generateId()
{
    int id = m_nextId;
    m_nextId = nextFreeId(m_nextId + 1);
    Q_EMIT nextIdChanged();
    return id;
}

int TopLevelSurfaceList::nextFreeId(int candidateId)
{
    if (candidateId > m_maxId) {
        return nextFreeId(1);
    } else {
        if (indexForId(candidateId) == -1) {
            // it's indeed free
            return candidateId;
        } else {
            return nextFreeId(candidateId + 1);
        }
    }
}

QString TopLevelSurfaceList::toString()
{
    QString str;
    for (int i = 0; i < m_surfaceList.count(); ++i) {
        auto item = m_surfaceList.at(i);

        QString itemStr = QString("(index=%1,appId=%2,surface=0x%3,id=%4)")
            .arg(i)
            .arg(item.application->appId())
            .arg((qintptr)item.surface, 0, 16)
            .arg(item.id);

        if (i > 0) {
            str.append(",");
        }
        str.append(itemStr);
    }
    return str;
}

void TopLevelSurfaceList::addApplication(ApplicationInfoInterface *application)
{
    DEBUG_MSG << "(" << application->appId() << ")";
    Q_ASSERT(!m_applications.contains(application));
    m_applications.append(application);

    MirSurfaceListInterface *surfaceList = application->surfaceList();

    if (application->state() != ApplicationInfoInterface::Stopped) {
        if (surfaceList->count() == 0) {
            appendPlaceholder(application);
        } else {
            for (int i = 0; i < surfaceList->count(); ++i) {
                appendSurface(surfaceList->get(i), application);
            }
        }
    }

    connect(surfaceList, &QAbstractItemModel::rowsInserted, this,
            [this, application, surfaceList](const QModelIndex & /*parent*/, int first, int last)
            {
                for (int i = last; i >= first; --i) {
                    this->appendSurface(surfaceList->get(i), application);
                }
            });
}

void TopLevelSurfaceList::removeApplication(ApplicationInfoInterface *application)
{
    DEBUG_MSG << "(" << application->appId() << ")";
    Q_ASSERT(m_applications.contains(application));

    MirSurfaceListInterface *surfaceList = application->surfaceList();

    disconnect(surfaceList, 0, this, 0);

    Q_ASSERT(m_modelState == IdleState);
    m_modelState = RemovingState;

    int i = 0;
    while (i < m_surfaceList.count()) {
        if (m_surfaceList.at(i).application == application) {
            beginRemoveRows(QModelIndex(), i, i);
            m_surfaceList.removeAt(i);
            endRemoveRows();
            Q_EMIT countChanged();
            Q_EMIT listChanged();
        } else {
            ++i;
        }
    }

    m_modelState = IdleState;

    DEBUG_MSG << " after " << toString();

    m_applications.removeAll(application);
}

QAbstractListModel *TopLevelSurfaceList::applicationsModel() const
{
    return m_applicationsModel;
}

void TopLevelSurfaceList::setApplicationsModel(QAbstractListModel* value)
{
    if (m_applicationsModel == value) {
        return;
    }

    DEBUG_MSG << "(" << value << ")";

    Q_ASSERT(m_modelState == IdleState);
    m_modelState = ResettingState;

    beginResetModel();

    if (m_applicationsModel) {
        m_surfaceList.clear();
        m_applications.clear();
        disconnect(m_applicationsModel, 0, this, 0);
    }

    m_applicationsModel = value;

    if (m_applicationsModel) {
        findApplicationRole();

        connect(m_applicationsModel, &QAbstractItemModel::rowsInserted,
                this, [this](const QModelIndex &/*parent*/, int first, int last) {
                    for (int i = first; i <= last; ++i) {
                        auto application = getApplicationFromModelAt(i);
                        addApplication(application);
                    }
                });

        connect(m_applicationsModel, &QAbstractItemModel::rowsAboutToBeRemoved,
                this, [this](const QModelIndex &/*parent*/, int first, int last) {
                    for (int i = first; i <= last; ++i) {
                        auto application = getApplicationFromModelAt(i);
                        removeApplication(application);
                    }
                });

        for (int i = 0; i < m_applicationsModel->rowCount(); ++i) {
            auto application = getApplicationFromModelAt(i);
            addApplication(application);
        }
    }

    endResetModel();
    m_modelState = IdleState;
}

ApplicationInfoInterface *TopLevelSurfaceList::getApplicationFromModelAt(int index)
{
    QModelIndex modelIndex = m_applicationsModel->index(index);

    QVariant variant =  m_applicationsModel->data(modelIndex, m_applicationRole);

    // variant.value<ApplicationInfoInterface*>() returns null for some reason.
    return static_cast<ApplicationInfoInterface*>(variant.value<QObject*>());
}

void TopLevelSurfaceList::findApplicationRole()
{
    QHash<int, QByteArray> namesHash = m_applicationsModel->roleNames();

    m_applicationRole = -1;
    for (auto i = namesHash.begin(); i != namesHash.end() && m_applicationRole == -1; ++i) {
        if (i.value() == "application") {
            m_applicationRole = i.key();
        }
    }

    if (m_applicationRole == -1) {
        qFatal("TopLevelSurfaceList: applicationsModel must have a \"application\" role.");
    }
}
