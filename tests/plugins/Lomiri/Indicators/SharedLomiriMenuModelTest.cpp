/*
 * Copyright 2014 Canonical Ltd.
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
 */

#include "sharedlomirimenumodel.h"
#include "lomirimenumodelcache.h"

#include <QtTest>
#include <unitymenumodel.h>

class SharedLomiriMenuModelTest : public QObject
{
    Q_OBJECT

    SharedLomiriMenuModel* createFullModel(const QByteArray& testId)
    {
        SharedLomiriMenuModel* model = new SharedLomiriMenuModel;
        model->setBusName("com.canonical." + testId);
        model->setMenuObjectPath("/com/canonical/" + testId);
        QVariantMap actions;
        actions["test"] = QString("/com/canonical/%1/actions").arg(QString(testId));
        model->setActions(actions);

        return model;
    }

private Q_SLOTS:

    void testCreateModel()
    {
        QSharedPointer<SharedLomiriMenuModel> model(createFullModel("test1"));
        QVERIFY(model->model() != nullptr);
    }

    void testDifferentDataCreatesDifferentModels()
    {
        QSharedPointer<SharedLomiriMenuModel> model1(createFullModel("test1"));
        QSharedPointer<SharedLomiriMenuModel> model2(createFullModel("test2"));

        QVERIFY(model1->model() != model2->model());
    }

    void testSameDataCreatesSameModels()
    {
        QSharedPointer<SharedLomiriMenuModel> model1(createFullModel("test1"));
        QSharedPointer<SharedLomiriMenuModel> model2(createFullModel("test1"));

        QCOMPARE(model1->model(), model2->model());
    }

    void testSavedData()
    {
        QSharedPointer<SharedLomiriMenuModel> model1(createFullModel("test1"));
        QSharedPointer<SharedLomiriMenuModel> model2(createFullModel("test1"));

        QCOMPARE(LomiriMenuModelCache::singleton()->contains("/com/canonical/test1"), true);
        model1.clear();
        QCOMPARE(LomiriMenuModelCache::singleton()->contains("/com/canonical/test1"), true);
        model2.clear();
        QCOMPARE(LomiriMenuModelCache::singleton()->contains("/com/canonical/test1"), true);
    }

    // Tests that changing cached model data does not change the model path of others
    void testLP1328646()
    {
        QSharedPointer<SharedLomiriMenuModel> model1(createFullModel("test1"));
        QSharedPointer<SharedLomiriMenuModel> model2(createFullModel("test1"));

        model2->setMenuObjectPath("/com/canonical/LP1328646");

        QVERIFY(model1->model() != model2->model());
        QCOMPARE(model1->model()->menuObjectPath(), QByteArray("/com/canonical/test1"));
        QCOMPARE(model2->model()->menuObjectPath(), QByteArray("/com/canonical/LP1328646"));
    }

    // Tests that the cache is recreated if deleted.
    void testDeletedCache()
    {
        QSharedPointer<SharedLomiriMenuModel> model1(createFullModel("test1"));

        QCOMPARE(LomiriMenuModelCache::singleton()->contains("/com/canonical/test1"), true);
        delete LomiriMenuModelCache::singleton();
        QCOMPARE(LomiriMenuModelCache::singleton()->contains("/com/canonical/test1"), false);
    }

};

QTEST_GUILESS_MAIN(SharedLomiriMenuModelTest)
#include "SharedLomiriMenuModelTest.moc"
