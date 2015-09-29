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

#include "launchermodel.h"
#include "launcheritem.h"
#include "gsettings.h"
#include "desktopfilehandler.h"
#include "dbusinterface.h"
#include "asadapter.h"

#include <unity/shell/application/ApplicationInfoInterface.h>

#include <QDesktopServices>
#include <QDebug>

using namespace unity::shell::application;

LauncherModel::LauncherModel(QObject *parent):
    LauncherModelInterface(parent),
    m_settings(new GSettings(this)),
    m_dbusIface(new DBusInterface(this)),
    m_asAdapter(new ASAdapter()),
    m_appManager(nullptr)
{
    connect(m_dbusIface, &DBusInterface::countChanged, this, &LauncherModel::countChanged);
    connect(m_dbusIface, &DBusInterface::countVisibleChanged, this, &LauncherModel::countVisibleChanged);
    connect(m_dbusIface, &DBusInterface::progressChanged, this, &LauncherModel::progressChanged);
    connect(m_dbusIface, &DBusInterface::refreshCalled, this, &LauncherModel::refresh);
    connect(m_dbusIface, &DBusInterface::alertCalled, this, &LauncherModel::alert);

    connect(m_settings, &GSettings::changed, this, &LauncherModel::refresh);

    refresh();
}

LauncherModel::~LauncherModel()
{
    while (!m_list.empty()) {
        m_list.takeFirst()->deleteLater();
    }

    delete m_asAdapter;
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
        case RoleAlerting:
            return item->alerting();
        case RoleRunning:
            return item->running();
        default:
            qWarning() << Q_FUNC_INFO << "missing role, implement me";
            return QVariant();
    }

    return QVariant();
}

void LauncherModel::setAlerting(const QString &appId, bool alerting) {
    int index = findApplication(appId);
    if (index >= 0) {
        QModelIndex modelIndex = this->index(index);
        LauncherItem *item = m_list.at(index);
        if (!item->focused()) {
            item->setAlerting(alerting);
            Q_EMIT dataChanged(modelIndex, modelIndex, QVector<int>() << RoleAlerting);
        }
    }
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
    // Make sure its not moved outside the lists
    if (newIndex < 0) {
        newIndex = 0;
    }
    if (newIndex >= m_list.count()) {
        newIndex = m_list.count()-1;
    }

    // Nothing to do?
    if (oldIndex == newIndex) {
        return;
    }

    // QList's and QAbstractItemModel's move implementation differ when moving an item up the list :/
    // While QList needs the index in the resulting list, beginMoveRows expects it to be in the current list
    // adjust the model's index by +1 in case we're moving upwards
    int newModelIndex = newIndex > oldIndex ? newIndex+1 : newIndex;

    beginMoveRows(QModelIndex(), oldIndex, oldIndex, QModelIndex(), newModelIndex);
    m_list.move(oldIndex, newIndex);
    endMoveRows();

    if (!m_list.at(newIndex)->pinned()) {
        pin(m_list.at(newIndex)->appId());
    } else {
        storeAppList();
    }
}

void LauncherModel::pin(const QString &appId, int index)
{
    int currentIndex = findApplication(appId);

    if (currentIndex >= 0) {
        if (index == -1 || index == currentIndex) {
            m_list.at(currentIndex)->setPinned(true);
            QModelIndex modelIndex = this->index(currentIndex);
            Q_EMIT dataChanged(modelIndex, modelIndex, {RolePinned});
        } else {
            move(currentIndex, index);
            // move() will store the list to the backend itself, so just exit at this point.
            return;
        }
    } else {
        if (index == -1) {
            index = m_list.count();
        }

        DesktopFileHandler desktopFile(appId);
        if (!desktopFile.isValid()) {
            qWarning() << "Can't pin this application, there is no .desktop file available.";
            return;
        }

        beginInsertRows(QModelIndex(), index, index);
        LauncherItem *item = new LauncherItem(appId,
                                              desktopFile.displayName(),
                                              desktopFile.icon(),
                                              this);
        item->setPinned(true);
        m_list.insert(index, item);
        endInsertRows();
    }

    storeAppList();
}

