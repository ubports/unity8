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

class tst_DirectionalDragArea: public QObject
{
    Q_OBJECT
public:
    tst_DirectionalDragArea() : device(0) { }
private Q_SLOTS:
    void initTestCase(); // will be called before the first test function is executed
    void cleanupTestCase(); // will be called after the last test function was executed.

    void edgeDrag();
    void edgeDrag_data();
    void dragWithShortDirectionChange();

private:
    QQuickView *createView();
    QTouchDevice *device;
};

void tst_DirectionalDragArea::initTestCase()
{
    if (!device) {
        device = new QTouchDevice;
        device->setType(QTouchDevice::TouchScreen);
        QWindowSystemInterface::registerTouchDevice(device);
    }
}

void tst_DirectionalDragArea::cleanupTestCase()
{
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
        case DirectionalDragArea::Upwards:
            return QPointF(view->width()/2.0f, view->height() - (edgeDragArea->height()/2.0f));
        case DirectionalDragArea::Downwards:
            return QPointF(view->width()/2.0f, edgeDragArea->height()/2.0f);
        case DirectionalDragArea::Leftwards:
            return QPointF(view->width() - (edgeDragArea->width()/2.0f), view->height()/2.0f);
        default: // DirectionalDragArea::Rightwards:
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
        case DirectionalDragArea::Upwards:
            return QPointF(angleSin, -angleCos);
        case DirectionalDragArea::Downwards:
            return QPointF(angleSin, angleCos);
        case DirectionalDragArea::Leftwards:
            return QPointF(-angleCos, angleSin);
        default: // DirectionalDragArea::Rightwards:
            return QPointF(angleCos, angleSin);
    }
}

QPointF createTouchDeviation(DirectionalDragArea *edgeDragArea)
{
    qreal deviation = edgeDragArea->maxDeviation() * 0.8;

    if (edgeDragArea->direction() == DirectionalDragArea::Leftwards
            || edgeDragArea->direction() == DirectionalDragArea::Rightwards) {
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

    QQuickView *view = createView();
    QScopedPointer<QQuickView> scope(view);
    view->setSource(QUrl::fromLocalFile("edgeDragExample.qml"));
    view->show();
    QVERIFY(QTest::qWaitForWindowExposed(view));
    QVERIFY(view->rootObject() != 0);
    qApp->processEvents();

    DirectionalDragArea *edgeDragArea =
        view->rootObject()->findChild<DirectionalDragArea*>(dragAreaObjectName);
    QVERIFY(edgeDragArea != 0);

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
    QQuickView *view = createView();
    QScopedPointer<QQuickView> scope(view);
    view->setSource(QUrl::fromLocalFile("edgeDragExample.qml"));
    view->show();
    QVERIFY(QTest::qWaitForWindowExposed(view));
    QVERIFY(view->rootObject() != 0);
    qApp->processEvents();

    DirectionalDragArea *edgeDragArea =
        view->rootObject()->findChild<DirectionalDragArea*>("hpDragArea");
    QVERIFY(edgeDragArea != 0);

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

QTEST_MAIN(tst_DirectionalDragArea)

#include "tst_DirectionalDragArea.moc"
