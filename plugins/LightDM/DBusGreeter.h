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

#ifndef UNITY_DBUSGREETER_H
#define UNITY_DBUSGREETER_H

#include "unitydbusobject.h"
#include <QDBusConnection>

class Greeter;

/** This is an internal class used to talk with the indicators.
  */

class DBusGreeter : public UnityDBusObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.UnityGreeter")

    Q_PROPERTY(bool IsActive READ isActive NOTIFY isActiveChanged) // since 14.10

public:
    explicit DBusGreeter(Greeter *greeter, const QString &path);

    bool isActive() const;
    Q_SCRIPTABLE void ShowGreeter(); // temporary, until we split the greeter again
    Q_SCRIPTABLE void HideGreeter(); // temporary, until we split the greeter again

Q_SIGNALS:
    void isActiveChanged();

private Q_SLOTS:
    void isActiveChangedHandler();

private:
    Greeter *m_greeter;
};

#endif
