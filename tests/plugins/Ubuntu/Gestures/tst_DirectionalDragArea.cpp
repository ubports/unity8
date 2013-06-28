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
#include <qpa/qwindowsysteminterface.h>
#include <QtQuick/QQuickView>
#include <QtQml/QQmlEngine>

#include <DirectionalDragArea.h>

class FakeTimer : public UbuntuGestures::AbstractTimer
{
    Q_OBJECT
public:
    FakeTimer(QObject *parent = 0)
        : UbuntuGestures::AbstractTimer(parent)
    {}

    virtual int interval() const { return m_duration; }
    virtual void setInterval(int msecs) { m_duration = msecs; }

    void emitTimeout() {Q_EMIT timeout();}
private:
    int m_duration;
};

class FakeTimeSource : public UbuntuGestures::TimeSource
{
public:
    FakeTimeSource() { m_msecsSinceReference = 0; }
    virtual qint64 msecsSinceReference() {return m_msecsSinceReference;}
    qint64 m_msecsSinceReference;
};

class tst_DirectionalDragArea: public QObject
{
    Q_OBJECT
public:
    tst_DirectionalDragArea() : device(0) { }
private Q_SLOTS:
    void initTestCase(); // will be called before the first test function is executed
    void cleanupTestCase(); // will be called after the last test function was executed.

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

private:
    QQuickView *createView();
    QQuickView *view;
    QTouchDevice *device;
    FakeTimer *fakeTimer;
    FakeTimeSource *fakeTimeSource;
};

void tst_DirectionalDragArea::initTestCase()
{
    if (!device) {
        device = new QTouchDevice;
        device->setType(QTouchDevice::TouchScreen);
        QWindowSystemInterface::registerTouchDevice(device);
    }

    view = 0;
}

void tst_DirectionalDragArea::cleanupTestCase()
{
}

void tst_DirectionalDragArea::init()
{
    view = createView();
    view->setSource(QUrl::fromLocalFile("edgeDragExample.qml"));
    view->show();
    QVERIFY(QTest::qWaitForWindowExposed(view));
    QVERIFY(view->rootObject() != 0);
    qApp->processEvents();

    fakeTimer = new FakeTimer;
    fakeTimeSource = new FakeTimeSource;
}

void tst_DirectionalDragArea::cleanup()
{
    delete view;
    view = 0;

    delete fakeTimer;
    fakeTimer = 0;

    delete fakeTimeSource;
    fakeTimeSource = 0;
}

QQuickView *tst_DirectionalDragArea::createView()
{
    QQuickView *window = new QQuickView(0);
    window->setResizeMode(QQuickView::SizeRootObjectToView);
    window->resize(600, 600);
    window->engine()->addImportPath(QLatin1String(UBUNTU_GESTURES_PLUGIN_DIR));

    return window;
}

namespace {
QPointF calculateInitialTouchPos(DirectionalDragArea *edgeDragArea, QQuickView *view)
{
    switch (edgeDragArea->direction()) {
        case Direction::Upwards:
            return QPointF(view->width()/2.0f, view->height() - (edgeDragArea->height()/2.0f));
        case Direction::Downwards:
            return QPointF(view->width()/2.0f, edgeDragArea->height()/2.0f);
        case Direction::Leftwards:
            return QPointF(view->width() - (edgeDragArea->width()/2.0f), view->height()/2.0f);
        default: // Direction::Rightwards:
            return QPointF(edgeDragArea->width()/2.0f, view->height()/2.0f);
    }
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
    QFETCH(int, expectedGestureRecognition);

    DirectionalDragArea *edgeDragArea =
        view->rootObject()->findChild<DirectionalDragArea*>(dragAreaObjectName);
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QSignalSpy draggingSpy(edgeDragArea, SIGNAL(draggingChanged(bool)));

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea, view);
    QPointF touchPoint = initialTouchPos;

    qreal desiredDragDistance = edgeDragArea->distanceThreshold()*dragDistanceFactor;
    QPointF dragDirectionVector = calculateDirectionVector(edgeDragArea,
                                                           wideningAngleMultiplier);
    QPointF touchMovement = dragDirectionVector * (edgeDragArea->distanceThreshold() * 0.1f);

    QTest::touchEvent(view, device).press(0, touchPoint.toPoint());

    QCOMPARE(draggingSpy.count(), 1);
    QCOMPARE(edgeDragArea->dragging(), true);

    if (wideningAngleMultiplier > 0) {
        // go close to the border of the valid area for this touch point
        // in order to make it easier to leave it by dragging at an angle
        // slightly bigger than the widening angle
        touchPoint += createTouchDeviation(edgeDragArea);
        QTest::touchEvent(view, device).move(0, touchPoint.toPoint());
    }

    do {
        touchPoint += touchMovement;
        QTest::touchEvent(view, device).move(0, touchPoint.toPoint());
    } while ((touchPoint - initialTouchPos).manhattanLength() < desiredDragDistance);

