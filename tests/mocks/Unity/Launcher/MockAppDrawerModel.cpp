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
    item = new MockLauncherItem("libreoffice", "/usr/share/applications/libreoffice.desktop","Libre Office", "libreoffice", this);
    m_list.append(item);
    qDebug() << "mock model created";

    qsrand(QDateTime::currentMSecsSinceEpoch() / 1000);
}

int MockAppDrawerModel::rowCount(const QModelIndex &parent) const
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
