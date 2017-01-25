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
    AppDrawerModelInterface(parent)
{
    Q_FOREACH (const QString &appId, UalWrapper::installedApps()) {
        UalWrapper::AppInfo info = UalWrapper::getApplicationInfo(appId);
        if (!info.valid) {
            qWarning() << "Failed to get app info for app" << appId;
            continue;
        }
        m_list.append(new LauncherItem(appId, info.name, info.icon, this));
        m_list.last()->setKeywords(info.keywords);
    }
    qsrand(QDateTime::currentMSecsSinceEpoch() / 100);
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
        // FIXME: u-a-l needs to provide API for usage stats.
        // don't forget to drop the qsrand() call in the ctor when dropping this.
        return qrand();
    }

    return QVariant();
}
