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

#include "Broadcaster.h"
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>
#include <QDebug>

#include <glib.h>

#define BROADCAST_SERVICE   "com.ubports.Lomiri.Broadcast"
#define BROADCAST_PATH      "/com/ubports/Lomiri/Broadcast"
#define BROADCAST_INTERFACE "com.ubports.Lomiri.Broadcast"

Broadcaster::Broadcaster(QObject* parent)
  : QObject(parent)
{
}

void Broadcaster::notifyMediaKey(const QString &keyMsg)
{

    auto connection = QDBusConnection::SM_BUSNAME();
    QDBusMessage msg = QDBusMessage::createSignal(BROADCAST_PATH, BROADCAST_INTERFACE, "MediaKey");

    QVariantMap args;
    args.insert("key-msg", keyMsg);
    msg << args;

    connection.send(msg);
}
