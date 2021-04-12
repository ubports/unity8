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

#include "unitydbusobject.h"

#include <QDebug>
#include <QDBusMessage>
#include <QMetaClassInfo>
#include <QTimer>

UnityDBusObject::UnityDBusObject(const QString &path, const QString &service, bool async, QObject *parent)
    : QObject(parent)
    , m_connection(QDBusConnection::sessionBus())
    , m_path(path)
    , m_service(service)
{
    if (async) {
        // Use a zero-timer to let Qml finish loading before we announce on DBus
        QTimer::singleShot(0, this, &UnityDBusObject::registerObject);
    } else {
        registerObject();
    }
}

UnityDBusObject::~UnityDBusObject()
{
    // Leave service in place because multiple objects may be registered with
    // the same service.  But we know we own the object path and can unregister it.
    m_connection.unregisterObject(path());
}

QDBusConnection UnityDBusObject::connection() const
{
    return m_connection;
}

QString UnityDBusObject::path() const
{
    return m_path;
}

// Manually emit a PropertiesChanged signal over DBus, because QtDBus
// doesn't do it for us on Q_PROPERTIES, oddly enough.
void UnityDBusObject::notifyPropertyChanged(const QString& propertyName, const QVariant &value)
{
    QDBusMessage message;
    QString interface;
    QVariantMap changedProps;

    interface = metaObject()->classInfo(metaObject()->indexOfClassInfo("D-Bus Interface")).value();
    changedProps.insert(propertyName, value);

    message = QDBusMessage::createSignal(path(),
                                         QStringLiteral("org.freedesktop.DBus.Properties"),
                                         QStringLiteral("PropertiesChanged"));
    message << interface;
    message << changedProps;
    message << QStringList();

    connection().send(message);
}

void UnityDBusObject::registerObject()
{
    if (!m_connection.registerObject(m_path, this, QDBusConnection::ExportScriptableContents)) {
        qWarning() << "Unable to register DBus object" << m_path;
    }
    if (!m_service.isEmpty()) {
        if (!m_connection.registerService(m_service)) {
            qWarning() << "Unable to register DBus service" << m_service;
        }
    }
}
