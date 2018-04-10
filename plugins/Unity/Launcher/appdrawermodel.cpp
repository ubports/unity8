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

#include "appdrawermodel.h"
#include "ualwrapper.h"

#include <QDebug>
#include <QDateTime>

AppDrawerModel::AppDrawerModel(QObject *parent):
    AppDrawerModelInterface(parent),
    m_ual(new UalWrapper(this))
{
    Q_FOREACH (const QString &appId, UalWrapper::installedApps()) {
        UalWrapper::AppInfo info = UalWrapper::getApplicationInfo(appId);
        if (!info.valid) {
            qWarning() << "Failed to get app info for app" << appId;
            continue;
        }
        LauncherItem* item = new LauncherItem(appId, info.name, info.icon, this);
        item->setKeywords(info.keywords);
        item->setPopularity(info.popularity);
        m_list.append(item);
    }

    // keep this a queued connection as it's coming from another thread.
    connect(m_ual, &UalWrapper::appAdded, this, &AppDrawerModel::appAdded, Qt::QueuedConnection);
    connect(m_ual, &UalWrapper::appRemoved, this, &AppDrawerModel::appRemoved, Qt::QueuedConnection);
    connect(m_ual, &UalWrapper::appInfoChanged, this, &AppDrawerModel::appInfoChanged, Qt::QueuedConnection);
}

int AppDrawerModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant AppDrawerModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleAppId:
        return m_list.at(index.row())->appId();
    case RoleName:
        return m_list.at(index.row())->name();
    case RoleIcon:
        return m_list.at(index.row())->icon();
    case RoleKeywords:
        return m_list.at(index.row())->keywords();
    case RoleUsage:
        return m_list.at(index.row())->popularity();
    }

    return QVariant();
}

void AppDrawerModel::appAdded(const QString &appId)
{
    UalWrapper::AppInfo info = UalWrapper::getApplicationInfo(appId);
    if (!info.valid) {
        qWarning() << "App added signal received but failed to get app info for app" << appId;
        return;
    }

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    LauncherItem* item = new LauncherItem(appId, info.name, info.icon, this);
    item->setKeywords(info.keywords);
    item->setPopularity(info.popularity);
    m_list.append(item);
    endInsertRows();
}

void AppDrawerModel::appRemoved(const QString &appId)
{
    int idx = -1;
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->appId() == appId) {
            idx = i;
            break;
        }
    }
    if (idx < 0) {
        qWarning() << "App removed signal received but app doesn't seem to be in the drawer model";
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.takeAt(idx)->deleteLater();
    endRemoveRows();
}

void AppDrawerModel::appInfoChanged(const QString &appId)
{
    LauncherItem *item = nullptr;
    int idx = -1;

    for(int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->appId() == appId) {
            item = m_list.at(i);
            idx = i;
            break;
        }
    }

    if (!item) {
        return;
    }

    UalWrapper::AppInfo info = m_ual->getApplicationInfo(appId);
    item->setPopularity(info.popularity);
    Q_EMIT dataChanged(index(idx), index(idx), {AppDrawerModelInterface::RoleUsage});
}
