/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "platform.h"

#include <QDBusConnection>

Platform::Platform(QObject *parent)
    : QObject(parent)
    , m_iface("org.freedesktop.hostname1", "/org/freedesktop/hostname1", "org.freedesktop.hostname1",
              QDBusConnection::systemBus(), this)
{
    QMetaObject::invokeMethod(this, "init");
}

void Platform::init()
{
    m_chassis = m_iface.property("Chassis").toString();
    m_isPC = (m_chassis == "desktop" || m_chassis == "laptop" || m_chassis == "server");
}

QString Platform::chassis() const
{
    return m_chassis;
}

bool Platform::isPC() const
{
    return m_isPC;
}
