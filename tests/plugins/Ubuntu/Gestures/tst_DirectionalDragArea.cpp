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
 */

#include <QtTest/QtTest>
#include <QtCore/QObject>
#include <QtQuick/QQuickView>
#include <QtQml/QQmlEngine>
#include <QPointer>

#include <DirectionalDragArea.h>

#include "GestureTest.h"

using namespace UbuntuGestures;

class FakeTimer : public AbstractTimer
{
    Q_OBJECT
public:
    FakeTimer(const SharedTimeSource &timeSource, QObject *parent = 0)
        : UbuntuGestures::AbstractTimer(parent),
          m_timeSource(timeSource)
    {}

    int interval() const override { return m_interval; }
    void setInterval(int msecs) override { m_interval = msecs; }
    void start() override {
        AbstractTimer::start();
        m_nextTimeoutTime = m_timeSource->msecsSinceReference() + (qint64)m_interval;
    }

    void emitTimeout() {
        m_nextTimeoutTime += m_interval;
        Q_EMIT timeout();
    }

    qint64 nextTimeoutTime() const { return m_nextTimeoutTime; }
private:
    int m_interval;
    SharedTimeSource m_timeSource;
    qint64 m_nextTimeoutTime;
};

class FakeTimeSource : public UbuntuGestures::TimeSource
{
public:
    FakeTimeSource() { m_msecsSinceReference = 0; }
    virtual qint64 msecsSinceReference() {return m_msecsSinceReference;}
    qint64 m_msecsSinceReference;
};

class tst_DirectionalDragArea: public GestureTest
{
    Q_OBJECT
public:
    tst_DirectionalDragArea();
private Q_SLOTS:
    void init(); // called right before each and every test function is executed
    void cleanup(); // called right after each and every test function is executed

    void edgeDrag();
    void edgeDrag_data();
    void dragWithShortDirectionChange();
    void minSpeed();
    void minSpeed_data();
    void recognitionTimerUsage();
    void maxSilenceTime();
    void sceneXAndX();
    void sceneYAndY();
    void twoFingerTap();
    void movingDDA();
    void ignoreOldFinger();
    void rotated();
    void sceneDistance();
    void sceneDistance_data();
    void disabledWhileDragging();

private:
    void passTime(qint64 timeSpan);
    FakeTimer *fakeTimer;
    QSharedPointer<FakeTimeSource> fakeTimeSource;
};

tst_DirectionalDragArea::tst_DirectionalDragArea()
    : GestureTest(QStringLiteral("tst_DirectionalDragArea.qml"))
{
}

void tst_DirectionalDragArea::init()
{
    GestureTest::init();

    // We shouldn't need the three lines below, but a compiz/unity7
    // regression means we don't pass the test without them because
    // the window doesn't have the proper size. Can be removed in the
    // future if the regression is fixed and tests pass again
    m_view->resize(m_view->rootObject()->width(), m_view->rootObject()->height());
    QTRY_COMPARE(m_view->width(), (int)m_view->rootObject()->width());
    QTRY_COMPARE(m_view->height(), (int)m_view->rootObject()->height());

    fakeTimeSource.reset(new FakeTimeSource);
    fakeTimer = new FakeTimer(fakeTimeSource);
}

void tst_DirectionalDragArea::cleanup()
{
    delete fakeTimer;
    fakeTimer = 0;

    fakeTimeSource.reset();

    GestureTest::cleanup();
}

void tst_DirectionalDragArea::passTime(qint64 timeSpan)
{
    qint64 finalTime = fakeTimeSource->m_msecsSinceReference + timeSpan;

    if (fakeTimer->isRunning() && finalTime >= fakeTimer->nextTimeoutTime()) {
        fakeTimeSource->m_msecsSinceReference = fakeTimer->nextTimeoutTime();
        fakeTimer->emitTimeout();

        qint64 timeSpanRemainder = finalTime - fakeTimeSource->m_msecsSinceReference;
        if (timeSpanRemainder > 0) {
            passTime(timeSpanRemainder);
        }
    } else {
        fakeTimeSource->m_msecsSinceReference = finalTime;
    }
}

