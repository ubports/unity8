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

#include "DBusGreeter.h"
#include "Greeter.h"

#include <QDBusMessage>
#include <QStringList>

DBusGreeter::DBusGreeter(Greeter *greeter, const QDBusConnection &connection, const QString &path)
 : QObject(greeter),
   m_greeter(greeter),
   m_connection(connection),
   m_path(path)
{
    connect(m_greeter, SIGNAL(isActiveChanged()), this, SLOT(isActiveChangedHandler()));
}

bool DBusGreeter::isActive() const
{
    return m_greeter->isActive();
}

void DBusGreeter::isActiveChangedHandler()
{
    notifyPropertyChanged("IsActive", isActive());
    Q_EMIT isActiveChanged();
}

// Manually emit a PropertiesChanged signal over DBus, because QtDBus
// doesn't do it for us on Q_PROPERTIES, oddly enough.
void DBusGreeter::notifyPropertyChanged(const QString& propertyName, const QVariant &value)
{
    QDBusMessage message;
    QVariantMap changedProps;

    changedProps.insert(propertyName, value);

    message = QDBusMessage::createSignal(m_path,
                                         "org.freedesktop.DBus.Properties",
                                         "PropertiesChanged");
    message << "com.canonical.UnityGreeter";
    message << changedProps;
    message << QStringList();

    m_connection.send(message);
}
