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

#include <paths.h>

#include <QtTest>
#include <QDebug>

class IndicatorsModelTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:

    void initTestCase()
    {
        setenv("XDG_DATA_DIRS", (testDataDir() + "/data").toLatin1().data(), 1);
    }

    void cleanupTestCase()
    {
    }

    /*
     * Testa that all the plugins are loaded / unloaded correctly
     */
    void testLoad()
    {
        IndicatorsModel model;
        model.setProfile("test1");

        QCOMPARE(model.property("count").toInt(), 0);

        model.load();

        QCOMPARE(model.property("count").toInt(), 4);

        model.unload();

        QCOMPARE(model.property("count").toInt(), 0);

    }

    /*
     * Testa that the plugin data was loaded correctly ( "test1" )
     */
    void testDataAndOrderProfile1()
    {
        // Priority order. (2, 1, 4, 3)
        IndicatorsModel model;
        model.setProfile("test1");
        model.load();

        // should be in order:
        // fake3, fake4, fake1, fake2

        QCOMPARE(model.data(0, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake3"));
        QCOMPARE(model.data(0, IndicatorsModelRole::Position).toInt(), 3);
        QCOMPARE(model.data(0, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake3"));
        QCOMPARE(model.data(0, IndicatorsModelRole::IndicatorProperties).toMap()["actionsObjectPath"].toString(), QString("/com/canonical/indicator/fake3"));
        QCOMPARE(model.data(0, IndicatorsModelRole::IndicatorProperties).toMap()["menuObjectPath"].toString(), QString("/com/canonical/indicator/fake3/test1"));

        QCOMPARE(model.data(1, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake4"));
        QCOMPARE(model.data(1, IndicatorsModelRole::Position).toInt(), 2);
        QCOMPARE(model.data(1, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake4"));
        QCOMPARE(model.data(1, IndicatorsModelRole::IndicatorProperties).toMap()["actionsObjectPath"].toString(), QString("/com/canonical/indicator/fake4"));
        QCOMPARE(model.data(1, IndicatorsModelRole::IndicatorProperties).toMap()["menuObjectPath"].toString(), QString("/com/canonical/indicator/fake4/test1"));

        QCOMPARE(model.data(2, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake1"));
        QCOMPARE(model.data(2, IndicatorsModelRole::Position).toInt(), 1);
        QCOMPARE(model.data(2, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake1"));
        QCOMPARE(model.data(2, IndicatorsModelRole::IndicatorProperties).toMap()["actionsObjectPath"].toString(), QString("/com/canonical/indicator/fake1"));
        QCOMPARE(model.data(2, IndicatorsModelRole::IndicatorProperties).toMap()["menuObjectPath"].toString(), QString("/com/canonical/indicator/fake1/test1"));

        QCOMPARE(model.data(3, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake2"));
        QCOMPARE(model.data(3, IndicatorsModelRole::Position).toInt(), 0);
        QCOMPARE(model.data(3, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake2"));
        QCOMPARE(model.data(3, IndicatorsModelRole::IndicatorProperties).toMap()["actionsObjectPath"].toString(), QString("/com/canonical/indicator/fake2"));
        QCOMPARE(model.data(3, IndicatorsModelRole::IndicatorProperties).toMap()["menuObjectPath"].toString(), QString("/com/canonical/indicator/fake2/test1"));
    }

    /*
     * Testa that the plugin data was loaded correctly ( "test2" )
     */
    void testDataAndOrderProfile2()
    {
        // Priority order. (2, 1, 4, 3)
        IndicatorsModel model;
        model.setProfile("test2");
        model.load();

        // should be in order:
        // fake3, fake4, fake1, fake2

        QCOMPARE(model.data(0, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake3"));
        QCOMPARE(model.data(0, IndicatorsModelRole::Position).toInt(), 3);
        QCOMPARE(model.data(0, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake3"));
        QCOMPARE(model.data(0, IndicatorsModelRole::IndicatorProperties).toMap()["actionsObjectPath"].toString(), QString("/com/canonical/indicator/fake3"));
        QCOMPARE(model.data(0, IndicatorsModelRole::IndicatorProperties).toMap()["menuObjectPath"].toString(), QString("/com/canonical/indicator/fake3/test2"));

        QCOMPARE(model.data(1, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake4"));
        QCOMPARE(model.data(1, IndicatorsModelRole::Position).toInt(), 2);
        QCOMPARE(model.data(1, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake4"));
        QCOMPARE(model.data(1, IndicatorsModelRole::IndicatorProperties).toMap()["actionsObjectPath"].toString(), QString("/com/canonical/indicator/fake4"));
        QCOMPARE(model.data(1, IndicatorsModelRole::IndicatorProperties).toMap()["menuObjectPath"].toString(), QString("/com/canonical/indicator/fake4/test2"));

        QCOMPARE(model.data(2, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake1"));
        QCOMPARE(model.data(2, IndicatorsModelRole::Position).toInt(), 1);
        QCOMPARE(model.data(2, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake1"));
        QCOMPARE(model.data(2, IndicatorsModelRole::IndicatorProperties).toMap()["actionsObjectPath"].toString(), QString("/com/canonical/indicator/fake1"));
        QCOMPARE(model.data(2, IndicatorsModelRole::IndicatorProperties).toMap()["menuObjectPath"].toString(), QString("/com/canonical/indicator/fake1/test2"));

        QCOMPARE(model.data(3, IndicatorsModelRole::Identifier).toString(), QString("indicator-fake2"));
        QCOMPARE(model.data(3, IndicatorsModelRole::Position).toInt(), 0);
        QCOMPARE(model.data(3, IndicatorsModelRole::IndicatorProperties).toMap()["busName"].toString(), QString("com.canonical.indicator.fake2"));
        QCOMPARE(model.data(3, IndicatorsModelRole::IndicatorProperties).toMap()["actionsObjectPath"].toString(), QString("/com/canonical/indicator/fake2"));
        QCOMPARE(model.data(3, IndicatorsModelRole::IndicatorProperties).toMap()["menuObjectPath"].toString(), QString("/com/canonical/indicator/fake2/test2"));
    }
};

QTEST_GUILESS_MAIN(IndicatorsModelTest)

#include "IndicatorsModelTest.moc"