namespace {
QPointF calculateInitialTouchPos(DirectionalDragArea *edgeDragArea)
{
    QPointF localCenter(edgeDragArea->width() / 2., edgeDragArea->height() / 2.);
    return edgeDragArea->mapToScene(localCenter);
}

QPointF calculateDirectionVector(DirectionalDragArea *edgeDragArea,
                                 qreal wideningAngleMultiplier)
{
    qreal angleRadians = edgeDragArea->wideningAngle() * wideningAngleMultiplier
        * M_PI / 180.0;

    qreal angleCos = qCos(angleRadians);
    qreal angleSin = qSin(angleRadians);

    switch (edgeDragArea->direction()) {
        case Direction::Upwards:
            return QPointF(angleSin, -angleCos);
        case Direction::Downwards:
            return QPointF(angleSin, angleCos);
        case Direction::Leftwards:
            return QPointF(-angleCos, angleSin);
        default: // Direction::Rightwards:
            return QPointF(angleCos, angleSin);
    }
}

QPointF createTouchDeviation(DirectionalDragArea *edgeDragArea)
{
    qreal deviation = edgeDragArea->maxDeviation() * 0.8;

    if (Direction::isHorizontal(edgeDragArea->direction())) {
        return QPointF(0, deviation);
    } else {
        return QPointF(deviation, 0);
    }
}
}

void tst_DirectionalDragArea::edgeDrag()
{
    QFETCH(QString, dragAreaObjectName);
    QFETCH(qreal, wideningAngleMultiplier);
    QFETCH(qreal, dragDistanceFactor);
    QFETCH(bool, expectGestureRecognition);

    DirectionalDragArea *edgeDragArea =
        m_view->rootObject()->findChild<DirectionalDragArea*>(dragAreaObjectName);
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QSignalSpy draggingSpy(edgeDragArea, SIGNAL(draggingChanged(bool)));

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea);
    QPointF touchPoint = initialTouchPos;

    qreal desiredDragDistance = edgeDragArea->distanceThreshold()*dragDistanceFactor;
    QPointF dragDirectionVector = calculateDirectionVector(edgeDragArea,
                                                           wideningAngleMultiplier);
    qreal movementStepDistance = edgeDragArea->distanceThreshold() * 0.1f;
    QPointF touchMovement = dragDirectionVector * movementStepDistance;
    int totalMovementSteps = qCeil(desiredDragDistance / movementStepDistance);
    int movementTimeStepMs = (edgeDragArea->compositionTime() * 1.5f) / totalMovementSteps;

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    QCOMPARE(draggingSpy.count(), 1);
    QCOMPARE(edgeDragArea->dragging(), true);

    if (wideningAngleMultiplier > 0) {
        // go close to the border of the valid area for this touch point
        // in order to make it easier to leave it by dragging at an angle
        // slightly bigger than the widening angle
        touchPoint += createTouchDeviation(edgeDragArea);
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());
    }

    for (int i = 0; i < totalMovementSteps; ++i) {
        touchPoint += touchMovement;
        passTime(movementTimeStepMs);
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());
    }

    if (expectGestureRecognition)
        QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Recognized);

    if (edgeDragArea->status() == DirectionalDragArea::WaitingForTouch) {
        QCOMPARE(edgeDragArea->dragging(), false);
        QCOMPARE(draggingSpy.count(), 2);
    }

    QTest::touchEvent(m_view, m_device).release(0, touchPoint.toPoint());

    QCOMPARE(draggingSpy.count(), 2);
    QCOMPARE(edgeDragArea->dragging(), false);
}

