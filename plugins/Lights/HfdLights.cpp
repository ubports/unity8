/*
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
 * Author: Florian Leeber <florian@ubports.com>
 */

#include "HfdLights.h"
#include <QtCore/QDebug>
#include <QProcess>
#include <QDBusArgument>
#include <QDBusConnection>
#include <iostream>

extern "C" {
#include <string.h>
}

HfdLights::HfdLights(QObject* parent)
  : Lights(parent)
{
        m_hfdInterface = new QDBusInterface(
            QStringLiteral(HFD_SERVICE_NAME),
            QStringLiteral(HFD_SERVICE_PATH),
            QStringLiteral(HFD_SERVICE_INTERFACE),
            QDBusConnection::systemBus(),
            this
        );
}

bool HfdLights::init()
{
    // hfd does not need any initalization to be used
    return true;
}

void HfdLights::turnOn()
{
    m_hfdInterface->call(QStringLiteral("setState"), 0);
    m_hfdInterface->call(QStringLiteral("setColor"), (quint32)m_color.rgba());
    m_hfdInterface->call(QStringLiteral("setOnMs"), m_onMs);
    m_hfdInterface->call(QStringLiteral("setOffMs"), m_offMs);
    m_hfdInterface->call(QStringLiteral("setState"), 1);
}

void HfdLights::turnOff()
{
    m_hfdInterface->call(QStringLiteral("setState"), 0);
    m_hfdInterface->call(QStringLiteral("setColor"), (quint32)0);
    m_hfdInterface->call(QStringLiteral("setOnMs"), 0);
    m_hfdInterface->call(QStringLiteral("setOffMs"), 0);
}
