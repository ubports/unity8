/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "GestureTest.h"

#include <TouchGestureArea.h>

#include <QQuickItem>
#include <QQuickView>
#include <QtTest>

namespace {
QPointF calculateInitialTouchPos(TouchGestureArea *edgeDragArea)
{
    QPointF localCenter(edgeDragArea->width() / 2., edgeDragArea->height() / 2.);
    return edgeDragArea->mapToScene(localCenter);
}
}

class tst_TouchGestureArea: public GestureTest
{
    Q_OBJECT
public:
    tst_TouchGestureArea();
private Q_SLOTS:
    void init() override; // called right before each and every test function is executed

    void minimumTouchPoints();
    void maximumTouchPoints();
    void minimumAndMaximumTouchPoints();
    void rejectGestureAfterRecognitionPeriod();
    void releaseAndPressRecognisedGestureDoesNotRejectForPeriod();
    void topAreaReceivesOwnershipFirstWithEqualPoints();
    void topAreaReceivesOwnershipFirstWithMorePoints();

private:
    void initGestureComponent(TouchGestureArea *area);

    QQuickItem *m_blueRect;
    TouchGestureArea *m_gestureBottom;
    TouchGestureArea *m_gestureMiddle;
    TouchGestureArea *m_gestureTop;
};

tst_TouchGestureArea::tst_TouchGestureArea()
    : GestureTest(QStringLiteral("tst_TouchGestureArea.qml"))
{
}

inline void tst_TouchGestureArea::initGestureComponent(TouchGestureArea* area)
{
    area->setRecognitionTimer(m_fakeTimerFactory->createTimer(area));
    area->setMinimumTouchPoints(1);
    area->setMaximumTouchPoints(INT_MAX);
    area->setRecognitionPeriod(50);
    area->setReleaseRejectPeriod(100);
    // start tests with area disabled (enable as desired)
    area->setEnabled(false);
}

void tst_TouchGestureArea::init()
{
    GestureTest::init();

    m_blueRect = m_view->rootObject()->findChild<QQuickItem*>("blueRect");
    Q_ASSERT(m_blueRect != nullptr);

    m_gestureBottom =
        m_view->rootObject()->findChild<TouchGestureArea*>("touchGestureAreaBottom");
    Q_ASSERT(m_gestureBottom != nullptr);

    m_gestureMiddle =
        m_view->rootObject()->findChild<TouchGestureArea*>("touchGestureAreaMiddle");
    Q_ASSERT(m_gestureMiddle != nullptr);

    m_gestureTop =
        m_view->rootObject()->findChild<TouchGestureArea*>("touchGestureAreaTop");
    Q_ASSERT(m_gestureTop != nullptr);

    initGestureComponent(m_gestureBottom);
    initGestureComponent(m_gestureMiddle);
    initGestureComponent(m_gestureTop);
}

void tst_TouchGestureArea::minimumTouchPoints()
{
    m_gestureBottom->setEnabled(true);
    m_gestureBottom->setMinimumTouchPoints(4);

    QPointF touchPoint = calculateInitialTouchPos(m_gestureBottom);

    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::WaitingForTouch);
    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Undecided);
    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .press(1, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Undecided);
    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .stationary(1)
                                       .press(2, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Undecided);
    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .stationary(1)
                                       .stationary(2)
                                       .press(3, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Recognized);
    // test minimum overflow
    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .stationary(1)
                                       .stationary(2)
                                       .stationary(3)
                                       .press(4, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Recognized);
}

void tst_TouchGestureArea::maximumTouchPoints()
{
    m_gestureBottom->setEnabled(true);
    m_gestureBottom->setMaximumTouchPoints(2);

    QPointF touchPoint = calculateInitialTouchPos(m_gestureBottom);

    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::WaitingForTouch);
    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Recognized);
    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .press(1, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Recognized);

    // test maximum overflow
    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .stationary(1)
                                       .press(2, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Rejected);
    // test still rejected
    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .stationary(1)
                                       .press(3, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Rejected);
}

