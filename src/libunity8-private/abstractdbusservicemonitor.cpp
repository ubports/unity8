/*
 * Copyright (C) 2011-2014 Canonical, Ltd.
 *
 * Authors:
 *  Ugo Riboni <ugo.riboni@canonical.com>
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

#include "abstractdbusservicemonitor.h"

#include <QDBusInterface>
#include <QDBusServiceWatcher>
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusReply>

AbstractDBusServiceMonitor::AbstractDBusServiceMonitor(const QString &service, const QString &path,
                                                       const QString &interface, const Bus bus,
                                                       QObject *parent)
    : QObject(parent)
    , m_service(service)
    , m_path(path)
    , m_interface(interface)
    , m_bus(bus)
    , m_watcher(new QDBusServiceWatcher(service,
                                        (bus == SystemBus) ? QDBusConnection::systemBus()
                                                           : QDBusConnection::sessionBus()))
    , m_dbusInterface(nullptr)
{
    connect(m_watcher, &QDBusServiceWatcher::serviceRegistered, this, &AbstractDBusServiceMonitor::onServiceRegistered);
    connect(m_watcher, &QDBusServiceWatcher::serviceUnregistered, this, &AbstractDBusServiceMonitor::onServiceUnregistered);

    // Connect to the service if it's up already
    QDBusConnectionInterface* sessionBus = QDBusConnection::sessionBus().interface();
    QDBusReply<bool> reply = sessionBus->isServiceRegistered(m_service);
    if (reply.isValid() && reply.value()) {
        onServiceRegistered(m_service);
    }
}

AbstractDBusServiceMonitor::~AbstractDBusServiceMonitor()
{
    delete m_watcher;
    delete m_dbusInterface;
}

void AbstractDBusServiceMonitor::onServiceRegistered(const QString &)
{
    if (m_dbusInterface != nullptr) {
        delete m_dbusInterface;
        m_dbusInterface = nullptr;
    }

    m_dbusInterface = createInterface(m_service, m_path, m_interface,
                                      (m_bus == SystemBus) ? QDBusConnection::systemBus()
                                                           : QDBusConnection::sessionBus());
    Q_EMIT serviceAvailableChanged(true);
}

/*
 * Default implementation creates a QDBusInterface. This performs blocking introspection of the
 * service at initialization, which may be undesirable if the service is slow/blocked.
 */
QDBusAbstractInterface*
AbstractDBusServiceMonitor::createInterface(const QString &service, const QString &path,
                                            const QString &interface, const QDBusConnection &connection)
{
    return new QDBusInterface(service, path, interface, connection);
}

void AbstractDBusServiceMonitor::onServiceUnregistered(const QString &)
{
    if (m_dbusInterface != nullptr) {
        delete m_dbusInterface;
        m_dbusInterface = nullptr;
    }

    Q_EMIT serviceAvailableChanged(false);
}

QDBusAbstractInterface* AbstractDBusServiceMonitor::dbusInterface() const
{
    return m_dbusInterface;
}

bool AbstractDBusServiceMonitor::serviceAvailable() const
{
    return m_dbusInterface != nullptr;
}
