/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include "WorkspaceModel.h"
#include "WorkspaceManager.h"
#include "Workspace.h"
#include "Screen.h"

#include <QQmlEngine>

Q_LOGGING_CATEGORY(WORKSPACES, "Workspaces", QtInfoMsg)

#define DEBUG_MSG qCDebug(WORKSPACES).nospace().noquote() << __func__
#define INFO_MSG qCInfo(WORKSPACES).nospace().noquote() << __func__

WorkspaceModel::WorkspaceModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

WorkspaceModel::~WorkspaceModel()
{
    qDeleteAll(m_workspaces.toList()); // make a copy so the list doesnt edit itself during delete.
    m_workspaces.clear();
}

void WorkspaceModel::append(Workspace *workspace)
{
    insert(m_workspaces.count(), workspace);
}

void WorkspaceModel::insert(int index, Workspace *workspace)
{
    beginInsertRows(QModelIndex(), index, index);

    m_workspaces.insert(index, workspace);

    endInsertRows();

    Q_EMIT workspaceInserted(index, workspace);
    Q_EMIT countChanged();
}

void WorkspaceModel::remove(Workspace *workspace)
{
    int index = m_workspaces.indexOf(workspace);
    if (index < 0) return;

    beginRemoveRows(QModelIndex(), index, index);

    m_workspaces.removeAt(index);
    insertUnassigned(workspace);

    endRemoveRows();

    Q_EMIT workspaceRemoved(workspace);
    Q_EMIT countChanged();
}

void WorkspaceModel::move(int from, int to)
{
    if (from == to) return;
    DEBUG_MSG << " from=" << from << " to=" << to;

    if (from >= 0 && from < m_workspaces.size() && to >= 0 && to < m_workspaces.size()) {
        QModelIndex parent;

        beginMoveRows(parent, from, from, parent, to + (to > from ? 1 : 0));
#if QT_VERSION < QT_VERSION_CHECK(5, 6, 0)
        const auto &window = m_windowModel.takeAt(from);
        m_workspaces.insert(to, window);
#else
        m_workspaces.move(from, to);
#endif
        endMoveRows();

        Q_EMIT workspaceMoved(from, to);
    }
}

int WorkspaceModel::indexOf(Workspace *workspace) const
{
    return m_workspaces.indexOf(workspace);
}

Workspace *WorkspaceModel::get(int index) const
{
    if (index < 0 || index >= rowCount()) return nullptr;
    return m_workspaces.at(index);
}

int WorkspaceModel::rowCount(const QModelIndex &) const
{
    return m_workspaces.count();
}

QVariant WorkspaceModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_workspaces.size())
        return QVariant();

    if (role == WorkspaceRole) {
        Workspace *workspace = m_workspaces.at(index.row());
        return QVariant::fromValue(workspace);
    } else {
        return QVariant();
    }
}

void WorkspaceModel::sync(WorkspaceModel *proxy)
{
    if (!proxy) return;
    const auto& proxyList = proxy->list();

    // check for removals
    int removedIndexWhichWasActive = -1;
    QVector<Workspace*> dpCpy(this->list());
    Q_FOREACH(auto workspace, dpCpy) {

        bool found = false;
        Q_FOREACH(auto p, proxyList) {
            auto workspaceProxy = qobject_cast<ProxyWorkspace*>(p);
            if (workspaceProxy->proxyObject() == workspace) {
                found = true;
                break;
            }
        }
        if (!found) {
            if (workspace->isActive()) {
                removedIndexWhichWasActive = indexOf(workspace);
            }
            workspace->unassign();
        }
    }

    // existing
    QSet<Workspace*> newWorkspaces;
    for (int i = 0; i < proxyList.count(); i++) {
        auto workspaceProxy = qobject_cast<ProxyWorkspace*>(proxyList[i]);
        auto workspace = workspaceProxy->proxyObject();

        int oldIndex = this->indexOf(workspace);

        if (oldIndex < 0) {
            workspace->assign(this, QVariant(i));
        } else if (oldIndex != i) {
            this->move(oldIndex, i);
        }
        newWorkspaces.insert(workspace);
    }

    // Make sure we have at least one workspace in the model.
    if (rowCount() == 0) {
        Workspace* workspace = WorkspaceManager::instance()->createWorkspace();
        workspace->assign(this);
        (new ProxyWorkspace(workspace))->assign(proxy);
    }

    if (removedIndexWhichWasActive != -1) {
        int newActiveIndex = qMin(removedIndexWhichWasActive, this->rowCount()-1);
        Workspace* newActiveWorkspace = newActiveIndex >= 0 ? this->get(newActiveIndex) : nullptr;

        WorkspaceManager::instance()->setActiveWorkspace(newActiveWorkspace);
    }

    proxy->finishSync();
    finishSync();
}

void WorkspaceModel::finishSync()
{
    QSet<Workspace*> dpCpy(m_unassignedWorkspaces);
    Q_FOREACH(auto workspace, dpCpy) {
        delete workspace;
    }
    m_unassignedWorkspaces.clear();
}

void WorkspaceModel::insertUnassigned(Workspace *workspace)
{
    m_unassignedWorkspaces.insert(workspace);
    connect(workspace, &Workspace::assigned, this, [=]() {
        m_unassignedWorkspaces.remove(workspace);
        disconnect(workspace, &Workspace::assigned, this, 0);
    });
    connect(workspace, &QObject::destroyed, this, [=]() {
        m_unassignedWorkspaces.remove(workspace);
    });
}


ProxyWorkspaceModel::ProxyWorkspaceModel(WorkspaceModel * const model, ProxyScreen* screen)
    : m_original(model)
    , m_screen(screen)
{
    Q_FOREACH(auto workspace, model->list()) {
        auto proxy = new ProxyWorkspace(workspace);
        QQmlEngine::setObjectOwnership(proxy, QQmlEngine::CppOwnership);
        proxy->assign(this);
    }
    connect(m_original, &WorkspaceModel::workspaceInserted, this, [this](int index, Workspace* inserted) {
        if (isSyncing()) return;

        (new ProxyWorkspace(inserted))->assign(this, index);
    });
    connect(m_original, &WorkspaceModel::workspaceRemoved, this, [this](Workspace* removed) {
        if (isSyncing()) return;

        for (int i = 0; i < rowCount(); i++) {
            auto workspaceProxy = qobject_cast<ProxyWorkspace*>(get(i));
            auto w = workspaceProxy->proxyObject();
            if (w == removed) {
                remove(workspaceProxy);
                break;
            }
        }
    });
    connect(m_original, &WorkspaceModel::workspaceMoved, this, [this](int from, int to) {
        if (isSyncing()) return;

        move(from, to);
    });
}

void ProxyWorkspaceModel::move(int from, int to)
{
    WorkspaceModel::move(from, to);
}

bool ProxyWorkspaceModel::isSyncing() const
{
    return m_screen->isSyncing();
}

void ProxyWorkspaceModel::addWorkspace()
{
    auto newWorkspace = WorkspaceManager::instance()->createWorkspace();
    m_original->insertUnassigned(newWorkspace);

    (new ProxyWorkspace(newWorkspace))->assign(this);
}
