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

#include "LightDMServer.h"
#include "LightDMSessionAdaptor.h"
#include "LogindManagerAdaptor.h"
#include "LogindServer.h"
#include "LogindSessionAdaptor.h"
#include <QCoreApplication>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    auto logind = new LogindServer(&a);
    new LogindManagerAdaptor(logind);
    new LogindSessionAdaptor(logind);

    auto lightdm = new LightDMServer(logind, &a);
    new LightDMSessionAdaptor(lightdm);

    // We use the session bus for testing.  The real plugin uses the system bus
    auto connection = QDBusConnection::sessionBus();
    if (!connection.registerObject("/org/freedesktop/login1", logind))
        return 1;
    if (!connection.registerObject("/logindsession", logind))
        return 1;
    if (!connection.registerService("org.freedesktop.login1"))
        return 1;
    if (!connection.registerObject("/session", lightdm))
        return 1;
    if (!connection.registerService("org.freedesktop.DisplayManager"))
        return 1;

    return a.exec();
}
