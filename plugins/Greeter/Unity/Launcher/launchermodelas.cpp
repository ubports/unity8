/*
 * Copyright 2014-2015 Canonical Ltd.
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
 */

#include "launchermodelas.h"
#include "launcheritem.h"
#include "AccountsServiceDBusAdaptor.h"
#include <unity/shell/application/ApplicationInfoInterface.h>

#include <QDesktopServices>
#include <QDebug>
#include <QDBusArgument>

using namespace unity::shell::application;

LauncherModel::LauncherModel(QObject *parent):
    LauncherModelInterface(parent),
    m_accounts(new AccountsServiceDBusAdaptor(this)),
    m_onlyPinned(true)
{
    connect(m_accounts, &AccountsServiceDBusAdaptor::propertiesChanged, this, &LauncherModel::propertiesChanged);
    refresh();
}

LauncherModel::~LauncherModel()
{
    while (!m_list.empty()) {
        m_list.takeFirst()->deleteLater();
    }
}

int LauncherModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant LauncherModel::data(const QModelIndex &index, int role) const
{
    LauncherItem *item = m_list.at(index.row());
    switch(role) {
        case RoleAppId:
            return item->appId();
        case RoleName:
            return item->name();
        case RoleIcon:
            return item->icon();
        case RolePinned:
            return item->pinned();
        case RoleCount:
            return item->count();
        case RoleCountVisible:
            return item->countVisible();
        case RoleProgress:
            return item->progress();
        case RoleFocused:
            return item->focused();
        case RoleRunning:
            return item->running();
        case RoleSurfaceCount:
            return item->surfaceCount();
    }

    return QVariant();
}

unity::shell::launcher::LauncherItemInterface *LauncherModel::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return 0;
    }
    return m_list.at(index);
}

void LauncherModel::move(int oldIndex, int newIndex)
{
    Q_UNUSED(oldIndex)
    Q_UNUSED(newIndex)
    qWarning() << "This is a read only implementation. Cannot move items.";
}

void LauncherModel::pin(const QString &appId, int index)
{
    Q_UNUSED(appId)
    Q_UNUSED(index)
    qWarning() << "This is a read only implementation. Cannot pin items";
}

void LauncherModel::requestRemove(const QString &appId)
{
    Q_UNUSED(appId)
    qWarning() << "This is a read only implementation. Cannot remove items";
}

void LauncherModel::quickListActionInvoked(const QString &appId, int actionIndex)
{
    int index = findApplication(appId);
    if (index < 0) {
        return;
    }

    LauncherItem *item = m_list.at(index);
    QuickListModel *model = qobject_cast<QuickListModel*>(item->quickList());
    if (model) {
        QString actionId = model->get(actionIndex).actionId();

        // Check if this is one of the launcher actions we handle ourselves
        if (actionId == QLatin1String("launch_item")) {
            QDesktopServices::openUrl(getUrlForAppId(appId));

        // Nope, we don't know this action, let the backend forward it to the application
        } else {
            // TODO: forward quicklist action to app, possibly via m_dbusIface
        }
    }
}

void LauncherModel::setUser(const QString &username)
{
    if (m_user != username) {
        m_user = username;
        refresh();
    }
}

QString LauncherModel::getUrlForAppId(const QString &appId) const
{
    // appId is either an appId or a legacy app name.  Let's find out which
    if (appId.isEmpty()) {
        return QString();
    }

    if (!appId.contains('_')) {
        return "application:///" + appId + ".desktop";
    }

    QStringList parts = appId.split('_');
    QString package = parts.value(0);
    QString app = parts.value(1, QStringLiteral("first-listed-app"));
    return "appid://" + package + "/" + app + "/current-user-version";
}

ApplicationManagerInterface *LauncherModel::applicationManager() const
{
    return nullptr;
}

void LauncherModel::setApplicationManager(unity::shell::application::ApplicationManagerInterface *appManager)
{
    Q_UNUSED(appManager)
    qWarning() << "This plugin syncs all its states from AccountsService. Not using ApplicationManager.";
    return;
}

bool LauncherModel::onlyPinned() const
{
    return m_onlyPinned;
}

void LauncherModel::setOnlyPinned(bool onlyPinned)
{
    if (m_onlyPinned != onlyPinned) {
        m_onlyPinned = onlyPinned;
        Q_EMIT onlyPinnedChanged();
        refresh();
    }
}

int LauncherModel::findApplication(const QString &appId)
{
    for (int i = 0; i < m_list.count(); ++i) {
        LauncherItem *item = m_list.at(i);
        if (item->appId() == appId) {
            return i;
        }
    }
    return -1;
}

