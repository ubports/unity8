/*
 * Copyright 2016 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the  Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * version 3 along with this program.  If not, see
 * <http://www.gnu.org/licenses/>
 */

#include "BroadcastAdaptor.h"
#include "BroadcastServer.h"
#include <QCoreApplication>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    auto broadcast = new BroadcastServer(&a);
    new BroadcastAdaptor(broadcast);

    // We use the session bus for testing.  The real plugin uses the system bus
    auto connection = QDBusConnection::sessionBus();
    if (!connection.registerObject("/com/canonical/Unity/Greeter/Broadcast", broadcast))
        return 1;
    if (!connection.registerService("com.canonical.Unity.Greeter.Broadcast"))
        return 1;

    return a.exec();
}
