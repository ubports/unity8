/*
 * Copyright (C) 2016 Canonical, Ltd.
 * Copyright (C) 2020 UBports Foundation.
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

#include "appdrawermodel.h"
#include "ualwrapper.h"
#include "xdgwatcher.h"

#include <QDebug>
#include <QDateTime>
#include <QtConcurrentRun>

static std::shared_ptr<LauncherItem> makeSharedLauncherItem(
        const QString &appId, const QString &name, const QString &icon, QObject * parent)
{
    return std::shared_ptr<LauncherItem>(
                new LauncherItem(appId, name, icon, parent),
                [] (LauncherItem *item) { item->deleteLater(); });
}

AppDrawerModel::AppDrawerModel(QObject *parent):
    AppDrawerModelInterface(parent),
    m_ual(new UalWrapper(this)),
    m_xdgWatcher(new XdgWatcher(this)),
    m_refreshing(false)
{
    connect(&m_refreshFutureWatcher, &QFutureWatcher<ItemList>::finished,
            this,                    &AppDrawerModel::onRefreshFinished);

    // keep this a queued connection as it's coming from another thread.
    connect(m_xdgWatcher, &XdgWatcher::appAdded, this, &AppDrawerModel::appAdded, Qt::QueuedConnection);
    connect(m_xdgWatcher, &XdgWatcher::appRemoved, this, &AppDrawerModel::appRemoved, Qt::QueuedConnection);
    connect(m_xdgWatcher, &XdgWatcher::appInfoChanged, this, &AppDrawerModel::appInfoChanged, Qt::QueuedConnection);

    refresh();
}

int AppDrawerModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant AppDrawerModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleAppId:
        return m_list.at(index.row())->appId();
    case RoleName:
        return m_list.at(index.row())->name();
    case RoleIcon:
        return m_list.at(index.row())->icon();
    case RoleKeywords:
        return m_list.at(index.row())->keywords();
    case RoleUsage:
        return m_list.at(index.row())->popularity();
    }

    return QVariant();
}

void AppDrawerModel::appAdded(const QString &appId)
{
    if (m_refreshing)
        // Will be replaced by the refresh result anyway.
        return;

    UalWrapper::AppInfo info = UalWrapper::getApplicationInfo(appId);
    if (!info.valid) {
        qWarning() << "App added signal received but failed to get app info for app" << appId;
        return;
    }

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    auto item = makeSharedLauncherItem(appId, info.name, info.icon, /* parent */ nullptr);
    item->setKeywords(info.keywords);
    item->setPopularity(info.popularity);
    m_list.append(std::move(item));
    endInsertRows();
}

void AppDrawerModel::appRemoved(const QString &appId)
{
    if (m_refreshing)
        // Will be replaced by the refresh result anyway.
        return;

    int idx = -1;
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->appId() == appId) {
            idx = i;
            break;
        }
    }
    if (idx < 0) {
        qWarning() << "App removed signal received but app doesn't seem to be in the drawer model";
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.removeAt(idx);
    endRemoveRows();
}

void AppDrawerModel::appInfoChanged(const QString &appId)
{
    if (m_refreshing)
        // Will be replaced by the refresh result anyway.
        return;

    std::shared_ptr<LauncherItem> item;
    int idx = -1;

    for(int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->appId() == appId) {
            item = m_list.at(i);
            idx = i;
            break;
        }
    }

    if (!item) {
        return;
    }

    UalWrapper::AppInfo info = m_ual->getApplicationInfo(appId);
    item->setPopularity(info.popularity);
    Q_EMIT dataChanged(index(idx), index(idx), {AppDrawerModelInterface::RoleUsage});
}

bool AppDrawerModel::refreshing() {
    return m_refreshing;
}

void AppDrawerModel::refresh() {
    if (m_refreshing)
        return;

    m_refreshFutureWatcher.setFuture(QtConcurrent::run([](QThread *thread) {
        ItemList list;

        Q_FOREACH (const QString &appId, UalWrapper::installedApps()) {
            UalWrapper::AppInfo info = UalWrapper::getApplicationInfo(appId);
            if (!info.valid) {
                qWarning() << "Failed to get app info for app" << appId;
                continue;
            }
            // We don't pass parent in because this may run after the model is destroyed.
            // (And, in fact, we can't, because the model is in a diferent thread.)
            auto item = makeSharedLauncherItem(appId, info.name, info.icon, /* parent */ nullptr);
            item->setKeywords(info.keywords);
            item->setPopularity(info.popularity);
            item->moveToThread(thread);
            list.append(std::move(item));
        }

        return list;
    }, this->thread()));

    m_refreshing = true;
    Q_EMIT refreshingChanged();
}

void AppDrawerModel::onRefreshFinished() {
    if (m_refreshFutureWatcher.isCanceled())
        // This is the result of setting canceled future below.
        return;

    beginResetModel();

    m_list = m_refreshFutureWatcher.result();
    // Remove the future & its result, so that future modifications won't
    // create a copy.
    m_refreshFutureWatcher.setFuture(QFuture<ItemList>());

    endResetModel();

    m_refreshing = false;
    Q_EMIT refreshingChanged();
}
