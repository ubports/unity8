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

//#define BROADCAST_SERVICE   "com.canonical.Unity.Broadcast"
//#define BROADCAST_SERVICE   "com.canonical.Unity"
//#define BROADCAST_PATH      "/com/canonical/Unity/Broadcast"
//#define BROADCAST_INTERFACE "com.canonical.Unity.Broadcast"

Broadcaster::Broadcaster(QObject* parent)
  : QObject(parent)
{

    auto connection = QDBusConnection::SM_BUSNAME();
    //auto interface = connection.interface();
    //auto reply = interface->startService(QStringLiteral(BROADCAST_INTERFACE));
    //if(!reply.isValid())
    //    qWarning() << "Failed to start DBus service " << BROADCAST_SERVICE << ": " << reply.error().message();

    /*m_broadcaster = new QDBusInterface(QStringLiteral(BROADCAST_SERVICE),
                                       QStringLiteral(BROADCAST_PATH),
                                       QStringLiteral(BROADCAST_INTERFACE),
                                       connection, this);
    */
}

void Broadcaster::notifyMediaKey(const QString &keyMsg)
{

    auto connection = QDBusConnection::SM_BUSNAME();
    QDBusMessage msg = QDBusMessage::createSignal("/com/ubports/Lomiri/Broadcast", "com.ubports.Lomiri.Broadcast", "MediaKey");

    QVariantMap args;
    args.insert("key-msg", keyMsg);
    msg << args; // keyMsg;

    connection.send(msg);

    //m_broadcaster->asyncCall(QStringLiteral("MediaKey"), args);
    /*QDBusReply<void> reply = m_broadcaster->call(QStringLiteral("MediaKey"), args);
    if(!reply.isValid())
        qWarning() << "Failed to signal MediaKey: " << reply.error().message();
    */
}
