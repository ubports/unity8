/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

#include <qpa/qwindowsysteminterface.h>
#include <QtTest>
#include <QQmlEngine>
#include <QQuickView>
#include <QSharedPointer>
#include <private/qquickanimatorcontroller_p.h>
#include <private/qquickwindow_p.h>

// C++ std lib
#include <functional>

#include <TouchGate.h>
#include <UbuntuGestures/private/touchregistry_p.h>

#include "TestItem.h"

#include <paths.h>

UG_USE_NAMESPACE

class CandidateItem : public QQuickItem
{
    Q_OBJECT

public:
    std::function<void(QTouchEvent*)> touchEventHandler;

protected:
    void touchEvent(QTouchEvent *event) override;
};

class tst_TouchGate : public QObject
{
    Q_OBJECT
public:
    tst_TouchGate(QObject *parent = nullptr);
private Q_SLOTS:
    void initTestCase(); // will be called before the first test function is executed
    void cleanupTestCase(); // will be called after the last test function was executed.

    void init(); // called right before each and every test function is executed
    void cleanup(); // called right after each and every test function is executed

private:
    void onlyCandidate_passThrough();
    void holdsEventsUntilGainsOwnership();
    void holdsEventsUntilGainsOwnership_data();
    void holdsEventsUntilGainsOwnership_repeatingTouchId();
    void dontDispacthToDisabledOrInvisibleTarget();
    void dontDispacthToDisabledOrInvisibleTarget_data();

private Q_SLOTS:
    void disabledWhileHoldingTouch();

private:
    QQuickView *createView();
    TouchRegistry *touchRegistry;
    QQuickView *view;
    QTouchDevice *device;
};

tst_TouchGate::tst_TouchGate(QObject *parent)
    : QObject(parent)
    , touchRegistry(nullptr)
    , view(nullptr)
    , device(nullptr)
{
}

void tst_TouchGate::initTestCase()
{
    if (!device) {
        device = new QTouchDevice;
        device->setType(QTouchDevice::TouchScreen);
        QWindowSystemInterface::registerTouchDevice(device);
    }
}

void tst_TouchGate::cleanupTestCase()
{
}

void tst_TouchGate::init()
{
    touchRegistry = TouchRegistry::instance();

    view = createView();
    view->setSource(QUrl::fromLocalFile(testDataDir() + "/plugins/Ubuntu/Gestures/touchGateExample.qml"));
    view->show();
    QVERIFY(QTest::qWaitForWindowExposed(view));
    QVERIFY(view->rootObject() != 0);
    qApp->processEvents();
}

void tst_TouchGate::cleanup()
{
    delete view;
    view = 0;

    delete touchRegistry;
    touchRegistry = nullptr;
}

QQuickView *tst_TouchGate::createView()
{
    QQuickView *window = new QQuickView(0);
    window->setResizeMode(QQuickView::SizeRootObjectToView);
    window->resize(720, 720);

    return window;
}

/*
 Simplest case. TouchGate is the only candidate for the touch point, thus it
 will instantly gain ownership causing the event to pass through it directly to
 its child.
 */
void tst_TouchGate::onlyCandidate_passThrough()
{
    TouchGate *touchGate = view->rootObject()->findChild<TouchGate*>("touchGate");
    Q_ASSERT(touchGate);

    TestItem *testItem = new TestItem;
    testItem->setWidth(touchGate->width());
    testItem->setHeight(touchGate->height());
    testItem->setParentItem(view->rootObject());
    testItem->setZ(0.0);

    touchGate->setZ(1.0);
    touchGate->setTargetItem(testItem);

    QTest::touchEvent(view, device)
        .press(0, QPoint(100,100));

    QCOMPARE(testItem->touchEventsReceived.count(), 1);
    QVERIFY(touchGate->m_storedEvents.isEmpty());
}

