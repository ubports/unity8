/*
 * Copyright (C) 2017 Canonical, Ltd.
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
 *
 * Authors:
 *  Pete Woods <pete.woods@canonical.com>
 */

#include "platform.h"

#include <libqtdbustest/DBusTestRunner.h>
#include <libqtdbusmock/DBusMock.h>

#include <QtTest>
#include <QDebug>

using namespace QtDBusTest;
using namespace QtDBusMock;

class PlatformTest: public QObject
{

Q_OBJECT

private:
    struct TestFixture
    {
        TestFixture() :
            mock(dbus)
        {
        }

        DBusTestRunner dbus;
        DBusMock mock;
    };

    QScopedPointer<TestFixture> m_data;

    void registerLogin1(bool canMultiSession, bool canGraphical)
    {
        m_data->mock.registerLogin1({{"DefaultSeat", QVariantMap
            {
                {"CanMultiSession", canMultiSession},
                {"CanGraphical", canGraphical}
            }}}
        );
    }

    void registerHostname1(const QString& chassis)
    {
        m_data->mock.registerHostname1({
            {"Chassis", chassis}
        });
    }

    void startServices()
    {
        m_data->dbus.startServices();
    }

private Q_SLOTS:

    void init()
    {
        m_data.reset(new TestFixture);
    }

    void cleanup()
    {
        m_data.reset();
    }

    void testIsPC_data()
    {
        QTest::addColumn<QString>("chassis");
        QTest::addColumn<bool>("result");

        QTest::newRow("vm") << "vm" << true;
        QTest::newRow("container") << "container" << true;
        QTest::newRow("desktop") << "desktop" << true;
        QTest::newRow("laptop") << "laptop" << true;
        QTest::newRow("server") << "server" << true;
        QTest::newRow("tablet") << "tablet" << false;
        QTest::newRow("handset") << "handset" << false;
        QTest::newRow("watch") << "watch" << false;
        QTest::newRow("embedded") << "embedded" << true;
    }

    void testIsPC()
    {
        QFETCH(QString, chassis);
        QFETCH(bool, result);

        registerLogin1(true, true);
        registerHostname1(chassis);
        startServices();

        Platform p;
        QCOMPARE(p.isPC(), result);
        QCOMPARE(p.chassis(), chassis);
    }

    void testIsMultiSession_data()
    {
        QTest::addColumn<bool>("canMultiSession");
        QTest::addColumn<bool>("canGraphical");
        QTest::addColumn<bool>("result");

        QTest::newRow("") << true << true << true;
        QTest::newRow("") << true << false << false;
        QTest::newRow("") << false << true << false;
        QTest::newRow("") << false << false << false;
    }

    void testIsMultiSession()
    {
        QFETCH(bool, canMultiSession);
        QFETCH(bool, canGraphical);
        QFETCH(bool, result);

        registerLogin1(canMultiSession, canGraphical);
        registerHostname1("desktop");
        startServices();

        Platform p;
        QCOMPARE(p.isMultiSession(), result);
    }
};

QTEST_GUILESS_MAIN(PlatformTest)
#include "platformtest.moc"
