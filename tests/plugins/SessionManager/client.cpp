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

#include "SessionManager.h"
#include <QtTest/QSignalSpy>
#include <QtTest/QTest>


// These tests assume the following behavior from our mock logind server:
// * IsActive will return false
// * Lock() will emit an ActiveChanged(true) signal
//
// This should lead to the following behavior from our SessionManager plugin:
// * Starts active
// * Becomes inactive once it connects to logind and sees IsActive result
// * Becomes active once Lock() is called (which isn't really sensible, but
//   it's just a mock)

class SessionManagerTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void waitForChange(SessionManager *session)
    {
        // Wait 5 seconds for initial activeChanged signal
        QSignalSpy spy(session, SIGNAL(activeChanged()));
        int i = 0;
        while (spy.count() == 0 && i++ < 50)
            QTest::qWait(100);
        QCOMPARE(spy.count(), 1);
    }

    void testAssumeActive()
    {
        // Test that active() starts as true before we connect to service
        SessionManager session;
        QCOMPARE(session.active(), true);
    }

    void testSafeLock()
    {
        // Test that lock() doesn't crash if used before we connect to service
        // (i.e. just test that we're not being stupid about pointers)
        SessionManager session;
        session.lock();
    }

    void testInitialSignal()
    {
        // Test that we get notified of change once we connect to service
        SessionManager session;
        waitForChange(&session);
        QCOMPARE(session.active(), false);
    }

    void testLock()
    {
        // Test that lock() gets called correctly and that we listen for
        // the activeChanged signal too.
        SessionManager session;
        waitForChange(&session);
        session.lock();
        waitForChange(&session);
        QCOMPARE(session.active(), true);
    }
};

QTEST_MAIN(SessionManagerTest)

#include "client.moc"
