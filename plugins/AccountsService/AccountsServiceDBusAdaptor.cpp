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
 * Author: Michael Terry <michael.terry@canonical.com>
 */

#include "AccountsServiceDBusAdaptor.h"
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusMessage>
#include <QDBusVariant>

AccountsServiceDBusAdaptor::AccountsServiceDBusAdaptor(QObject* parent)
  : QObject(parent),
    m_accountsManager(nullptr),
    m_users()
{
    QDBusConnection connection = QDBusConnection::SM_BUSNAME();
    QDBusConnectionInterface *interface = connection.interface();
    interface->startService("org.freedesktop.Accounts");
    m_accountsManager = new QDBusInterface("org.freedesktop.Accounts",
                                          "/org/freedesktop/Accounts",
                                          "org.freedesktop.Accounts",
                                          connection, this);
}

QVariant AccountsServiceDBusAdaptor::getUserProperty(const QString &user, const QString &interface, const QString &property)
{
    QDBusInterface *iface = getUserInterface(user);
    if (iface != nullptr && iface->isValid()) {
        QDBusMessage answer = iface->call("Get", interface, property);
        if (answer.type() == QDBusMessage::ReplyMessage) {
            return answer.arguments()[0].value<QDBusVariant>().variant();
        }
    }
    return QVariant();
}

void AccountsServiceDBusAdaptor::setUserProperty(const QString &user, const QString &interface, const QString &property, const QVariant &value)
{
    QDBusInterface *iface = getUserInterface(user);
    if (iface != nullptr && iface->isValid()) {
        // The value needs to be carefully wrapped
        iface->call("Set", interface, property, QVariant::fromValue(QDBusVariant(value)));
    }
}

void AccountsServiceDBusAdaptor::propertiesChangedSlot(const QString &interface, const QVariantMap &changed, const QStringList &invalid)
{
    // Merge changed and invalidated together
    QStringList combined;
    combined << invalid;
    combined << changed.keys();
    combined.removeDuplicates();

    Q_EMIT propertiesChanged(getUserForPath(message().path()), interface, combined);
}

void AccountsServiceDBusAdaptor::maybeChangedSlot()
{
    Q_EMIT maybeChanged(getUserForPath(message().path()));
}

QString AccountsServiceDBusAdaptor::getUserForPath(const QString &path)
{
    QMap<QString, QDBusInterface *>::const_iterator i;
    for (i = m_users.constBegin(); i != m_users.constEnd(); ++i) {
        if (i.value()->path() == path) {
            return i.key();
        }
    }
    return QString();
}

QDBusInterface *AccountsServiceDBusAdaptor::getUserInterface(const QString &user)
{
    QDBusInterface *iface = m_users.value(user);
    if (iface == nullptr && m_accountsManager->isValid()) {
        QDBusMessage answer = m_accountsManager->call("FindUserByName", user);
        if (answer.type() == QDBusMessage::ReplyMessage) {
            QString path = answer.arguments()[0].value<QDBusObjectPath>().path();

            iface = new QDBusInterface("org.freedesktop.Accounts",
                                       path,
                                       "org.freedesktop.DBus.Properties",
                                       m_accountsManager->connection(), this);

            // With its own pre-defined properties, AccountsService is oddly
            // close-lipped.  It won't send out proper DBus.Properties notices,
            // but it does have one catch-all Changed() signal.  So let's
            // listen to that.
            iface->connection().connect(
                iface->service(),
                path,
                "org.freedesktop.Accounts.User",
                "Changed",
                this,
                SLOT(maybeChangedSlot()));

            // But custom properties do send out the right notifications, so
            // let's still listen there.
            iface->connection().connect(
                iface->service(),
                path,
                "org.freedesktop.DBus.Properties",
                "PropertiesChanged",
                this,
                SLOT(propertiesChangedSlot(QString, QVariantMap, QStringList)));

            m_users.insert(user, iface);
        }
    }
    return iface;
}
