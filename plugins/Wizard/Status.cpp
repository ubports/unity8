/*
 * Copyright (C) 2015 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QDebug>
#include <QDBusConnection>

#include "Status.h"

Status::Status()
{
    initNM();
    initUPower();
}

void Status::initNM()
{
    m_nmIface = new QDBusInterface("org.freedesktop.NetworkManager", "/org/freedesktop/NetworkManager", "org.freedesktop.NetworkManager",
                                   QDBusConnection::systemBus(), this);

    QDBusConnection::systemBus().connect("org.freedesktop.NetworkManager", "/org/freedesktop/NetworkManager", "org.freedesktop.NetworkManager", "PropertiesChanged",
                                         this, SLOT(onNMPropertiesChanged(QVariantMap)));
}

void Status::onNMPropertiesChanged(const QVariantMap &changedProps)
{
    if (changedProps.contains("State") || changedProps.contains("Connectivity")) {
        Q_EMIT onlineChanged();
        Q_EMIT networkIconChanged();
    }

    if (changedProps.contains("PrimaryConnection") || changedProps.contains("SpecificObject") || changedProps.contains("Strength")) {
        Q_EMIT networkIconChanged();
    }
}

bool Status::online() const
{
    if (!m_nmIface->isValid())
        return false;

    return m_nmIface->property("State").toUInt() == 70;
}

QString Status::networkIcon()
{
    QString iconName = QStringLiteral("nm-no-connection");

    if (!online()) {
        return iconName;
    }

    const QString primaryConn = m_nmIface->property("PrimaryConnection").value<QDBusObjectPath>().path();
    const QString primaryConnType = m_nmIface->property("PrimaryConnectionType").toString();

    if (primaryConn.isEmpty()) {
        qWarning() << "Empty primary connection";
        return iconName;
    }

    if (primaryConnType == "802-11-wireless") {
        QDBusInterface activeConn("org.freedesktop.NetworkManager", primaryConn, "org.freedesktop.NetworkManager.Connection.Active", QDBusConnection::systemBus());

        if (activeConn.isValid()) {
            const QString apPath = activeConn.property("SpecificObject").value<QDBusObjectPath>().path();

            if (apPath.isEmpty()) {
                qWarning() << "No AP path";
                return iconName;
            }

            QDBusConnection::systemBus().connect("org.freedesktop.NetworkManager", primaryConn, "org.freedesktop.NetworkManager.Connection.Active", "PropertiesChanged",
                                                 this, SLOT(onNMPropertiesChanged(QVariantMap)));

            QDBusInterface ap("org.freedesktop.NetworkManager", apPath, "org.freedesktop.NetworkManager.AccessPoint", QDBusConnection::systemBus());

            if (!ap.isValid()) {
                qWarning() << "Invalid AP";
                return iconName;
            }

            QDBusConnection::systemBus().connect("org.freedesktop.NetworkManager", apPath, "org.freedesktop.NetworkManager.AccessPoint", "PropertiesChanged",
                                                 this, SLOT(onNMPropertiesChanged(QVariantMap)));

            const uint strength = ap.property("Strength").toUInt();
            const uint flags = ap.property("Flags").toUInt();

            if (strength == 0) {
                iconName = "nm-signal-00";
            } else if (strength <= 25) {
                iconName = "nm-signal-25";
            } else if (strength <= 50) {
                iconName = "nm-signal-50";
            } else if (strength <= 75) {
                iconName = "nm-signal-75";
            } else if (strength <= 100) {
                iconName = "nm-signal-100";
            }

            if (flags >= 1) {
                iconName += "-secure";
            }
        }
    }

    return iconName;
}

void Status::initUPower()
{
    m_upowerIface = new QDBusInterface("org.freedesktop.UPower", "/org/freedesktop/UPower/devices/DisplayDevice", "org.freedesktop.UPower.Device",
                                       QDBusConnection::systemBus(), this);
    QDBusConnection::systemBus().connect("org.freedesktop.UPower", "/org/freedesktop/UPower/devices/DisplayDevice", "org.freedesktop.DBus.Properties",
                                         "PropertiesChanged", this, SLOT(onUPowerPropertiesChanged(QString,QVariantMap,QStringList)));
}

void Status::onUPowerPropertiesChanged(const QString &iface, const QVariantMap &changedProps, const QStringList &invalidatedProps)
{
    Q_UNUSED(iface)
    Q_UNUSED(invalidatedProps)

    if (changedProps.contains("IconName")) {
        Q_EMIT batteryIconChanged();
    }
}

QString Status::batteryIcon() const
{
    const QString iconName = m_upowerIface->property("IconName").toString();
    return iconName;
}
