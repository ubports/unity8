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
    int     count;
    bool    countVisible;
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

    /* Set up ourselves on DBus */
    QDBusConnection con = QDBusConnection::sessionBus();
    if (!con.registerService("com.canonical.Unity.Launcher"))
        qDebug() << "Unable to register launcher name";
    if (!con.registerVirtualObject("/com/canonical/Unity/Launcher", this, QDBusConnection::VirtualObjectRegisterOption::SubPath))
        qDebug() << "Unable to register launcher object";
}

LauncherBackend::~LauncherBackend()
{
    /* Remove oursevles from DBus */
    QDBusConnection con = QDBusConnection::sessionBus();
    con.unregisterService("com.canonical.Unity.Launcher");
    con.unregisterObject("/com/canonical/Unity/Launcher");

    /* Clear data */
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
    LauncherBackendItem *item = m_itemCache.value(appId, nullptr);
    if (item) {
        return item->desktopFile;
    }

    return findDesktopFile(appId);
}

QString LauncherBackend::displayName(const QString &appId) const
{
    LauncherBackendItem *item = m_itemCache.value(appId, nullptr);
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
    LauncherBackendItem *item = getItem(appId);
    if (item) {
        iconName = item->icon;
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
    int count = -1;
    LauncherBackendItem *item = getItem(appId);

    if (item) {
        if (item->countVisible) {
            count = item->count;
        }
    }

    return count;
}

void LauncherBackend::setCount(const QString &appId, int count) const
{
    LauncherBackendItem *item = getItem(appId);

    bool emitchange = false;
    if (item) {
        emitchange = (item->count != count);
        item->count = count;
    }

    if (emitchange) {
        /* TODO: This needs to use the accessor to handle the visibility
           correctly, but when we have the two properties we can just use
           the local value */
        Q_EMIT countChanged(appId, this->count(appId));
        QVariant vcount(item->count);
        emitPropChangedDbus(appId, "count", vcount);
    }
}

bool LauncherBackend::countVisible(const QString &appId) const
{
    bool visible = false;
    LauncherBackendItem *item = getItem(appId);

    if (item) {
        visible = item->countVisible;
    }

    return visible;
}

void LauncherBackend::setCountVisible(const QString &appId, bool visible) const
{
    LauncherBackendItem *item = getItem(appId);

    bool emitchange = false;
    if (item) {
        emitchange = (item->countVisible != visible);
        item->countVisible = visible;
    } else {
        qDebug() << "Unable to find:" << appId;
    }

    if (emitchange) {
        /* TODO: Because we're using visible in determining the
           count we need to emit a count changed as well */
        Q_EMIT countChanged(appId, this->count(appId));
        Q_EMIT countVisibleChanged(appId, item->countVisible);
        QVariant vCountVisible(item->countVisible);
        emitPropChangedDbus(appId, "countVisible", vCountVisible);
    }
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

    /* TODO: These should be looked up in a cache somewhere */
    item->count = 0;
    item->countVisible = false;

    return item;
}

/* Gets an item, and tries to create a new one if we need it to */
LauncherBackendItem* LauncherBackend::getItem(const QString &appId) const
{
    LauncherBackendItem *item = m_itemCache.value(appId, nullptr);
    if (!item) {
        QString df = findDesktopFile(appId);
        if (!df.isEmpty()) {
            item = parseDesktopFile(df);
            if (item) {
                m_itemCache[appId] = item;
            } else {
                qWarning() << "Unable to parse desktop file for" << appId << "path" << df;
            }
        } else {
            qDebug() << "Unable to find desktop file for:" << appId;
        }
    }

    if (!item)
        qWarning() << "Unable to find item for: " << appId;

    return item;
}

void LauncherBackend::loadFromVariant(const QVariantMap &details)
{
    if (!details.contains("id")) {
        return;
    }
    QString appId = details.value("id").toString();

    LauncherBackendItem *item = m_itemCache.value(appId, nullptr);
    if (item) {
        delete item;
    }

    item = new LauncherBackendItem();

    item->desktopFile = details.value("desktopFile").toString();
    item->displayName = details.value("name").toString();
    item->icon = details.value("icon").toString();
    item->count = details.value("count").toInt();
    item->countVisible = details.value("countVisible").toBool();

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
    details.insert("count", item->count);
    details.insert("countVisible", item->countVisible);
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
    /* Check to make sure we're getting properties on our interface */
    if (message.type() != QDBusMessage::MessageType::MethodCallMessage)
        return false;
    if (message.interface() != "org.freedesktop.DBus.Properties")
        return false;
    if (message.arguments()[0].toString() != "com.canonical.Unity.Launcher.Item")
        return false;

    /* Break down the path to just the app id */
    QString pathtemp = message.path();
    if (!pathtemp.startsWith("/com/canonical/Unity/Launcher/"))
        return false;
    pathtemp.remove("/com/canonical/Unity/Launcher/");
    if (pathtemp.indexOf('/') >= 0)
        return false;

    /* Find ourselves an appid */
    QString appid = decodeAppId(pathtemp);
    QVariantList retval;

    if (message.member() == "Get") {
        if (message.arguments()[1].toString() == "count")
            retval.append(QVariant::fromValue(QDBusVariant(this->count(appid))));
        else if (message.arguments()[1].toString() == "countVisible")
            retval.append(QVariant::fromValue(QDBusVariant(this->countVisible(appid))));
    } else if (message.member() == "Set") {
        if (message.arguments()[1].toString() == "count")
            this->setCount(appid, message.arguments()[2].value<QDBusVariant>().variant().toInt());
        else if (message.arguments()[1].toString() == "countVisible")
            this->setCountVisible(appid, message.arguments()[2].value<QDBusVariant>().variant().toBool());
    } else if (message.member() == "GetAll") {
        retval.append(this->itemToVariant(appid));
    } else {
        return false;
    }

    QDBusMessage reply = message.createReply(retval);
    return connection.send(reply);
}

QString LauncherBackend::introspect(const QString &path) const
{
    /* This case we should just list the nodes */
    if (path == "/com/canonical/Unity/Launcher/" || path == "/com/canonical/Unity/Launcher") {
        QString nodes;

        Q_FOREACH(const QString &appId, m_itemCache.keys()) {
            nodes.append("<node name=\"");
            nodes.append(encodeAppId(appId));
            nodes.append("\"/>\n");
        }

        return nodes;
    }

    /* Should not happen, but let's handle it */
    if (!path.startsWith("/com/canonical/Unity/Launcher")) {
        return "";
    }

    /* Now we should be looking at a node */
    QString nodeiface =
        "<interface name=\"com.canonical.Unity.Launcher.Item\">"
            "<property name=\"count\" type=\"i\" access=\"readwrite\" />"
            "<property name=\"countVisible\" type=\"b\" access=\"readwrite\" />"
        "</interface>";
    return nodeiface;
}

QString LauncherBackend::decodeAppId(const QString& path)
{
    QByteArray bytes = path.toUtf8();
    QByteArray decoded;

    for (int i = 0; i < bytes.size(); ++i) {
        char chr = bytes.at(i);

        if (chr == '_') {
            QString number;
            number.append(bytes.at(i+1));
            number.append(bytes.at(i+2));

            bool okay;
            char newchar = number.toUInt(&okay, 16);
            if (okay)
                decoded.append(newchar);

            i += 2;
        } else {
            decoded.append(chr);
        }
    }

    return QString::fromUtf8(decoded);
}

QString LauncherBackend::encodeAppId(const QString& appId)
{
    QByteArray bytes = appId.toUtf8();
    QString encoded;

    for (int i = 0; i < bytes.size(); ++i) {
        uchar chr = bytes.at(i);

        if ((chr >= 'a' && chr <= 'z') ||
            (chr >= 'A' && chr <= 'Z') ||
            (chr >= '0' && chr <= '9'&& i != 0)) {
            encoded.append(chr);
        } else {
            QString hexval = QString("_%1").arg(chr, 2, 16, QChar('0'));
            encoded.append(hexval.toUpper());
        }
    }

    return encoded;
}

void LauncherBackend::emitPropChangedDbus(const QString& appId, const QString& property, QVariant &value) const
{
    QString path("/com/canonical/Unity/Launcher/");
    path.append(encodeAppId(appId));

    QDBusMessage message = QDBusMessage::createSignal(path, "org.freedesktop.DBus.Properties", "PropertiesChanged");

    QList<QVariant> arguments;
    QVariantHash changedprops;
    changedprops[property] = QVariant::fromValue(QDBusVariant(value));
    QVariantList deletedprops;

    arguments.append(changedprops);
    arguments.append(deletedprops);

    message.setArguments(arguments);

    QDBusConnection con = QDBusConnection::sessionBus();
    con.send(message);
}
