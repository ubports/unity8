/*
 * Copyright (C) 2014, 2015 Canonical, Ltd.
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

DBusGreeter::DBusGreeter(Greeter *greeter, const QString &path)
 : UnityDBusObject(path, QStringLiteral("com.canonical.UnityGreeter"), true, greeter),
   m_greeter(greeter)
{
    connect(m_greeter, &Greeter::isActiveChanged,
            this, &DBusGreeter::isActiveChangedHandler);
}

bool DBusGreeter::isActive() const
{
    return m_greeter->isActive();
}

void DBusGreeter::ShowGreeter()
{
    Q_EMIT m_greeter->showGreeter();
}

void DBusGreeter::HideGreeter()
{
    Q_EMIT m_greeter->hideGreeter();
}

void DBusGreeter::isActiveChangedHandler()
{
    notifyPropertyChanged(QStringLiteral("IsActive"), isActive());
    Q_EMIT isActiveChanged();
}
