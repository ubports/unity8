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
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

// unity-api
#include <unity/shell/launcher/LauncherModelInterface.h>
#include <unity/shell/application/ApplicationInfoInterface.h>

#include "launcheritem.h"
#include "launchermodelas.h"
#include "AccountsServiceDBusAdaptor.h"

#include <QtTest>

QList<QVariantMap> properties;

class LauncherModelASTest : public QObject
{
    Q_OBJECT

private:
    LauncherModel *launcherModel;

private Q_SLOTS:

    void init() {
        // Prepare some fake list
        QList<QVariantMap> list;
        QVariantMap item;
        item.insert("id", "appId1");
        item.insert("name", "Item 1");
        item.insert("icon", "fake.svg");
        item.insert("count", 0);
        item.insert("countVisible", false);
        list.append(item);
        item["id"] = "appId2";
        item["name"] = "Item 2";
        list.append(item);
        properties = list;
    }

    bool isInSync(LauncherModel *model) {
        // Verify after startup the items are in there
        bool inSync = model->rowCount() == properties.count();
        for (int i = 0; i < model->rowCount(); i++) {
            inSync &= model->get(i)->appId() == properties.at(i).value("id").toString();
            inSync &= model->get(i)->name() == properties.at(i).value("name").toString();
            inSync &= model->get(i)->icon() == properties.at(i).value("icon").toString();
            inSync &= model->get(i)->count() == properties.at(i).value("count").toInt();
            inSync &= model->get(i)->countVisible() == properties.at(i).value("countVisible").toBool();
        }
        return inSync;
    }

    void testLoadASOnStartup() {
        // Load up the model
        LauncherModel* model = new LauncherModel(this);

        // We didn't set a user yet. model should be empty
        QCOMPARE(model->rowCount(), 0);

        model->setUser("dummy");

        QCOMPARE(isInSync(model), true);
        model->deleteLater();
    }

    void testASChangedUpdatesModel_data() {
        QTest::addColumn<QString>("modelUser");
        QTest::addColumn<QString>("changedUser");
        QTest::addColumn<bool>("inSync");

        QTest::newRow("this user changed") << "dummy" << "dummy" << true;
        QTest::newRow("other user changed") << "dummy" << "fred" << false;
    }

    void testASChangedUpdatesModel() {
        QFETCH(QString, modelUser);
        QFETCH(QString, changedUser);
        QFETCH(bool, inSync);

        LauncherModel* model = new LauncherModel(this);
        model->setUser(modelUser);

        int oldCount = properties.count();
        QCOMPARE(model->rowCount(), oldCount);

        QList<QVariantMap> newList = properties;
        QVariantMap newEntry;
        newEntry.insert("id", "newappId");
        newEntry.insert("name", "New app");
        newEntry.insert("icon", "some-icon.svg");
        newEntry.insert("count", 0);
        newEntry.insert("countVisible", false);
        newList.append(newEntry);
        model->m_accounts->simulatePropertyChange(changedUser, "launcherItems", QVariant::fromValue(newList));

        QCOMPARE(isInSync(model), inSync);

        model->deleteLater();
    }

    void testUpdateCount() {
        LauncherModel* model = new LauncherModel(this);
        model->setUser("dummy");

        QCOMPARE(model->get(0)->countVisible(), false);
        QCOMPARE(model->get(0)->count(), 0);

        QList<QVariantMap> newList = properties;
        QVariantMap entry = newList.at(0);
        entry["countVisible"] = true;
        entry["count"] = 55;
        newList[0] = entry;
        model->m_accounts->simulatePropertyChange("dummy", "launcherItems", QVariant::fromValue(newList));

        QCOMPARE(isInSync(model), true);

        model->deleteLater();
    }
};

QTEST_GUILESS_MAIN(LauncherModelASTest)
#include "launchermodelastest.moc"
