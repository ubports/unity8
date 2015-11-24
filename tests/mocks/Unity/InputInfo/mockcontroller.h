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

#ifndef MOCKCONTROLLER_H
#define MOCKCONTROLLER_H

#include <QObject>
#include "qinputinfo.h"

class MockController: public QObject
{
    Q_OBJECT
public:
    MockController(QObject *parent = 0);
    ~MockController() = default;

    Q_INVOKABLE QInputDevice* addMockDevice(const QString &devicePath, QInputDevice::InputType type);
    Q_INVOKABLE void removeDevice(const QString &devicePath);
};

#endif
