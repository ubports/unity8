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
#include "android-hardware.h"
#include <string.h>
}

Lights::Lights(QObject* parent)
  : QObject(parent),
    m_lightDevice(0),
    m_color("blue"),
    m_state(Lights::Off),
    m_onMs(1000),
    m_offMs(3000)
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
    if (!init()) {
        qWarning() << "No lights device";
        return;
    }

    if (m_state != newState) {
        if (newState == Lights::On) {
            turnOn();
        } else {
            turnOff();
        }

        m_state = newState;
        Q_EMIT stateChanged(m_state);
    }
}

Lights::State Lights::state() const
{
    return m_state;
}

void Lights::setColor(const QColor &color)
{
    if (m_color != color) {
        m_color = color;
        Q_EMIT colorChanged(m_color);
        // FIXME: update the color if the light is already on
    }
}

QColor Lights::color() const
{
    return m_color;
}

int Lights::onMillisec() const
{
    return m_onMs;
}

void Lights::setOnMillisec(int onMs)
{
    if (m_onMs != onMs) {
        m_onMs = onMs;
        Q_EMIT onMillisecChanged(m_onMs);
        // FIXME: update the property if the light is already on
    }
}

int Lights::offMillisec() const
{
    return m_offMs;
}

void Lights::setOffMillisec(int offMs)
{
    if (m_offMs != offMs) {
        m_offMs = offMs;
        Q_EMIT offMillisecChanged(m_offMs);
        // FIXME: update the property if the light is already on
    }
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
            turnOff();
            return true;
        } else {
            qWarning() << "Failed to access notification lights";
        }
    } else {
        qWarning() << "Failed to initialize lights hardware.";
    }
    return false;
}

void Lights::turnOn()
{
    // pulse
    light_state_t state;
    memset(&state, 0, sizeof(light_state_t));
    state.color = m_color.rgba();
    state.flashMode = LIGHT_FLASH_TIMED;
    state.flashOnMS = m_onMs;
    state.flashOffMS = m_offMs;
    state.brightnessMode = BRIGHTNESS_MODE_USER;

    if (m_lightDevice->set_light(m_lightDevice, &state) != 0) {
         qWarning() << "Failed to turn the light off";
    }
}

void Lights::turnOff()
{
    light_state_t state;
    memset(&state, 0, sizeof(light_state_t));
    state.color = 0x00000000;
    state.flashMode = LIGHT_FLASH_NONE;
    state.flashOnMS = 0;
    state.flashOffMS = 0;
    state.brightnessMode = 0;

    if (m_lightDevice->set_light(m_lightDevice, &state) != 0) {
        qWarning() << "Failed to turn the light off";
    }
}
