/*
 * Copyright (C) 2014 Canonical, Ltd.
 * Copyright (C) 2021 UBports Foundation.
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
 * Author: Renato Araujo Oliveira Filho <renato.filho@canonical.com>
 */

#ifndef UNITY_LEGACYLIGHTS_H
#define UNITY_LEGACYLIGHTS_H

#include <QtCore/QObject>
#include "Lights.h"

struct light_device_t;

class LegacyLights: public Lights
{
    Q_OBJECT

public:
    ~LegacyLights();

protected:
    bool init() override;
    void turnOff() override;
    void turnOn() override;

private:
    light_device_t* m_lightDevice;

};

#endif
