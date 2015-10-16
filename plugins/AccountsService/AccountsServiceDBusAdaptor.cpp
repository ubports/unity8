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
#include <QDebug>

AccountsServiceDBusAdaptor::AccountsServiceDBusAdaptor(QObject* parent)
  : QObject(parent),
    m_accountsManager(nullptr),
    m_ignoreNextChanged(false)
{
    QDBusConnection connection = QDBusConnection::SM_BUSNAME();
    QDBusConnectionInterface *interface = connection.interface();
    interface->startService(QStringLiteral("org.freedesktop.Accounts"));
    m_accountsManager = new QDBusInterface(QStringLiteral("org.freedesktop.Accounts"),
                                           QStringLiteral("/org/freedesktop/Accounts"),
                                           QStringLiteral("org.freedesktop.Accounts"),
                                           connection, this);
}

QVariant AccountsServiceDBusAdaptor::getUserProperty(const QString &user, const QString &interface, const QString &property)
{
    QDBusInterface *iface = getUserInterface(user);
    if (iface != nullptr && iface->isValid()) {
        QDBusReply<QVariant> answer = iface->call(QStringLiteral("Get"), interface, property);
        if (answer.isValid()) {
            return answer;
        }
    }
    return QVariant();
}

QDBusPendingReply<QVariant> AccountsServiceDBusAdaptor::getUserPropertyAsync(const QString &user, const QString &interface, const QString &property)
{
    QDBusInterface *iface = getUserInterface(user);
    if (iface != nullptr && iface->isValid()) {
        return iface->asyncCall(QStringLiteral("Get"), interface, property);
    }
    return QDBusPendingReply<QVariant>(QDBusMessage::createError(QDBusError::Other, QStringLiteral("Invalid Interface")));
}

void AccountsServiceDBusAdaptor::setUserProperty(const QString &user, const QString &interface, const QString &property, const QVariant &value)
{
    QDBusInterface *iface = getUserInterface(user);
    if (iface != nullptr && iface->isValid()) {
        // The value needs to be carefully wrapped
        iface->call(QStringLiteral("Set"), interface, property, QVariant::fromValue(QDBusVariant(value)));
    }
}

QDBusPendingCall AccountsServiceDBusAdaptor::setUserPropertyAsync(const QString &user, const QString &interface, const QString &property, const QVariant &value)
{
    QDBusInterface *iface = getUserInterface(user);
    if (iface != nullptr && iface->isValid()) {
        // The value needs to be carefully wrapped
        return iface->asyncCall(QStringLiteral("Set"), interface, property, QVariant::fromValue(QDBusVariant(value)));
    }
    return QDBusPendingCall::fromCompletedCall(QDBusMessage::createError(QDBusError::Other, QStringLiteral("Invalid Interface")));
}

void AccountsServiceDBusAdaptor::propertiesChangedSlot(const QString &interface, const QVariantMap &changed, const QStringList &invalid)
{
    // Merge changed and invalidated together
    QStringList combined;
    combined << invalid;
    combined << changed.keys();
    combined.removeDuplicates();

    Q_EMIT propertiesChanged(getUserForPath(message().path()), interface, combined);

    // In case a non-builtin property changes, we're getting propertiesChanged *and* changed
    // As the generic changed requires asking back over DBus, it's quite slow to process.
    // We don't want to trigger that when we know it's not a built-in property change.
    m_ignoreNextChanged = true;
}

void AccountsServiceDBusAdaptor::maybeChangedSlot()
{
    if (!m_ignoreNextChanged) {
        Q_EMIT maybeChanged(getUserForPath(message().path()));
    }
    m_ignoreNextChanged = false;
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
        QDBusReply<QDBusObjectPath> answer = m_accountsManager->asyncCall(QStringLiteral("FindUserByName"), user);
        if (answer.isValid()) {
            const QString path = answer.value().path();

            iface = new QDBusInterface(QStringLiteral("org.freedesktop.Accounts"),
                                       path,
                                       QStringLiteral("org.freedesktop.DBus.Properties"),
                                       m_accountsManager->connection(), this);

            // With its own pre-defined properties, AccountsService is oddly
            // close-lipped.  It won't send out proper DBus.Properties notices,
            // but it does have one catch-all Changed() signal.  So let's
            // listen to that.
            iface->connection().connect(
                iface->service(),
                path,
                QStringLiteral("org.freedesktop.Accounts.User"),
                QStringLiteral("Changed"),
                this,
                SLOT(maybeChangedSlot()));

            // But custom properties do send out the right notifications, so
            // let's still listen there.
            iface->connection().connect(
                iface->service(),
                path,
                QStringLiteral("org.freedesktop.DBus.Properties"),
                QStringLiteral("PropertiesChanged"),
                this,
                SLOT(propertiesChangedSlot(QString, QVariantMap, QStringList)));

            m_users.insert(user, iface);
        } else {
            qWarning() << "Couldn't get user interface" << answer.error().name() << answer.error().message();
        }
    }
    return iface;
}
