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

#include "AccountsServiceDBusAdaptor.h"
#include "launcherbackend.h"

#include <QDir>
#include <QDBusArgument>
#include <QFileInfo>
#include <QGSettings>
#include <QDebug>
#include <QStandardPaths>

class LauncherBackendItem
{
public:
    QString desktopFile;
    QString displayName;
    QString icon;
};

LauncherBackend::LauncherBackend(QObject *parent):
    QDBusVirtualObject(parent),
    m_accounts(nullptr)
{
#ifndef LAUNCHER_TESTING
    m_accounts = new AccountsServiceDBusAdaptor(this);
#endif
    m_user = qgetenv("USER");
    syncFromAccounts();
}

LauncherBackend::~LauncherBackend()
{
    m_storedApps.clear();

    Q_FOREACH(LauncherBackendItem *item, m_itemCache) {
        delete item;
    }
    m_itemCache.clear();
}

QStringList LauncherBackend::storedApplications() const
{
    return m_storedApps;
}

void LauncherBackend::setStoredApplications(const QStringList &appIds)
{
    if (appIds.count() < m_storedApps.count()) {
        Q_FOREACH(const QString &appId, m_storedApps) {
            if (!appIds.contains(appId)) {
                delete m_itemCache.take(appId);
            }
        }
    }
    m_storedApps = appIds;
    Q_FOREACH(const QString &appId, appIds) {
        if (!m_itemCache.contains(appId)) {
            QString df = findDesktopFile(appId);
            if (!df.isEmpty()) {
                LauncherBackendItem *item = parseDesktopFile(df);
                m_itemCache.insert(appId, item);
            } else {
                // Cannot find any data for that app... ignoring it.
                qWarning() << "cannot find desktop file for" << appId << ". discarding app.";
                m_storedApps.removeAll(appId);
            }
        }
    }
    syncToAccounts();
}

QString LauncherBackend::desktopFile(const QString &appId) const
{
    LauncherBackendItem *item = m_itemCache.value(appId);
    if (item) {
        return item->desktopFile;
    }

    return findDesktopFile(appId);
}

QString LauncherBackend::displayName(const QString &appId) const
{
    LauncherBackendItem *item = m_itemCache.value(appId);
    if (item) {
        return item->displayName;
    }

    QString df = findDesktopFile(appId);
    if (!df.isEmpty()) {
        LauncherBackendItem *item = parseDesktopFile(df);
        m_itemCache.insert(appId, item);
        return item->displayName;
    }

    return QString();
}

QString LauncherBackend::icon(const QString &appId) const
{
    QString iconName;
    LauncherBackendItem *item = m_itemCache.value(appId);
    if (item) {
        iconName = item->icon;
    } else {
        QString df = findDesktopFile(appId);
        if (!df.isEmpty()) {
            LauncherBackendItem *item = parseDesktopFile(df);
            m_itemCache.insert(appId, item);
            iconName = item->icon;
        }
    }

    return iconName;
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
    if (qgetenv("USER") == "lightdm" && m_user != username) {
        m_user = username;
        syncFromAccounts();
    }
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
    bool defaults = true;

    m_storedApps.clear();

    if (m_accounts && !m_user.isEmpty()) {
        QVariant variant = m_accounts->getUserProperty(m_user, "com.canonical.unity.AccountsService", "launcher-items");
        if (variant.isValid() && variant.canConvert<QDBusArgument>()) {
            apps = qdbus_cast<QList<QVariantMap>>(variant.value<QDBusArgument>());
            defaults = isDefaultsItem(apps);
        }
    }

    if (m_accounts && defaults) { // Checking accounts as it'll be null when !useStorage
        QGSettings gSettings("com.canonical.Unity.Launcher", "/com/canonical/unity/launcher/");
        Q_FOREACH(const QString &entry, gSettings.get("favorites").toStringList()) {
            if (entry.startsWith("application://")) {
                QString appId = entry;
                // Transform "application://foobar.desktop" to "foobar"
                appId.remove("application://");
                if (appId.endsWith(".desktop")) {
                    appId.chop(8);
                }
                QString df = findDesktopFile(appId);

                if (!df.isEmpty()) {
                    m_storedApps << appId;

                    if (!m_itemCache.contains(appId)) {
                        m_itemCache.insert(appId, parseDesktopFile(df));
                    }
                }
            }
        }
    } else {
        for (const QVariant &app: apps) {
            loadFromVariant(app.toMap());
        }
    }
}