void tst_DirectionalDragArea::edgeDrag_data()
{
    QTest::addColumn<QString>("dragAreaObjectName");
    QTest::addColumn<qreal>("wideningAngleMultiplier");
    QTest::addColumn<qreal>("dragDistanceFactor");
    QTest::addColumn<bool>("expectGestureRecognition");

    QTest::newRow("rightwards, tiny drag")
        << "hpDragArea" << 0.0 << 0.2 << false;

    QTest::newRow("rightwards, straight drag")
        << "hpDragArea" << 0.0 << 3.0 << true;

    QTest::newRow("rightwards, diagonal drag")
        << "hpDragArea" << 0.9 << 3.0 << true;

    QTest::newRow("rightwards, overly diagonal drag")
        << "hpDragArea" << 2.0 << 3.0 << false;

    QTest::newRow("leftwards, tiny drag")
        << "hnDragArea" << 0.0 << 0.2 << false;

    QTest::newRow("leftwards, straight drag")
        << "hnDragArea" << 0.0 << 3.0 << true;

    QTest::newRow("leftwards, diagonal drag")
        << "hnDragArea" << 0.9 << 3.0 << true;

    QTest::newRow("downwards, tiny drag")
        << "vpDragArea" << 0.0 << 0.2 << false;

    QTest::newRow("downwards, straight drag")
        << "vpDragArea" << 0.0 << 3.0 << true;

    QTest::newRow("downwards, diagonal drag")
        << "vpDragArea" << 0.9 << 3.0 << true;

    QTest::newRow("upwards, tiny drag")
        << "vnDragArea" << 0.0 << 0.2 << false;

    QTest::newRow("upwards, straight drag")
        << "vnDragArea" << 0.0 << 3.0 << true;

    QTest::newRow("upwards, diagonal drag")
        << "vnDragArea" << 0.9 << 3.0 << true;

    QTest::newRow("upwards, overly diagonal drag")
        << "vnDragArea" << 2.0 << 3.0 << false;
}

/*
  A directional drag should still be recognized if there is a momentaneous, small,
  change in the direction of a drag. That should be accounted as input noise and
  therefore ignored.
 */
void tst_DirectionalDragArea::dragWithShortDirectionChange()
{
    DirectionalDragArea *edgeDragArea =
        m_view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea);
    QPointF touchPoint = initialTouchPos;

    qreal desiredDragDistance = edgeDragArea->distanceThreshold()*2.0;
    QPointF dragDirectionVector(1.0, 0.0);
    qreal touchStepDistance = edgeDragArea->distanceThreshold() * 0.1f;
    // make sure we are above minimum speed
    int touchStepTimeMs = (touchStepDistance / (edgeDragArea->minSpeed() * 5.0f)) * 1000.0f;
    QPointF touchMovement = dragDirectionVector * touchStepDistance;

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    // Move a bit in the proper direction
    for (int i=0; i < 3; ++i) {
        touchPoint += touchMovement;
        passTime(touchStepTimeMs);
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());
    }

    // Then a sudden and small movement to the opposite direction
    touchPoint -= touchMovement*0.2;
    passTime(touchStepTimeMs*0.2);
    QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());

    // And then resume movment in the correct direction until it crosses the distance and time
    // thresholds.
    do {
        touchPoint += touchMovement;
        passTime(touchStepTimeMs);
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());
    } while ((touchPoint - initialTouchPos).manhattanLength() < desiredDragDistance
            || fakeTimeSource->m_msecsSinceReference < (edgeDragArea->compositionTime() * 1.5f));

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Recognized);

    QTest::touchEvent(m_view, m_device).release(0, touchPoint.toPoint());
}

/*
   Checks that a gesture will be rejected if it's slower than minSpeed while
   status is Undecided.
 */
void tst_DirectionalDragArea::minSpeed()
{
    QFETCH(qreal, minSpeed);
    QFETCH(qreal, speed);
    QFETCH(int, expectedStatusAfterSpeedCheck);

    DirectionalDragArea *edgeDragArea =
        m_view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    // A really long, unattainable, number. We don't want it getting recognized before
    // the speed checks we want have been performed
    edgeDragArea->setDistanceThreshold(500000);

    edgeDragArea->setMinSpeed(minSpeed);

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea);
    QPointF touchPoint = initialTouchPos;

    QPointF dragDirectionVector(1.0, 0.0);
    qint64 timeStepMsecs = 10;
    qreal distanceStep = (speed / 1000.0f) * timeStepMsecs;
    QPointF touchMovement = dragDirectionVector * distanceStep;

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    // Move for a while to ensure our speed check is performed a couple of times
    for (int i=0; i < 20; ++i) {
        touchPoint += touchMovement;
        passTime(timeStepMsecs);
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());
    }

    QCOMPARE((int)edgeDragArea->status(), expectedStatusAfterSpeedCheck);
}

