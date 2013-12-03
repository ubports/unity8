/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#include "Greeter.h"

#include <QDBusInterface>
#include <QDBusReply>
#include <QSignalSpy>
#include <QQuickItem>
#include <QQuickView>
#include <QtTestGui>

class GreeterDBusTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void init()
    {
        view = new QQuickView();
        view->setSource(QUrl::fromLocalFile(CURRENT_SOURCE_DIR "/greeter.qml"));
        greeter = dynamic_cast<Greeter*>(view->rootObject()->property("greeter").value<QObject*>());
        QVERIFY(greeter);
        QVERIFY(greeter->authenticationUser() == "");
        view->show();
        QTest::qWaitForWindowExposed(view);

        dbusList = new QDBusInterface("com.canonical.UnityGreeter",
                                      "/list",
                                      "com.canonical.UnityGreeter.List",
                                      QDBusConnection::sessionBus(), view);
        QVERIFY(dbusList->isValid());
    }

    void cleanup()
    {
        delete view;
    }

    void testGetActiveEntry()
    {
        greeter->authenticate("has-password");

        QDBusReply<QString> reply = dbusList->call("GetActiveEntry");
        QVERIFY(reply.isValid());
        QVERIFY(reply.value() == "has-password");
    }

    void testSetActiveEntry()
    {
        QSignalSpy spy(greeter, SIGNAL(requestAuthenticationUser(QString)));
        QDBusReply<void> reply = dbusList->call("SetActiveEntry", "has-password");
        QVERIFY(reply.isValid());
        spy.wait();

        QCOMPARE(spy.count(), 1);
        QList<QVariant> arguments = spy.takeFirst();
        QVERIFY(arguments.at(0).toString() == "has-password");
    }

    void testEntrySelectedSignal()
    {
        QSignalSpy spy(dbusList, SIGNAL(EntrySelected(QString)));
        greeter->authenticate("has-password");
        spy.wait();

        QCOMPARE(spy.count(), 1);
        QList<QVariant> arguments = spy.takeFirst();
        QVERIFY(arguments.at(0).toString() == "has-password");
    }

    void testActiveEntryGet()
    {
        greeter->authenticate("has-password");
        QVERIFY(dbusList->property("ActiveEntry").toString() == "has-password");
    }

    void testActiveEntrySet()
    {
        QSignalSpy spy(greeter, SIGNAL(requestAuthenticationUser(QString)));
        QVERIFY(dbusList->setProperty("ActiveEntry", "has-password"));
        spy.wait();

        QCOMPARE(spy.count(), 1);
        QList<QVariant> arguments = spy.takeFirst();
        QVERIFY(arguments.at(0).toString() == "has-password");
    }

    void testEntryIsLockedGet()
    {
        greeter->authenticate("has-password");
        QVERIFY(dbusList->property("EntryIsLocked").toBool());

        greeter->authenticate("no-password");
        QVERIFY(!dbusList->property("EntryIsLocked").toBool());
    }

private:
    QQuickView *view;
    Greeter *greeter;
    QDBusInterface *dbusList;
};

QTEST_MAIN(GreeterDBusTest)

#include "dbus.moc"
