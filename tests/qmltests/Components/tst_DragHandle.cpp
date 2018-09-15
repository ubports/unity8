/*
 * Copyright (C) 2013-2014,2016 Canonical, Ltd.
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

#include <functional>
#include <QtTest/QtTest>
#include <QtCore/QObject>
#include <qpa/qwindowsysteminterface.h>
#include <QtQuick/QQuickView>
#include <QtQml/QQmlEngine>
#include <private/qquickanimatorcontroller_p.h>
#include <private/qquickwindow_p.h>
#include <UbuntuGestures/private/ucswipearea_p_p.h>

#include <AxisVelocityCalculator.h>
#include <UbuntuGestures/private/timer_p.h>
#include "Direction.h"

#include <paths.h>

UG_USE_NAMESPACE

class tst_DragHandle: public QObject
{
    Q_OBJECT
public:
    tst_DragHandle() : m_device(0) { }
private Q_SLOTS:
    void initTestCase(); // will be called before the first test function is executed
    void cleanupTestCase(); // will be called after the last test function was executed.

    void init(); // called right before each and every test function is executed
    void cleanup(); // called right after each and every test function is executed

    void dragThreshold_horizontal();
    void dragThreshold_horizontal_data();
    void dragThreshold_vertical();
    void dragThreshold_vertical_data();
    void stretch_horizontal();
    void stretch_vertical();
    void hintingAnimation();
    void hintingAnimation_dontRestartAfterFinishedAndStillPressed();

private:
    void flickAndHold(QQuickItem *dragHandle, qreal distance);
    void drag(QPointF &touchPoint, const QPointF& direction, qreal distance,
              int numSteps, qint64 timeMs = 500);
    QQuickItem *fetchAndSetupDragHandle(const char *objectName);
    qreal fetchDragThreshold(QQuickItem *dragHandle);
    void tryCompare(std::function<qreal ()> actualFunc, qreal expectedValue);

    QQuickView *createView();
    QQuickView *m_view;
    QTouchDevice *m_device;
    FakeTimer *m_fakeTimer;
    QSharedPointer<FakeTimeSource> m_fakeTimeSource;
};


void tst_DragHandle::initTestCase()
{
    if (!m_device) {
        m_device = new QTouchDevice;
        m_device->setType(QTouchDevice::TouchScreen);
        QWindowSystemInterface::registerTouchDevice(m_device);
    }

    m_view = 0;
}

void tst_DragHandle::cleanupTestCase()
{
}

void tst_DragHandle::init()
{
    m_view = createView();
    m_view->setSource(QUrl::fromLocalFile(testDataDir() + "/" TEST_DIR "/tst_DragHandle.qml"));
    m_view->show();
    QVERIFY(QTest::qWaitForWindowExposed(m_view));
    QVERIFY(m_view->rootObject() != 0);
    qApp->processEvents();

    // Hide the controls to ensure we don't hit them accidentally
    QQuickItem *controls =  m_view->rootObject()->findChild<QQuickItem*>("controls");
    controls->setVisible(false);

    m_fakeTimeSource.reset(new FakeTimeSource);
    m_fakeTimer = new FakeTimer(m_fakeTimeSource);
}

void tst_DragHandle::cleanup()
{
    delete m_view;
    m_view = 0;

    delete m_fakeTimer;
    m_fakeTimer = 0;

    m_fakeTimeSource.reset();
}

QQuickView *tst_DragHandle::createView()
{
    QQuickView *window = new QQuickView(0);
    window->setResizeMode(QQuickView::SizeRootObjectToView);
    window->engine()->addImportPath(testDataDir() + "/" TEST_DIR);

    return window;
}

void tst_DragHandle::tryCompare(std::function<qreal ()> actualFunc,
                                qreal expectedValue)
{
    int waitCount = 0;
    while (actualFunc() != expectedValue && waitCount < 100) {
        QTest::qWait(50);
        ++waitCount;
    }
    QCOMPARE(actualFunc(), expectedValue);
}

namespace {
QPointF calculateDirectionVector(QQuickItem *edgeDragArea)
{
    QPointF localOrigin(0., 0.);
    QPointF localDirection;
    switch (edgeDragArea->property("direction").toInt()) {
        case Direction::Upwards:
            localDirection.rx() = 0.;
            localDirection.ry() = -1.;
            break;
        case Direction::Downwards:
            localDirection.rx() = 0.;
            localDirection.ry() = 1;
            break;
        case Direction::Leftwards:
            localDirection.rx() = -1.;
            localDirection.ry() = 0.;
            break;
        default: // Direction::Rightwards:
            localDirection.rx() = 1.;
            localDirection.ry() = 0.;
            break;
    }
    QPointF sceneOrigin = edgeDragArea->mapToScene(localOrigin);
    QPointF sceneDirection = edgeDragArea->mapToScene(localDirection);
    return sceneDirection - sceneOrigin;
}
}

void tst_DragHandle::flickAndHold(QQuickItem *dragHandle,
                                  qreal distance)
{
    QPointF initialTouchPos = dragHandle->mapToScene(
        QPointF(dragHandle->width() / 2.0, dragHandle->height() / 2.0));
    QPointF touchPoint = initialTouchPos;

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    int numSteps = 10;
    QPointF dragDirectionVector = calculateDirectionVector(dragHandle);
    drag(touchPoint, dragDirectionVector, distance, numSteps);

    // Wait for quite a bit before finally releasing to make a very low flick/release
    // speed.
    m_fakeTimeSource->m_msecsSinceReference += 5000;
    QTest::touchEvent(m_view, m_device).release(0, touchPoint.toPoint());

    QQuickWindowPrivate *windowPrivate = QQuickWindowPrivate::get(m_view);
    if (windowPrivate->delayedTouch) {
        windowPrivate->deliverDelayedTouchEvent();

        // Touch events which constantly start animations (such as a behavior tracking
        // the mouse point) need animations to start.
        QQmlAnimationTimer *ut = QQmlAnimationTimer::instance();
        if (ut && ut->hasStartAnimationPending())
            ut->startAnimations();
    }
}

void tst_DragHandle::drag(QPointF &touchPoint, const QPointF& direction, qreal distance,
                          int numSteps, qint64 timeMs)
{
    QQuickWindowPrivate *windowPrivate = QQuickWindowPrivate::get(m_view);

    qint64 timeStep = timeMs / numSteps;
    QPointF touchMovement = direction * (distance / (qreal)numSteps);
    for (int i = 0; i < numSteps; ++i) {
        touchPoint += touchMovement;
        m_fakeTimeSource->m_msecsSinceReference += timeStep;
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());

        if (windowPrivate->delayedTouch) {
            windowPrivate->deliverDelayedTouchEvent();

            // Touch events which constantly start animations (such as a behavior tracking
            // the mouse point) need animations to start.
            QQmlAnimationTimer *ut = QQmlAnimationTimer::instance();
            if (ut && ut->hasStartAnimationPending())
                ut->startAnimations();
        }
    }
}

QQuickItem *tst_DragHandle::fetchAndSetupDragHandle(const char *objectName)
{
    QQuickItem *dragHandle =
        m_view->rootObject()->findChild<QQuickItem*>(objectName);
    Q_ASSERT(dragHandle != 0);
    UCSwipeArea *swipeArea = dynamic_cast<UCSwipeArea*>(dragHandle);
    if (swipeArea) {
        UCSwipeAreaPrivate *swipeAreaPrivate = dynamic_cast<UCSwipeAreaPrivate *>(QQuickItemPrivate::get(swipeArea));
        swipeAreaPrivate->setRecognitionTimer(m_fakeTimer);
        swipeAreaPrivate->setTimeSource(m_fakeTimeSource);
    }

    AxisVelocityCalculator *edgeDragEvaluator =
        dragHandle->findChild<AxisVelocityCalculator*>("edgeDragEvaluator");
    Q_ASSERT(edgeDragEvaluator != 0);
    edgeDragEvaluator->setTimeSource(m_fakeTimeSource);

    return dragHandle;
}

qreal tst_DragHandle::fetchDragThreshold(QQuickItem *dragHandle)
{
    AxisVelocityCalculator *edgeDragEvaluator =
        dragHandle->findChild<AxisVelocityCalculator*>("edgeDragEvaluator");
    Q_ASSERT(edgeDragEvaluator != 0);

    return edgeDragEvaluator->property("dragThreshold").toReal();
}

/*
    Checks that ending a low-speed drag before dragThreshold results in the
    Showable getting back to its original position, whereas ending after dragThreshold
    results in Showable continuing until reaching its new states (shown or hidden)
 */
