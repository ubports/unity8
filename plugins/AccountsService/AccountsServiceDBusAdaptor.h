/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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

#include <QDBusArgument>
#include <QDBusContext>
#include <QDBusInterface>
#include <QDBusPendingReply>
#include <QMap>
#include <QObject>
#include <QString>

class AccountsServiceDBusAdaptor: public QObject, public QDBusContext
{
    Q_OBJECT

public:
    explicit AccountsServiceDBusAdaptor(QObject *parent = 0);
    ~AccountsServiceDBusAdaptor() = default;

    QDBusPendingReply<QVariantMap> getAllPropertiesAsync(const QString &user, const QString &interface);
    QDBusPendingReply<QVariant> getUserPropertyAsync(const QString &user, const QString &interface, const QString &property);
    QDBusPendingCall setUserPropertyAsync(const QString &user, const QString &interface, const QString &property, const QVariant &value);

Q_SIGNALS:
    void propertiesChanged(const QString &user, const QString &interface, const QStringList &changed);
    void maybeChanged(const QString &user); // Standard properties might have changed

private Q_SLOTS:
    void propertiesChangedSlot(const QString &interface, const QVariantMap &changed, const QStringList &invalid);
    void maybeChangedSlot();

private:
    QDBusInterface *getUserInterface(const QString &user);
    QString getUserForPath(const QString &path) const;

    QDBusInterface *m_accountsManager;
    QMap<QString, QDBusInterface *> m_users;

    bool m_ignoreNextChanged;
};

#endif
