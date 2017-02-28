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

    m_workspaces.append(workspace);

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
    disconnect(workspace);

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
