/*
 * Copyright (C) 2014 Canonical, Ltd.
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
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "AccountsServiceDBusAdaptor.h"
#include <QDebug>

AccountsServiceDBusAdaptor::AccountsServiceDBusAdaptor(QObject* parent)
  : QObject(parent)
{
}

QVariant AccountsServiceDBusAdaptor::getUserProperty(const QString &user, const QString &interface, const QString &property)
{
    Q_UNUSED(user)
    Q_UNUSED(interface)
    qDebug() << "returning properties" << m_properties.value(property);
    return m_properties.value(property);
}

void AccountsServiceDBusAdaptor::setUserProperty(const QString &user, const QString &interface, const QString &property, const QVariant &value)
{
    qDebug() << "setting property" << property << value;
    Q_UNUSED(user)
    Q_UNUSED(interface)
    m_properties[property] = value;
}

void AccountsServiceDBusAdaptor::setUserPropertyAsync(const QString &user, const QString &interface, const QString &property, const QVariant &value)
{
    setUserProperty(user, interface, property, value);
}
