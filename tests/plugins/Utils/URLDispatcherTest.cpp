/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "URLDispatcher.h"

#include <QDBusInterface>
#include <QSignalSpy>
#include <QTest>

class URLDispatcherTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase() {
        dispatchServer = new QDBusInterface("com.canonical.URLDispatcher",
                                            "/com/canonical/URLDispatcher",
                                            "com.canonical.URLDispatcher",
                                            QDBusConnection::sessionBus(), this);
    }

    void init()
    {
        dispatcher = new URLDispatcher(this);
        dispatchSpy = new QSignalSpy(dispatcher,
                                     SIGNAL(urlRequested(const QString &)));
    }

    void cleanup()
    {
        delete dispatcher;
    }

    void testInactiveByDefault() {
        QVERIFY(!dispatcher->active());
    }

    void testActiveRequest() {
        dispatcher->setActive(true);
        dispatchServer->call("DispatchURL", "test:", "package");
        QCOMPARE(dispatchSpy->count(), 1);
        QCOMPARE((*dispatchSpy)[0][0], QVariant("test:"));
    }

    void testInactiveRequest() {
        dispatchServer->call("DispatchURL", "test:", "package");
        QCOMPARE(dispatchSpy->count(), 0);
    }

    void testInactiveAfterActiveRequest() {
        dispatcher->setActive(true);
        dispatcher->setActive(false);
        dispatchServer->call("DispatchURL", "test:", "package");
        QCOMPARE(dispatchSpy->count(), 0);
    }

private:
    QDBusInterface *dispatchServer;
    URLDispatcher *dispatcher;
    QSignalSpy *dispatchSpy;
};

QTEST_GUILESS_MAIN(URLDispatcherTest)
#include "URLDispatcherTest.moc"
