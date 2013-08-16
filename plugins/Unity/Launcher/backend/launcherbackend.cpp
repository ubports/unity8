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

#include "launcherbackend.h"

#include <QHash>

LauncherBackend::LauncherBackend(QObject *parent):
    QObject(parent)
{

    // TODO: load default pinned ones from default config, instead of hardcoding here...

    m_storedApps <<
        QLatin1String("phone-app.desktop") <<
        QLatin1String("camera-app.desktop") <<
        QLatin1String("gallery-app.desktop") <<
        QLatin1String("facebook-webapp.desktop") <<
        QLatin1String("webbrowser-app.desktop") <<
        QLatin1String("twitter-webapp.desktop") <<
        QLatin1String("gmail-webapp.desktop") <<
        QLatin1String("ubuntu-weather-app.desktop") <<
        QLatin1String("notes-app.desktop") <<
        QLatin1String("calendar-app.desktop");

    // TODO: get stuff from desktop files instead this hardcoded map
    m_displayNameMap.insert("phone-app.desktop", "Phone");
    m_displayNameMap.insert("camera-app.desktop", "Camera");
    m_displayNameMap.insert("gallery-app.desktop", "Gallery");
    m_displayNameMap.insert("facebook-webapp.desktop", "Facebook");
    m_displayNameMap.insert("webbrowser-app.desktop", "Browser");
    m_displayNameMap.insert("twitter-webapp.desktop", "Twitter");
    m_displayNameMap.insert("gmail-webapp.desktop", "GMail");
    m_displayNameMap.insert("ubuntu-weather-app.desktop", "Weather");
    m_displayNameMap.insert("notes-app.desktop", "Notes");
    m_displayNameMap.insert("calendar-app.desktop", "Calendar");

    // TODO: get stuff from desktop files instead this hardcoded map
    m_iconMap.insert("phone-app.desktop", "phone-app");
    m_iconMap.insert("camera-app.desktop", "camera");
    m_iconMap.insert("gallery-app.desktop", "gallery");
    m_iconMap.insert("facebook-webapp.desktop", "facebook");
    m_iconMap.insert("webbrowser-app.desktop", "browser");
    m_iconMap.insert("twitter-webapp.desktop", "twitter");
    m_iconMap.insert("gmail-webapp.desktop", "gmail");
    m_iconMap.insert("ubuntu-weather-app.desktop", "weather");
    m_iconMap.insert("notes-app.desktop", "notepad");
    m_iconMap.insert("calendar-app.desktop", "calendar");

}

LauncherBackend::~LauncherBackend()
{

}

QStringList LauncherBackend::storedApplications() const
{
    return m_storedApps;
}

void LauncherBackend::setStoredApplications(const QStringList &appIds)
{
    m_storedApps = appIds;
    // TODO: Cleanup pinned state from settings for apps not in list any more.
}

QString LauncherBackend::desktopFile(const QString &appId) const
{
    // TODO: return real path instead of this hardcoded one
    return QLatin1String("/usr/share/applications/") + appId;
}

QString LauncherBackend::displayName(const QString &appId) const
{
    return m_displayNameMap.value(appId);
}

QString LauncherBackend::icon(const QString &appId) const
{
    return m_iconMap.value(appId);
}

bool LauncherBackend::isPinned(const QString &appId) const
{
    // TODO: return app's pinned state from settings
    Q_UNUSED(appId)
    return false;
}

void LauncherBackend::setPinned(const QString &appId, bool pinned)
{
    // TODO: Store pinned state in settings.
    Q_UNUSED(appId)
    Q_UNUSED(pinned)
}

QList<QuickListEntry> LauncherBackend::quickList(const QString &appId) const
{
    // TODO: Get static (from .desktop file) and dynamic (from the app itself)
    // entries and return them here. Frontend related entries (like "Pin to launcher")
    // don't matter here. This is just the backend part.
    // TODO: emit quickListChanged() when the dynamic part changes
    Q_UNUSED(appId)
    return QList<QuickListEntry>();
}

int LauncherBackend::progress(const QString &appId) const
{
    // TODO: Return value for progress emblem.
    // TODO: emit progressChanged() when this value changes.
    Q_UNUSED(appId)
    return -1;
}

int LauncherBackend::count(const QString &appId) const
{
    // TODO: Return value for count emblem.
    // TODO: emit countChanged() when this value changes.
    Q_UNUSED(appId)
    return 0;
}

void LauncherBackend::triggerQuickListAction(const QString &appId, const QString &quickListId)
{
    // TODO: execute the given quicklist action
    Q_UNUSED(appId)
    Q_UNUSED(quickListId)
}
