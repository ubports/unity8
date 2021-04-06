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

#include <memory>
#include <QFutureWatcher>
#include <lomiri/shell/launcher/AppDrawerModelInterface.h>

#include "launcheritem.h"

class UalWrapper;
class XdgWatcher;

class AppDrawerModel: public AppDrawerModelInterface
{
    Q_OBJECT
    // TODO: Add this to AppDrawerModelInterface in unity-api.
    // Or, better yet, remove AppDrawerModelInterface from unity-api.
    Q_PROPERTY(bool refreshing READ refreshing NOTIFY refreshingChanged)
public:
    AppDrawerModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    // TODO: add these to AppDrawerModelInterface too.
    bool refreshing();
    Q_INVOKABLE void refresh();

Q_SIGNALS:
    void refreshingChanged();

private Q_SLOTS:
    void appAdded(const QString &appId);
    void appRemoved(const QString &appId);
    void appInfoChanged(const QString &appId);

    void onRefreshFinished();

private:
    // Using shared_ptr is unavoidable in order to share the refresh result
    // from the worker thread safely without a memory leak, in case the model
    // is destructed before the worker finishes.
    typedef QList<std::shared_ptr<LauncherItem>> ItemList;

    ItemList m_list;
    UalWrapper *m_ual;
    XdgWatcher *m_xdgWatcher;
    QFutureWatcher<ItemList> m_refreshFutureWatcher;
    bool m_refreshing;
};