void LauncherModel::requestRemove(const QString &appId)
{
    unpin(appId);
    storeAppList();
}

void LauncherModel::quickListActionInvoked(const QString &appId, int actionIndex)
{
    const int index = findApplication(appId);
    if (index < 0) {
        return;
    }

    LauncherItem *item = m_list.at(index);
    QuickListModel *model = qobject_cast<QuickListModel*>(item->quickList());
    if (model) {
        const QString actionId = model->get(actionIndex).actionId();

        // Check if this is one of the launcher actions we handle ourselves
        if (actionId == QLatin1String("pin_item")) {
            if (item->pinned()) {
                requestRemove(appId);
            } else {
                pin(appId);
            }
        } else if (actionId == QLatin1String("launch_item")) {
            QDesktopServices::openUrl(getUrlForAppId(appId));
        } else if (actionId == QLatin1String("stop_item")) { // Quit
            if (m_appManager) {
                m_appManager->stopApplication(appId);
            }
        // Nope, we don't know this action, let the backend forward it to the application
        } else {
            // TODO: forward quicklist action to app, possibly via m_dbusIface
        }
    }
}

void LauncherModel::setUser(const QString &username)
{
    Q_UNUSED(username)
    qWarning() << "This backend doesn't support multiple users";
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
    return m_appManager;
}

void LauncherModel::setApplicationManager(unity::shell::application::ApplicationManagerInterface *appManager)
{
    // Is there already another appmanager set?
    if (m_appManager) {
        // Disconnect any signals
        disconnect(this, &LauncherModel::applicationAdded, 0, nullptr);
        disconnect(this, &LauncherModel::applicationRemoved, 0, nullptr);
        disconnect(this, &LauncherModel::focusedAppIdChanged, 0, nullptr);

        // remove any recent/running apps from the launcher
        QList<int> recentAppIndices;
        for (int i = 0; i < m_list.count(); ++i) {
            if (m_list.at(i)->recent()) {
                recentAppIndices << i;
            }
        }
        int run = 0;
        while (recentAppIndices.count() > 0) {
            beginRemoveRows(QModelIndex(), recentAppIndices.first() - run, recentAppIndices.first() - run);
            m_list.takeAt(recentAppIndices.first() - run)->deleteLater();
            endRemoveRows();
            recentAppIndices.takeFirst();
            ++run;
        }
    }

    m_appManager = appManager;
    connect(m_appManager, &ApplicationManagerInterface::rowsInserted, this, &LauncherModel::applicationAdded);
    connect(m_appManager, &ApplicationManagerInterface::rowsAboutToBeRemoved, this, &LauncherModel::applicationRemoved);
    connect(m_appManager, &ApplicationManagerInterface::focusedApplicationIdChanged, this, &LauncherModel::focusedAppIdChanged);

    Q_EMIT applicationManagerChanged();

    for (int i = 0; i < appManager->count(); ++i) {
        applicationAdded(QModelIndex(), i);
    }
}

bool LauncherModel::onlyPinned() const
{
    return false;
}

void LauncherModel::setOnlyPinned(bool onlyPinned) {
    Q_UNUSED(onlyPinned);
    qWarning() << "This launcher implementation does not support showing only pinned apps";
}

void LauncherModel::storeAppList()
{
    QStringList appIds;
    Q_FOREACH(LauncherItem *item, m_list) {
        if (item->pinned()) {
            appIds << item->appId();
        }
    }
    m_settings->setStoredApplications(appIds);
    m_asAdapter->syncItems(m_list);
}

