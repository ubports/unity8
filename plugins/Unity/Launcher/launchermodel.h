/*
 * Copyright 2013 Canonical Ltd.
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

#ifndef LAUNCHERMODEL_H
#define LAUNCHERMODEL_H

// unity-api
#include <unity/shell/launcher/LauncherModelInterface.h>
#include <unity/shell/application/ApplicationManagerInterface.h>

// Qt
#include <QAbstractListModel>

class LauncherItem;
class LauncherBackend;

using namespace unity::shell::launcher;
using namespace unity::shell::application;

class LauncherModel: public LauncherModelInterface
{
   Q_OBJECT

public:
    LauncherModel(QObject *parent = 0);
    ~LauncherModel();

    int rowCount(const QModelIndex &parent) const;

    QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE unity::shell::launcher::LauncherItemInterface* get(int index) const;
    Q_INVOKABLE void move(int oldIndex, int newIndex);
    Q_INVOKABLE void pin(const QString &appId, int index = -1);
    Q_INVOKABLE void requestRemove(const QString &appId);
    Q_INVOKABLE void quickListActionInvoked(const QString &appId, int actionIndex);
    Q_INVOKABLE void setUser(const QString &username);
    Q_INVOKABLE QString getUrlForAppId(const QString &appId) const;

    unity::shell::application::ApplicationManagerInterface* applicationManager() const;
    void setApplicationManager(unity::shell::application::ApplicationManagerInterface *appManager);

private:
    void storeAppList();
    int findApplication(const QString &appId);

private Q_SLOTS:
    void progressChanged(const QString &appId, int progress);
    void countChanged(const QString &appId, int count);
    void refreshStoredApplications();

    void applicationAdded(const QModelIndex &parent, int row);
    void applicationRemoved(const QModelIndex &parent, int row);
    void focusedAppIdChanged();

private:
    QList<LauncherItem*> m_list;
    bool m_greeterMode;
    LauncherBackend *m_backend;
    ApplicationManagerInterface *m_appManager;
};

#endif // LAUNCHERMODEL_H