void tst_TouchGestureArea::minimumAndMaximumTouchPoints()
{
    m_gestureBottom->setEnabled(true);
    m_gestureBottom->setMinimumTouchPoints(2);
    m_gestureBottom->setMaximumTouchPoints(2);

    QPointF touchPoint = calculateInitialTouchPos(m_gestureBottom);

    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::WaitingForTouch);
    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Undecided);
    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .press(1, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Recognized);

    // test maximum overflow
    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .stationary(1)
                                       .press(2, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Rejected);
}

void tst_TouchGestureArea::rejectGestureAfterRecognitionPeriod()
{
    m_gestureBottom->setEnabled(true);
    m_gestureBottom->setMinimumTouchPoints(2);
    m_gestureBottom->setMaximumTouchPoints(2);

    QPointF touchPoint = calculateInitialTouchPos(m_gestureBottom);

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Undecided); // Recognition period is 50.
    passTime(40);
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Undecided);
    passTime(10);
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Rejected);
}

void tst_TouchGestureArea::releaseAndPressRecognisedGestureDoesNotRejectForPeriod()
{
    m_gestureBottom->setEnabled(true);
    m_gestureBottom->setMinimumTouchPoints(2);
    m_gestureBottom->setMaximumTouchPoints(2);

    bool wasRejected = false;
    connect(m_gestureBottom, &TouchGestureArea::statusChanged,
            this, [&wasRejected](int status) {
        if (status == TouchGestureArea::Rejected) wasRejected = true;
    });

    QPointF touchPoint = calculateInitialTouchPos(m_gestureBottom);

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint())
                                       .press(1, touchPoint.toPoint());
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Recognized);
    passTime(5);
    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .release(1, touchPoint.toPoint()); // Release period is 100.
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Recognized);
    passTime(70);
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Recognized);
    QCOMPARE(wasRejected, false);
    passTime(29);
    QCOMPARE(wasRejected, false);
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Recognized);
    passTime(1);
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::Rejected);
}

void tst_TouchGestureArea::topAreaReceivesOwnershipFirstWithEqualPoints()
{
    m_gestureBottom->setEnabled(true);
    m_gestureMiddle->setEnabled(true);
    m_gestureTop->setEnabled(true);

    m_gestureBottom->setMinimumTouchPoints(1);
    m_gestureMiddle->setMinimumTouchPoints(1);
    m_gestureTop->setMinimumTouchPoints(1);

    QPointF touchPoint = calculateInitialTouchPos(m_gestureBottom);

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    QCOMPARE((int)m_gestureTop->status(), (int)TouchGestureArea::Recognized);
    // Lower items will not recieve the touch events
    QCOMPARE((int)m_gestureMiddle->status(), (int)TouchGestureArea::WaitingForTouch);
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::WaitingForTouch);
}

void tst_TouchGestureArea::topAreaReceivesOwnershipFirstWithMorePoints()
{
    m_gestureBottom->setEnabled(true);
    m_gestureMiddle->setEnabled(true);
    m_gestureTop->setEnabled(true);

    m_gestureBottom->setMinimumTouchPoints(1);
    m_gestureMiddle->setMinimumTouchPoints(1);
    m_gestureTop->setMinimumTouchPoints(2);

    QPointF touchPoint = calculateInitialTouchPos(m_gestureBottom);

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());
    QCOMPARE((int)m_gestureTop->status(), (int)TouchGestureArea::Undecided);
    QCOMPARE((int)m_gestureMiddle->status(), (int)TouchGestureArea::Undecided);
    // The middle item will accept the events; so the bottom item will not get a chance.
    QCOMPARE((int)m_gestureBottom->status(), (int)TouchGestureArea::WaitingForTouch);

    QTest::touchEvent(m_view, m_device).stationary(0)
                                       .press(1, touchPoint.toPoint());
    QCOMPARE((int)m_gestureTop->status(), (int)TouchGestureArea::Recognized);
    QCOMPARE((int)m_gestureMiddle->status(), (int)TouchGestureArea::Rejected);
}

QTEST_MAIN(tst_TouchGestureArea)

#include "tst_TouchGestureArea.moc"
