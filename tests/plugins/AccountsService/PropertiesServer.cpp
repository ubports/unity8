/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the  Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * version 3 along with this program.  If not, see
 * <http://www.gnu.org/licenses/>
 *
 * Authored by: Michael Terry <michael.terry@canonical.com>
 */

#include "PropertiesServer.h"
#include "AccountsService.h"

// Qt
#include <QDebug>
#include <QDBusMessage>
#include <QDBusMetaType>

PropertiesServer::PropertiesServer(QObject *parent)
    : QObject(parent)
{
    qDBusRegisterMetaType<QList<QVariantMap>>();
    Reset();
}

QDBusVariant PropertiesServer::Get(const QString &interface, const QString &property) const
{
    if (m_properties.contains(interface) && m_properties[interface].contains(property)) {
        return QDBusVariant(m_properties[interface][property]);
    } else {
        sendErrorReply(QDBusError::InvalidArgs, "Bad interface or property");
        return QDBusVariant(QVariant());
    }
}

QVariantMap PropertiesServer::GetAll(const QString &interface) const
{
    if (m_properties.contains(interface)) {
        return m_properties[interface];
    } else {
        sendErrorReply(QDBusError::InvalidArgs, "Bad interface");
        return QVariantMap();
    }
}

void PropertiesServer::Set(const QString &interface, const QString &property, const QDBusVariant &variant)
{
    QVariant newValue = variant.variant();

    if (m_properties[interface].contains(property)) {
        QVariant& oldValue = m_properties[interface][property];
        if (oldValue != newValue) {
            // complex types have an extra layer of wrapping via QDBusArgument
            if (interface == QStringLiteral("com.canonical.unity.AccountsService") &&
                    property == QStringLiteral("LauncherItems")) {
                newValue = QVariant::fromValue(qdbus_cast<QList<QVariantMap>>(newValue.value<QDBusArgument>()));
            }

            oldValue = newValue;

            // Special case for user properties.
            if (interface == "org.freedesktop.Accounts.User") {
                Q_EMIT Changed();
            } else {
                QVariantMap propertyChanges;
                propertyChanges[property] = newValue;
                Q_EMIT PropertiesChanged(interface, propertyChanges, QStringList());

                // FIXME: Here to replicate current behaviour
                // Not sure why accounts-service is triggering Changed when we're
                // emitting PropertyChanges from org.freedesktop.DBus.Properties as well.
                Q_EMIT Changed();
            }
        }
    } else {
        sendErrorReply(QDBusError::InvalidArgs, "Bad interface or property");
    }
}

void PropertiesServer::Reset()
{
    m_properties["com.canonical.unity.AccountsService"]["demo-edges"] = false;
    m_properties["com.canonical.unity.AccountsService"]["DemoEdgesCompleted"] = QStringList();
    m_properties["com.canonical.unity.AccountsService"]["LauncherItems"] = QVariant::fromValue(QList<QVariantMap>());
    m_properties["com.canonical.unity.AccountsService.Private"]["FailedLogins"] = 0;
    m_properties["com.ubuntu.touch.AccountsService.SecurityPrivacy"]["StatsWelcomeScreen"] = true;
    m_properties["com.ubuntu.AccountsService.Input"]["MousePrimaryButton"] = "right";
    m_properties["com.ubuntu.AccountsService.SecurityPrivacy"]["EnableLauncherWhileLocked"] = true;
    m_properties["com.ubuntu.AccountsService.SecurityPrivacy"]["EnableIndicatorsWhileLocked"] = true;
    m_properties["com.ubuntu.AccountsService.SecurityPrivacy"]["PasswordDisplayHint"] = AccountsService::Keyboard;
    m_properties["com.ubuntu.location.providers.here.AccountsService"]["LicenseAccepted"] = false;
    m_properties["com.ubuntu.location.providers.here.AccountsService"]["LicenseBasePath"] = "";
    m_properties["org.freedesktop.Accounts.User"]["BackgroundFile"] = "";
    m_properties["org.freedesktop.Accounts.User"]["RealName"] = "";
}
