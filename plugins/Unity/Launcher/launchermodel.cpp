/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michael Zanetti <michael.zanetti@canonical.com>
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

#include "launchermodel.h"
#include "launcheritem.h"
#include "backend/launcherbackend.h"

#include <QDebug>

LauncherModel::LauncherModel(QObject *parent):
    LauncherModelInterface(parent),
    m_backend(new LauncherBackend(this))
{
    Q_FOREACH (const QString &entry, m_backend->storedApplications()) {
        LauncherItem *item = new LauncherItem(entry, m_backend->displayName(entry), m_backend->icon(entry), this);
        if (m_backend->isPinned(entry)) {
            item->setFavorite(true);
        } else {
            item->setRecent(true);
        }
    }
}

LauncherModel::~LauncherModel()
{
    while (!m_list.empty()) {
        m_list.takeFirst()->deleteLater();
    }
}

int LauncherModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant LauncherModel::data(const QModelIndex &index, int role) const
{
    LauncherItem *item = m_list.at(index.row());
    switch(role) {
    case RoleDesktopFile:
        return item->desktopFile();
    case RoleName:
        return item->name();
    case RoleIcon:
        return item->icon();
    case RoleFavorite:
        return item->favorite();
    }

    return QVariant();
}

unity::shell::launcher::LauncherItemInterface *LauncherModel::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return 0;
    }
    return m_list.at(index);
}

void LauncherModel::move(int oldIndex, int newIndex)
{
    // Perform the move in our list
    beginMoveRows(QModelIndex(), oldIndex, oldIndex, QModelIndex(), newIndex);
    m_list.move(oldIndex, newIndex);
    endMoveRows();

    storeAppList();

    pin(newIndex);
}

void LauncherModel::pin(int index)
{
    LauncherItem *item = m_list.at(index);
    if (!item->favorite()) {

        item->setFavorite(true);
        item->setRecent(false);

        m_backend->setPinned(item->desktopFile(), true);

        QModelIndex modelIndex = this->index(index);
        Q_EMIT dataChanged(modelIndex, modelIndex);

        storeAppList();
    }
}

QHash<int, QByteArray> LauncherModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleDesktopFile, "desktopFile");
    roles.insert(RoleName, "name");
    roles.insert(RoleIcon, "icon");
    roles.insert(RoleFavorite, "favorite");
    roles.insert(RoleRunning, "runnng");
    return roles;
}

void LauncherModel::storeAppList()
{
    QStringList appIds;
    Q_FOREACH(LauncherItem *item, m_list) {
        if (item->favorite() || item->recent()) {
            appIds << item->desktopFile();
        }
    }
    m_backend->setStoredApplications(appIds);
}
