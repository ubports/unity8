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
#include <QDBusPendingCall>

namespace
{
char const* const dbus_lightcontrol_servicename = "com.ubports.lightcontrol";
char const* const dbus_lightcontrol_path = "/com/ubports/lightcontrol";
char const* const dbus_lightcontrol_interface = "com.ubports.lightcontrol";
}

Lights::Lights(QObject* parent)
  : QObject(parent),
    m_lightDevice(0),
    m_color("blue"),
    m_state(Lights::Off),
    m_onMs(1000),
    m_offMs(3000),
    lightControl(nullptr)
{
    lightControl = new QDBusInterface(dbus_lightcontrol_servicename,
                                     dbus_lightcontrol_path,
                                     dbus_lightcontrol_interface,
                                     QDBusConnection::systemBus(), this);
    turnOff();

    QString colorString = QString("0x%1").arg(m_color.rgb(), 6, 16, QChar('0'));
    lightControl->asyncCall("set_led_attributes", colorString, m_onMs, m_offMs);

    qWarning() << "[Lights] New Lights are there!";
}

Lights::~Lights()
{
}

void Lights::setState(Lights::State newState)
{
    qWarning() << "[Lights] setState: " << newState;
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
    qWarning() << "[Lights] setColor: " << color;
    if (m_color != color) {
        m_color = color;
        QString colorString = QString("0x%1").arg(color.rgb(), 6, 16, QChar('0'));
        qWarning() << "[Lights] calling set_led_color: " << colorString;
        lightControl->asyncCall("set_led_color", colorString);
        Q_EMIT colorChanged(m_color);
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


void Lights::turnOn()
{
    qWarning() << "[Lights] turnOn";
    lightControl->asyncCall("turn_led_on");
}

void Lights::turnOff()
{
    qWarning() << "[Lights] turnOff";
    lightControl->asyncCall("turn_led_off");
}
