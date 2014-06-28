/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "Lights.h"
#include <QtCore/QDebug>

extern "C" {
#include <hardware/hardware.h>
#include <hardware/lights.h>
#include <string.h>
}

Lights::Lights(QObject* parent)
  : QObject(parent),
    m_state(Lights::Off),
    m_lightDevice(0)
{
}


Lights::~Lights()
{
    if (m_lightDevice) {
        hw_device_t* device = (hw_device_t*) m_lightDevice;
        device->close(device);
    }
}

void Lights::setState(Lights::State newState)
{
    if (m_state != newState) {
        if (newState == Lights::On) {
            turnOn();
        } else {
            turnOff();
        }
    }
}

Lights::State Lights::state() const
{
    return m_state;
}

bool Lights::init()
{
    if (m_lightDevice) {
        return true;
    }

    int err;
    hw_module_t* module;

    err = hw_get_module(LIGHTS_HARDWARE_MODULE_ID, (hw_module_t const**)&module);
    if (err == 0) {
        hw_device_t* device;
        err = module->methods->open(module, LIGHT_ID_NOTIFICATIONS, &device);
        if (err == 0) {
            m_lightDevice = (light_device_t*)device;
            return true;
        } else {
            qWarning() << "Failt to access notification lights";
        }
    } else {
        qWarning() << "Failt to initialize lights hardware.";
    }
    return false;
}

void Lights::turnOn()
{
    if (!init()) {
        qWarning() << "No lights device";
        return;
    }

    if (m_state == Lights::On) {
        return;
    }

    // pulse
    light_state_t state;
    memset(&state, 0, sizeof(light_state_t));
    state.color = 0xff0000ff; // blue
    state.flashMode = LIGHT_FLASH_TIMED;
    state.flashOnMS = 1000;
    state.flashOffMS = 1000;
    state.brightnessMode = BRIGHTNESS_MODE_USER;

    if (m_lightDevice->set_light(m_lightDevice, &state) != 0) {
         qWarning() << "Fail to turn the light off";
    } else {
        m_state = Lights::On;
        Q_EMIT stateChanged(m_state);
    }
}

void Lights::turnOff()
{
    if (!init()) {
        qWarning() << "No lights device";
        return;
    }

    if (m_state == Lights::Off) {
        return;
    }

    light_state_t state;
    memset(&state, 0, sizeof(light_state_t));
    state.color = 0x00000000;
    state.flashMode = LIGHT_FLASH_NONE;
    state.flashOnMS = 0;
    state.flashOffMS = 0;
    state.brightnessMode = 0;

    if (m_lightDevice->set_light(m_lightDevice, &state) != 0) {
        qWarning() << "Fail to turn the light off";
    } else {
        m_state = Lights::Off;
        Q_EMIT stateChanged(m_state);
    }
}
