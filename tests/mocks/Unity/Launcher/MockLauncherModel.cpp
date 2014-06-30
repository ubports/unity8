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
    MockLauncherItem *item = new MockLauncherItem("dialer-app", "/usr/share/applications/dialer-app.desktop", "Dialer", "dialer-app", this);
    item->setProgress(0);
    m_list.append(item);
    item->setFocused(true);
    item = new MockLauncherItem("camera-app", "/usr/share/applications/camera-app.desktop", "Camera", "camera", this);
    item->setProgress(10);
    m_list.append(item);
    item = new MockLauncherItem("gallery-app", "/usr/share/applications/gallery-app.desktop", "Gallery", "gallery", this);
    item->setProgress(50);
    m_list.append(item);
    item = new MockLauncherItem("facebook-webapp", "/usr/share/applications/facebook-webapp.desktop", "Facebook", "facebook", this);
    item->setProgress(150);
    m_list.append(item);
    item = new MockLauncherItem("webbrowser-app", "/usr/share/applications/webbrowser-app.desktop", "Browser", "browser", this);
    item->setCount(1);
    m_list.append(item);
    item = new MockLauncherItem("twitter-webapp", "/usr/share/applications/twitter-webapp.desktop", "Twitter", "twitter", this);
    item->setCount(12);
    m_list.append(item);
    item = new MockLauncherItem("gmail-webapp", "/usr/share/applications/gmail-webapp.desktop", "GMail", "gmail", this);
    item->setCount(123);
    m_list.append(item);
    item = new MockLauncherItem("ubuntu-weather-app", "/usr/share/applications/ubuntu-weather-app.desktop", "Weather", "weather", this);
    item->setCount(1234567890);
    m_list.append(item);
    item = new MockLauncherItem("notes-app", "/usr/share/applications/notes-app.desktop", "Notepad", "notepad", this);
    item->setProgress(50);
    item->setCount(5);
    item->setFocused(true);
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
    case RoleFocused:
        return item->focused();
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
    // Make sure its not moved outside the lists
    if (newIndex < 0) {
        newIndex = 0;
    }
    if (newIndex >= m_list.count()) {
        newIndex = m_list.count()-1;
    }

    // Nothing to do?
    if (oldIndex == newIndex) {
        return;
    }

    // QList's and QAbstractItemModel's move implementation differ when moving an item up the list :/
    // While QList needs the index in the resulting list, beginMoveRows expects it to be in the current list
    // adjust the model's index by +1 in case we're moving upwards
    int newModelIndex = newIndex > oldIndex ? newIndex+1 : newIndex;

    beginMoveRows(QModelIndex(), oldIndex, oldIndex, QModelIndex(), newModelIndex);
    m_list.move(oldIndex, newIndex);
    endMoveRows();

    pin(m_list.at(newIndex)->appId());
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
    Q_EMIT quickListTriggered(appId, actionIndex);
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

void MockLauncherModel::setUser(const QString &username)
{
    Q_UNUSED(username)
    // TODO: implement this...
}

QString MockLauncherModel::getUrlForAppId(const QString &appId) const
{
    return "application:///" + appId + ".desktop";
}

void MockLauncherModel::setApplicationManager(unity::shell::application::ApplicationManagerInterface *applicationManager)
{
    Q_UNUSED(applicationManager)
}

unity::shell::application::ApplicationManagerInterface *MockLauncherModel::applicationManager() const
{
    return nullptr;
}
