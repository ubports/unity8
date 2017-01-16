/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "dbusapplicationmenuregistry.h"
#include "menuregistraradaptor.h"

DBusApplicationMenuRegistry::DBusApplicationMenuRegistry(QObject *parent)
    : ApplicationMenuRegistry(parent)
{
    new MenuRegistrarAdaptor(this);

    QDBusConnection connection = QDBusConnection::sessionBus();
    if (!connection.registerObject("/com/ubuntu/MenuRegistrar", this)) {
        qCWarning(UNITY_APPMENU) << "Unable to register DBus object /com/ubuntu/MenuRegistrar";
    }
    if (!connection.registerService("com.ubuntu.MenuRegistrar")) {
        qCWarning(UNITY_APPMENU) << "Unable to register DBus service com.ubuntu.MenuRegistrar";
    }
}

DBusApplicationMenuRegistry::~DBusApplicationMenuRegistry()
{
    QDBusConnection connection = QDBusConnection::sessionBus();
    connection.unregisterObject("/com/ubuntu/MenuRegistrar");
}

ApplicationMenuRegistry *DBusApplicationMenuRegistry::instance()
{
    static ApplicationMenuRegistry* reg(new DBusApplicationMenuRegistry());
    return reg;
}
