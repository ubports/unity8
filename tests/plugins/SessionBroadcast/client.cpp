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

#include "SessionBroadcast.h"
#include <QSignalSpy>
#include <QTest>

class BroadcastServiceTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void testRequest(const QString &requestedAppId, const QString &expectedAppId)
    {
        SessionBroadcast broadcaster;
        QSignalSpy spy(&broadcaster, SIGNAL(startApplication(const QString &)));

        broadcaster.requestApplicationStart(qgetenv("USER"), requestedAppId);

        // Wait one second for the signal
        int i = 0;
        while (spy.count() == 0 && i++ < 10)
            QTest::qWait(100);
        QCOMPARE(spy.count(), 1);

        // Test the argument
        auto arguments = spy.takeFirst();
        QCOMPARE(arguments.at(0).toString(), QString(expectedAppId));
    }

    void testAppId()
    {
        // Since our mock u-g-s-b just passes on the incoming appId, we test
        // here that our plugin mangles the names appropriately.
        testRequest("appid", "appid");
        testRequest("appid.desktop", "appid");
        testRequest("appid.info", "appid.info");
        testRequest("/usr/share/applications/appid.desktop", "appid");
        testRequest("/full/appid.desktop", "appid");
    }
};

QTEST_MAIN(BroadcastServiceTest)

#include "client.moc"
