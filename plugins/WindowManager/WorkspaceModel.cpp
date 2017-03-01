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

Q_LOGGING_CATEGORY(WORKSPACES, "Workspaces", QtInfoMsg)

#define DEBUG_MSG qCDebug(WORKSPACES).nospace().noquote() << __func__
#define INFO_MSG qCInfo(WORKSPACES).nospace().noquote() << __func__

WorkspaceModel::WorkspaceModel(QObject *parent)
    : QAbstractListModel(parent)
{
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

    Q_EMIT workspaceAdded(workspace);
    Q_EMIT countChanged();
}

void WorkspaceModel::remove(Workspace *workspace)
{
    int index = m_workspaces.indexOf(workspace);
    if (index < 0) return;

    beginRemoveRows(QModelIndex(), index, index);

    m_workspaces.removeAt(index);

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
        Q_EMIT countChanged();
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
            auto workspaceProxy = static_cast<WorkspaceProxy*>(p);
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
        auto workspaceProxy = static_cast<WorkspaceProxy*>(proxyList[i]);
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
        (new WorkspaceProxy(workspace))->assign(proxy);
    }

    if (removedIndexWhichWasActive != -1) {
        int newActiveIndex = qMin(removedIndexWhichWasActive, this->rowCount()-1);
        Workspace* newActiveWorkspace = newActiveIndex >= 0 ? this->get(newActiveIndex) : nullptr;

        WorkspaceManager::instance()->setActiveWorkspace(newActiveWorkspace);
    }
}


WorkspaceModelProxy::WorkspaceModelProxy(WorkspaceModel * const model)
    : m_original(model)
{
    Q_FOREACH(auto workspace, model->list()) {
        (new WorkspaceProxy(workspace))->assign(this);
    }
}
