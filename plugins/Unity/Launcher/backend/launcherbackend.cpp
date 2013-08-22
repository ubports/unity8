/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michael Terry <michael.terry@canonical.com>
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

#include "AccountsService.h"
#include "launcherbackend.h"

#include <QDir>
#include <QFileInfo>

LauncherBackend::LauncherBackend(bool useStorage, QObject *parent):
    QObject(parent),
    m_accounts(nullptr)
{
    if (useStorage) {
        m_accounts = new AccountsService(this);
    }
    setUser(qgetenv("USER"));
}

LauncherBackend::~LauncherBackend()
{
    clearItems();
}

void LauncherBackend::clearItems()
{
    for (int i = 0; i < m_storedApps.size(); i++) {
        delete m_storedApps[i].settings;
    }
    m_storedApps.clear();
}

QStringList LauncherBackend::storedApplications() const
{
    auto files = QStringList();
    for (int i = 0; i < m_storedApps.size(); i++) {
        files << m_storedApps[i].settings->fileName();
    }
    return files;
}

void LauncherBackend::setStoredApplications(const QStringList &appIds)
{
    // Are we dropping any pinned apps?
    auto needToSync = false;
    auto pinnedItems = QStringList();
    for (int i = 0; i < m_storedApps.size(); i++) {
        if (m_storedApps[i].pinned) {
            auto found = false;
            for (int j = 0; j < appIds.size(); j++) {
                auto fullAppId = desktopFile(appIds[j]);
                if (m_storedApps[i].settings->fileName() == fullAppId) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                needToSync = true;
            }
            pinnedItems.append(m_storedApps[i].settings->fileName());
        }
    }

    clearItems();

    for (auto appId: appIds) {
        loadDesktopFile(appId, pinnedItems.contains(desktopFile(appId)));
    }

    if (needToSync) {
        syncToAccounts();
    }
}

QString LauncherBackend::desktopFile(const QString &appId) const
{
    QFileInfo fileInfo(QDir("/usr/share/applications"), appId);
    return fileInfo.absoluteFilePath();
}

QString LauncherBackend::displayName(const QString &appId) const
{
    auto desktopFile = parseDesktopFile(appId);
    auto displayName = desktopFile->value("Desktop Entry/Name").toString();
    delete desktopFile;
    return displayName;
}

QString LauncherBackend::icon(const QString &appId) const
{
    auto desktopFile = parseDesktopFile(appId);
    auto iconName = desktopFile->value("Desktop Entry/Icon").toString();
    delete desktopFile;

    if (!iconName.isEmpty()) {
        QFileInfo iconFileInfo(iconName);
        if (iconFileInfo.isRelative()) {
            iconName = "image://gicon/" + iconName;
        }
    }

    return iconName;
}

bool LauncherBackend::isPinned(const QString &appId) const
{
    auto index = findItem(appId);
    if (index < 0) {
        return false;
    } else {
        return m_storedApps[index].pinned;
    }
}

void LauncherBackend::setPinned(const QString &appId, bool pinned)
{
    auto index = findItem(appId);
    if (index >= 0 && !m_storedApps[index].pinned) {
        m_storedApps[index].pinned = pinned;
        syncToAccounts();
    }
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

void LauncherBackend::setUser(const QString &username)
{
    m_user = username;
    syncFromAccounts();
}

void LauncherBackend::triggerQuickListAction(const QString &appId, const QString &quickListId)
{
    // TODO: execute the given quicklist action
    Q_UNUSED(appId)
    Q_UNUSED(quickListId)
}

void LauncherBackend::syncFromAccounts()
{
    auto appIds = QStringList();

    if (m_user != "" && m_accounts != nullptr) {
        appIds = m_accounts->getUserProperty(m_user, "launcher-items").toStringList();
    }

    // TODO: load default pinned ones from default config, instead of hardcoding here...
    if (appIds.isEmpty()) {
        appIds <<
            "phone-app.desktop" <<
            "camera-app.desktop" <<
            "gallery-app.desktop" <<
            "facebook-webapp.desktop" <<
            "webbrowser-app.desktop" <<
            "twitter-webapp.desktop" <<
            "gmail-webapp.desktop" <<
            "ubuntu-weather-app.desktop" <<
            "notes-app.desktop" <<
            "calendar-app.desktop";
    }

    setStoredApplications(appIds);

    // Mark all apps as pinned (since we just refreshed the set)
    for (int i = 0; i < m_storedApps.size(); i++) {
        m_storedApps[i].pinned = true;
    }
}

void LauncherBackend::syncToAccounts()
{
    auto pinnedItems = QStringList();
    for (int i = 0; i < m_storedApps.size(); i++) {
        if (m_storedApps[i].pinned) {
            pinnedItems.append(m_storedApps[i].settings->fileName());
        }
    }

    if (m_user != "" && m_accounts != nullptr) {
        m_accounts->setUserProperty(m_user, "launcher-items", QVariant(pinnedItems));
    }
}

QSettings *LauncherBackend::parseDesktopFile(const QString &appId) const
{
    auto fullAppId = desktopFile(appId);
    return new QSettings(fullAppId, QSettings::IniFormat);
}

bool LauncherBackend::loadDesktopFile(const QString &appId, bool isPinned)
{
    auto item = LauncherBackendItem();
    item.settings = parseDesktopFile(appId);
    item.pinned = isPinned;
    m_storedApps.append(item);
    return true; // QSettings doesn't really indicate a failure mode right now
}

int LauncherBackend::findItem(const QString &appId) const
{
    auto fullAppId = desktopFile(appId);
    for (int i = 0; i < m_storedApps.size(); i++) {
        if (m_storedApps[i].settings->fileName() == fullAppId) {
            return i;
        }
    }
    return -1;
}
