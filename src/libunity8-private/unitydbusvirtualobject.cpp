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
 */

#include "unitydbusvirtualobject.h"

#include <QDebug>
#include <QDBusMessage>
#include <QTimer>

UnityDBusVirtualObject::UnityDBusVirtualObject(const QString &path, const QString &service, bool async, QObject *parent)
    : QDBusVirtualObject(parent)
    , m_connection(QDBusConnection::sessionBus())
    , m_path(path)
    , m_service(service)
{
    if (async) {
        // Use a zero-timer to let Qml finish loading before we announce on DBus
        QTimer::singleShot(0, this, &UnityDBusVirtualObject::registerObject);
    } else {
        registerObject();
    }
}

UnityDBusVirtualObject::~UnityDBusVirtualObject()
{
    // Leave service in place because multiple objects may be registered with
    // the same service.  But we know we own the object path and can unregister it.
    m_connection.unregisterObject(path());
}

QDBusConnection UnityDBusVirtualObject::connection() const
{
    return m_connection;
}

QString UnityDBusVirtualObject::path() const
{
    return m_path;
}

// Manually emit a PropertiesChanged signal over DBus, because QtDBus
// doesn't do it for us on Q_PROPERTIES, oddly enough.
void UnityDBusVirtualObject::notifyPropertyChanged(const QString& interface, const QString& node, const QString& propertyName, const QVariant &value)
{
    QDBusMessage message;
    QVariantMap changedProps;

    changedProps.insert(propertyName, value);

    message = QDBusMessage::createSignal(path() + "/" + node,
                                         QStringLiteral("org.freedesktop.DBus.Properties"),
                                         QStringLiteral("PropertiesChanged"));
    message << interface;
    message << changedProps;
    message << QStringList();

    connection().send(message);
}

void UnityDBusVirtualObject::registerObject()
{
    if (!m_connection.registerVirtualObject(m_path, this, QDBusConnection::VirtualObjectRegisterOption::SubPath)) {
        qWarning() << "Unable to register DBus object" << m_path;
    }
    if (!m_service.isEmpty()) {
        if (!m_connection.registerService(m_service)) {
            qWarning() << "Unable to register DBus service" << m_service;
        }
    }
}