void tst_DirectionalDragArea::minSpeed_data()
{
    QTest::addColumn<qreal>("minSpeed");
    QTest::addColumn<qreal>("speed");
    QTest::addColumn<int>("expectedStatusAfterSpeedCheck");

    QTest::newRow("slower than minSpeed") << 100.0 << 50.0 << (int)DirectionalDragArea::WaitingForTouch;
    QTest::newRow("faster than minSpeed") << 100.0 << 150.0 << (int)DirectionalDragArea::Undecided;
}

/*
    Checks that the recognition timer is started and stopped appropriately.
    I.e., check that it's running only while gesture recognition is taking place
    (status == Undecided)
 */
void tst_DirectionalDragArea::recognitionTimerUsage()
{
    DirectionalDragArea *edgeDragArea =
        m_view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    // don't let it interfere with our test
    edgeDragArea->setMinSpeed(0.0);

    int timeStepMs = 5; // some arbitrary small value.

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea);
    QPointF touchPoint = initialTouchPos;

    QPointF dragDirectionVector(1.0, 0.0);
    QPointF touchMovement = dragDirectionVector * (edgeDragArea->distanceThreshold() * 0.2f);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);
    QVERIFY(!fakeTimer->isRunning());

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Undecided);
    QVERIFY(fakeTimer->isRunning());

    // Move beyond distance threshold and composition time to ensure recognition
    while (fakeTimeSource->m_msecsSinceReference <= edgeDragArea->compositionTime() ||
           (touchPoint - initialTouchPos).manhattanLength() <= edgeDragArea->distanceThreshold()) {

        QCOMPARE(edgeDragArea->status() == DirectionalDragArea::Undecided, fakeTimer->isRunning());

        touchPoint += touchMovement;
        passTime(timeStepMs);
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());
    }

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Recognized);
    QVERIFY(!fakeTimer->isRunning());
}

/*
    A gesture should be rejected if too much time has passed without any new input
    events from it.
 */
void tst_DirectionalDragArea::maxSilenceTime()
{
    DirectionalDragArea *edgeDragArea =
        m_view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    // Make sure this property is not disabled
    edgeDragArea->setMaxSilenceTime(100);

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea);
    QPointF touchPoint = initialTouchPos;

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Undecided);
    QVERIFY(fakeTimer->isRunning());

    // Force timer to timeout until after maxSilenceTime has been reached
    while (fakeTimeSource->m_msecsSinceReference < edgeDragArea->maxSilenceTime()) {
        passTime(fakeTimer->interval());
    }

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);
}

/*
  Checks that it informs the X coordinate of the touch point in local and scene coordinates
  correctly.
 */
