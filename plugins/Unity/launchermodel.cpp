/*
 * Copyright (C) 2011 Canonical, Ltd.
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

LauncherModel::LauncherModel(QObject *parent): QAbstractListModel(parent)
{
    // FIXME: Dummy data... Aggregate real data from backends

    // Fake favorites
    LauncherItem *item = new LauncherItem("/usr/share/applications/phone-app.desktop", "Phone", "phone-app");
    m_list.append(item);
    item = new LauncherItem("/usr/share/applications/camera-app.desktop", "Camera", "camera");
    m_list.append(item);
    item = new LauncherItem("/usr/share/applications/gallery-app.desktop", "Gallery", "gallery");
    m_list.append(item);
    item = new LauncherItem("/usr/share/applications/facebook-webapp.desktop", "Facebook", "facebook");
    m_list.append(item);
    item = new LauncherItem("/usr/share/applications/webbrowser-app.desktop", "Browser", "browser");
    m_list.append(item);
    item = new LauncherItem("/usr/share/applications/twitter-webapp.desktop", "Twitter", "twitter");
    m_list.append(item);
    item = new LauncherItem("/usr/share/applications/gmail-webapp.desktop", "GMail", "gmail");
    m_list.append(item);
    item = new LauncherItem("/usr/share/applications/ubuntu-weather-app.desktop", "Weather", "weather");
    m_list.append(item);
    item = new LauncherItem("/usr/share/applications/notes-app.desktop", "Notepad", "notepad");
    m_list.append(item);
    item = new LauncherItem("/usr/share/applications/ubuntu-calendar-app.desktop","Calendar", "calendar");
    m_list.append(item);
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
    case RoleName:
        return item->name();
    case RoleIcon:
        return item->icon();
    case RoleFavorite:
        return item->favorite();
    }

    return QVariant();
}

LauncherItem *LauncherModel::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return 0;
    }
    return m_list.at(index);
}

void LauncherModel::move(int oldIndex, int newIndex)
{
    beginMoveRows(QModelIndex(), oldIndex, oldIndex, QModelIndex(), newIndex);
    m_list.move(oldIndex, newIndex);
    endMoveRows();
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


LauncherItem::LauncherItem(const QString &desktopFile, const QString &name, const QString &icon, QObject *parent):
    QObject(parent),
    m_desktopFile(desktopFile),
    m_name(name),
    m_icon(icon),
    m_favorite(false)
{

}

QString LauncherItem::desktopFile() const
{
    return m_desktopFile;
}

QString LauncherItem::name() const
{
    return m_name;
}

QString LauncherItem::icon() const
{
    return m_icon;
}

bool LauncherItem::favorite() const
{
    return m_favorite;
}

void LauncherItem::setFavorite(bool favorite)
{
    if (m_favorite != favorite) {
        m_favorite = favorite;
        Q_EMIT favoriteChanged(m_favorite);
    }
}

bool LauncherItem::running() const
{
    return m_running;
}

void LauncherItem::setRunning(bool running)
{
    if (m_running != running) {
        m_running = running;
        Q_EMIT runningChanged(running);
    }
}
