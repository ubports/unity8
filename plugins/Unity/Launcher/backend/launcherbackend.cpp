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
#include <QDBusArgument>
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
    for (LauncherBackendItem &app: m_storedApps) {
        delete app.settings;
    }
    m_storedApps.clear();
}

QStringList LauncherBackend::storedApplications() const
{
    auto files = QStringList();
    for (const LauncherBackendItem &app: m_storedApps) {
        files << app.settings->fileName();
    }
    return files;
}

void LauncherBackend::setStoredApplications(const QStringList &appIds)
{
    // Record all existing pinned apps, so we can notice them in new list
    auto pinnedItems = QStringList();
    for (LauncherBackendItem &app: m_storedApps) {
        if (app.pinned) {
            pinnedItems.append(app.settings->fileName());
        }
    }

    clearItems();

    for (const QString &appId: appIds) {
        loadApp(makeAppDetails(appId, pinnedItems.contains(desktopFile(appId))));
    }

    syncToAccounts();
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
    QList<QVariantMap> apps;

    clearItems();

    if (m_user != "" && m_accounts != nullptr) {
        auto variant = m_accounts->getUserProperty(m_user, "launcher-items");
        variant.value<QDBusArgument>() >> apps;
    }

    // TODO: load default pinned ones from default config, instead of hardcoding here...
    if (apps.isEmpty()) {
        apps <<
            makeAppDetails("phone-app.desktop", true) <<
            makeAppDetails("camera-app.desktop", true) <<
            makeAppDetails("gallery-app.desktop", true) <<
            makeAppDetails("facebook-webapp.desktop", true) <<
            makeAppDetails("webbrowser-app.desktop", true) <<
            makeAppDetails("twitter-webapp.desktop", true) <<
            makeAppDetails("gmail-webapp.desktop", true) <<
            makeAppDetails("ubuntu-weather-app.desktop", true) <<
            makeAppDetails("notes-app.desktop", true) <<
            makeAppDetails("calendar-app.desktop", true);
    }

    for (const QVariant &app: apps) {
        loadApp(app.toMap());
    }
}

void LauncherBackend::syncToAccounts()
{
    if (m_user != "" && m_accounts != nullptr) {
        QList<QVariantMap> items;

        for (LauncherBackendItem &app: m_storedApps) {
            items << makeAppDetails(app.settings->fileName(), app.pinned);
        }

        m_accounts->setUserProperty(m_user, "launcher-items", QVariant::fromValue(items));
    }
}

QSettings *LauncherBackend::parseDesktopFile(const QString &appId) const
{
    auto fullAppId = desktopFile(appId);
    return new QSettings(fullAppId, QSettings::IniFormat);
}

void LauncherBackend::loadApp(const QVariantMap &details)
{
    auto appId = details.value("id").toString();
    auto isPinned = details.value("is-pinned").toBool();

    if (appId.isEmpty()) {
        return;
    }

    LauncherBackendItem item;
    item.settings = parseDesktopFile(appId);
    item.pinned = isPinned;
    m_storedApps.append(item);
}

QVariantMap LauncherBackend::makeAppDetails(const QString &appId, bool pinned) const
{
    QVariantMap details;
    details.insert("id", appId);
    details.insert("is-pinned", pinned);
    return details;
}

int LauncherBackend::findItem(const QString &appId) const
{
    auto fullAppId = desktopFile(appId);
    for (int i = 0; i < m_storedApps.size(); ++i) {
        if (m_storedApps[i].settings->fileName() == fullAppId) {
            return i;
        }
    }
    return -1;
}
