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
#include "indicatorsmodel.h"
#include "indicatorsfactory.h"
#include "paths.h"

#include <QtTest>
#include <QDebug>

FAKE_INDICATOR(1, "Fake Title 1")
FAKE_INDICATOR(2, "Fake Title 2")

class IndicatorsModelTest : public QObject
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
        IndicatorsModel model;

        QCOMPARE(model.property("count").toInt(), 0);

        model.load();

        QCOMPARE(model.property("count").toInt(), 2);

        model.unload();

        QCOMPARE(model.property("count").toInt(), 0);

    }

    /*
     * Test if the plugin data was loaded correct
     */
    void testDataOrder()
    {
        IndicatorsModel model;
        model.load();

        QVariantMap data = model.get(0);
        QCOMPARE(data["title"].toString(), QString("Fake Title 1"));
        QCOMPARE(data["label"].toString(), QString());
        QCOMPARE(data["description"].toString(), QString());
        // There is no QML context
        QVERIFY(!data["component"].value<QObject*>());
        QCOMPARE(data["isValid"].toBool(), true);

        data = model.get(1);
        QCOMPARE(data["title"].toString(), QString("Fake Title 2"));
        QCOMPARE(data["label"].toString(), QString());
        QCOMPARE(data["description"].toString(), QString());
        // There is no QML context
        QVERIFY(!data["component"].value<QObject*>());
        QCOMPARE(data["isValid"].toBool(), true);

        data = model.get(3);
        QVERIFY(data.isEmpty());
    }
};

QTEST_MAIN(IndicatorsModelTest)

#include "indicatorsmodeltest.moc"