    if (expectedGestureRecognition)
        QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Recognized);

    if (edgeDragArea->status() == DirectionalDragArea::Rejected) {
        QCOMPARE(edgeDragArea->dragging(), false);
        QCOMPARE(draggingSpy.count(), 2);
    }

    QTest::touchEvent(view, device).release(0, touchPoint.toPoint());

    QCOMPARE(draggingSpy.count(), 2);
    QCOMPARE(edgeDragArea->dragging(), false);
}

void tst_DirectionalDragArea::edgeDrag_data()
{
    QTest::addColumn<QString>("dragAreaObjectName");
    QTest::addColumn<qreal>("wideningAngleMultiplier");
    QTest::addColumn<qreal>("dragDistanceFactor");
    QTest::addColumn<int>("expectedGestureRecognition");

    QTest::newRow("rightwards, tiny drag")
        << "hpDragArea" << 0.0 << 0.2 << 0;

    QTest::newRow("rightwards, straight drag")
        << "hpDragArea" << 0.0 << 3.0 << 1;

    QTest::newRow("rightwards, diagonal drag")
        << "hpDragArea" << 0.9 << 3.0 << 1;

    QTest::newRow("rightwards, overly diagonal drag")
        << "hpDragArea" << 2.0 << 3.0 << 0;

    QTest::newRow("leftwards, tiny drag")
        << "hnDragArea" << 0.0 << 0.2 << 0;

    QTest::newRow("leftwards, straight drag")
        << "hnDragArea" << 0.0 << 3.0 << 1;

    QTest::newRow("leftwards, diagonal drag")
        << "hnDragArea" << 0.9 << 3.0 << 1;

    QTest::newRow("downwards, tiny drag")
        << "vpDragArea" << 0.0 << 0.2 << 0;

    QTest::newRow("downwards, straight drag")
        << "vpDragArea" << 0.0 << 3.0 << 1;

    QTest::newRow("downwards, diagonal drag")
        << "vpDragArea" << 0.9 << 3.0 << 1;

    QTest::newRow("upwards, tiny drag")
        << "vnDragArea" << 0.0 << 0.2 << 0;

    QTest::newRow("upwards, straight drag")
        << "vnDragArea" << 0.0 << 3.0 << 1;

    QTest::newRow("upwards, diagonal drag")
        << "vnDragArea" << 0.9 << 3.0 << 1;

    QTest::newRow("upwards, overly diagonal drag")
        << "vnDragArea" << 2.0 << 3.0 << 0;
}

/*
  A directional drag should still be recognized if there is a momentaneous, small,
  change in the direction of a drag. That should be accounted as input noise and
  therefore ignored.
 */
void tst_DirectionalDragArea::dragWithShortDirectionChange()
{
    DirectionalDragArea *edgeDragArea =
        view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea, view);
    QPointF touchPoint = initialTouchPos;

    qreal desiredDragDistance = edgeDragArea->distanceThreshold()*2.0;
    QPointF dragDirectionVector(1.0, 0.0);
    QPointF touchMovement = dragDirectionVector * (edgeDragArea->distanceThreshold() * 0.1f);

    QTest::touchEvent(view, device).press(0, touchPoint.toPoint());

    // Move a bit in the proper direction
    for (int i=0; i < 3; ++i) {
        touchPoint += touchMovement;
        QTest::touchEvent(view, device).move(0, touchPoint.toPoint());
    }

    // Then a sudden and small movement to the opposite direction
    touchPoint -= dragDirectionVector * (edgeDragArea->maxDeviation() * 0.7);
    QTest::touchEvent(view, device).move(0, touchPoint.toPoint());

    // And then resume movment in the correct direction until it crosses the distance threshold.
    do {
        touchPoint += touchMovement;
        QTest::touchEvent(view, device).move(0, touchPoint.toPoint());
    } while ((touchPoint - initialTouchPos).manhattanLength() < desiredDragDistance);

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Recognized);

    QTest::touchEvent(view, device).release(0, touchPoint.toPoint());
}

/*
   Checks that a gesture will be rejected if it's slower than minSpeed while
   status is Undecided.
 */
void tst_DirectionalDragArea::minSpeed()
{
    QFETCH(int, minSpeedMsecsDeviation);
    QFETCH(int, expectedStatusAfterSpeedCheck);

    DirectionalDragArea *edgeDragArea =
        view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea, view);
    QPointF touchPoint = initialTouchPos;

    QPointF dragDirectionVector(1.0, 0.0);
    qreal distanceStep = edgeDragArea->distanceThreshold() * 0.1f;
    QPointF touchMovement = dragDirectionVector * distanceStep;
    qreal minSpeedMsecs = edgeDragArea->minSpeed() / 1000.0;
    qint64 timeStepMsecs = qFloor(distanceStep / minSpeedMsecs) + minSpeedMsecsDeviation;

    // if it fails it means the params set in the QML file are not in harmony with the values
    // used in this test
    Q_ASSERT(timeStepMsecs > 0);

    fakeTimeSource->m_msecsSinceReference = 0;
    QTest::touchEvent(view, device).press(0, touchPoint.toPoint());

    // Move a bit in the proper direction
    for (int i=0; i < 4; ++i) {
        touchPoint += touchMovement;
        fakeTimeSource->m_msecsSinceReference += timeStepMsecs;
        QTest::touchEvent(view, device).move(0, touchPoint.toPoint());
    }

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Undecided);

    // Force the periodic speed check.
    fakeTimer->emitTimeout();

    QCOMPARE((int)edgeDragArea->status(), expectedStatusAfterSpeedCheck);
}

