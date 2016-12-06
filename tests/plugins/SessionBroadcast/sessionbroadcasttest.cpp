/*
 * Copyright 2016 Canonical Ltd.
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
 */

#include <QtTest>
#include <QDBusInterface>
#include <QSignalSpy>

#include <glib.h>

#include "SessionBroadcast.h"

class SessionBroadcastTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase() {
        broadcastServer = new QDBusInterface("com.canonical.Unity.Greeter.Broadcast",
                                             "/com/canonical/Unity/Greeter/Broadcast",
                                             "com.canonical.Unity.Greeter.Broadcast",
                                             QDBusConnection::sessionBus(), this);
        serverStartUrlSpy = new QSignalSpy(broadcastServer,
                                           SIGNAL(StartUrl(const QString &, const QString &)));
        serverShowHomeSpy = new QSignalSpy(broadcastServer,
                                           SIGNAL(ShowHome(const QString &)));
        user = QString(g_get_user_name());
        otherUser = user + "2";
    }

    void init()
    {
        serverStartUrlSpy->clear();
        serverShowHomeSpy->clear();

        broadcastPlugin = new SessionBroadcast(this);
        pluginStartUrlSpy = new QSignalSpy(broadcastPlugin,
                                           SIGNAL(startUrl(const QString &)));
        pluginShowHomeSpy = new QSignalSpy(broadcastPlugin,
                                           SIGNAL(showHome()));
    }

    void cleanup()
    {
        delete broadcastPlugin;
    }

    void testReceiveUrlStart() {
        broadcastServer->call("RequestUrlStart", user, "test:");
        QTRY_COMPARE(serverStartUrlSpy->count(), 1);
        QCOMPARE(pluginStartUrlSpy->count(), 1);
        QCOMPARE((*pluginStartUrlSpy)[0][0], QVariant("test:"));
    }

    void testReceiveUrlStartOtherUser() {
        broadcastServer->call("RequestUrlStart", otherUser, "test:");
        QTRY_COMPARE(serverStartUrlSpy->count(), 1);
        QCOMPARE(pluginStartUrlSpy->count(), 0);
    }

    void testReceiveShowHome() {
        broadcastServer->call("RequestHomeShown", user);
        QTRY_COMPARE(serverShowHomeSpy->count(), 1);
        QCOMPARE(pluginShowHomeSpy->count(), 1);
    }

    void testReceiveShowHomeOtherUser() {
        broadcastServer->call("RequestHomeShown", otherUser);
        QTRY_COMPARE(serverShowHomeSpy->count(), 1);
        QCOMPARE(pluginShowHomeSpy->count(), 0);
    }

    void testSendUrlStart() {
        broadcastPlugin->requestUrlStart(otherUser, "test:");
        QTRY_COMPARE(serverStartUrlSpy->count(), 1);
        QCOMPARE((*serverStartUrlSpy)[0][0], QVariant(otherUser));
        QCOMPARE((*serverStartUrlSpy)[0][1], QVariant("test:"));
    }

    void testSendShowHome() {
        broadcastPlugin->requestHomeShown(otherUser);
        QTRY_COMPARE(serverShowHomeSpy->count(), 1);
        QCOMPARE((*serverShowHomeSpy)[0][0], QVariant(otherUser));
    }

private:
    QDBusInterface *broadcastServer;
    SessionBroadcast *broadcastPlugin;
    QSignalSpy *serverStartUrlSpy;
    QSignalSpy *serverShowHomeSpy;
    QSignalSpy *pluginStartUrlSpy;
    QSignalSpy *pluginShowHomeSpy;
    QString user;
    QString otherUser;
};

QTEST_GUILESS_MAIN(SessionBroadcastTest)
#include "sessionbroadcasttest.moc"
