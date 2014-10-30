/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include <TouchDispatcher.h>

class tst_TouchDispatcher : public GestureTest
{
    Q_OBJECT
public:
    tst_TouchDispatcher();
private Q_SLOTS:
    void sendMouseEventIfTouchIgnored_data();
    void sendMouseEventIfTouchIgnored();
};

tst_TouchDispatcher::tst_TouchDispatcher()
    : GestureTest(QStringLiteral("empty.qml"))
{
}

void tst_TouchDispatcher::sendMouseEventIfTouchIgnored_data()
{
    QTest::addColumn<bool>("itemAcceptsTouch");
    QTest::addColumn<int>("acceptedMouseButtons");
    QTest::addColumn<bool>("shouldGetMousePress");

    QTest::newRow("accepts touch and doesn't accept mouse buttons") << true << (int)Qt::NoButton << false;
    QTest::newRow("ignores touch and accepts mouse buttons") << false << (int)Qt::LeftButton << true;
    QTest::newRow("ignores touch and doesn't accept mouse buttons") << false << (int)Qt::NoButton << false;
}

void tst_TouchDispatcher::sendMouseEventIfTouchIgnored()
{
    QFETCH(bool, itemAcceptsTouch);
    QFETCH(int, acceptedMouseButtons);
    QFETCH(bool, shouldGetMousePress);
    DummyItem *dummyItem = new DummyItem(m_view->rootObject());

    TouchDispatcher touchDispatcher;
    touchDispatcher.setTargetItem(dummyItem);

    QList<QTouchEvent::TouchPoint> touchPoints;
    QTouchEvent::TouchPoint touchPoint;
    touchPoint.setId(0);
    touchPoint.setState(Qt::TouchPointPressed);
    touchPoints.append(touchPoint);

    bool gotTouchEvent = false;
    bool gotMousePressEvent = false;

    dummyItem->setAcceptedMouseButtons((Qt::MouseButtons)acceptedMouseButtons);

    dummyItem->touchEventHandler = [&](QTouchEvent *event) {
        gotTouchEvent = true;
        event->setAccepted(itemAcceptsTouch);
    };

    dummyItem->mousePressEventHandler = [&](QMouseEvent *event) {
        gotMousePressEvent = true;
        event->accept();
    };

    touchDispatcher.dispatch(QEvent::TouchBegin, m_device, Qt::NoModifier, touchPoints, m_view,
                             12345 /* timestamp */);

    QVERIFY(gotTouchEvent);
    QCOMPARE(gotMousePressEvent, shouldGetMousePress);
}

QTEST_MAIN(tst_TouchDispatcher)

#include "tst_TouchDispatcher.moc"
