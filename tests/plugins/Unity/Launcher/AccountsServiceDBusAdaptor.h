/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

#ifndef UNITY_ACCOUNTSSERVICEDBUSADAPTOR_H
#define UNITY_ACCOUNTSSERVICEDBUSADAPTOR_H

#include <QMap>
#include <QObject>
#include <QString>
#include <QHash>

class AccountsServiceDBusAdaptor: public QObject
{
    Q_OBJECT

public:
    explicit AccountsServiceDBusAdaptor(QObject *parent = 0);

    Q_INVOKABLE QVariant getUserProperty(const QString &user, const QString &interface, const QString &property);
    Q_INVOKABLE void setUserProperty(const QString &user, const QString &interface, const QString &property, const QVariant &value);
    Q_INVOKABLE void setUserPropertyAsync(const QString &user, const QString &interface, const QString &property, const QVariant &value);

Q_SIGNALS:
    void propertiesChanged(const QString &user, const QString &interface, const QStringList &changed);
    void maybeChanged(const QString &user); // Standard properties might have changed

private:
    void simulatePropertyChange(const QString &property, const QVariant &value);

private:
    QHash<QString, QVariant> m_properties;
};

#endif