void tst_DragHandle::dragThreshold_horizontal()
{
    QFETCH(qreal, rotation);

    QQuickItem *baseItem =  m_view->rootObject()->findChild<QQuickItem*>("baseItem");
    baseItem->setRotation(rotation);

    QQuickItem *dragHandle = fetchAndSetupDragHandle("rightwardsDragHandle");
    QQuickItem *parentItem = dragHandle->parentItem();

    qreal dragThreshold = fetchDragThreshold(dragHandle);

    // end before the threshold
    flickAndHold(dragHandle, dragThreshold * 0.7);

    // should rollback
    tryCompare([&](){ return parentItem->x(); }, -parentItem->width());
    QCOMPARE(parentItem->property("shown").toBool(), false);

    // end after the threshold
    flickAndHold(dragHandle, dragThreshold * 1.2);

    // should keep going until completion
    tryCompare([&](){ return parentItem->x(); }, 0);
    QCOMPARE(parentItem->property("shown").toBool(), true);

    dragHandle = fetchAndSetupDragHandle("leftwardsDragHandle");

    dragThreshold = fetchDragThreshold(dragHandle);

    // end before the threshold
    flickAndHold(dragHandle, dragThreshold * 0.7);

    // should rollback
    tryCompare([&](){ return parentItem->x(); }, 0);
    QCOMPARE(parentItem->property("shown").toBool(), true);

    // end after the threshold
    flickAndHold(dragHandle, dragThreshold * 1.2);

    // should keep going until completion
    tryCompare([&](){ return parentItem->x(); }, -parentItem->width());
    QCOMPARE(parentItem->property("shown").toBool(), false);
}