void LauncherBackend::syncToAccounts()
{
    if (m_accounts && !m_user.isEmpty()) {
        QList<QVariantMap> items;

        Q_FOREACH(const QString &appId, m_storedApps) {
            items << itemToVariant(appId);
        }

        m_accounts->setUserProperty(m_user, "com.canonical.unity.AccountsService", "launcher-items", QVariant::fromValue(items));
    }
}

QString LauncherBackend::findDesktopFile(const QString &appId) const
{
    int dashPos = -1;
    QString helper = appId;

    QStringList searchDirs = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);
#ifdef LAUNCHER_TESTING
    searchDirs << "";
#endif

    do {
        if (dashPos != -1) {
            helper = helper.replace(dashPos, 1, '/');
        }

        Q_FOREACH(const QString &searchDir, searchDirs) {
            QFileInfo fileInfo(QDir(searchDir), helper + ".desktop");
            if (fileInfo.exists()) {
                return fileInfo.absoluteFilePath();
            }
        }

        dashPos = helper.indexOf("-");
    } while (dashPos != -1);

    return QString();
}

LauncherBackendItem* LauncherBackend::parseDesktopFile(const QString &desktopFile) const
{
    QSettings settings(desktopFile, QSettings::IniFormat);

    LauncherBackendItem* item = new LauncherBackendItem();
    item->desktopFile = desktopFile;
    item->displayName = settings.value("Desktop Entry/Name").toString();

    QString iconString = settings.value("Desktop Entry/Icon").toString();
    QString pathString = settings.value("Desktop Entry/Path").toString();
    if (QFileInfo(iconString).exists()) {
        item->icon = QFileInfo(iconString).absoluteFilePath();
    } else if (QFileInfo(pathString + '/' + iconString).exists()) {
        item->icon = pathString + '/' + iconString;
    } else {
        item->icon =  "image://theme/" + iconString;
    }
    return item;
}

void LauncherBackend::loadFromVariant(const QVariantMap &details)
{
    if (!details.contains("id")) {
        return;
    }
    QString appId = details.value("id").toString();

    LauncherBackendItem *item = m_itemCache.value(appId);
    if (item) {
        delete item;
    }

    item = new LauncherBackendItem();

    item->desktopFile = details.value("desktopFile").toString();
    item->displayName = details.value("name").toString();
    item->icon = details.value("icon").toString();

    m_itemCache.insert(appId, item);
    m_storedApps.append(appId);
}

QVariantMap LauncherBackend::itemToVariant(const QString &appId) const
{
    LauncherBackendItem *item = m_itemCache.value(appId);
    QVariantMap details;
    details.insert("id", appId);
    details.insert("name", item->displayName);
    details.insert("icon", item->icon);
    details.insert("desktopFile", item->desktopFile);
    return details;
}

bool LauncherBackend::isDefaultsItem(const QList<QVariantMap> &apps) const
{
    // To differentiate between an empty list and a list that hasn't been set
    // yet (and should thus be populated with the defaults), we use a special
    // list of one item with the 'defaults' field set to true.
    return (apps.size() == 1 && apps[0].value("defaults").toBool());
}

bool LauncherBackend::handleMessage(const QDBusMessage& message, const QDBusConnection& connection)
{
    Q_UNUSED(message)
    Q_UNUSED(connection)
    return false;
}

QString LauncherBackend::introspect (const QString &path) const
{
    Q_UNUSED(path)
    return "";
}