void LauncherModel::refresh()
{
    if (!m_accounts || m_user.isEmpty()) {
        refreshWithItems(QList<QVariantMap>());
    } else {
        QDBusPendingCall pendingCall = m_accounts->getUserPropertyAsync(m_user, QStringLiteral("com.canonical.unity.AccountsService"), QStringLiteral("LauncherItems"));
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pendingCall, this);
        connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

            QDBusPendingReply<QVariant> reply = *watcher;
            watcher->deleteLater();
            if (reply.isError()) {
                qWarning() << "Failed to refresh LauncherItems" << reply.error().message();
                return;
            }

            refreshWithItems(qdbus_cast<QList<QVariantMap>>(reply.value().value<QDBusArgument>()));
        });
    }
}

void LauncherModel::refreshWithItems(const QList<QVariantMap> &items)
{
    // First walk through all the existing items and see if we need to remove something
    QList<LauncherItem*> toBeRemoved;

    Q_FOREACH (LauncherItem* item, m_list) {
        bool found = false;
        Q_FOREACH(const QVariant &asItem, items) {
            QVariantMap cachedMap = asItem.toMap();
            if (cachedMap.value(QStringLiteral("id")).toString() == item->appId()) {
                // Only keep and update it if we either show unpinned or it is pinned
                if (!m_onlyPinned || cachedMap.value(QStringLiteral("pinned")).toBool()) {
                    found = true;
                    item->setName(cachedMap.value(QStringLiteral("name")).toString());
                    item->setIcon(cachedMap.value(QStringLiteral("icon")).toString());
                    item->setCount(cachedMap.value(QStringLiteral("count")).toInt());
                    item->setCountVisible(cachedMap.value(QStringLiteral("countVisible")).toBool());
                    item->setProgress(cachedMap.value(QStringLiteral("progress")).toInt());
                    item->setRunning(cachedMap.value(QStringLiteral("running")).toBool());

                    int idx = m_list.indexOf(item);
                    Q_EMIT dataChanged(index(idx), index(idx), {RoleName, RoleIcon, RoleCount, RoleCountVisible, RoleRunning, RoleProgress});
                }
                break;
            }
        }
        if (!found) {
            toBeRemoved.append(item);
        }
    }

    Q_FOREACH (LauncherItem* item, toBeRemoved) {
        int idx = m_list.indexOf(item);
        beginRemoveRows(QModelIndex(), idx, idx);
        m_list.takeAt(idx)->deleteLater();
        endRemoveRows();
    }

    // Now walk through list and see if we need to add something
    int skipped = 0;
    for (int asIndex = 0; asIndex < items.count(); ++asIndex) {
        QVariant entry = items.at(asIndex);

        if (m_onlyPinned && !entry.toMap().value(QStringLiteral("pinned")).toBool()) {
            // Skipping it as we only show pinned and it is not
            skipped++;
            continue;
        }
        int newPosition = asIndex - skipped;

        int itemIndex = -1;
        for (int i = 0; i < m_list.count(); ++i) {
            if (m_list.at(i)->appId() == entry.toMap().value(QStringLiteral("id")).toString()) {
                itemIndex = i;
                break;
            }
        }

        if (itemIndex == -1) {
            QVariantMap cachedMap = entry.toMap();
            // Need to add it. Just add it into the addedIndex to keep same ordering as the list in AS.
            LauncherItem *item = new LauncherItem(cachedMap.value(QStringLiteral("id")).toString(),
                                                  cachedMap.value(QStringLiteral("name")).toString(),
                                                  cachedMap.value(QStringLiteral("icon")).toString(),
                                                  this);
            item->setPinned(true);
            item->setCount(cachedMap.value(QStringLiteral("count")).toInt());
            item->setCountVisible(cachedMap.value(QStringLiteral("countVisible")).toBool());
            item->setProgress(cachedMap.value(QStringLiteral("progress")).toInt());
            item->setRunning(cachedMap.value(QStringLiteral("running")).toBool());
            beginInsertRows(QModelIndex(), newPosition, newPosition);
            m_list.insert(newPosition, item);
            endInsertRows();
        } else if (itemIndex != newPosition) {
            // The item is already there, but it is in a different place than in the settings.
            // Move it to the addedIndex
            beginMoveRows(QModelIndex(), itemIndex, itemIndex, QModelIndex(), newPosition);
            m_list.move(itemIndex, newPosition);
            endMoveRows();
        }
    }
}

void LauncherModel::propertiesChanged(const QString &user, const QString &interface, const QStringList &changed)
{
    if (user != m_user || interface != QLatin1String("com.canonical.unity.AccountsService") || !changed.contains(QStringLiteral("LauncherItems"))) {
        return;
    }
    refresh();
}
