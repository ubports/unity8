/*
 * Copyright 2012 Canonical Ltd.
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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

#include "indicatorsmanager.h"
#include "paths.h"

#include <QtTest>
#include <QDebug>

class IndicatorsManagerTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:

    void initTestCase()
    {
        setenv("UNITY_TEST_ENV", "1", 1);
        setenv("XDG_DATA_DIRS", (sourceDirectory() + "/tests/data").toLatin1().data(), 1);
    }

    void cleanupTestCase()
    {
        unsetenv("UNITY_TEST_ENV");
    }

    /*
     * Test if all plugins is loaded correct
     */
    void testLoad()
    {
        IndicatorsManager manager;

        QVERIFY(!manager.isLoaded());
        QCOMPARE(manager.indicators().count(), 0);

        manager.load();

        QVERIFY(manager.isLoaded());
        QCOMPARE(manager.indicators().count(), 4);

        manager.unload();

        QVERIFY(!manager.isLoaded());
        QCOMPARE(manager.indicators().count(), 0);
    }

    /*
     * Test the creation & initialising of the indicator data
     */
    void testPluginInterface()
    {
        IndicatorsManager manager;
        manager.load();

        Indicator::Ptr indicator = manager.indicator("indicator-fake1");
        QVERIFY(indicator.get());

        QCOMPARE(indicator->identifier(), QString("indicator-fake1"));

        // Check that the initial properties have been set.
        QVariantMap props = indicator->indicatorProperties().toMap();
        QCOMPARE(props.count(), 4);
        QCOMPARE(props["busType"].toInt(), 1);
        QCOMPARE(props["busName"].toString(), QString("com.canonical.indicator.fake1"));
        QCOMPARE(props["actionsObjectPath"].toString(), QString("/com/canonical/indicator/fake1"));

        QVariantMap objectPaths = props["menuObjectPaths"].toMap();
        QCOMPARE(objectPaths["phone"].toString(), QString("/com/canonical/indicator/fake1/phone"));
        QCOMPARE(objectPaths["desktop"].toString(), QString("/com/canonical/indicator/fake1/desktop"));
    }

    /*
     * Test if a new plugin object is create for each different plugin
     */
    void testPluginInstance()
    {
        IndicatorsManager manager;
        manager.load();

        Indicator::Ptr i0 = manager.indicator("indicator-fake1");
        Indicator::Ptr i1 = manager.indicator("indicator-fake1");
        QVERIFY(i0?true:false);
        QVERIFY(i1?true:false);
        QCOMPARE(i0, i1);

        Indicator::Ptr i2 = manager.indicator("indicator-fake2");
        QVERIFY(i2?true:false);
        QVERIFY(i2 != i1);
        QVERIFY(i2 != i1);
    }

    /*
     * Test if a new plugin init function is called only once
     */
    void testPluginInitAndShutdown()
    {
        IndicatorsManager manager;
        manager.load();

        QPointer<QObject> pi0;
        QPointer<QObject> pi1;
        {
            Indicator::Ptr i0 = manager.indicator("indicator-fake1");
            pi0 = dynamic_cast<QObject*>(i0.get());

            Indicator::Ptr i1 = manager.indicator("indicator-fake1");
            pi1 = dynamic_cast<QObject*>(i1.get());

            manager.unload();
            // still alive while we have the shared pointers.
            QVERIFY(!pi0.isNull());
            QVERIFY(!pi1.isNull());

        }

        // no more smart pointers. should have been released.
        QVERIFY(pi0.isNull());
        QVERIFY(pi1.isNull());
    }
};

QTEST_MAIN(IndicatorsManagerTest)
#include "indicatorsmanagertest.moc"
