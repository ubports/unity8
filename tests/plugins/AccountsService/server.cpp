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

#include "AccountsAdaptor.h"
#include "AccountsServer.h"
#include "InputAdaptor.h"
#include "PropertiesServer.h"
#include "SecurityPrivacyAdaptor.h"
#include "LocationAdaptor.h"
#include "AccountsPrivateAdaptor.h"
#include "UscInputAdaptor.h"
#include "UscServer.h"
#include <QCoreApplication>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    auto accounts = new AccountsServer(&a);
    new AccountsAdaptor(accounts);
    new InputAdaptor(accounts);
    new SecurityPrivacyAdaptor(accounts);
    new LocationAdaptor(accounts);
    new AccountsPrivateAdaptor(accounts);

    auto usc = new UscServer(&a);
    new UscInputAdaptor(usc);

    // We use the session bus for testing.  The real plugin uses the system bus
    auto connection = QDBusConnection::sessionBus();
    if (!connection.registerObject("/com/canonical/Unity/Input", usc))
        return 1;
    if (!connection.registerService("com.canonical.Unity.Input"))
        return 1;
    if (!connection.registerObject("/org/freedesktop/Accounts", accounts))
        return 1;
    if (!connection.registerService("org.freedesktop.Accounts"))
        return 1;

    return a.exec();
}