void tst_DirectionalDragArea::sceneXAndX()
{
    DirectionalDragArea *edgeDragArea =
        m_view->rootObject()->findChild<DirectionalDragArea*>("hnDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF touchScenePos(m_view->width() - (edgeDragArea->width()/2.0f), m_view->height()/2.0f);

    QTest::touchEvent(m_view, m_device).press(0, touchScenePos.toPoint());

    QSignalSpy touchXSpy(edgeDragArea, SIGNAL(touchXChanged(qreal)));
    QSignalSpy touchSceneXSpy(edgeDragArea, SIGNAL(touchSceneXChanged(qreal)));

    touchScenePos.rx() = m_view->width() / 2;
    QTest::touchEvent(m_view, m_device).move(0, touchScenePos.toPoint());

    QCOMPARE(touchXSpy.count(), 1);
    QCOMPARE(touchSceneXSpy.count(), 1);
    QCOMPARE(edgeDragArea->touchX(), touchScenePos.x() - edgeDragArea->x());
    QCOMPARE(edgeDragArea->touchSceneX(), touchScenePos.x());
}

/*
  Checks that it informs the Y coordinate of the touch point in local and scene coordinates
  correctly.
 */
void tst_DirectionalDragArea::sceneYAndY()
{
    DirectionalDragArea *edgeDragArea =
        m_view->rootObject()->findChild<DirectionalDragArea*>("vnDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF touchScenePos(m_view->width()/2.0f, m_view->height() - (edgeDragArea->height()/2.0f));

    QTest::touchEvent(m_view, m_device).press(0, touchScenePos.toPoint());

    QSignalSpy touchYSpy(edgeDragArea, SIGNAL(touchYChanged(qreal)));
    QSignalSpy touchSceneYSpy(edgeDragArea, SIGNAL(touchSceneYChanged(qreal)));

    touchScenePos.ry() = m_view->height() / 2;
    QTest::touchEvent(m_view, m_device).move(0, touchScenePos.toPoint());

    QCOMPARE(touchYSpy.count(), 1);
    QCOMPARE(touchSceneYSpy.count(), 1);
    QCOMPARE(edgeDragArea->touchY(), touchScenePos.y() - edgeDragArea->y());
    QCOMPARE(edgeDragArea->touchSceneY(), touchScenePos.y());
}

/*
  Regression test for https://bugs.launchpad.net/bugs/1228336

  Perform a quick two-finger double-tap and check that DirectionalDragArea properly
  rejects those touch points. In the bug above it got confused and crashed.
 */
void tst_DirectionalDragArea::twoFingerTap()
{
    DirectionalDragArea *edgeDragArea =
        m_view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    // Make touches evenly spaced along the edgeDragArea
    QPoint touchAPos(edgeDragArea->width()/2.0f, m_view->height()*0.33f);
    QPoint touchBPos(edgeDragArea->width()/2.0f, m_view->height()*0.66f);

    qint64 timeStepMsecs = 5; // some arbitrary, small value

    // Perform the first two-finger tap
    // NB: using move() instead of stationary() becasue in the latter you cannot provide
    //     the touch position and therefore it's left with some garbage numbers.
    QTest::touchEvent(m_view, m_device)
        .press(0, touchAPos);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Undecided);

    passTime(timeStepMsecs);
    QTest::touchEvent(m_view, m_device)
        .move(0, touchAPos)
        .press(1, touchBPos);

    // A second touch point appeared during recognition, reject immediately as this
    // can't be a single-touch gesture anymore.
    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);

    passTime(timeStepMsecs);
    QTest::touchEvent(m_view, m_device)
        .release(0, touchAPos)
        .move(1, touchBPos);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);

    passTime(timeStepMsecs);
    QTest::touchEvent(m_view, m_device)
        .release(1, touchBPos);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);

    // Perform the second two-finger tap

    passTime(timeStepMsecs);
    QTest::touchEvent(m_view, m_device)
        .press(0, touchAPos);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Undecided);

    passTime(timeStepMsecs);
    QTest::touchEvent(m_view, m_device)
        .move(0, touchAPos)
        .press(1, touchBPos);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);

    passTime(timeStepMsecs);
    QTest::touchEvent(m_view, m_device)
        .release(0, touchAPos)
        .move(1, touchBPos);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);

    passTime(timeStepMsecs);
    QTest::touchEvent(m_view, m_device)
        .release(1, touchBPos);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);
}

/*
   Tests that gesture recognition works normally even if the DirectionalDragArea moves
   during recognition.
   This effectively means that we have to do gesture recognition with scene coordinates
   instead of local item coordinates.
 */
void tst_DirectionalDragArea::movingDDA()
{
    QQuickItem *rightwardsLauncher =  m_view->rootObject()->findChild<QQuickItem*>("rightwardsLauncher");
    Q_ASSERT(rightwardsLauncher != 0);

    DirectionalDragArea *edgeDragArea =
        rightwardsLauncher->findChild<DirectionalDragArea*>("hpDragArea");
    Q_ASSERT(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea);
    QPointF touchPoint = initialTouchPos;

    qreal desiredDragDistance = edgeDragArea->distanceThreshold()*2.0f;
    QPointF dragDirectionVector(1.0f, 0.0f);

    qreal movementStepDistance = edgeDragArea->distanceThreshold() * 0.1f;
    QPointF touchMovement = dragDirectionVector * movementStepDistance;
    int totalMovementSteps = qCeil(desiredDragDistance / movementStepDistance);
    int movementTimeStepMs = (edgeDragArea->compositionTime() * 1.5f) / totalMovementSteps;

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    // Move it far ahead along the direction of the gesture
    // rightwardsLauncher is a parent of our DirectionalDragArea. So moving it will move our DDA
    rightwardsLauncher->setX(rightwardsLauncher->x() + edgeDragArea->distanceThreshold() * 5.0f);

    for (int i = 0; i < totalMovementSteps; ++i) {
        touchPoint += touchMovement;
        passTime(movementTimeStepMs);
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());
    }

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Recognized);

    QTest::touchEvent(m_view, m_device).release(0, touchPoint.toPoint());
}

