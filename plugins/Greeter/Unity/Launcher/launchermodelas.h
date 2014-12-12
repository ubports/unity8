/*
 * Copyright 2014 Canonical Ltd.
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

#include <unity/shell/launcher/LauncherModelInterface.h>
#include <unity/shell/application/ApplicationManagerInterface.h>

#include <QAbstractListModel>

class LauncherItem;
class GSettings;
class AccountsServiceDBusAdaptor;

using namespace unity::shell::launcher;
using namespace unity::shell::application;

class LauncherModel: public LauncherModelInterface
{
   Q_OBJECT

public:
    LauncherModel(QObject *parent = 0);
    ~LauncherModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE unity::shell::launcher::LauncherItemInterface* get(int index) const;
    Q_INVOKABLE void move(int oldIndex, int newIndex);
    Q_INVOKABLE void pin(const QString &appId, int index = -1);
    Q_INVOKABLE void quickListActionInvoked(const QString &appId, int actionIndex);
    Q_INVOKABLE void setUser(const QString &username);
    Q_INVOKABLE QString getUrlForAppId(const QString &appId) const;

    unity::shell::application::ApplicationManagerInterface* applicationManager() const;
    void setApplicationManager(unity::shell::application::ApplicationManagerInterface *appManager);

    int findApplication(const QString &appId);

public Q_SLOTS:
    void requestRemove(const QString &appId) override;
    Q_INVOKABLE void refresh();

private Q_SLOTS:
    void propertiesChanged(const QString &user, const QString &interface, const QStringList &changed);

private:
    QString m_user;
    QList<LauncherItem*> m_list;
    AccountsServiceDBusAdaptor *m_accounts;

    friend class LauncherModelASTest;
};

#endif // LAUNCHERMODEL_H