void tst_DirectionalDragArea::minSpeed_data()
{
    QTest::addColumn<int>("minSpeedMsecsDeviation");
    QTest::addColumn<int>("expectedStatusAfterSpeedCheck");

    QTest::newRow("slower than minSpeed") << 20 << (int)DirectionalDragArea::Rejected;
    QTest::newRow("faster than minSpeed") << -20 << (int)DirectionalDragArea::Undecided;
}

/*
    Checks that the recognition timer is started and stopped appropriately.
    I.e., check that it's running only while gesture recognition is taking place
    (status == Undecided)
 */
void tst_DirectionalDragArea::recognitionTimerUsage()
{
    DirectionalDragArea *edgeDragArea =
        view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea, view);
    QPointF touchPoint = initialTouchPos;

    QPointF dragDirectionVector(1.0, 0.0);
    QPointF touchMovement = dragDirectionVector * (edgeDragArea->distanceThreshold() * 0.2f);

    QVERIFY(!fakeTimer->isRunning());

    QTest::touchEvent(view, device).press(0, touchPoint.toPoint());

    QVERIFY(fakeTimer->isRunning());

    // Move a bit in the proper direction
    for (int i=0; i < 3; ++i) {
        touchPoint += touchMovement;
        QTest::touchEvent(view, device).move(0, touchPoint.toPoint());
    }

    QVERIFY(fakeTimer->isRunning());

    // Move beyond distance threshold
    touchPoint += 3*touchMovement;
    QTest::touchEvent(view, device).move(0, touchPoint.toPoint());

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
        view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF initialTouchPos = calculateInitialTouchPos(edgeDragArea, view);
    QPointF touchPoint = initialTouchPos;

    fakeTimeSource->m_msecsSinceReference = 0;
    QTest::touchEvent(view, device).press(0, touchPoint.toPoint());

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Undecided);

    int neededTimeouts = qCeil((qreal)edgeDragArea->maxSilenceTime() / (qreal)fakeTimer->interval());
    if ((edgeDragArea->maxSilenceTime() % fakeTimer->interval()) == 0) {
        ++neededTimeouts;
    }

    // Force the periodic speed check.
    for (int i = 0; i < neededTimeouts; ++i) {
        fakeTimer->emitTimeout();

        if (i < neededTimeouts - 1) {
            QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Undecided);
        }
    }

    QCOMPARE((int)edgeDragArea->status(), (int)DirectionalDragArea::Rejected);
}

/*
  Checks that it informs the X coordinate of the touch point in local and scene coordinates
  correctly.
 */
void tst_DirectionalDragArea::sceneXAndX()
{
    DirectionalDragArea *edgeDragArea =
        view->rootObject()->findChild<DirectionalDragArea*>("hnDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF touchScenePos(view->width() - (edgeDragArea->width()/2.0f), view->height()/2.0f);

    fakeTimeSource->m_msecsSinceReference = 0;
    QTest::touchEvent(view, device).press(0, touchScenePos.toPoint());

    QSignalSpy touchXSpy(edgeDragArea, SIGNAL(touchXChanged(qreal)));
    QSignalSpy touchSceneXSpy(edgeDragArea, SIGNAL(touchSceneXChanged(qreal)));

    touchScenePos.rx() = view->width() / 2;
    QTest::touchEvent(view, device).move(0, touchScenePos.toPoint());

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
        view->rootObject()->findChild<DirectionalDragArea*>("vnDragArea");
    QVERIFY(edgeDragArea != 0);
    edgeDragArea->setRecognitionTimer(fakeTimer);
    edgeDragArea->setTimeSource(fakeTimeSource);

    QPointF touchScenePos(view->width()/2.0f, view->height() - (edgeDragArea->height()/2.0f));

    fakeTimeSource->m_msecsSinceReference = 0;
    QTest::touchEvent(view, device).press(0, touchScenePos.toPoint());

    QSignalSpy touchYSpy(edgeDragArea, SIGNAL(touchYChanged(qreal)));
    QSignalSpy touchSceneYSpy(edgeDragArea, SIGNAL(touchSceneYChanged(qreal)));

    touchScenePos.ry() = view->height() / 2;
    QTest::touchEvent(view, device).move(0, touchScenePos.toPoint());

    QCOMPARE(touchYSpy.count(), 1);
    QCOMPARE(touchSceneYSpy.count(), 1);
    QCOMPARE(edgeDragArea->touchY(), touchScenePos.y() - edgeDragArea->y());
    QCOMPARE(edgeDragArea->touchSceneY(), touchScenePos.y());
}

QTEST_MAIN(tst_DirectionalDragArea)

#include "tst_DirectionalDragArea.moc"
