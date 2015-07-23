/*
 * Copyright 2013-2015 Canonical Ltd.
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
 *      Lukáš Tinkl <lukas.tinkl@canonical.com>
 */

#include <QtTest>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusVariant>

#include "dbusunitysessionservice.h"

enum class Action : unsigned
{
  LOGOUT = 0,
  SHUTDOWN,
  REBOOT,
  NONE
};

class SessionBackendTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase() {
        dbusUnitySession = new QDBusInterface ("com.canonical.Unity",
                                               "/com/canonical/Unity/Session",
                                               "com.canonical.Unity.Session",
                                               QDBusConnection::sessionBus());
    }

    void testUnitySessionLogoutRequested_data() {
        QTest::addColumn<QString>("method");
        QTest::addColumn<QString>("signal");

        QTest::newRow("Logout") << "RequestLogout" << "logoutRequested(bool)";
        QTest::newRow("Reboot") << "RequestReboot" << "rebootRequested(bool)";
        QTest::newRow("Shutdown") << "RequestShutdown" << "shutdownRequested(bool)";
    }

    void testUnitySessionLogoutRequested() {
        QFETCH(QString, method);
        QFETCH(QString, signal);

        DBusUnitySessionService dbusUnitySessionService;
        QCoreApplication::processEvents(); // to let the service register on DBus

        // .. because QSignalSpy checks the signal signature like this: "if (((aSignal[0] - '0') & 0x03) != QSIGNAL_CODE)"
        QSignalSpy spy(&dbusUnitySessionService, signal.prepend(QSIGNAL_CODE).toLocal8Bit().constData());

        QDBusReply<void> reply = dbusUnitySession->call(method);
        QCOMPARE(reply.isValid(), true);

        QCOMPARE(spy.count(), 1);
    }

    void testGnomeSessionWrapper_data() {
        QTest::addColumn<uint>("method");
        QTest::addColumn<QString>("signal");

        QTest::newRow("Logout") << (uint)Action::LOGOUT << "logoutRequested(bool)";
        QTest::newRow("Shutdown") << (unsigned)Action::SHUTDOWN << "shutdownRequested(bool)";
        QTest::newRow("Reboot") << (unsigned)Action::REBOOT << "rebootRequested(bool)";
    }

    void testGnomeSessionWrapper() {
        QFETCH(uint, method);
        QFETCH(QString, signal);

        DBusUnitySessionService dbusUnitySessionService;
        QCoreApplication::processEvents(); // to let the service register on DBus

        // Spy on the given signal on the /com/canonical/Unity/Session object
        // as proof we are actually calling the actual method.
        // .. because QSignalSpy checks the signal signature like this: "if (((aSignal[0] - '0') & 0x03) != QSIGNAL_CODE)"
        QSignalSpy spy(&dbusUnitySessionService, signal.prepend(QSIGNAL_CODE).toLocal8Bit().constData());

        DBusGnomeSessionManagerWrapper dbusGnomeSessionManagerWrapper;
        QCoreApplication::processEvents(); // to let the service register on DBus

        QDBusInterface dbusGnomeSessionWrapper("com.canonical.Unity",
                                               "/org/gnome/SessionManager/EndSessionDialog",
                                               "org.gnome.SessionManager.EndSessionDialog",
                                               QDBusConnection::sessionBus());

        QCOMPARE(dbusGnomeSessionWrapper.isValid(), true);

        // Set the QVariant as a QList<QDBusObjectPath> type
        QDbusList var;
        QVariant inhibitors;
        inhibitors.setValue(var);

        QDBusReply<void> reply = dbusGnomeSessionWrapper.call("Open", method, (unsigned)0, (unsigned)0, inhibitors);
        QCOMPARE(reply.isValid(), true);

        // Make sure we see the signal being emitted.
        QCOMPARE(spy.count(), 1);
    }

private:
    QDBusInterface *dbusUnitySession;
};

QTEST_GUILESS_MAIN(SessionBackendTest)
#include "sessionbackendtest.moc"