/*
    The presence of and old, rejected, touch point lying on the DirectionalDragArea
    shouldn't impede the recognition of a gesture from a new touch point.
 */
void tst_DirectionalDragArea::ignoreOldFinger()
{
    DirectionalDragArea *edgeDragArea =
        m_view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    Q_ASSERT(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    // Make touches evenly spaced along the edgeDragArea
    QPoint touch0Pos(edgeDragArea->width()/2.0f, m_view->height()*0.33f);
    QPoint touch1Pos(edgeDragArea->width()/2.0f, m_view->height()*0.66f);

    QTest::touchEvent(m_view, m_device).press(0, touch0Pos);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Undecided);

    // leave it lying around for some time
    passTime(qMax(edgeDragArea->maxSilenceTime(), edgeDragArea->compositionTime()) * 10);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);

    qreal desiredDragDistance = edgeDragArea->distanceThreshold()*2.0f;
    QPointF dragDirectionVector(1.0f, 0.0f);

    qreal movementStepDistance = edgeDragArea->distanceThreshold() * 0.1f;
    QPointF touchMovement = dragDirectionVector * movementStepDistance;
    int totalMovementSteps = qCeil(desiredDragDistance / movementStepDistance);
    int movementTimeStepMs = (edgeDragArea->compositionTime() * 1.5f) / totalMovementSteps;

    QTest::touchEvent(m_view, m_device)
        .move(0, touch0Pos)
        .press(1, touch1Pos);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Undecided);

    for (int i = 0; i < totalMovementSteps; ++i) {
        touch1Pos += touchMovement.toPoint();
        passTime(movementTimeStepMs);
        QTest::touchEvent(m_view, m_device)
            .move(0, touch0Pos)
            .move(1, touch1Pos);
    }

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Recognized);

    QTest::touchEvent(m_view, m_device)
        .move(0, touch0Pos)
        .release(1, touch1Pos);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);
}

/*
    A Rightwards DDA that is rotated 90 degrees clockwise should recognize gestures
    that are done downwards in scene coordinates. I.e. the gesture recognition direction
    should be in local coordinates, not scene coordinates.
 */
void tst_DirectionalDragArea::rotated()
{
    QQuickItem *baseItem =  m_view->rootObject()->findChild<QQuickItem*>("baseItem");
    baseItem->setRotation(90.);

    QQuickItem *rightwardsLauncher =  m_view->rootObject()->findChild<QQuickItem*>("rightwardsLauncher");
    Q_ASSERT(rightwardsLauncher != 0);

    DirectionalDragArea *edgeDragArea =
        rightwardsLauncher->findChild<DirectionalDragArea*>("hpDragArea");
    Q_ASSERT(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea);
    QPointF touchPoint = initialTouchPos;

    qreal desiredDragDistance = edgeDragArea->distanceThreshold()*2.0f;
    QPointF dragDirectionVector(0.0f, 1.0f);

    qreal movementStepDistance = edgeDragArea->distanceThreshold() * 0.1f;
    QPointF touchMovement = dragDirectionVector * movementStepDistance;
    int totalMovementSteps = qCeil(desiredDragDistance / movementStepDistance);
    int movementTimeStepMs = (edgeDragArea->compositionTime() * 1.5f) / totalMovementSteps;

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    for (int i = 0; i < totalMovementSteps; ++i) {
        touchPoint += touchMovement;
        passTime(movementTimeStepMs);
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());
    }

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Recognized);

    QTest::touchEvent(m_view, m_device).release(0, touchPoint.toPoint());
}

