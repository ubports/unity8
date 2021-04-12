/*
 * Copyright (C) 2015 Canonical, Ltd.
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
 */

#include <QtTest>
#include <QQuickView>

#include "GestureTest.h"
#include "TestItem.h"
#include "Direction.h"

UG_USE_NAMESPACE

class tst_FloatingFlickable: public GestureTest
{
    Q_OBJECT
public:
    tst_FloatingFlickable();
private Q_SLOTS:
    void tapGoesThrough();
    void flickChangesContentX();
    void flickChangesContentY();
};

tst_FloatingFlickable::tst_FloatingFlickable()
    : GestureTest(QStringLiteral("tst_FloatingFlickable.qml"))
{
}

void tst_FloatingFlickable::tapGoesThrough()
{
    QQuickItem *floatingFlickable =
        m_view->rootObject()->findChild<QQuickItem*>("floatingFlickable");
    QVERIFY(floatingFlickable != nullptr);

    TestItem *testItem = new TestItem;
    testItem->setWidth(floatingFlickable->width());
    testItem->setHeight(floatingFlickable->height());
    testItem->setParentItem(m_view->rootObject());
    testItem->setZ(1.0);

    floatingFlickable->setZ(2.0);

    QTest::touchEvent(m_view, m_device)
        .press(0, QPoint(floatingFlickable->width()/2, floatingFlickable->height()/2));

    QCOMPARE(testItem->touchEventsReceived.count(), 1);
}

static void removeTimeConstraints(QQuickItem *floatingFlickable)
{
    auto children = floatingFlickable->findChildren<QObject*>();
    Q_FOREACH(QObject *child, children) {
        if (child->metaObject()->className() == QByteArray("UCSwipeAreaPrivate")) {
            QMetaObject::invokeMethod(child, "setMaxTime", Q_ARG(int, 60 * 60 * 1000));
            QMetaObject::invokeMethod(child, "setCompositionTime", Q_ARG(int, 0));
        }
    }
}

void tst_FloatingFlickable::flickChangesContentX()
{
    QSKIP("This fails due to bug #1564571");
    QQuickItem *floatingFlickable =
        m_view->rootObject()->findChild<QQuickItem*>("floatingFlickable");
    QVERIFY(floatingFlickable != nullptr);
    removeTimeConstraints(floatingFlickable);

    qreal startContentX = floatingFlickable->property("contentX").toReal();

    QPoint startPos(floatingFlickable->width() - 5, 10);
    int stepCount = 20;
    int step = (startPos.x() - 5) / stepCount;

    QTest::touchEvent(m_view, m_device).press(0, startPos);
    for (int i = 0; i < stepCount; ++i) {
        QTest::qWait(10);
        QPoint touchPos = startPos - QPoint(step*i, 0);
        QTest::touchEvent(m_view, m_device).move(0, touchPos);
    }

    QTest::qWait(10);
    QTest::touchEvent(m_view, m_device).release(0, QPoint(5, 10));

    QVERIFY(floatingFlickable->property("contentX").toReal() > (startContentX + floatingFlickable->width()/2));
}

void tst_FloatingFlickable::flickChangesContentY()
{
    QSKIP("This fails due to bug #1564571");
    QQuickItem *floatingFlickable =
        m_view->rootObject()->findChild<QQuickItem*>("floatingFlickable");
    QVERIFY(floatingFlickable != nullptr);

    floatingFlickable->setProperty("direction", Direction::Vertical);
    removeTimeConstraints(floatingFlickable);

    qreal startContentY = floatingFlickable->property("contentY").toReal();

    QPoint startPos(10, floatingFlickable->height() - 5);
    int stepCount = 20;
    int step = (startPos.y() - 5) / stepCount;

    QTest::touchEvent(m_view, m_device).press(0, startPos);
    for (int i = 0; i < stepCount; ++i) {
        QTest::qWait(10);
        QPoint touchPos = startPos - QPoint(0, step*i);
        QTest::touchEvent(m_view, m_device).move(0, touchPos);
    }

    QTest::qWait(10);
    QTest::touchEvent(m_view, m_device).release(0, QPoint(10, 5));

    QVERIFY(floatingFlickable->property("contentY").toReal() > (startContentY + floatingFlickable->height()/2));
}

QTEST_MAIN(tst_FloatingFlickable)

#include "tst_FloatingFlickable.moc"
