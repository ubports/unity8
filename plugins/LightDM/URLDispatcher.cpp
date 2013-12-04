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
 */

#include "URLDispatcher.h"

#include <QDBusConnection>

class DBusURLDispatcher : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.URLDispatcher")

public:
    explicit DBusURLDispatcher(URLDispatcher *parent);

    Q_SCRIPTABLE void DispatchURL(const QString &url);

private:
    URLDispatcher *m_parent;
};

DBusURLDispatcher::DBusURLDispatcher(URLDispatcher *parent)
  : QObject(parent),
    m_parent(parent)
{
}

void DBusURLDispatcher::DispatchURL(const QString &url)
{
    Q_EMIT m_parent->dispatchURL(url);
}

URLDispatcher::URLDispatcher(QObject *parent)
  : QObject(parent)
{
    // Own url dispatcher on DBus, we want to intercept these calls
    QDBusConnection connection = QDBusConnection::sessionBus();
    DBusURLDispatcher *dispatcher = new DBusURLDispatcher(this);
    connection.registerObject("/com/canonical/URLDispatcher", dispatcher, QDBusConnection::ExportScriptableContents);
    connection.registerService("com.canonical.URLDispatcher");
}

#include "URLDispatcher.moc"