void tst_DirectionalDragArea::sceneDistance()
{
    QQuickItem *baseItem =  m_view->rootObject()->findChild<QQuickItem*>("baseItem");
    QFETCH(qreal, rotation);
    QFETCH(QPointF, dragDirectionVector);
    baseItem->setRotation(rotation);

    QQuickItem *rightwardsLauncher =  m_view->rootObject()->findChild<QQuickItem*>("rightwardsLauncher");
    Q_ASSERT(rightwardsLauncher != 0);

    DirectionalDragArea *edgeDragArea =
        rightwardsLauncher->findChild<DirectionalDragArea*>("hpDragArea");
    Q_ASSERT(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea);
    QPointF touchPoint = initialTouchPos;

    qreal desiredDragDistance = edgeDragArea->distanceThreshold()*2.0f;

    qreal movementStepDistance = edgeDragArea->distanceThreshold() * 0.1f;
    QPointF touchMovement = dragDirectionVector * movementStepDistance;
    int totalMovementSteps = qCeil(desiredDragDistance / movementStepDistance);
    int movementTimeStepMs = (edgeDragArea->compositionTime() * 1.5f) / totalMovementSteps;

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    for (int i = 0; i < totalMovementSteps; ++i) {
        touchPoint += touchMovement;
        passTime(movementTimeStepMs);
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());
    }

    qreal actualDragDistance = ((qreal)totalMovementSteps) * movementStepDistance;

    // DirectionalDragArea::sceneDistance() must match the actual drag distance as the
    // drag was aligned with the gesture direction
    // NB: qFuzzyCompare(), used internally by QCOMPARE(), is broken.
    QVERIFY(qAbs(edgeDragArea->sceneDistance() - actualDragDistance) < 0.001);

    QTest::touchEvent(m_view, m_device).release(0, touchPoint.toPoint());
}

void tst_DirectionalDragArea::sceneDistance_data()
{
    QTest::addColumn<qreal>("rotation");
    QTest::addColumn<QPointF>("dragDirectionVector");

    QTest::newRow("not rotated")           << 0.  << QPointF(1., 0.);
    QTest::newRow("rotated by 90 degrees") << 90. << QPointF(0., 1.);
}

/*
    Regression test for https://bugs.launchpad.net/unity8/+bug/1276122

    The bug:
    If setting "enabled: false" while the DirectionalDragArea's (DDA) dragging
    property is true, the DDA stays in that state and doesn't recover any more.
*/
void tst_DirectionalDragArea::disabledWhileDragging()
{
    DirectionalDragArea *edgeDragArea =
        m_view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    Q_ASSERT(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF touchPoint = calculateInitialTouchPos(edgeDragArea);

    qreal desiredDragDistance = edgeDragArea->distanceThreshold()*2.0f;
    QPointF dragDirectionVector(1., 0.); // horizontal positive

    qreal movementStepDistance = edgeDragArea->distanceThreshold() * 0.1f;
    QPointF touchMovement = dragDirectionVector * movementStepDistance;
    int totalMovementSteps = qCeil(desiredDragDistance / movementStepDistance);
    int movementTimeStepMs = (edgeDragArea->compositionTime() * 1.5f) / totalMovementSteps;

    QTest::touchEvent(m_view, m_device).press(0, touchPoint.toPoint());

    for (int i = 0; i < totalMovementSteps; ++i) {
        touchPoint += touchMovement;
        passTime(movementTimeStepMs);
        QTest::touchEvent(m_view, m_device).move(0, touchPoint.toPoint());
    }

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Recognized);
    QCOMPARE(edgeDragArea->dragging(), true);

    // disable the dragArea while it's being dragged.
    edgeDragArea->setEnabled(false);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::WaitingForTouch);
    QCOMPARE(edgeDragArea->dragging(), false);

    QTest::touchEvent(m_view, m_device).release(0, touchPoint.toPoint());
}

QTEST_MAIN(tst_DirectionalDragArea)

#include "tst_DirectionalDragArea.moc"
