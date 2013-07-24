/*
 * Copyright (C) 2012,2013 Canonical, Ltd.
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
 *
 * Authors: Gerry Boland <gerry.boland@canonical.com>
 *          Michael Terry <michael.terry@canonical.com>
 */

#ifndef UNITY_ACCOUNTSSERVICE_H
#define UNITY_ACCOUNTSSERVICE_H

#include <QtDBus/QDBusInterface>
#include <QtCore/QMap>
#include <QtCore/QObject>
#include <QtCore/QString>

class AccountsService: public QObject
{
    Q_OBJECT

public:
    explicit AccountsService(QObject *parent = 0);

public Q_SLOTS:
    QVariant getUserProperty(const QString &user, const QString &property);
    void setUserProperty(const QString &user, const QString &property, const QVariant &value);

private Q_SLOTS:
    QDBusInterface *getUserInterface(const QString &user);

private:
    QDBusInterface *accounts_manager;
    QMap<QString, QDBusInterface *> users;
};

#endif
