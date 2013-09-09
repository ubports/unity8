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

#include "AccountsService.h"
#include "AccountsServiceDBusAdaptor.h"
#include <QSignalSpy>
#include <QTest>

class AccountsServiceTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void testInvalids()
    {
        // Test various invalid calls
        AccountsServiceDBusAdaptor session;
        QCOMPARE(session.getUserProperty("NOPE", "com.canonical.unity.AccountsService", "demo-edges"), QVariant());
        QCOMPARE(session.getUserProperty("testuser", "com.canonical.unity.AccountsService", "NOPE"), QVariant());
    }

    void testGetSetServiceDBusAdaptor()
    {
        AccountsServiceDBusAdaptor session;
        session.setUserProperty("testuser", "com.canonical.unity.AccountsService", "demo-edges", QVariant(true));
        QCOMPARE(session.getUserProperty("testuser", "com.canonical.unity.AccountsService", "demo-edges"), QVariant(true));
        session.setUserProperty("testuser", "com.canonical.unity.AccountsService", "demo-edges", QVariant(false));
        QCOMPARE(session.getUserProperty("testuser", "com.canonical.unity.AccountsService", "demo-edges"), QVariant(false));
    }

    void testGetSetService()
    {
        AccountsService session;
        session.setUser("testuser");
        session.setDemoEdges(true);
        QCOMPARE(session.getDemoEdges(), true);
        session.setDemoEdges(false);
        QCOMPARE(session.getDemoEdges(), false);
    }
};

QTEST_MAIN(AccountsServiceTest)

#include "client.moc"
