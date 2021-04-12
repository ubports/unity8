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
    if (!connection.registerObject("/com/lomiri/MenuRegistrar", this)) {
        qCWarning(LOMIRI_APPMENU) << "Unable to register DBus object /com/lomiri/MenuRegistrar";
    }
    if (!connection.registerService("com.lomiri.MenuRegistrar")) {
        qCWarning(LOMIRI_APPMENU) << "Unable to register DBus service com.lomiri.MenuRegistrar";
    }
}

DBusApplicationMenuRegistry::~DBusApplicationMenuRegistry()
{
    QDBusConnection connection = QDBusConnection::sessionBus();
    connection.unregisterObject("/com/lomiri/MenuRegistrar");
}

ApplicationMenuRegistry *DBusApplicationMenuRegistry::instance()
{
    static ApplicationMenuRegistry* reg(new DBusApplicationMenuRegistry());
    return reg;
}
