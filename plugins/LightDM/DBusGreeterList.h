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

#ifndef UNITY_DBUSGREETERLIST_H
#define UNITY_DBUSGREETERLIST_H

#include "unitydbusobject.h"
#include <QDBusConnection>

class Greeter;

/** This is an internal class used to talk with the indicators.
  */

class DBusGreeterList : public UnityDBusObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.UnityGreeter.List")

    Q_PROPERTY(QString ActiveEntry READ GetActiveEntry WRITE SetActiveEntry NOTIFY EntrySelected) // since 14.04
    Q_PROPERTY(bool EntryIsLocked READ entryIsLocked NOTIFY entryIsLockedChanged) // since 14.04

public:
    explicit DBusGreeterList(Greeter *greeter, const QString &path);

    Q_SCRIPTABLE void SetActiveEntry(const QString &entry); // since 13.04
    Q_SCRIPTABLE QString GetActiveEntry() const; // since 13.10

    bool entryIsLocked() const;

Q_SIGNALS:
    Q_SCRIPTABLE void EntrySelected(const QString &entry); // since 13.10

    void entryIsLockedChanged();

private Q_SLOTS:
    void authenticationUserChangedHandler();
    void promptlessChangedHandler();

private:
    Greeter *m_greeter;
};

#endif
