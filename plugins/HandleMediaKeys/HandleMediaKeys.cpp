/*
 * Copyright (C) 2020 UBports Foundation
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

#include "HandleMediaKeys.h"
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>
#include <QDebug>

#include <glib.h>

HandleMediaKeys::HandleMediaKeys(QObject* parent)
  : QObject(parent)
{

    auto connection = QDBusConnection::SM_BUSNAME();
    auto interface = connection.interface();
    interface->startService(QStringLiteral("com.ubports.Lomiri.Broadcast"));

    m_broadcaster = new QDBusInterface(QStringLiteral("com.ubports.Lomiri.Broadcast"),
                                       QStringLiteral("/com/ubports/Lomiri/Broadcast"),
                                       QStringLiteral("com.ubports.Lomiri.Broadcast"),
                                       connection, this);

    connect(m_broadcaster, SIGNAL(MediaKey(int key)),
            this, SLOT(onMediaKey(int key)));

}

void HandleMediaKeys::notifyMediaKey(int key)
{
    qDebug() << "notifyMediaKey(" << key << ")";
    m_broadcaster->asyncCall(QStringLiteral("MediaKey"), key);
}

void HandleMediaKeys::onMediaKey(int key)
{
    Q_EMIT mediaKey(key);
}

