/*
 * Copyright 2013,2015 Canonical Ltd.
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
    item->setPinned(true);
    item->setSurfaceCount(1);
    item->setRunning(true);
    item->setFocused(true);
    m_list.append(item);
    item = new MockLauncherItem("camera-app", "/usr/share/applications/camera-app.desktop", "Camera", "camera", this);
    item->setProgress(10);
    item->setPinned(true);
    m_list.append(item);
    item = new MockLauncherItem("camera-app2", "/usr/share/applications/camera-app2.desktop", "Camera2", "camera", this);
    item->setPinned(true);
    m_list.append(item);
    item = new MockLauncherItem("camera-app3", "/usr/share/applications/camera-app2.desktop", "Camera2", "camera", this);
    item->setPinned(true);
    m_list.append(item);
    item = new MockLauncherItem("gallery-app", "/usr/share/applications/gallery-app.desktop", "Gallery", "gallery", this);
    item->setProgress(50);
    item->setCountVisible(true);
    item->setRunning(true);
    item->setSurfaceCount(2);
    item->setAlerting(false);
    m_list.append(item);
    item = new MockLauncherItem("music-app", "/usr/share/applications/music-app.desktop", "Music", "soundcloud", this);
    m_list.append(item);
    item = new MockLauncherItem("facebook-webapp", "/usr/share/applications/facebook-webapp.desktop", "Facebook", "facebook", this);
    item->setProgress(150);
    m_list.append(item);
    item = new MockLauncherItem("morph-browser", "/usr/share/applications/morph-browser.desktop", "Browser", "browser", this);
    item->setSurfaceCount(5);
    item->setCount(1);
    item->setCountVisible(true);
    item->setRunning(true);
    item->setAlerting(false);
    m_list.append(item);
    item = new MockLauncherItem("twitter-webapp", "/usr/share/applications/twitter-webapp.desktop", "Twitter", "twitter", this);
    item->setCount(12);
    item->setCountVisible(true);
    item->setAlerting(false);
    item->setPinned(true);
    m_list.append(item);
    item = new MockLauncherItem("gmail-webapp", "/usr/share/applications/gmail-webapp.desktop", "GMail", "gmail", this);
    item->setCount(123);
    item->setCountVisible(true);
    item->setAlerting(false);
    m_list.append(item);
    item = new MockLauncherItem("ubuntu-weather-app", "/usr/share/applications/ubuntu-weather-app.desktop", "Weather", "weather", this);
    item->setCount(1234567890);
    item->setCountVisible(true);
    item->setAlerting(false);
    item->setPinned(true);
    m_list.append(item);
    item = new MockLauncherItem("notes-app", "/usr/share/applications/notes-app.desktop", "Notepad", "notepad", this);
    item->setProgress(50);
    item->setCount(5);
    item->setCountVisible(true);
    item->setAlerting(false);
    item->setFocused(true);
    item->setPinned(true);
    m_list.append(item);
    item = new MockLauncherItem("calendar-app", "/usr/share/applications/calendar-app.desktop","Calendar", "calendar", this);
    item->setPinned(true);
    m_list.append(item);
    item = new MockLauncherItem("libreoffice", "/usr/share/applications/libreoffice.desktop","Libre Office", "libreoffice", this);
    item->setPinned(true);
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
    case RoleAppId:
        return item->appId();
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
    case RoleCountVisible:
        return item->countVisible();
    case RoleFocused:
        return item->focused();
    case RoleAlerting:
        return item->alerting();
    case RoleSurfaceCount:
        return item->surfaceCount();
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

void MockLauncherModel::setAlerting(const QString &appId, bool alerting) {
    int index = findApp(appId);
    if (index >= 0) {
        QModelIndex modelIndex = this->index(index);
        MockLauncherItem *item = m_list.at(index);
        if (!item->focused()) {
            item->setAlerting(alerting);
            Q_EMIT dataChanged(modelIndex, modelIndex, QVector<int>() << RoleAlerting);
        }
    }
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
        MockLauncherItem * item = m_list.takeAt(index);
        item->setRunning(false);
        item->deleteLater();
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

void MockLauncherModel::setProgress(const QString &appId, int progress)
{
    int index = findApp(appId);
    if (index >= 0) {
        m_list.at(index)->setProgress(progress);
        QModelIndex modelIndex = this->index(index);
        Q_EMIT dataChanged(modelIndex, modelIndex, QVector<int>() << RoleProgress);
    }
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

bool MockLauncherModel::onlyPinned() const
{
    return false;
}

void MockLauncherModel::setOnlyPinned(bool onlyPinned)
{
    Q_UNUSED(onlyPinned)
}

void MockLauncherModel::emitHint()
{
    Q_EMIT hint();
}

void MockLauncherModel::setCount(const QString &appId, int count)
{
    int index = findApp(appId);
    if (index >= 0) {
        m_list.at(index)->setCount(count);
        QModelIndex modelIndex = this->index(index);
        Q_EMIT dataChanged(modelIndex, modelIndex);
    }
}

void MockLauncherModel::setCountVisible(const QString &appId, bool countVisible)
{
    int index = findApp(appId);
    if (index >= 0) {
        m_list.at(index)->setCountVisible(countVisible);
        QModelIndex modelIndex = this->index(index);
        Q_EMIT dataChanged(modelIndex, modelIndex);
    }
}

unity::shell::application::ApplicationManagerInterface *MockLauncherModel::applicationManager() const
{
    return nullptr;
}
