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

        QTest::newRow("Logout") << "RequestLogout";
    }

    void testUnitySessionLogoutRequested() {
        QFETCH(QString, method);

        DBusUnitySessionService dbusUnitySessionService;
        QCoreApplication::processEvents(); // to let the service register on DBus

        QSignalSpy spy(&dbusUnitySessionService, SIGNAL(logoutRequested(bool)));

        QDBusReply<void> reply = dbusUnitySession->call(method);
        QCOMPARE(reply.isValid(), true);

        QCOMPARE(spy.count(), 1);
    }

    void testGnomeSessionWrapperLogoutRequested() {
        DBusUnitySessionService dbusUnitySessionService;
        QCoreApplication::processEvents(); // to let the service register on DBus

        // Spy on the logoutRequested signal on the /com/canonical/Unity/Session object
        // as proof we are actually calling the actual method.
        QSignalSpy spy(&dbusUnitySessionService, SIGNAL(logoutRequested(bool)));

        DBusGnomeSessionManagerWrapper dbusGnomeSessionManagerWrapper;
        QCoreApplication::processEvents(); // to let the service register on DBus

        QDBusInterface dbusGnomeSessionWrapper ("com.canonical.Unity",
                                                "/org/gnome/SessionManager/EndSessionDialog",
                                                "org.gnome.SessionManager.EndSessionDialog",
                                                QDBusConnection::sessionBus());

        QCOMPARE(dbusGnomeSessionWrapper.isValid(), true);

        // Set the QVariant as a QList<QDBusObjectPath> type
        QDbusList var;
        QVariant inhibitors;
        inhibitors.setValue(var);

        QDBusReply<void> reply = dbusGnomeSessionWrapper.call("Open", (unsigned)Action::LOGOUT, (unsigned)0, (unsigned)0, inhibitors);
        QCOMPARE(reply.isValid(), true);

        // Make sure we see the signal being emitted.
        QCOMPARE(spy.count(), 1);
    }

    void testGnomeSessionWrapperShutdownRequested() {
        DBusUnitySessionService dbusUnitySessionService;
        QCoreApplication::processEvents(); // to let the service register on DBus

        // Spy on the shutdownRequested signal on the /com/canonical/Unity/Session object
        // as proof we are actually calling the actual method.
        QSignalSpy spy(&dbusUnitySessionService, SIGNAL(shutdownRequested(bool)));

        DBusGnomeSessionManagerWrapper dbusGnomeSessionManagerWrapper;
        QCoreApplication::processEvents(); // to let the service register on DBus

        QDBusInterface dbusGnomeSessionWrapper ("com.canonical.Unity",
                                                "/org/gnome/SessionManager/EndSessionDialog",
                                                "org.gnome.SessionManager.EndSessionDialog",
                                                QDBusConnection::sessionBus());

        QCOMPARE(dbusGnomeSessionWrapper.isValid(), true);

        // Set the QVariant as a QList<QDBusObjectPath> type
        QDbusList var;
        QVariant inhibitors;
        inhibitors.setValue(var);

        // * Reboot action translates to the shutdown signal due to some weird idiosyncracy
        //   in the indicator-session/Unity interaction. *
        QDBusReply<void> reply = dbusGnomeSessionWrapper.call("Open", (unsigned)Action::REBOOT, (unsigned)0, (unsigned)0, inhibitors);
        QCOMPARE(reply.isValid(), true);

        // Make sure we see the signal being emitted.
        QCOMPARE(spy.count(), 1);
    }

private:
    QDBusInterface *dbusUnitySession;
};

QTEST_GUILESS_MAIN(SessionBackendTest)
#include "sessionbackendtest.moc"
