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
    MockLauncherItem *item = new MockLauncherItem("phone-app", "/usr/share/applications/phone-app.desktop", "Phone", "phone-app", this);
    m_list.append(item);
    item = new MockLauncherItem("camera-app", "/usr/share/applications/camera-app.desktop", "Camera", "camera", this);
    m_list.append(item);
    item = new MockLauncherItem("gallery-app", "/usr/share/applications/gallery-app.desktop", "Gallery", "gallery", this);
    m_list.append(item);
    item = new MockLauncherItem("facebook-webapp", "/usr/share/applications/facebook-webapp.desktop", "Facebook", "facebook", this);
    m_list.append(item);
    item = new MockLauncherItem("webbrowser-app", "/usr/share/applications/webbrowser-app.desktop", "Browser", "browser", this);
    m_list.append(item);
    item = new MockLauncherItem("twitter-webapp", "/usr/share/applications/twitter-webapp.desktop", "Twitter", "twitter", this);
    m_list.append(item);
    item = new MockLauncherItem("gmail-webapp", "/usr/share/applications/gmail-webapp.desktop", "GMail", "gmail", this);
    m_list.append(item);
    item = new MockLauncherItem("ubuntu-weather-app", "/usr/share/applications/ubuntu-weather-app.desktop", "Weather", "weather", this);
    m_list.append(item);
    item = new MockLauncherItem("notes-app", "/usr/share/applications/notes-app.desktop", "Notepad", "notepad", this);
    m_list.append(item);
    item = new MockLauncherItem("calendar-app", "/usr/share/applications/calendar-app.desktop","Calendar", "calendar", this);
    m_list.append(item);
}

MockLauncherModel::~MockLauncherModel()
{
}

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
    case RolePinned:
        return item->pinned();
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

void MockLauncherModel::pin(const QString &appId, int index)
{
    int currentIndex = findApp(appId);

    if (currentIndex >= 0) {
        if (index == -1 || index == currentIndex) {
            m_list.at(currentIndex)->setPinned(true);
            QModelIndex modelIndex = this->index(currentIndex);
            Q_EMIT dataChanged(modelIndex, modelIndex);
        } else {
            move(currentIndex, index);
        }
    } else {
        beginInsertRows(QModelIndex(), index, index);
        m_list.insert(index, new MockLauncherItem(appId,
                                                  appId + ".desktop",
                                                  appId,
                                                  appId + ".png"));
        m_list.at(index)->setPinned(true);
        endInsertRows();
    }
}

void MockLauncherModel::requestRemove(const QString &appId)
{
    int index = findApp(appId);
    if (index >= 0) {
        beginRemoveRows(QModelIndex(), index, 0);
        m_list.takeAt(index)->deleteLater();
        endRemoveRows();
    }
}

void MockLauncherModel::quickListActionInvoked(const QString &appId, int actionIndex)
{
    Q_UNUSED(appId)
    Q_UNUSED(actionIndex)
    // Nothing to mock yet...
}

int MockLauncherModel::findApp(const QString &appId)
{
    for (int i = 0; i < m_list.count(); ++i) {
        MockLauncherItem *item = m_list.at(i);
        if (item->appId() == appId) {
            return i;
        }
    }
    return -1;
}
