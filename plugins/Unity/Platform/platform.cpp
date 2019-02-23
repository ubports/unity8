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
#include <QSet>
#include <QString>
#include <QFileInfo>

Platform::Platform(QObject *parent)
    : QObject(parent), m_isPC(true), m_isMultiSession(true)
{
    QMetaObject::invokeMethod(this, "init");
}

void Platform::init()
{
    QDBusInterface iface("org.freedesktop.hostname1", "/org/freedesktop/hostname1", "org.freedesktop.hostname1",
                         QDBusConnection::systemBus(), this);
    QDBusInterface seatIface("org.freedesktop.login1", "/org/freedesktop/login1/seat/self", "org.freedesktop.login1.Seat",
                             QDBusConnection::systemBus(), this);

    // From the source at https://cgit.freedesktop.org/systemd/systemd/tree/src/hostname/hostnamed.c#n130
    // "vm\0"
    // "container\0"
    // "desktop\0"
    // "laptop\0"
    // "server\0"
    // "tablet\0"
    // "handset\0"
    // "watch\0"
    // "embedded\0",
    m_chassis = iface.property("Chassis").toString();

    // A PC is not a handset, tablet or watch.
    // HACK! On some mobile devices chassis is empty, if so check if
    // lxc-android-config is installed, this way we know if we are on mobile
    if (m_chassis.isEmpty())
      m_isPC = !QFileInfo::exists("/var/lib/lxc/android/config");
    else
      m_isPC = !QSet<QString>{"handset", "tablet", "watch"}.contains(m_chassis);
    m_isMultiSession = seatIface.property("CanMultiSession").toBool() && seatIface.property("CanGraphical").toBool();
}

QString Platform::chassis() const
{
    return m_chassis;
}

bool Platform::isPC() const
{
    return m_isPC;
}

bool Platform::isMultiSession() const
{
    return m_isMultiSession;
}
