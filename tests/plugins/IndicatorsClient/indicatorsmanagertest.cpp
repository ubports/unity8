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

#include "fakeindicator.h"
#include "indicatorsmanager.h"
#include "indicatorsfactory.h"
#include "paths.h"

#include <QtTest>
#include <QDebug>

FAKE_INDICATOR(1, "Fake Title 1", "fake-indicator-1")
FAKE_INDICATOR(2, "Fake Title 2", "fake-indicator-2")

class IndicatorsManagerTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:

    void initTestCase() {
        setenv("XDG_DATA_DIRS", (sourceDirectory() + "/tests/data").toLatin1().data(), 1);

        IndicatorsFactory::instance().registerIndicator<FakeIndicatorClient1>("indicator-fake1");
        IndicatorsFactory::instance().registerIndicator<FakeIndicatorClient2>("indicator-fake2");
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
        QCOMPARE(manager.indicators().count(), 2);

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

        IndicatorClientInterface::Ptr indicator = manager.indicator("indicator-fake1");
        QVERIFY(indicator.get());

        QCOMPARE(indicator->identifier(), QString("indicator-fake1"));
        QCOMPARE(indicator->icon(), QUrl("image://gicon/fake-indicator-1"));
        QCOMPARE(indicator->title(), QString("Fake Title 1"));
        QCOMPARE(indicator->label(), QString());
        QCOMPARE(indicator->description(), QString());
        QCOMPARE(indicator->priority(), 1);

        // Check that the initial properties have been set.
        IndicatorClientInterface::PropertiesMap props = indicator->initialProperties();
        QCOMPARE(props.count(), 4);
        QCOMPARE(props["title"].toString(), QString("Fake Title 1"));
        QCOMPARE(props["busType"].toInt(), 1);
        QCOMPARE(props["busName"].toString(), QString("com.canonical.indicator.fake1"));
        QCOMPARE(props["objectPath"].toString(), QString("/com/canonical/indicator/fake1"));
    }

    /*
     * Test if a new plugin object is create for each different plugin
     */
    void testPluginInstance()
    {
        IndicatorsManager manager;
        manager.load();

        IndicatorClientInterface::Ptr i0 = manager.indicator("indicator-fake1");
        IndicatorClientInterface::Ptr i1 = manager.indicator("indicator-fake1");
        QVERIFY(i0?true:false);
        QVERIFY(i1?true:false);
        QCOMPARE(i0, i1);

        IndicatorClientInterface::Ptr i2 = manager.indicator("indicator-fake2");
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
            IndicatorClientInterface::Ptr i0 = manager.indicator("indicator-fake1");
            pi0 = dynamic_cast<QObject*>(i0.get());
            QCOMPARE(pi0->property("initializedCount").toInt(), 1);

            IndicatorClientInterface::Ptr i1 = manager.indicator("indicator-fake1");
            pi1 = dynamic_cast<QObject*>(i1.get());
            QCOMPARE(pi0->property("initializedCount").toInt(), 1);
            QCOMPARE(pi1->property("initializedCount").toInt(), 1);

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

