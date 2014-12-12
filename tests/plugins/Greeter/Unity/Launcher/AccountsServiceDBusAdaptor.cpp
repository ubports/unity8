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

#include "AccountsServiceDBusAdaptor.h"
#include <QDebug>
#include <QDBusArgument>
#include <QDBusMessage>
#include <QDBusMetaType>

AccountsServiceDBusAdaptor::AccountsServiceDBusAdaptor(QObject* parent)
  : QObject(parent)
{
    qDBusRegisterMetaType<QList<QVariantMap>>();
}

QVariant AccountsServiceDBusAdaptor::getUserProperty(const QString &user, const QString &interface, const QString &property)
{
    Q_UNUSED(user)
    Q_UNUSED(interface)
    Q_UNUSED(property) // We only fake one property here (launcher-items)

    QDBusMessage msg;
    QVariant v = QVariant::fromValue(properties);
    QDBusVariant dv(v);
    QVariant packed = QVariant::fromValue(dv);
    msg << packed;

    return packed.value<QDBusArgument>().asVariant();
}

void AccountsServiceDBusAdaptor::simulatePropertyChange(const QString &user, const QString &property, const QVariant &value)
{
    Q_ASSERT(property == "launcher-items");
    properties = value.value<QList<QVariantMap>>();
    Q_EMIT propertiesChanged(user, "com.canonical.unity.AccountsService", QStringList() << property);
}
