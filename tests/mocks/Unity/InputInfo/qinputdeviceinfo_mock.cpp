/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "qinputdeviceinfo_mock_p.h"

#include <QTimer>
#include <QDebug>

QInputDeviceManagerPrivate::QInputDeviceManagerPrivate(QObject *parent) :
    QObject(parent),
    currentFilter(QInputDevice::Unknown)
{
    QTimer::singleShot(1, SIGNAL(ready()));
}

QInputDeviceManagerPrivate::~QInputDeviceManagerPrivate()
{
}

QInputDevice *QInputDeviceManagerPrivate::addMockDevice(const QString &devicePath, QInputDevice::InputType type)
{
    QInputDevice *inputDevice = new QInputDevice(this);
    inputDevice->setDevicePath(devicePath);
    inputDevice->setName("Mock Device " + devicePath);
    inputDevice->setType(type);
    deviceMap.insert(devicePath, inputDevice);
    Q_EMIT deviceAdded(devicePath);
    return inputDevice;
}

void QInputDeviceManagerPrivate::removeDevice(const QString &path)
{
    Q_FOREACH (const QString devicePath, deviceMap.keys()) {
        if (devicePath.contains(path)) {
            deviceMap.remove(devicePath);
            Q_EMIT deviceRemoved(devicePath);
        }
    }
}
