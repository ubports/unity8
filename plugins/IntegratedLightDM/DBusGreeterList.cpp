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

#include "DBusGreeterList.h"
#include "Greeter.h"

#include <QDBusMessage>
#include <QStringList>

DBusGreeterList::DBusGreeterList(Greeter *greeter, const QString &path)
 : UnityDBusObject(path, "com.canonical.UnityGreeter", true, greeter),
   m_greeter(greeter)
{
    connect(m_greeter, SIGNAL(authenticationUserChanged(const QString &)), this, SLOT(authenticationUserChangedHandler(const QString &)));
    connect(m_greeter, SIGNAL(promptlessChanged()), this, SLOT(promptlessChangedHandler()));
}

QString DBusGreeterList::GetActiveEntry() const
{
    return m_greeter->authenticationUser();
}

void DBusGreeterList::SetActiveEntry(const QString &entry)
{
    Q_EMIT m_greeter->requestAuthenticationUser(entry);
}

bool DBusGreeterList::entryIsLocked() const
{
    return !m_greeter->promptless();
}

void DBusGreeterList::authenticationUserChangedHandler(const QString &user)
{
    notifyPropertyChanged("ActiveEntry", user);
    Q_EMIT EntrySelected(user);
}

void DBusGreeterList::promptlessChangedHandler()
{
    notifyPropertyChanged("EntryIsLocked", entryIsLocked());
    Q_EMIT entryIsLockedChanged();
}
