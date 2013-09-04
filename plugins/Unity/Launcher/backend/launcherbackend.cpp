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
#include <QGSettings>

class LauncherBackendItem
{
public:
    LauncherBackendItem(): pinned(false) {}

    QString desktopFile;
    QString displayName;
    QString icon;
    bool pinned;
};

LauncherBackend::LauncherBackend(bool useStorage, QObject *parent):
    QObject(parent),
    m_accounts(nullptr)
{
    if (useStorage) {
        m_accounts = new AccountsService(this);
    }
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

    QFileInfo info(iconName);
    if (info.exists()) {
        return info.absoluteFilePath();
    }
    return "image://theme/" + iconName;
}

bool LauncherBackend::isPinned(const QString &appId) const
{
    LauncherBackendItem *item = m_itemCache.value(appId);
    if (item) {
        return item->pinned;
    }
    return false;
}

void LauncherBackend::setPinned(const QString &appId, bool pinned)
{
    if (!m_storedApps.contains(appId)) {
        return;
    }

    LauncherBackendItem *item = m_itemCache.value(appId);
    if (!item) {
        item = new LauncherBackendItem();
        m_itemCache.insert(appId, item);
    }
    if (item->pinned != pinned) {
        item->pinned = pinned;
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

    if (m_accounts && m_user.isEmpty()) {
        QVariant variant = m_accounts->getUserProperty(m_user, "launcher-items");
        apps = qdbus_cast<QList<QVariantMap>>(variant.value<QDBusArgument>());
        defaults = isDefaultsItem(apps);
    }

    if (m_accounts && defaults) { // Checking accounts as it'll be null when !useStorage
        QGSettings gSettings("com.canonical.Unity.Launcher", "/com/canonical/unity/launcher/");
        Q_FOREACH(const QString &entry, gSettings.get("favorites").toStringList()) {
            if (entry.startsWith("application://")) {
                QString appId = entry;
                appId.remove("application://");
                QString df = findDesktopFile(appId);

                if (!df.isEmpty()) {
                    m_storedApps << appId;

                    if (!m_itemCache.contains(appId)) {
                        m_itemCache.insert(appId, parseDesktopFile(df));
                    }
                    m_itemCache.value(appId)->pinned = true;
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

        m_accounts->setUserProperty(m_user, "launcher-items", QVariant::fromValue(items));
    }
}

QString LauncherBackend::findDesktopFile(const QString &appId) const
{
    int dashPos = -1;
    QString helper = appId;

    do {
        if (dashPos != -1) {
            helper = helper.replace(dashPos, 1, '/');
        }

        QFileInfo fileInfo(QDir("/usr/share/applications"), helper);
        if (fileInfo.exists()) {
            return fileInfo.absoluteFilePath();
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
    item->icon = settings.value("Desktop Entry/Icon").toString();
    item->pinned = false;
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
    item->pinned = details.value("is-pinned").toBool();

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
    details.insert("is-pinned", item->pinned);
    return details;
}

bool LauncherBackend::isDefaultsItem(const QList<QVariantMap> &apps) const
{
    // To differentiate between an empty list and a list that hasn't been set
    // yet (and should thus be populated with the defaults), we use a special
    // list of one item with the 'defaults' field set to true.
    return (apps.size() == 1 && apps[0].value("defaults").toBool());
}
