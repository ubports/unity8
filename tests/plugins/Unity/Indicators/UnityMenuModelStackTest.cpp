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
#include "unitymenumodelstack.h"

#include <QtTest>
#include <QDebug>
#include <unitymenumodel.h>

#include <functional>
#include <chrono>

class UnityMenuModelStackTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:

    void init()
    {
        m_model = new UnityMenuModel();
        m_headChanged = false;
        m_tailChanged = false;
    }

    void cleanup()
    {
        delete m_model;
        m_model = nullptr;
    }

    void testHeadOnSetHead()
    {
        UnityMenuModelStack stack;
        connect(&stack, &UnityMenuModelStack::headChanged, this, &UnityMenuModelStackTest::onHeadChanged);
        stack.setHead(m_model);

        QCOMPARE(stack.head(), m_model);
        QCOMPARE(m_headChanged, true);
    }

    void testTailOnSetHead()
    {
        UnityMenuModelStack stack;
        connect(&stack, &UnityMenuModelStack::tailChanged, this, &UnityMenuModelStackTest::onTailChanged);
        stack.setHead(m_model);

        QCOMPARE(stack.tail(), m_model);
        QCOMPARE(m_tailChanged, true);
    }

    void testPushPop_data() {
        QTest::addColumn<int>("menuDepth");
        QTest::addColumn<int>("subMenuCount");
        QTest::addColumn<int>("subMenuIndex");

        QTest::newRow("depth=0") << 0 << 1 << 0;
        QTest::newRow("depth=1") << 1 << 1 << 0;
        QTest::newRow("depth=8") << 8 << 2 << 1;
    }

    void testPushPop()
    {
        QFETCH(int, menuDepth);
        QFETCH(int, subMenuCount);
        QFETCH(int, subMenuIndex);

        m_model->setModelData(recuseAddMenu(subMenuCount, menuDepth));

        UnityMenuModelStack stack;
        connect(&stack, &UnityMenuModelStack::tailChanged, this, &UnityMenuModelStackTest::onTailChanged);

        QList<UnityMenuModel*> models;

        int count = 0;
        auto foreachChild = [&](UnityMenuModel* child, int childIndex) {
            stack.push(child, childIndex);
            QCOMPARE(stack.count(), count+1);

            count++;
            models << child;
        };
        recuseSubmenus(m_model, subMenuIndex, foreachChild);

        QCOMPARE(stack.count(), models.count());
        QCOMPARE(stack.count(), menuDepth+1);
        while(stack.count() > 0) {
            m_tailChanged = false;

            QCOMPARE(stack.pop(), models.takeLast());

            QCOMPARE(m_tailChanged, true);
            if (stack.count()) {
                QCOMPARE(stack.tail(), models.last());
            }
        }
        QCOMPARE(m_tailChanged, true);
    }

    void testPopOnRemove_data() {
        QTest::addColumn<int>("menuDepth");
        QTest::addColumn<int>("subMenuCount");
        QTest::addColumn<int>("subMenuIndex");
        QTest::addColumn<int>("removeIndex");
        QTest::addColumn<int>("resultCount");

        QTest::newRow("removeIndexBefore") << 4 << 2 << 1 << 0 << 5;
        QTest::newRow("removeCurrentIndex") << 4 << 2 << 0 << 0 << 1;
        QTest::newRow("removeIndexAfter") << 4 << 2 << 0 << 1 << 5;
    }

    void testPopOnRemove()
    {
        QFETCH(int, menuDepth);
        QFETCH(int, subMenuCount);
        QFETCH(int, subMenuIndex);
        QFETCH(int, removeIndex);
        QFETCH(int, resultCount);

        m_model->setModelData(recuseAddMenu(subMenuCount, menuDepth));

        UnityMenuModelStack stack;

        auto foreachChild = [&](UnityMenuModel* child, int childIndex) {
            stack.push(child, childIndex);
        };
        recuseSubmenus(m_model, subMenuIndex, foreachChild);

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

    void recuseSubmenus(UnityMenuModel* model, int childIndex, std::function<void(UnityMenuModel*, int)> func) {
        UnityMenuModel* parent = model;
        UnityMenuModel* child = model;

        while(child) {
            if (func) {
                func(child, childIndex);
            }

            parent = child;
            child = qobject_cast<UnityMenuModel*>(parent->submenu(childIndex));
        }

    }

private Q_SLOTS:
    void onHeadChanged() { m_headChanged = true; }
    void onTailChanged() { m_tailChanged = true; }

public:
    UnityMenuModel* m_model;
    bool m_headChanged;
    bool m_tailChanged;
};

QTEST_GUILESS_MAIN(UnityMenuModelStackTest)
#include "UnityMenuModelStackTest.moc"
