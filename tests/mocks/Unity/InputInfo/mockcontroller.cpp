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

#include "mockcontroller.h"

#include "qinputdeviceinfo_mock_p.h"

MockController::MockController(QObject *parent):
    QObject(parent)
{

}

QInputDevice *MockController::addMockDevice(const QString &devicePath, QInputDevice::InputType type)
{
    return QInputDeviceManagerPrivate::instance()->addMockDevice(devicePath, type);
}

void MockController::removeDevice(const QString &devicePath)
{
    QInputDeviceManagerPrivate::instance()->removeDevice(devicePath);
}
