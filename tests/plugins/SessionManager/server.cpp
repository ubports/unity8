/*
 * Copyright 2013 Canonical Ltd.
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
 *
 * Authored by: Michael Terry <michael.terry@canonical.com>
 */

#include "LightDMSessionAdaptor.h"
#include "LightDMSessionServer.h"
#include "LoginManagerAdaptor.h"
#include "LoginManagerServer.h"
#include "LoginPropertiesAdaptor.h"
#include "LoginSessionAdaptor.h"
#include "LoginSessionServer.h"
#include <QtCore/QCoreApplication>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    LoginManagerServer *manager = new LoginManagerServer();
    new LoginManagerAdaptor(manager);

    LoginSessionServer *l1_session = new LoginSessionServer();
    new LoginSessionAdaptor(l1_session);
    new LoginPropertiesAdaptor(l1_session);

    LightDMSessionServer *ldm_session = new LightDMSessionServer(l1_session);
    new LightDMSessionAdaptor(ldm_session);

    // We use the session bus for testing.  The real plugin uses the system bus
    QDBusConnection connection = QDBusConnection::sessionBus();
    if (!connection.registerObject("/org/freedesktop/login1", manager))
        return 1;
    if (!connection.registerObject("/mocksession/login1", l1_session))
        return 1;
    if (!connection.registerObject("/mocksession/lightdm", ldm_session))
        return 1;
    if (!connection.registerService("org.freedesktop.DisplayManager"))
        return 1;
    if (!connection.registerService("org.freedesktop.login1"))
        return 1;

    return a.exec();
}