void tst_DragHandle::dragThreshold_horizontal_data()
{
    QTest::addColumn<qreal>("rotation");

    QTest::newRow("not rotated") << 0.;
    QTest::newRow("rotated 90")  << 90.;
}

void tst_DragHandle::dragThreshold_vertical()
{
    QFETCH(qreal, rotation);

    QQuickItem *baseItem =  m_view->rootObject()->findChild<QQuickItem*>("baseItem");
    baseItem->setRotation(rotation);

    QQuickItem *dragHandle = fetchAndSetupDragHandle("topEdgeShowDragHandle");

    qreal dragThreshold = fetchDragThreshold(dragHandle);

    // end before the threshold
    flickAndHold(dragHandle, dragThreshold * 0.7);

    // should rollback
    QQuickItem *parentItem = dragHandle->parentItem();
    tryCompare([&](){ return parentItem->y(); }, -parentItem->height());
    QCOMPARE(parentItem->property("shown").toBool(), false);

    // end after the threshold
    flickAndHold(dragHandle, dragThreshold * 1.2);

    // should keep going until completion
    tryCompare([&](){ return parentItem->y(); }, 0);
    QCOMPARE(parentItem->property("shown").toBool(), true);

    dragHandle = fetchAndSetupDragHandle("topEdgeHideDragHandle");

    dragThreshold = fetchDragThreshold(dragHandle);

    // end before the threshold
    flickAndHold(dragHandle, dragThreshold * 0.7);

    // should rollback
    tryCompare([&](){ return parentItem->y(); }, 0);
    QCOMPARE(parentItem->property("shown").toBool(), true);

    // end after the threshold
    flickAndHold(dragHandle, dragThreshold * 1.2);

    // should keep going until completion
    tryCompare([&](){ return parentItem->y(); }, -parentItem->height());
    QCOMPARE(parentItem->property("shown").toBool(), false);
}

void tst_DragHandle::dragThreshold_vertical_data()
{
    QTest::addColumn<qreal>("rotation");

    QTest::newRow("not rotated") << 0.;
    QTest::newRow("rotated 90")  << 90.;
}

/*
  Checks that when the stretch property is true, dragging the DragHandle increases
  the width or height (depending on its direction) of its parent Showable
 */
void tst_DragHandle::stretch_horizontal()
{
    QQuickItem *dragHandle = fetchAndSetupDragHandle("rightwardsDragHandle");
    qreal totalDragDistance = dragHandle->property("maxTotalDragDistance").toReal();
    QQuickItem *parentItem = dragHandle->parentItem();

    // enable strech mode
    m_view->rootObject()->setProperty("stretch", QVariant(true));

    QCOMPARE(parentItem->width(), 0.0);

    // flick all the way
    flickAndHold(dragHandle, totalDragDistance);

    // should keep going until completion
    // Parent item should now have its full height
    tryCompare([&](){ return parentItem->width(); }, totalDragDistance);
    QCOMPARE(parentItem->property("shown").toBool(), true);

    dragHandle = fetchAndSetupDragHandle("leftwardsDragHandle");

    // flick all the way
    flickAndHold(dragHandle, totalDragDistance);

    // should keep going until completion
    // Parent item should now have its full height
    tryCompare([&](){ return parentItem->width(); }, 0.0);
    QCOMPARE(parentItem->property("shown").toBool(), false);
}