void tst_TouchGate::holdsEventsUntilGainsOwnership()
{
    TouchGate *touchGate = view->rootObject()->findChild<TouchGate*>("touchGate");
    Q_ASSERT(touchGate);
    QFETCH(bool, ownershipAfterTouchEnd);

    TestItem *testItem = new TestItem;
    testItem->setWidth(touchGate->width());
    testItem->setHeight(touchGate->height());
    testItem->setParentItem(view->rootObject());
    testItem->setZ(0.0);

    touchGate->setZ(1.0);
    touchGate->setTargetItem(testItem);

    // Put it in front of touchGate
    CandidateItem *candidateItem = new CandidateItem;
    candidateItem->setWidth(touchGate->width());
    candidateItem->setHeight(touchGate->height());
    candidateItem->setParentItem(view->rootObject());
    candidateItem->setZ(2.0);

    candidateItem->touchEventHandler = [&](QTouchEvent* event) {
        touchRegistry->addCandidateOwnerForTouch(0, candidateItem);
        event->ignore();
    };

    QTest::touchEvent(view, device)
        .press(0, QPoint(100,100));

    QCOMPARE(testItem->touchEventsReceived.count(), 0);

    QTest::touchEvent(view, device)
        .move(0, QPoint(101,101));

    QCOMPARE(testItem->touchEventsReceived.count(), 0);

    if (!ownershipAfterTouchEnd) {
        touchRegistry->removeCandidateOwnerForTouch(0, candidateItem);
        QQuickWindowPrivate *wp = QQuickWindowPrivate::get(testItem->window());
        if (wp->delayedTouch) {
            wp->deliverDelayedTouchEvent();

            // Touch events which constantly start animations (such as a behavior tracking
            // the mouse point) need animations to start.
            QQmlAnimationTimer *ut = QQmlAnimationTimer::instance();
            if (ut && ut->hasStartAnimationPending())
                ut->startAnimations();
        }
        // TouchGate should now open its flood gates and let testItem get all
        // events from touch 0 produced so far
        QCOMPARE(testItem->touchEventsReceived.count(), 2);
    }

    QTest::touchEvent(view, device)
        .release(0, QPoint(101,101));

    if (ownershipAfterTouchEnd) {
        QCOMPARE(testItem->touchEventsReceived.count(), 0);
        touchRegistry->removeCandidateOwnerForTouch(0, candidateItem);
        // TouchGate should now open its flood gates and let testItem get all
        // events from touch 0 produced so far
    }

    QCOMPARE(testItem->touchEventsReceived.count(), 3);

    QVERIFY(touchGate->m_storedEvents.isEmpty());
    QVERIFY(touchGate->m_touchInfoMap.isEmpty());
}

void tst_TouchGate::holdsEventsUntilGainsOwnership_data()
{
    QTest::addColumn<bool>("ownershipAfterTouchEnd");

    QTest::newRow("touch end after touch ownership") << false;
    QTest::newRow("touch ownership after touch end") << true;
}

/*
    A touch point of id 0 starts and ends. Then the next touch point is also given
    id 0. Check that TouchGate behaves correcly recognizing them as two distinct touch
    points.

    Note that this won't be a problem with Mir as it assigns unique ids for the touch
    points it produces.
 */
void tst_TouchGate::holdsEventsUntilGainsOwnership_repeatingTouchId()
{
    TouchGate *touchGate = view->rootObject()->findChild<TouchGate*>("touchGate");
    Q_ASSERT(touchGate);

    TestItem *testItem = new TestItem;
    testItem->setWidth(touchGate->width());
    testItem->setHeight(touchGate->height());
    testItem->setParentItem(view->rootObject());
    testItem->setZ(0.0);

    touchGate->setZ(1.0);
    touchGate->setTargetItem(testItem);

    QTest::touchEvent(view, device)
        .press(0, QPoint(100,100));
    QTest::touchEvent(view, device)
        .move(0, QPoint(101,101));
    QTest::touchEvent(view, device)
        .release(0, QPoint(101,101));

    QCOMPARE(testItem->touchEventsReceived.count(), 3);
    testItem->touchEventsReceived.clear();

    // Put it in front of touchGate
    CandidateItem *candidateItem = new CandidateItem;
    candidateItem->setWidth(touchGate->width());
    candidateItem->setHeight(touchGate->height());
    candidateItem->setParentItem(view->rootObject());
    candidateItem->setZ(2.0);

    candidateItem->touchEventHandler = [&](QTouchEvent* event) {
        touchRegistry->addCandidateOwnerForTouch(0, candidateItem);
        event->ignore();
    };

    // A brand new touch, but with the same id as the previous one
    QTest::touchEvent(view, device)
        .press(0, QPoint(200,200));
    QTest::touchEvent(view, device)
        .move(0, QPoint(201,201));
    QTest::touchEvent(view, device)
        .release(0, QPoint(201,201));

    QCOMPARE(testItem->touchEventsReceived.count(), 0);

    touchRegistry->requestTouchOwnership(0, candidateItem);

    QCOMPARE(testItem->touchEventsReceived.count(), 0);

    QVERIFY(touchGate->m_storedEvents.isEmpty());
}

