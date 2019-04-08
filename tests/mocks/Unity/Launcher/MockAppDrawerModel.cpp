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

#include "MockAppDrawerModel.h"

#include <QDebug>
#include <QDateTime>

MockAppDrawerModel::MockAppDrawerModel(QObject *parent):
    AppDrawerModelInterface(parent)
{
    MockLauncherItem *item = new MockLauncherItem("dialer-app", "/usr/share/applications/dialer-app.desktop", "Dialer", "dialer-app", this);
    m_list.append(item);
    item = new MockLauncherItem("camera-app", "/usr/share/applications/camera-app.desktop", "Camera", "camera", this);
    m_list.append(item);
    item = new MockLauncherItem("camera-app2", "/usr/share/applications/camera-app2.desktop", "Camera2", "camera", this);
    m_list.append(item);
    item = new MockLauncherItem("gallery-app", "/usr/share/applications/gallery-app.desktop", "Gallery", "gallery", this);
    m_list.append(item);
    item = new MockLauncherItem("music-app", "/usr/share/applications/music-app.desktop", "Music", "soundcloud", this);
    m_list.append(item);
    item = new MockLauncherItem("facebook-webapp", "/usr/share/applications/facebook-webapp.desktop", "Facebook", "facebook", this);
    m_list.append(item);
    item = new MockLauncherItem("morph-browser", "/usr/share/applications/morph-browser.desktop", "Browser", "browser", this);
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
    item = new MockLauncherItem("libreoffice", "/usr/share/applications/libreoffice.desktop","Libre Office Writer", "libreoffice", this);
    m_list.append(item);

    qsrand(QDateTime::currentMSecsSinceEpoch() / 1000);
}

int MockAppDrawerModel::rowCount(const QModelIndex & /*parent*/) const
{
    return m_list.count();
}

QVariant MockAppDrawerModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleAppId:
        return m_list.at(index.row())->appId();
    case RoleName:
        return m_list.at(index.row())->name();
    case RoleIcon:
        return m_list.at(index.row())->icon();
    case RoleUsage:
        return qrand();
    }

    return QVariant();
}
