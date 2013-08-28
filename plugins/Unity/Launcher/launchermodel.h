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

// Qt
#include <QAbstractListModel>

class LauncherItem;
class LauncherBackend;

using namespace unity::shell::launcher;

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
    Q_INVOKABLE void applicationFocused(const QString &appId);

private:
    void storeAppList();
    int findApplication(const QString &appId);

private:
    QList<LauncherItem*> m_list;
    LauncherBackend *m_backend;
};

#endif // LAUNCHERMODEL_H
