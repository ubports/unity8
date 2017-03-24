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
#include <QDebug>
#include <QDBusObjectPath>

#include <unistd.h>
#include <sys/types.h>

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

    void init() {
        qputenv("TEST_USER", "testuser");
        qputenv("TEST_NOPASSWD_USERS", "");
    }

    void testUnitySessionLogoutRequested_data() {
        QTest::addColumn<QString>("method");
        QTest::addColumn<QString>("signal");

        QTest::newRow("Logout") << "RequestLogout" << "LogoutRequested(bool)";
        QTest::newRow("Reboot") << "RequestReboot" << "RebootRequested(bool)";
        QTest::newRow("Shutdown") << "RequestShutdown" << "ShutdownRequested(bool)";
        QTest::newRow("PromptLock") << "PromptLock" << "LockRequested()";
        QTest::newRow("Lock") << "Lock" << "LockRequested()";
        QTest::newRow("LockLightDM") << "Lock" << "Locked()"; // happens when we lock LightDM, only for Lock()
    }

    void testUnitySessionLogoutRequested() {
        QFETCH(QString, method);
        QFETCH(QString, signal);

        DBusUnitySessionService dbusUnitySessionService;
        QCoreApplication::processEvents(); // to let the service register on DBus

        // .. because QSignalSpy checks the signal signature like this: "if (((aSignal[0] - '0') & 0x03) != QSIGNAL_CODE)"
        QSignalSpy spy(&dbusUnitySessionService, qPrintable(signal.prepend(QSIGNAL_CODE)));

        QDBusReply<void> reply = dbusUnitySession->call(method);
        QCOMPARE(reply.isValid(), true);

        QTRY_COMPARE(spy.count(), 1);
    }

    void testGnomeSessionWrapperWithoutConfirmation_data() {
        QTest::addColumn<QString>("method");
        QTest::addColumn<QString>("signal");

        QTest::newRow("Reboot") << "RequestReboot" << SIGNAL(RebootCalled(bool));
        QTest::newRow("Shutdown") << "RequestShutdown" << SIGNAL(PowerOffCalled(bool));
    }

    void testGnomeSessionWrapperWithoutConfirmation() {
        QFETCH(QString, method);
        QFETCH(QString, signal);

        DBusUnitySessionService dbusUnitySessionService;
        DBusGnomeSessionManagerWrapper dbusGnomeSessionManagerWrapper;
        QCoreApplication::processEvents(); // to let the services register on DBus

        QDBusInterface login1Interface("org.freedesktop.login1",
                                      "/logindsession",
                                      "org.freedesktop.login1.Manager");
        QSignalSpy spy(&login1Interface, signal.toUtf8().data());

        QDBusInterface dbusGnomeSessionWrapper("org.gnome.SessionManager",
                                               "/org/gnome/SessionManager",
                                               "org.gnome.SessionManager",
                                               QDBusConnection::sessionBus());
        QVERIFY(dbusGnomeSessionWrapper.isValid());

        QDBusReply<void> reply = dbusGnomeSessionWrapper.call(method);
        QVERIFY(reply.isValid());
        QTRY_COMPARE(spy.count(), 1);
    }

    void testGnomeSessionWrapperWithConfirmation_data() {
        QTest::addColumn<QString>("method");
        QTest::addColumn<QString>("signal");

        QTest::newRow("Reboot") << "Reboot" << SIGNAL(RebootRequested(bool));
        QTest::newRow("Shutdown") << "Shutdown" << SIGNAL(ShutdownRequested(bool));
    }

    void testGnomeSessionWrapperWithConfirmation() {
        QFETCH(QString, method);
        QFETCH(QString, signal);

        DBusUnitySessionService dbusUnitySessionService;
        DBusGnomeSessionManagerWrapper dbusGnomeSessionManagerWrapper;
        QCoreApplication::processEvents(); // to let the services register on DBus

        QSignalSpy spy(&dbusUnitySessionService, signal.toUtf8().data());

        QDBusInterface dbusGnomeSessionWrapper("org.gnome.SessionManager",
                                               "/org/gnome/SessionManager",
                                               "org.gnome.SessionManager",
                                               QDBusConnection::sessionBus());
        QVERIFY(dbusGnomeSessionWrapper.isValid());

        QDBusReply<void> reply = dbusGnomeSessionWrapper.call(method);
        QVERIFY(reply.isValid());
        QCOMPARE(spy.count(), 1);
    }

    void testGnomeSessionWrapperLogout_data() {
        QTest::addColumn<int>("mode");
        QTest::addColumn<QString>("signal");

        QTest::newRow("Logout") << 0 << SIGNAL(LogoutRequested(bool));
        QTest::newRow("LogoutNoDialog") << 1 << SIGNAL(LogoutReady());
        QTest::newRow("LogoutNoInhibits") << 2 << SIGNAL(LogoutReady());
        QTest::newRow("LogoutNoDialogNoInhibits") << 3 << SIGNAL(LogoutReady());
    }

    void testGnomeSessionWrapperLogout() {
        QFETCH(int, mode);
        QFETCH(QString, signal);

        DBusUnitySessionService dbusUnitySessionService;
        DBusGnomeSessionManagerWrapper dbusGnomeSessionManagerWrapper;
        QCoreApplication::processEvents(); // to let the services register on DBus

        QSignalSpy spy(&dbusUnitySessionService, signal.toUtf8().data());

        QDBusInterface dbusGnomeSessionWrapper("org.gnome.SessionManager",
                                               "/org/gnome/SessionManager",
                                               "org.gnome.SessionManager",
                                               QDBusConnection::sessionBus());
        QVERIFY(dbusGnomeSessionWrapper.isValid());

        QDBusReply<void> reply = dbusGnomeSessionWrapper.call("Logout", (quint32)mode);
        QVERIFY(reply.isValid());
        QCOMPARE(spy.count(), 1);
    }

    void testGnomeSessionDialogWrapper_data() {
        QTest::addColumn<uint>("method");
        QTest::addColumn<QString>("signal");

        QTest::newRow("Logout") << (uint)Action::LOGOUT << "LogoutRequested(bool)";
        QTest::newRow("Shutdown") << (uint)Action::SHUTDOWN << "ShutdownRequested(bool)";
        QTest::newRow("Reboot") << (uint)Action::REBOOT << "RebootRequested(bool)";
    }

    void testGnomeSessionDialogWrapper() {
        QFETCH(uint, method);
        QFETCH(QString, signal);

        DBusUnitySessionService dbusUnitySessionService;
        QCoreApplication::processEvents(); // to let the service register on DBus

        // Spy on the given signal on the /com/canonical/Unity/Session object
        // as proof we are actually calling the actual method.
        // .. because QSignalSpy checks the signal signature like this: "if (((aSignal[0] - '0') & 0x03) != QSIGNAL_CODE)"
        QSignalSpy spy(&dbusUnitySessionService, qPrintable(signal.prepend(QSIGNAL_CODE)));

        DBusGnomeSessionManagerDialogWrapper dbusGnomeSessionManagerDialogWrapper;
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

    void testUnlockFromLogind() {
        DBusUnitySessionService dbusUnitySessionService;
        QCoreApplication::processEvents(); // to let the service register on DBus

        QDBusInterface iface("org.freedesktop.login1", "/logindsession", "org.freedesktop.login1.Session");
        QVERIFY(iface.isValid());

        QSignalSpy spy(&dbusUnitySessionService, SIGNAL(Unlocked()));
        QCOMPARE(iface.call("MockEmitUnlock").errorMessage(), QString());
        QTRY_COMPARE(spy.count(), 1);
    }

    void testUserName() {
        DBusUnitySessionService dbusUnitySessionService;
        QCOMPARE(dbusUnitySessionService.UserName(), QString("testuser"));
    }

    void testRealName() {
        DBusUnitySessionService dbusUnitySessionService;
        QCoreApplication::processEvents(); // to let the service register on DBus

        QDBusInterface accIface("org.freedesktop.Accounts", "/org/freedesktop/Accounts", "org.freedesktop.Accounts", QDBusConnection::systemBus());
        if (accIface.isValid()) {
            QDBusReply<QDBusObjectPath> userPath = accIface.asyncCall("FindUserById", static_cast<qint64>(geteuid()));
            if (userPath.isValid()) {
                QDBusInterface userAccIface("org.freedesktop.Accounts", userPath.value().path(), "org.freedesktop.Accounts.User", QDBusConnection::systemBus());
                QCOMPARE(dbusUnitySessionService.RealName(), userAccIface.property("RealName").toString());
            }
        }
    }

    void testCanLock() {
        DBusUnitySessionService dbusUnitySessionService;

        qputenv("TEST_USER", "testuser");
        QVERIFY(dbusUnitySessionService.CanLock());

        qputenv("TEST_USER", "guest-abcdef"); // guest-* can't lock
        QVERIFY(!dbusUnitySessionService.CanLock());

        qputenv("TEST_USER", "testuser");
        qputenv("TEST_NOPASSWD_USERS", "testuser"); // nopasswdlogin can't lock
        QVERIFY(!dbusUnitySessionService.CanLock());
    }

    void testPromptLockRespectsCanLock() {
        DBusUnitySessionService dbusUnitySessionService;

        QSignalSpy spy(&dbusUnitySessionService, SIGNAL(lockRequested()));
        QVERIFY(dbusUnitySessionService.CanLock());
        dbusUnitySessionService.PromptLock();
        QCOMPARE(spy.count(), 1);

        spy.clear();
        qputenv("TEST_USER", "guest-abcdef");
        QVERIFY(!dbusUnitySessionService.CanLock());
        dbusUnitySessionService.PromptLock();
        QCOMPARE(spy.count(), 0);
    }

private:
    QDBusInterface *dbusUnitySession;
};

QTEST_GUILESS_MAIN(SessionBackendTest)
#include "sessionbackendtest.moc"