void LauncherModel::unpin(const QString &appId)
{
    const int index = findApplication(appId);
    if (index < 0) {
        return;
    }

    if (m_appManager->findApplication(appId)) {
        if (m_list.at(index)->pinned()) {
            m_list.at(index)->setPinned(false);
            QModelIndex modelIndex = this->index(index);
            Q_EMIT dataChanged(modelIndex, modelIndex, {RolePinned});
        }
    } else {
        beginRemoveRows(QModelIndex(), index, index);
        m_list.takeAt(index)->deleteLater();
        endRemoveRows();
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

void LauncherModel::progressChanged(const QString &appId, int progress)
{
    const int idx = findApplication(appId);
    if (idx >= 0) {
        LauncherItem *item = m_list.at(idx);
        item->setProgress(progress);
        Q_EMIT dataChanged(index(idx), index(idx), {RoleProgress});
    }
}

void LauncherModel::countChanged(const QString &appId, int count)
{
    const int idx = findApplication(appId);
    if (idx >= 0) {
        LauncherItem *item = m_list.at(idx);
        item->setCount(count);
        if (item->countVisible()) {
            setAlerting(item->appId(), true);
        }
        m_asAdapter->syncItems(m_list);
        Q_EMIT dataChanged(index(idx), index(idx), {RoleCount});
    }
}

void LauncherModel::countVisibleChanged(const QString &appId, bool countVisible)
{
    int idx = findApplication(appId);
    if (idx >= 0) {
        LauncherItem *item = m_list.at(idx);
        item->setCountVisible(countVisible);
        if (countVisible) {
            setAlerting(item->appId(), true);
        }
        Q_EMIT dataChanged(index(idx), index(idx), {RoleCountVisible});

        // If countVisible goes to false, and the item is neither pinned nor recent we can drop it
        if (!countVisible && !item->pinned() && !item->recent()) {
            beginRemoveRows(QModelIndex(), idx, idx);
            m_list.takeAt(idx)->deleteLater();
            endRemoveRows();
        }
    } else {
        // Need to create a new LauncherItem and show the highlight
        DesktopFileHandler desktopFile(appId);
        if (countVisible && desktopFile.isValid()) {
            LauncherItem *item = new LauncherItem(appId,
                                                  desktopFile.displayName(),
                                                  desktopFile.icon());
            item->setCountVisible(true);
            beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
            m_list.append(item);
            endInsertRows();
        }
    }
    m_asAdapter->syncItems(m_list);
}

void LauncherModel::refresh()
{
    // First walk through all the existing items and see if we need to remove something
    QList<LauncherItem*> toBeRemoved;
    Q_FOREACH (LauncherItem* item, m_list) {
        DesktopFileHandler desktopFile(item->appId());
        if (!desktopFile.isValid()) {
            // Desktop file not available for this app => drop it!
            toBeRemoved << item;
        } else if (!m_settings->storedApplications().contains(item->appId())) {
            // Item not in settings any more => drop it!
            toBeRemoved << item;
        } else {
            int idx = m_list.indexOf(item);
            item->setName(desktopFile.displayName());
            item->setIcon(desktopFile.icon());
            item->setPinned(item->pinned()); // update pinned text if needed
            item->setRunning(item->running());
            Q_EMIT dataChanged(index(idx), index(idx), {RoleName, RoleIcon, RoleRunning});
        }
    }

    Q_FOREACH (LauncherItem* item, toBeRemoved) {
        unpin(item->appId());
    }

    bool changed = toBeRemoved.count() > 0;

    // This brings the Launcher into sync with the settings backend again. There's an issue though:
    // If we can't find a .desktop file for an entry we need to skip it. That makes our settingsIndex
    // go out of sync with the actual index of items. So let's also use an addedIndex which reflects
    // the settingsIndex minus the skipped items.
    int addedIndex = 0;

    // Now walk through settings and see if we need to add something
    for (int settingsIndex = 0; settingsIndex < m_settings->storedApplications().count(); ++settingsIndex) {
        const QString entry = m_settings->storedApplications().at(settingsIndex);
        int itemIndex = -1;
        for (int i = 0; i < m_list.count(); ++i) {
            if (m_list.at(i)->appId() == entry) {
                itemIndex = i;
                break;
            }
        }

        if (itemIndex == -1) {
            // Need to add it. Just add it into the addedIndex to keep same ordering as the list
            // in the settings.
            DesktopFileHandler desktopFile(entry);
            if (!desktopFile.isValid()) {
                qWarning() << "Couldn't find a .desktop file for" << entry << ". Skipping...";
                continue;
            }

            LauncherItem *item = new LauncherItem(entry,
                                                  desktopFile.displayName(),
                                                  desktopFile.icon(),
                                                  this);
            item->setPinned(true);
            beginInsertRows(QModelIndex(), addedIndex, addedIndex);
            m_list.insert(addedIndex, item);
            endInsertRows();
            changed = true;
        } else if (itemIndex != addedIndex) {
            // The item is already there, but it is in a different place than in the settings.
            // Move it to the addedIndex
            beginMoveRows(QModelIndex(), itemIndex, itemIndex, QModelIndex(), addedIndex);
            m_list.move(itemIndex, addedIndex);
            endMoveRows();
            changed = true;
        }

        // Just like settingsIndex, this will increase with every item, except the ones we
        // skipped with the "continue" call above.
        addedIndex++;
    }

    if (changed) {
        Q_EMIT hint();
    }

    m_asAdapter->syncItems(m_list);
}

void LauncherModel::alert(const QString &appId)
{
    int idx = findApplication(appId);
    if (idx >= 0) {
        LauncherItem *item = m_list.at(idx);
        setAlerting(item->appId(), true);
        Q_EMIT dataChanged(index(idx), index(idx), QVector<int>() << RoleAlerting);
    }
}

void LauncherModel::applicationAdded(const QModelIndex &parent, int row)
{
    Q_UNUSED(parent);

    ApplicationInfoInterface *app = m_appManager->get(row);
    if (!app) {
        qWarning() << "LauncherModel received an applicationAdded signal, but there's no such application!";
        return;
    }

    if (app->appId() == QLatin1String("unity8-dash")) {
        // Not adding the dash app
        return;
    }

    const int itemIndex = findApplication(app->appId());
    if (itemIndex != -1) {
        LauncherItem *item = m_list.at(itemIndex);
        if (!item->recent()) {
            item->setRecent(true);
            Q_EMIT dataChanged(index(itemIndex), index(itemIndex), {RoleRecent});
        }
        item->setRunning(true);
    } else {
        LauncherItem *item = new LauncherItem(app->appId(), app->name(), app->icon().toString(), this);
        item->setRecent(true);
        item->setRunning(true);
        item->setFocused(app->focused());

        beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
        m_list.append(item);
        endInsertRows();
    }
    m_asAdapter->syncItems(m_list);
    Q_EMIT dataChanged(index(itemIndex), index(itemIndex), {RoleRunning});
}

void LauncherModel::applicationRemoved(const QModelIndex &parent, int row)
{
    Q_UNUSED(parent)

    int appIndex = -1;
    for (int i = 0; i < m_list.count(); ++i) {
        if (m_list.at(i)->appId() == m_appManager->get(row)->appId()) {
            appIndex = i;
            break;
        }
    }

    if (appIndex < 0) {
        qWarning() << Q_FUNC_INFO << "appIndex not found";
        return;
    }

    LauncherItem * item = m_list.at(appIndex);
    item->setRunning(false);

    if (!item->pinned()) {
        beginRemoveRows(QModelIndex(), appIndex, appIndex);
        m_list.takeAt(appIndex)->deleteLater();
        endRemoveRows();
        m_asAdapter->syncItems(m_list);
        Q_EMIT dataChanged(index(appIndex), index(appIndex), {RolePinned});
    }
    Q_EMIT dataChanged(index(appIndex), index(appIndex), {RoleRunning});
}

void LauncherModel::focusedAppIdChanged()
{
    const QString appId = m_appManager->focusedApplicationId();
    for (int i = 0; i < m_list.count(); ++i) {
        LauncherItem *item = m_list.at(i);
        if (!item->focused() && item->appId() == appId) {
            item->setFocused(true);
            Q_EMIT dataChanged(index(i), index(i), {RoleFocused});
        } else if (item->focused() && item->appId() != appId) {
            item->setFocused(false);
            Q_EMIT dataChanged(index(i), index(i), {RoleFocused});
        }
    }
}
