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

#include <functional>
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

class tst_DragHandle: public QObject
{
    Q_OBJECT
public:
    tst_DragHandle() : device(0) { }
private Q_SLOTS:
    void initTestCase(); // will be called before the first test function is executed
    void cleanupTestCase(); // will be called after the last test function was executed.

    void init(); // called right before each and every test function is executed
    void cleanup(); // called right after each and every test function is executed

    void dragThreshold_horizontal();
    void dragThreshold_vertical();

private:
    void flickAndHold(DirectionalDragArea *dragHandle, qreal distance);
    DirectionalDragArea *fetchAndSetupDragHandle(const char *objectName);
    qreal fetchDragThreshold(DirectionalDragArea *dragHandle);
    void tryCompare(std::function<qreal ()> actualFunc, qreal expectedValue);

    QQuickView *createView();
    QQuickView *view;
    QTouchDevice *device;
    FakeTimer *fakeTimer;
    FakeTimeSource *fakeTimeSource;
};


void tst_DragHandle::initTestCase()
{
    if (!device) {
        device = new QTouchDevice;
        device->setType(QTouchDevice::TouchScreen);
        QWindowSystemInterface::registerTouchDevice(device);
    }

    view = 0;
}

void tst_DragHandle::cleanupTestCase()
{
}

void tst_DragHandle::init()
{
    view = createView();
    view->setSource(QUrl::fromLocalFile(TEST_DIR"/tst_DragHandle.qml"));
    view->show();
    QVERIFY(QTest::qWaitForWindowExposed(view));
    QVERIFY(view->rootObject() != 0);
    qApp->processEvents();

    fakeTimer = new FakeTimer;
    fakeTimeSource = new FakeTimeSource;
}

void tst_DragHandle::cleanup()
{
    delete view;
    view = 0;

    delete fakeTimer;
    fakeTimer = 0;

    delete fakeTimeSource;
    fakeTimeSource = 0;
}

QQuickView *tst_DragHandle::createView()
{
    QQuickView *window = new QQuickView(0);
    window->setResizeMode(QQuickView::SizeRootObjectToView);
    window->resize(600, 600);
    window->engine()->addImportPath(QLatin1String(UBUNTU_GESTURES_PLUGIN_DIR));
    window->engine()->addImportPath(QLatin1String(TEST_DIR));

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
QPointF calculateDirectionVector(DirectionalDragArea *edgeDragArea)
{

    switch (edgeDragArea->direction()) {
        case Direction::Upwards:
            return QPointF(0, -1);
        case Direction::Downwards:
            return QPointF(0, 1);
        case Direction::Leftwards:
            return QPointF(-1, 0);
        default: // Direction::Rightwards:
            return QPointF(1, 0);
    }
}
}

void tst_DragHandle::flickAndHold(DirectionalDragArea *dragHandle,
                                  qreal distance)
{
    QPointF initialTouchPos = dragHandle->mapToScene(
        QPointF(dragHandle->width() / 2.0, dragHandle->height() / 2.0));
    QPointF touchPoint = initialTouchPos;
    int numSteps = 10;
    qint64 flickTimeMs = 500;
    qint64 timeStep = flickTimeMs / numSteps;

    QPointF dragDirectionVector = calculateDirectionVector(dragHandle);
    QPointF touchMovement = dragDirectionVector * (distance / (qreal)numSteps);

    QTest::touchEvent(view, device).press(0, touchPoint.toPoint());

    for (int i = 0; i < numSteps; ++i) {
        touchPoint += touchMovement;
        fakeTimeSource->m_msecsSinceReference += timeStep;
        QTest::touchEvent(view, device).move(0, touchPoint.toPoint());
    }

    // Wait for quite a bit before finally releasing to make a very low flick/release
    // speed.
    fakeTimeSource->m_msecsSinceReference += 5000;
    QTest::touchEvent(view, device).release(0, touchPoint.toPoint());
}

DirectionalDragArea *tst_DragHandle::fetchAndSetupDragHandle(const char *objectName)
{
    DirectionalDragArea *dragHandle =
        view->rootObject()->findChild<DirectionalDragArea*>(objectName);
    Q_ASSERT(dragHandle != 0);
    dragHandle->setRecognitionTimer(fakeTimer);
    dragHandle->setTimeSource(fakeTimeSource);

    AxisVelocityCalculator *edgeDragEvaluator =
        dragHandle->findChild<AxisVelocityCalculator*>("edgeDragEvaluator");
    Q_ASSERT(edgeDragEvaluator != 0);
    edgeDragEvaluator->setTimeSource(fakeTimeSource);

    return dragHandle;
}

qreal tst_DragHandle::fetchDragThreshold(DirectionalDragArea *dragHandle)
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
    DirectionalDragArea *dragHandle = fetchAndSetupDragHandle("rightwardsDragHandle");

    qreal dragThreshold = fetchDragThreshold(dragHandle);

    // end before the threshold
    flickAndHold(dragHandle, dragThreshold * 0.7);

    // should rollback
    QQuickItem *parentItem = dragHandle->parentItem();
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

void tst_DragHandle::dragThreshold_vertical()
{
    DirectionalDragArea *dragHandle = fetchAndSetupDragHandle("downwardsDragHandle");

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

    dragHandle = fetchAndSetupDragHandle("upwardsDragHandle");

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

QTEST_MAIN(tst_DragHandle)

#include "tst_DragHandle.moc"
