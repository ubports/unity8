/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "dashconnection.h"

#include <QDBusInterface>
#include <QDBusPendingCall>

/* The default implementation of AbstractDBusServiceMonitor creates a QDBusInterface when the service
 * appears on the bus.
 *
 * On construction QDBusInterface synchronously introspects the service, which will block the GUI
 * thread of this process if the service is busy. QDBusAbstractInterface does not perform this
 * introspection, so let's subclass that and avoid the blocking scenario.
 *
 * However we lose Qt's wrapping of the DBus service with a MetaObject, with the result that we
 * cannot easily connect to DBus signals with the usual connect() calls. So this approach only
 * suited to push communication with the DBus service.
 */
class AsyncDBusInterface : public QDBusAbstractInterface
{
public:
    AsyncDBusInterface(const QString &service, const QString &path,
                       const QString &interface, const QDBusConnection &connection,
                       QObject *parent = 0)
    : QDBusAbstractInterface(service, path, interface.toLatin1().data(), connection, parent)
    {}
    ~AsyncDBusInterface() = default;
};


DashConnection::DashConnection(const QString &service, const QString &path, const QString &interface, QObject *parent):
    AbstractDBusServiceMonitor(service, path, interface, SessionBus, parent)
{

}

/* Override the default implementation to create a non-blocking DBus interface (see note above). */
QDBusAbstractInterface* DashConnection::createInterface(const QString &service, const QString &path,
                                        const QString &interface, const QDBusConnection &connection)
{
    return new AsyncDBusInterface(service, path, interface, connection);
}

void DashConnection::setCurrentScope(int index, bool animate, bool isSwipe)
{
    if (dbusInterface()) {
        dbusInterface()->asyncCall(QStringLiteral("SetCurrentScope"), index, animate, isSwipe);
    }
}
