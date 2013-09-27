/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 *  Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "indicatorsmanager.h"
#include "paths.h"
#include "unitymenumodelstack.h"

#include <QtTest>
#include <QDebug>
#include <unitymenumodel.h>

class UnityMenuModelStackTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:

    void initTestCase()
    {
    }

    void cleanupTestCase()
    {
    }

    void init()
    {
        QFETCH(QString, test);
        QFETCH(int, menuDepth);
        QFETCH(int, subMenuCount);

        m_model = new UnityMenuModel();
        m_model->setModelData(recuseAddMenu(subMenuCount, menuDepth));
    }

    void cleanup() {
    }


    void testPushPop_data() {
        QTest::addColumn<QString>("test");
        QTest::addColumn<int>("menuDepth");
        QTest::addColumn<int>("subMenuCount");
        QTest::addColumn<int>("subMenuIndex");

        QTest::newRow("depth=0") << "testPushPop1" << 0 << 1 << 0;
        QTest::newRow("depth=1") << "testPushPop2" << 1 << 1 << 0;
        QTest::newRow("depth=8") << "testPushPop3" << 8 << 2 << 1;
    }

    void testPushPop()
    {
        QFETCH(int, menuDepth);
        QFETCH(int, subMenuCount);
        QFETCH(int, subMenuIndex);

        UnityMenuModelStack stack;
        QList<UnityMenuModel*> models;

        UnityMenuModel* parent = m_model;
        UnityMenuModel* child = m_model;

        while(child) {
            // submenus aren't immediate
            bool rows = waitFor([child, subMenuCount]() { return child->rowCount() == subMenuCount; }, 500);
            QVERIFY(rows);

            stack.push(child, subMenuIndex);
            models << child;

            parent = child;
            child = qobject_cast<UnityMenuModel*>(parent->submenu(subMenuIndex));
        }

        QCOMPARE(stack.count(), models.count());
        QCOMPARE(stack.count(), menuDepth+1);
        while(stack.count() > 0) {
            QCOMPARE(stack.pop(), models.takeLast());
        }
    }

    void testPopOnRemove_data() {
        QTest::addColumn<QString>("test");
        QTest::addColumn<int>("menuDepth");
        QTest::addColumn<int>("subMenuCount");
        QTest::addColumn<int>("subMenuIndex");
        QTest::addColumn<int>("removeIndex");
        QTest::addColumn<int>("resultCount");

        QTest::newRow("removeIndexBefore") << "removeIndexBefore" << 4 << 2 << 1 << 0 << 5;
        QTest::newRow("removeCurrentIndex") << "removeCurrentIndex" << 4 << 2 << 0 << 0 << 1;
        QTest::newRow("removeIndexAfter") << "removeIndexAfter" << 4 << 2 << 0 << 1 << 5;
    }

    void testPopOnRemove()
    {
        QFETCH(int, menuDepth);
        QFETCH(int, subMenuCount);
        QFETCH(int, subMenuIndex);
        QFETCH(int, removeIndex);
        QFETCH(int, resultCount);

        UnityMenuModelStack stack;

        UnityMenuModel* parent = m_model;
        UnityMenuModel* child = m_model;

        while(child) {
            // submenus aren't immediate
            bool rows = waitFor([child, subMenuCount]() { return child->rowCount() == subMenuCount; }, 1000);
            QVERIFY(rows);

            stack.push(child, subMenuIndex);

            parent = child;
            child = qobject_cast<UnityMenuModel*>(parent->submenu(subMenuIndex));
        }

        QCOMPARE(stack.count(), menuDepth+1);

        m_model->removeRow(removeIndex);

        waitFor([&stack, resultCount]() { return stack.count() == resultCount; }, 1000);
        QCOMPARE(stack.count(), resultCount);
    }

private:
    bool waitFor(std::function<bool()> functor, int ms) {

        QElapsedTimer timer;
        timer.start();
        while(!functor() && timer.elapsed() < ms) { QTest::qWait(10); }
        return functor();
    }

    QVariant recuseAddMenu(int subMenuCount, int depth_remaining)
    {
        QVariantList rows;

        for (int i = 0; i < subMenuCount; i ++) {
            QVariantMap row;
            QVariantMap rowData;

            if (depth_remaining > 0) {
                row["submenu"] = recuseAddMenu(subMenuCount, depth_remaining-1);
            }

            row["rowData"] = rowData;

            rows << row;
        }

        return rows;
    }

public:
    UnityMenuModel* m_model;
};



QTEST_GUILESS_MAIN(UnityMenuModelStackTest)
#include "unitymenumodelstacktest.moc"
