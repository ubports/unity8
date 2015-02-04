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
 *
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#ifndef UNITY_ACCOUNTSSERVICEDBUSADAPTOR_H
#define UNITY_ACCOUNTSSERVICEDBUSADAPTOR_H

#include <QMap>
#include <QObject>
#include <QString>
#include <QHash>
#include <QDBusArgument>

extern QList<QVariantMap> properties;

class AccountsServiceDBusAdaptor: public QObject
{
    Q_OBJECT

public:
    explicit AccountsServiceDBusAdaptor(QObject *parent = 0);

    Q_INVOKABLE QVariant getUserProperty(const QString &user, const QString &interface, const QString &property);
    template <typename T>
    inline T getUserProperty(const QString &user, const QString &interface, const QString &property) {
        Q_UNUSED(user)
        Q_UNUSED(interface)
        Q_ASSERT(property == "LauncherItems");
        T ret = properties;
        return ret;
    }

Q_SIGNALS:
    void propertiesChanged(const QString &user, const QString &interface, const QStringList &changed);

private:
    void simulatePropertyChange(const QString &user, const QString &property, const QVariant &value);

    friend class LauncherModelASTest;
};

#endif
