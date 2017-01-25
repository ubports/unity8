/*
 * Copyright 2012 Canonical Ltd.
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
 *      Olivier Tilloy <olivier.tilloy@canonical.com>
 */

#ifndef __DBUS_ENUMS__
#define __DBUS_ENUMS__

#include <QObject>

// This class acts as a namespace only, with the addition that its enums
// are registered to be exposed on the QML side.
class DBusEnums : public QObject
{
    Q_OBJECT

public:
    enum BusType {
        None = 0,
        SessionBus,
        SystemBus,
        LastBusType
    };
    Q_ENUM(BusType)

    enum ConnectionStatus {
        Disconnected = 0,
        Connecting,
        Connected
    };
    Q_ENUM(ConnectionStatus)

private:
    DBusEnums() {}
};

#endif // __DBUS_ENUMS__
