/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

// local
#include "DBusUnityShellService.h"

// Qt
#include <QDBusConnection>

DBusUnityShellService::DBusUnityShellService() : QObject()
{
    QDBusConnection connection = QDBusConnection::sessionBus();
    bool ok;

    connection.registerService("com.canonical.Unity.Shell");

    ok = connection.registerObject("/com/canonical/Unity/Shell", this,
            QDBusConnection::ExportScriptableSignals
            | QDBusConnection::ExportScriptableSlots
            | QDBusConnection::ExportScriptableInvokables);
    if (!ok) {
        qWarning("Failed to register /com/canonical/Unity/Shell D-Bus object.");
    }

    m_rotationAngle = 0;
}

DBusUnityShellService::~DBusUnityShellService()
{
    QDBusConnection connection = QDBusConnection::sessionBus();
    connection.unregisterService("com.canonical.Unity.Shell");
    connection.unregisterObject("/com/canonical/Unity/Shell");
}

void DBusUnityShellService::setRotationAngle(int angle)
{
    if (angle != m_rotationAngle) {
        m_rotationAngle = angle;
        Q_EMIT RotationAngleChanged(angle);
    }
}

int DBusUnityShellService::GetRotationAngle()
{
    return m_rotationAngle;
}
