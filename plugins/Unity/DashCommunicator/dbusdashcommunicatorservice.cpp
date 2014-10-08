/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "dbusdashcommunicatorservice.h"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDebug>
#include <QTimer>

DBusDashCommunicatorService::DBusDashCommunicatorService(QObject *parent):
    QObject(parent)
{
    // Use a zero-timer to let Qml finish loading before we announce on DBus
    QTimer::singleShot(0, this, SLOT(registerDBus()));
}

DBusDashCommunicatorService::~DBusDashCommunicatorService()
{
}

void DBusDashCommunicatorService::SetCurrentScope(const QString &scopeId, bool animate, bool isSwipe)
{
    Q_EMIT setCurrentScopeRequested(scopeId, animate, isSwipe);
}

void DBusDashCommunicatorService::registerDBus()
{
    QDBusConnection connection = QDBusConnection::sessionBus();

    connection.registerService("com.canonical.UnityDash");
    connection.registerObject("/com/canonical/UnityDash", this, QDBusConnection::ExportScriptableSlots);
}
