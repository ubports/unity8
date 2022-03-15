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
 */

#include "Leds.h"

#include <QDebug>

Leds::Leds(QObject* parent)
  : QObject(parent),
    m_color("blue"),
    m_state(Leds::Off),
    m_onMs(1000),
    m_offMs(3000)
{
}

Leds::~Leds()
{
}

void Leds::setState(Leds::State newState)
{
    if (m_state != newState) {
        m_state = newState;
        Q_EMIT stateChanged(m_state);
    }
}

Leds::State Leds::state() const
{
    return m_state;
}

void Leds::setColor(const QColor &color)
{
    if (m_color != color) {
        m_color = color;
        Q_EMIT colorChanged(m_color);
    }
}

QColor Leds::color() const
{
    return m_color;
}

int Leds::onMillisec() const
{
    return m_onMs;
}

void Leds::setOnMillisec(int onMs)
{
    if (m_onMs != onMs) {
        m_onMs = onMs;
        Q_EMIT onMillisecChanged(m_onMs);
    }
}

int Leds::offMillisec() const
{
    return m_offMs;
}

void Leds::setOffMillisec(int offMs)
{
    if (m_offMs != offMs) {
        m_offMs = offMs;
        Q_EMIT offMillisecChanged(m_offMs);
    }
}