void tst_DragHandle::stretch_vertical()
{
    QQuickItem *dragHandle = fetchAndSetupDragHandle("topEdgeShowDragHandle");
    qreal totalDragDistance = dragHandle->property("maxTotalDragDistance").toReal();
    QQuickItem *parentItem = dragHandle->parentItem();

    // enable strech mode
    m_view->rootObject()->setProperty("stretch", QVariant(true));

    QCOMPARE(parentItem->height(), 0.0);

    // flick all the way
    flickAndHold(dragHandle, totalDragDistance);

    // should keep going until completion
    // Parent item should now have its full height
    tryCompare([&](){ return parentItem->height(); }, totalDragDistance);
    QCOMPARE(parentItem->property("shown").toBool(), true);

    dragHandle = fetchAndSetupDragHandle("topEdgeHideDragHandle");

    // flick all the way
    flickAndHold(dragHandle, totalDragDistance);

    // should keep going until completion
    // Parent item should now have its full height
    tryCompare([&](){ return parentItem->height(); }, 0.0);
    QCOMPARE(parentItem->property("shown").toBool(), false);
}

/*
    Set DragHandle.hintDisplacement to a value bigger than zero.
    Then lay a finger on the DragHandle.
    The expected behavior is that it will move or strech its parent Showable
    by hintDisplacement pixels.
 */
void tst_DragHandle::hintingAnimation()
{
    QQuickItem *dragHandle = fetchAndSetupDragHandle("topEdgeShowDragHandle");
    QQuickItem *parentItem = dragHandle->parentItem();
    qreal hintDisplacement = 100.0;

    // enable hinting animations and stretch mode
    m_view->rootObject()->setProperty("hintDisplacement", QVariant(hintDisplacement));
    m_view->rootObject()->setProperty("stretch", QVariant(true));

    QCOMPARE(parentItem->height(), 0.0);

    QPointF initialTouchPos = dragHandle->mapToScene(
        QPointF(dragHandle->width() / 2.0, dragHandle->height() / 2.0));
    QPointF touchPoint = initialTouchPos;

    // Pressing causes the Showable to be stretched by hintDisplacement pixels
    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());
    tryCompare([&](){ return parentItem->height(); }, hintDisplacement);

    // Releasing causes the Showable to shrink back to 0 pixels.
    QTest::touchEvent(m_view, m_device).release(0, touchPoint.toPoint());
    tryCompare([&](){ return parentItem->height(); }, 0.0);

    QCOMPARE(parentItem->property("shown").toBool(), false);
}

/*
    Regression test for LP#1269022: https://bugs.launchpad.net/unity8/+bug/1269022

    1) Click on handle.
    2) wait for hint portion to appear
    3) slowly drag handle, only a few pixels

    Expected outcome:
        Nothing happens

    Actual outcome:
        Handle will momentarily move back to zero position, then back down to the
        hint displacement location.
 */
void tst_DragHandle::hintingAnimation_dontRestartAfterFinishedAndStillPressed()
{
    QQuickItem *dragHandle = fetchAndSetupDragHandle("topEdgeShowDragHandle");
    QQuickItem *parentItem = dragHandle->parentItem();
    qreal hintDisplacement = 100.0;

    // enable hinting animations
    m_view->rootObject()->setProperty("hintDisplacement", QVariant(hintDisplacement));
    m_view->rootObject()->setProperty("stretch", QVariant(true));

    QCOMPARE(parentItem->height(), 0.0);

    QPointF initialTouchPos = dragHandle->mapToScene(
        QPointF(dragHandle->width() / 2.0, dragHandle->height() / 2.0));
    QPointF touchPoint = initialTouchPos;

    // Pressing causes the Showable to be stretched by hintDisplacement pixels
    const int touchId = 0;
    QTest::touchEvent(m_view, m_device).press(touchId, touchPoint.toPoint());
    tryCompare([&](){ return parentItem->height(); }, hintDisplacement);


    QSignalSpy parentHeightChangedSpy(parentItem, &QQuickItem::heightChanged);

    drag(touchPoint, QPointF(0.0, -1.0) /*dragDirectionVector*/, 15 /*distance*/, 3 /*numSteps*/);

    // Give some time for animations to run, if any
    QTest::qWait(300);

    // parentItem height shouldn't have changed at all
    QVERIFY(parentHeightChangedSpy.isEmpty());
}

QTEST_MAIN(tst_DragHandle)

#include "tst_DragHandle.moc"
