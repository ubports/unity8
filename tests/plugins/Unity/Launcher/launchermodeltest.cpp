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

#include "launcheritem.h"
#include "launchermodel.h"

#include <QtTest>

class LauncherModelTest : public QObject
{
    Q_OBJECT

private:
    LauncherModel *launcherModel;

private Q_SLOTS:

    void initTestCase() {
        launcherModel = new LauncherModel(this);
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 0);
    }

    void init() {
/*        qDebug() << "init";
        launcherModel->applicationFocused("abs-icon");
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);

        launcherModel->applicationFocused("no-icon.desktop");
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);

        launcherModel->applicationFocused(QString());
        */
    }

    void cleanup() {
        while (launcherModel->rowCount(QModelIndex()) > 0) {
            launcherModel->requestRemove(launcherModel->get(0)->appId());
        }
    }

    void testMove() {
        QCOMPARE(launcherModel->get(0)->pinned(), false);
        QCOMPARE(launcherModel->get(1)->pinned(), false);

        LauncherItemInterface *item0BeforeMove = launcherModel->get(0);
        LauncherItemInterface *item1BeforeMove = launcherModel->get(1);
        launcherModel->move(1, 0);

        QCOMPARE(item0BeforeMove, launcherModel->get(1));
        QCOMPARE(item1BeforeMove, launcherModel->get(0));

        // moved item must be pinned now
        QCOMPARE(item0BeforeMove->pinned(), false);
        QCOMPARE(item1BeforeMove->pinned(), true);
    }

    void testPinning() {
        QCOMPARE(launcherModel->get(0)->pinned(), false);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
        launcherModel->pin(launcherModel->get(0)->appId());
        QCOMPARE(launcherModel->get(0)->pinned(), true);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
    }

    void testRemove() {
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);
        launcherModel->requestRemove(launcherModel->get(0)->appId());
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);
    }

    void testQuickListPinningRemoving() {
        // we start with 2 unpinned items
        QCOMPARE(launcherModel->get(0)->pinned(), false);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);

        // find the Pin item in the quicklist
        QuickListModel *model = qobject_cast<QuickListModel*>(launcherModel->get(0)->quickList());
        int pinActionIndex = -1;
        for (int i = 0; i < model->rowCount(QModelIndex()); ++i) {
            if (model->get(i).actionId() == "pin_item") {
                pinActionIndex = i;
                break;
            }
        }
        QVERIFY(pinActionIndex >= 0);

        // trigger pin item quicklist action => Item must be pinned now.
        launcherModel->quickListActionInvoked(launcherModel->get(0)->appId(), pinActionIndex);
        QCOMPARE(launcherModel->get(0)->pinned(), true);
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);

        // quicklist needs to transform to remove item. trigger it and check it item goes away
        launcherModel->quickListActionInvoked(launcherModel->get(0)->appId(), pinActionIndex);
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);
    }

    void testApplicationFocused() {
/*        // all apps unfocused at beginning...
        QCOMPARE(launcherModel->get(0)->focused(), false);
        QCOMPARE(launcherModel->get(1)->focused(), false);

        launcherModel->applicationFocused("abs-icon");
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);
        QCOMPARE(launcherModel->get(0)->focused(), true);
        QCOMPARE(launcherModel->get(1)->focused(), false);

        launcherModel->applicationFocused("no-icon");
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);
        QCOMPARE(launcherModel->get(0)->focused(), false);
        QCOMPARE(launcherModel->get(1)->focused(), true);

        launcherModel->applicationFocused("rel-icon");
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 3);
        QCOMPARE(launcherModel->get(0)->focused(), false);
        QCOMPARE(launcherModel->get(1)->focused(), false);
        QCOMPARE(launcherModel->get(2)->focused(), true);

        launcherModel->applicationFocused(QString());
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 3);
        QCOMPARE(launcherModel->get(0)->focused(), false);
        QCOMPARE(launcherModel->get(1)->focused(), false);
        QCOMPARE(launcherModel->get(2)->focused(), false);
        */
    }
};

QTEST_GUILESS_MAIN(LauncherModelTest)
#include "launchermodeltest.moc"
