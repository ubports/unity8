/*
 * Copyright 2013-2014 Canonical Ltd.
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
    m_accounts(new AccountsServiceDBusAdaptor(this))
{
    qDebug() << "Loading AS based launcher model";
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
        if (actionId == "launch_item") {
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

    if (!appId.contains("_")) {
        return "application:///" + appId + ".desktop";
    }

    QStringList parts = appId.split('_');
    QString package = parts.value(0);
    QString app = parts.value(1, "first-listed-app");
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

typedef QList<QVariantMap> VariantMapList;
void LauncherModel::refresh()
{
    QList<QVariantMap> items;

    if (m_accounts && !m_user.isEmpty()) {
        items = m_accounts->getUserProperty<VariantMapList>(m_user, "com.canonical.unity.AccountsService", "launcher-items");
    }

    // First walk through all the existing items and see if we need to remove something
    QList<LauncherItem*> toBeRemoved;

    Q_FOREACH (LauncherItem* item, m_list) {
        bool found = false;
        Q_FOREACH(const QVariant &asItem, items) {
            if (asItem.toMap().value("id").toString() == item->appId()) {
                found = true;
                item->setName(asItem.toMap().value("name").toString());
                item->setIcon(asItem.toMap().value("icon").toString());
                item->setCount(asItem.toMap().value("count").toInt());
                item->setCountVisible(asItem.toMap().value("countVisible").toBool());
                int idx = m_list.indexOf(item);
                Q_EMIT dataChanged(index(idx), index(idx), QVector<int>() << RoleName << RoleIcon);
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
    for (int asIndex = 0; asIndex < items.count(); ++asIndex) {
        QVariant entry = items.at(asIndex);
        qDebug() << "have AS item" << entry.toMap().value("id").toString();
        int itemIndex = -1;
        for (int i = 0; i < m_list.count(); ++i) {
            if (m_list.at(i)->appId() == entry.toMap().value("id").toString()) {
                itemIndex = i;
                break;
            }
        }

        if (itemIndex == -1) {
            // Need to add it. Just add it into the addedIndex to keep same ordering as the list in AS.
            LauncherItem *item = new LauncherItem(entry.toMap().value("id").toString(),
                                                  entry.toMap().value("name").toString(),
                                                  entry.toMap().value("icon").toString(),
                                                  this);
            item->setPinned(true);
            item->setCount(entry.toMap().value("count").toInt());
            item->setCountVisible(entry.toMap().value("countVisible").toBool());
            beginInsertRows(QModelIndex(), asIndex, asIndex);
            m_list.insert(asIndex, item);
            endInsertRows();
        } else if (itemIndex != asIndex) {
            // The item is already there, but it is in a different place than in the settings.
            // Move it to the addedIndex
            beginMoveRows(QModelIndex(), itemIndex, itemIndex, QModelIndex(), asIndex);
            m_list.move(itemIndex, asIndex);
            endMoveRows();
        }
    }
}

void LauncherModel::propertiesChanged(const QString &user, const QString &interface, const QStringList &changed)
{
    if (user != m_user || interface != "com.canonical.unity.AccountsService" || !changed.contains("launcher-items")) {
        return;
    }
    refresh();
}
