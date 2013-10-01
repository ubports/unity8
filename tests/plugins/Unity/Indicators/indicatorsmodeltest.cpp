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

#include "indicatorsmodel.h"
#include "indicators.h"
#include "paths.h"

#include <QtTest>
#include <QDebug>

class IndicatorsModelTest : public QObject
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
     * Testa that all the plugins are loaded / unloaded correctly
     */
    void testLoad()
    {
        IndicatorsModel model;

        QCOMPARE(model.property("count").toInt(), 0);

        model.load();

        QCOMPARE(model.property("count").toInt(), 4);

        model.unload();

        QCOMPARE(model.property("count").toInt(), 0);

    }

    /*
     * Testa that the plugin data was loaded correctly
     */
    void testDataAndOrder()
    {
        // Priority order. (2, 1, 4, 3)
        QVariantMap map;
        QVariantMap map1; map1["title"] = "fake1";
        QVariantMap map2; map2["title"] = "fake2";
        QVariantMap map3; map3["title"] = "fake3";
        map["indicator-fake1"] = map1;
        map["indicator-fake2"] = map2;
        map["indicator-fake3"] = map3;

        IndicatorsModel model;
        model.setIndicatorData(map);
        model.load();

        // should be in order:
        // fake3, fake4, fake1, fake2

        QCOMPARE(model.data(0, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake3"));
        QCOMPARE(model.data(0, IndicatorsModelRole::Title).toString(), QString("fake3"));
        QCOMPARE(model.data(0, IndicatorsModelRole::Position).toInt(), 3);
        QCOMPARE(model.data(0, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake3"));

        QCOMPARE(model.data(1, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake4"));
        QCOMPARE(model.data(1, IndicatorsModelRole::Title).toString(), QString("indicator-fake4"));
        QCOMPARE(model.data(1, IndicatorsModelRole::Position).toInt(), 2);
        QCOMPARE(model.data(1, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake4"));

        QCOMPARE(model.data(2, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake1"));
        QCOMPARE(model.data(2, IndicatorsModelRole::Title).toString(), QString("fake1"));
        QCOMPARE(model.data(2, IndicatorsModelRole::Position).toInt(), 1);
        QCOMPARE(model.data(2, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake1"));

        QCOMPARE(model.data(3, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake2"));
        QCOMPARE(model.data(3, IndicatorsModelRole::Title).toString(), QString("fake2"));
        QCOMPARE(model.data(3, IndicatorsModelRole::Position).toInt(), 0);
        QCOMPARE(model.data(3, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake2"));
    }
};

QTEST_GUILESS_MAIN(IndicatorsModelTest)

#include "indicatorsmodeltest.moc"
