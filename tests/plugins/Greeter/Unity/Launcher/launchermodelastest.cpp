/*
 * Copyright 2014-2015 Canonical Ltd.
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

// unity-api
#include <unity/shell/launcher/LauncherModelInterface.h>
#include <unity/shell/application/ApplicationInfoInterface.h>

#include "launcheritem.h"
#include "launchermodelas.h"
#include "AccountsServiceDBusAdaptor.h"

#include <QtTest>

QHash<QString, QList<QVariantMap>> mockProperties;

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
        item.insert("pinned", true);
        list.append(item);
        item["id"] = "appId2";
        item["name"] = "Item 2";
        list.append(item);
        mockProperties["user1"] = list;
    }

    bool isInSync(LauncherModel *model, const QList<QVariantMap> &properties) {
        QList<QVariantMap> list;
        // Strip unpinned if onlyPinned is set
        Q_FOREACH (const QVariantMap &map, properties) {
            if (!model->onlyPinned() || map.value("pinned").toBool()) {
                list << map;
            }
        }

        bool inSync = model->rowCount() == list.count();
        for (int i = 0; inSync && i < model->rowCount(); i++) {
            inSync &= model->get(i)->appId() == list.at(i).value("id").toString();
            inSync &= model->get(i)->name() == list.at(i).value("name").toString();
            inSync &= model->get(i)->icon() == list.at(i).value("icon").toString();
            inSync &= model->get(i)->count() == list.at(i).value("count").toInt();
            inSync &= model->get(i)->countVisible() == list.at(i).value("countVisible").toBool();
        }
        return inSync;
    }

    void testLoadASOnStartup() {
        // Load up the model
        LauncherModel* model = new LauncherModel(this);

        // We didn't set a user yet. model should be empty
        QCOMPARE(model->rowCount(), 0);

        model->setUser("user1");

        QCOMPARE(isInSync(model, mockProperties["user1"]), true);
        model->deleteLater();
    }

    void testASChangedUpdatesModel_data() {
        QTest::addColumn<QString>("modelUser");
        QTest::addColumn<QString>("changedUser");
        QTest::addColumn<bool>("inSync");

        QTest::newRow("this user changed") << "user1" << "user1" << true;
        QTest::newRow("other user changed") << "user1" << "user2" << false;
    }

    void testASChangedUpdatesModel() {
        QFETCH(QString, modelUser);
        QFETCH(QString, changedUser);
        QFETCH(bool, inSync);

        LauncherModel* model = new LauncherModel(this);
        model->setUser(modelUser);

        int oldCount = mockProperties[modelUser].count();
        QCOMPARE(model->rowCount(), oldCount);

        QList<QVariantMap> newList;
        QVariantMap newEntry;
        newEntry.insert("id", "newappId");
        newEntry.insert("name", "New app");
        newEntry.insert("icon", "some-icon.svg");
        newEntry.insert("count", 0);
        newEntry.insert("countVisible", false);
        newEntry.insert("pinned", true);
        newList.append(newEntry);
        model->m_accounts->simulatePropertyChange(changedUser, "LauncherItems", QVariant::fromValue(newList));

        QCOMPARE(isInSync(model, mockProperties[modelUser]), true);
        QCOMPARE(isInSync(model, mockProperties[changedUser]), inSync);

        model->deleteLater();
    }

    void testUpdateCount() {
        LauncherModel* model = new LauncherModel(this);
        model->setUser("user1");

        QCOMPARE(model->get(0)->countVisible(), false);
        QCOMPARE(model->get(0)->count(), 0);

        QList<QVariantMap> newList = mockProperties["user1"];
        QVariantMap entry = newList.at(0);
        entry["countVisible"] = true;
        entry["count"] = 55;
        newList[0] = entry;
        model->m_accounts->simulatePropertyChange("user1", "LauncherItems", QVariant::fromValue(newList));

        QCOMPARE(isInSync(model, mockProperties["user1"]), true);

        model->deleteLater();
    }

    void testOnlyPinned() {
        LauncherModel *model = new LauncherModel(this);
        model->setUser("user1");
        model->setOnlyPinned(true);

        QCOMPARE(isInSync(model, mockProperties["user1"]), true);

        // Let's unpin one item
        QList<QVariantMap> newList = mockProperties["user1"];
        QVariantMap entry = newList.at(0);
        entry["pinned"] = false;
        newList[0] = entry;
        model->m_accounts->simulatePropertyChange("user1", "LauncherItems", QVariant::fromValue(newList));
        QCOMPARE(isInSync(model, mockProperties["user1"]), true);

        // Now toggle onlyPinned and make sure the model keeps up
        model->setOnlyPinned(false);
        QCOMPARE(isInSync(model, mockProperties["user1"]), true);

        model->setOnlyPinned(true);
        QCOMPARE(isInSync(model, mockProperties["user1"]), true);
    }
};

QTEST_GUILESS_MAIN(LauncherModelASTest)
#include "launchermodelastest.moc"
