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
 * Authors: Michael Terry <michael.terry@canonical.com>
 */

#ifndef UNITY_ACCOUNTSSERVICEDBUSADAPTOR_H
#define UNITY_ACCOUNTSSERVICEDBUSADAPTOR_H

#include <QDBusContext>
#include <QDBusInterface>
#include <QMap>
#include <QObject>
#include <QString>
#include <QDBusArgument>

class AccountsServiceDBusAdaptor: public QObject, public QDBusContext
{
    Q_OBJECT

public:
    explicit AccountsServiceDBusAdaptor(QObject *parent = 0);

    Q_INVOKABLE QVariant getUserProperty(const QString &user, const QString &interface, const QString &property);

    template <typename T>
    inline T getUserProperty(const QString &user, const QString &interface, const QString &property) {
        QVariant variant = getUserProperty(user, interface, property);
        if (variant.isValid() && variant.canConvert<QDBusArgument>()) {
            return qdbus_cast<T>(variant.value<QDBusArgument>());
        }
        return T();
    }

    Q_INVOKABLE void setUserProperty(const QString &user, const QString &interface, const QString &property, const QVariant &value);
    Q_INVOKABLE void setUserPropertyAsync(const QString &user, const QString &interface, const QString &property, const QVariant &value);

Q_SIGNALS:
    void propertiesChanged(const QString &user, const QString &interface, const QStringList &changed);
    void maybeChanged(const QString &user); // Standard properties might have changed

private Q_SLOTS:
    void propertiesChangedSlot(const QString &interface, const QVariantMap &changed, const QStringList &invalid);
    void maybeChangedSlot();

private:
    QDBusInterface *getUserInterface(const QString &user);
    QString getUserForPath(const QString &path);

    QDBusInterface *m_accountsManager;
    QMap<QString, QDBusInterface *> m_users;
};

#endif
