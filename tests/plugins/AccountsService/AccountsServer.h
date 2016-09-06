/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the  Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * version 3 along with this program.  If not, see
 * <http://www.gnu.org/licenses/>
 *
 * Authored by: Michael Terry <michael.terry@canonical.com>
 */

#ifndef UNITY_ACCOUNTSSERVER_H
#define UNITY_ACCOUNTSSERVER_H

#include <QDBusContext>
#include <QDBusObjectPath>
#include <QObject>
#include <QSet>
#include <QString>

class AccountsServer: public QObject, protected QDBusContext
{
    Q_OBJECT

public:
    explicit AccountsServer(QObject *parent = 0);

public Q_SLOTS:

    QDBusObjectPath FindUserByName(const QString &user);

    // mock only.
    bool AddUser(const QString &user);
    bool RemoveUser(const QString &user);
    void RemoveAllUsers();

private:
    QSet<QString> m_users;
};

#endif