void tst_TouchGate::dontDispacthToDisabledOrInvisibleTarget()
{
    TouchGate *touchGate = view->rootObject()->findChild<TouchGate*>("touchGate");
    Q_ASSERT(touchGate);

    TestItem *testItem = new TestItem;
    testItem->setWidth(touchGate->width());
    testItem->setHeight(touchGate->height());
    testItem->setParentItem(view->rootObject());
    testItem->setZ(0.0);

    QFETCH(bool, isEnabled);
    testItem->setEnabled(isEnabled);

    QFETCH(bool, isVisible);
    testItem->setVisible(isVisible);

    touchGate->setZ(1.0);
    touchGate->setTargetItem(testItem);

    QTest::touchEvent(view, device)
        .press(0, QPoint(100,100));

    QCOMPARE(testItem->touchEventsReceived.count(), 0);
    QVERIFY(touchGate->m_storedEvents.isEmpty());
}

void tst_TouchGate::dontDispacthToDisabledOrInvisibleTarget_data()
{
    QTest::addColumn<bool>("isEnabled");
    QTest::addColumn<bool>("isVisible");

    QTest::newRow("disabled visible") << false << true;
    QTest::newRow("enabled invisible") << true << false;
    QTest::newRow("disabled invisible") << false << false;
}

void tst_TouchGate::disabledWhileHoldingTouch()
{
    TouchGate *touchGate = view->rootObject()->findChild<TouchGate*>("touchGate");
    Q_ASSERT(touchGate);

    TestItem *testItem = new TestItem;
    testItem->setWidth(touchGate->width());
    testItem->setHeight(touchGate->height());
    testItem->setParentItem(view->rootObject());
    testItem->setZ(0.0);

    touchGate->setZ(1.0);
    touchGate->setTargetItem(testItem);

    QTest::touchEvent(view, device)
        .press(0, QPoint(100,100));

    QCOMPARE(testItem->touchEventsReceived.count(), 1);
    testItem->touchEventsReceived.clear();

    touchGate->setEnabled(false);

    QTest::touchEvent(view, device)
        .move(0, QPoint(101,101));

    // Nothing new came as TouchGate didn't even get it because it's disabled
    QCOMPARE(testItem->touchEventsReceived.count(), 0);

    touchGate->setEnabled(true);

    QTest::touchEvent(view, device)
        .move(0, QPoint(102,102));

    QTest::touchEvent(view, device)
        .release(0, QPoint(102,102));

    // Nothing new came because TouchGate has already discarded touch 0
    QCOMPARE(testItem->touchEventsReceived.count(), 0);

    QTest::touchEvent(view, device)
        .press(1, QPoint(200,200));

    QCOMPARE(testItem->touchEventsReceived.count(), 1);
    {
        // it got only the new touch point.
        QSharedPointer<QTouchEvent> touchEvent = testItem->touchEventsReceived[0];
        QCOMPARE(touchEvent->touchPoints().count(), 1);
        QCOMPARE(touchEvent->touchPoints()[0].id(), 1);
    }
}

///////////// CandidateItem /////////////////////////////////////////////////////////////

void CandidateItem::touchEvent(QTouchEvent *event)
{
    touchEventHandler(event);
}


QTEST_MAIN(tst_TouchGate)

#include "tst_TouchGate.moc"
