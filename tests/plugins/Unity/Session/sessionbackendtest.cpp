/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Ying-Chun Liu (PaulLiu) <paul.liu@canonical.com>
 */

#include <QtTest>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusVariant>

#include "dbusunitysessionservice.h"

class SessionBackendTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase() {
    }

    void testDbusIfaceMethods_data() {
        QTest::addColumn<QString>("method");

        QTest::newRow("Logout") << "RequestLogout";
    }

    void testDbusIfaceMethods() {
        QFETCH(QString, method);

        DBusUnitySessionService dbusUnitySessionService;

        QDBusConnection con = QDBusConnection::sessionBus();
        QDBusInterface interface ("com.canonical.Unity",
                                  "/com/canonical/Unity/Session",
                                  "com.canonical.Unity.Session",
                                  con);
        QDBusReply<void> reply;

        QCOMPARE(interface.isValid(), true);
        reply = interface.call(method);
        QCOMPARE(reply.isValid(), true);

    }
};

QTEST_GUILESS_MAIN(SessionBackendTest)
#include "sessionbackendtest.moc"
