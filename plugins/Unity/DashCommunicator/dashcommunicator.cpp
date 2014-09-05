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

#include "dashcommunicator.h"

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>
#include <QDebug>

DashCommunicator::DashCommunicator(QObject *parent)
    : AbstractDBusServiceMonitor("com.canonical.UnityDash",
                                 "/com/canonical/UnityDash",
                                 "", parent)
{
}

void DashCommunicator::setCurrentScope(const QString &scopeId, bool animate, bool reset)
{
    if (dbusInterface() == nullptr) {
        qDebug() << "DashCommunicator - setCurrentScope failed as Dash DBus interface not available";
        return;
    } else {
        dbusInterface()->asyncCall("SetCurrentScope", scopeId, animate, reset);
    }
}
