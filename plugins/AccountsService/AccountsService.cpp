/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 * Author: Michael Terry <michael.terry@canonical.com>
 */

#include "AccountsService.h"
#include <QtCore/QEvent>
#include <QtDBus/QDBusPendingReply>

AccountsService::AccountsService(QObject* parent)
  : QObject(parent),
    accounts_manager(NULL),
    users()
{
    accounts_manager = new QDBusInterface("org.freedesktop.Accounts",
                                          "/org/freedesktop/Accounts",
                                          "org.freedesktop.Accounts",
                                          QDBusConnection::SM_BUSNAME(), this);
}

QVariant AccountsService::getUserProperty(const QString &user, const QString &property)
{
    auto iface = getUserInterface(user);
    if (iface != nullptr && iface->isValid()) {
        auto answer = iface->call("Get", "com.canonical.unity.AccountsService", property);
        if (answer.type() == QDBusMessage::ReplyMessage) {
            return answer.arguments()[0].value<QDBusVariant>().variant();
        }
    }
    return QVariant();
}

void AccountsService::setUserProperty(const QString &user, const QString &property, const QVariant &value)
{
    auto iface = getUserInterface(user);
    if (iface != nullptr && iface->isValid()) {
        // The value needs to be carefully wrapped thrice
        iface->call("Set", "com.canonical.unity.AccountsService", property, QVariant::fromValue(QDBusVariant(value)));
    }
}

QDBusInterface *AccountsService::getUserInterface(const QString &user)
{
    auto iface = users.value(user);
    if (iface == nullptr && accounts_manager->isValid()) {
        auto answer = accounts_manager->call("FindUserByName", user);
        if (answer.type() == QDBusMessage::ReplyMessage) {
            iface = new QDBusInterface("org.freedesktop.Accounts",
                                       answer.arguments()[0].value<QDBusObjectPath>().path(),
                                       "org.freedesktop.DBus.Properties",
                                       accounts_manager->connection(), this);
            users.insert(user, iface);
        }
    }
    return iface;
}

