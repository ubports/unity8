/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "MockLauncherModel.h"
#include "MockLauncherItem.h"

MockLauncherModel::MockLauncherModel(QObject* parent): LauncherModelInterface(parent)
{
    LauncherItemInterface *item = new MockLauncherItem("/usr/share/applications/phone-app.desktop", "Phone", "phone-app");
    m_list.append(item);
    item = new MockLauncherItem("/usr/share/applications/camera-app.desktop", "Camera", "camera");
    m_list.append(item);
    item = new MockLauncherItem("/usr/share/applications/gallery-app.desktop", "Gallery", "gallery");
    m_list.append(item);
    item = new MockLauncherItem("/usr/share/applications/facebook-webapp.desktop", "Facebook", "facebook");
    m_list.append(item);
    item = new MockLauncherItem("/usr/share/applications/webbrowser-app.desktop", "Browser", "browser");
    m_list.append(item);
    item = new MockLauncherItem("/usr/share/applications/twitter-webapp.desktop", "Twitter", "twitter");
    m_list.append(item);
    item = new MockLauncherItem("/usr/share/applications/gmail-webapp.desktop", "GMail", "gmail");
    m_list.append(item);
    item = new MockLauncherItem("/usr/share/applications/ubuntu-weather-app.desktop", "Weather", "weather");
    m_list.append(item);
    item = new MockLauncherItem("/usr/share/applications/notes-app.desktop", "Notepad", "notepad");
    m_list.append(item);
    item = new MockLauncherItem("/usr/share/applications/ubuntu-calendar-app.desktop","Calendar", "calendar");
    m_list.append(item);
}

MockLauncherModel::~MockLauncherModel()
{
    while (!m_list.empty())
    {
        m_list.takeFirst()->deleteLater();
    }
}

// cppcheck-suppress unusedFunction
int MockLauncherModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant MockLauncherModel::data(const QModelIndex& index, int role) const
{
    LauncherItemInterface *item = m_list.at(index.row());
    switch(role)
    {
    case RoleDesktopFile:
        return item->desktopFile();
    case RoleName:
        return item->name();
    case RoleIcon:
        return item->icon();
    case RoleFavorite:
        return item->favorite();
    case RoleRunning:
        return item->running();
    case RoleRecent:
        return item->recent();
    case RoleProgress:
        return item->progress();
    case RoleCount:
        return item->count();
    }

    return QVariant();
}

unity::shell::launcher::LauncherItemInterface *MockLauncherModel::get(int index) const
{
    if (index < 0 || index >= m_list.count())
    {
        return 0;
    }
    return m_list.at(index);
}

void MockLauncherModel::move(int oldIndex, int newIndex)
{
    beginMoveRows(QModelIndex(), oldIndex, oldIndex, QModelIndex(), newIndex);
    m_list.move(oldIndex, newIndex);
    endMoveRows();
}
