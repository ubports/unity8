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
#include <QtTest/QSignalSpy>
#include <QtTest/QTest>

class AccountsServiceTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void testInvalids()
    {
        // Test various invalid calls
        AccountsService session;
        QCOMPARE(session.getUserProperty("NOPE", "demo-edges"), QVariant());
        QCOMPARE(session.getUserProperty("testuser", "NOPE"), QVariant());
    }

    void testGetSet()
    {
        AccountsService session;
        QCOMPARE(session.getUserProperty("testuser", "demo-edges"), QVariant(true));
        session.setUserProperty("testuser", "demo-edges", QVariant(false));
        QCOMPARE(session.getUserProperty("testuser", "demo-edges"), QVariant(false));
    }
};

QTEST_MAIN(AccountsServiceTest)

#include "client.moc"
