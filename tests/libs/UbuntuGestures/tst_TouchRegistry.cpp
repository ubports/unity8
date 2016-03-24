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

#include <QtTest>
#include <QSet>
#include <QTouchEvent>

#include <Timer.h>
#include <TouchOwnershipEvent.h>
#include <TouchRegistry.h>
#include <UnownedTouchEvent.h>

using namespace UbuntuGestures;

class TouchMemento {
public:
    TouchMemento(const QTouchEvent *touchEvent);
    Qt::TouchPointStates touchPointStates;
    QList<QTouchEvent::TouchPoint> touchPoints;

    bool containsTouchWithId(int touchId) const;
};

class DummyCandidate : public QQuickItem
{
    Q_OBJECT
public:
    bool event(QEvent *e) override;
    QSet<int> ownedTouches;
    QSet<int> lostTouches;
    QList<TouchMemento> unownedTouchEvents;

Q_SIGNALS:
    void gainedOwnership();
    void lostOwnership();
};

class tst_TouchRegistry : public QObject
{
    Q_OBJECT
public:
    tst_TouchRegistry() : QObject(0) { }
private Q_SLOTS:
    void initTestCase() {} // will be called before the first test function is executed
    void cleanupTestCase() {} // will be called after the last test function was executed.

    void init(); // called right before each and every test function is executed
    void cleanup(); // called right after each and every test function is executed

    void requestWithNoCandidates();
    void lateCandidateRequestGetsNothing();
    void lateCandidateGestOwnershipOnceEarlyCandidateQuits();
    void dispatchesTouchEventsToCandidates();
    void dispatchesTouchEventsToWatchers();
    void keepDispatchingToWatchersAfterLastCandidateGivesUp();
    void candidatesAndWatchers_1();
    void candidatesAndWatchers_2();
    void rejectingTouchfterItsEnd();
    void removeOldUndecidedCandidates();
    void interimOwnerWontGetUnownedTouchEvents();
    void candidateVanishes();
    void candicateOwnershipReentrace();

private:
    TouchRegistry *touchRegistry;
};

void tst_TouchRegistry::init()
{
    touchRegistry = TouchRegistry::instance();
}

void tst_TouchRegistry::cleanup()
{
    delete touchRegistry;
}

void tst_TouchRegistry::requestWithNoCandidates()
{
    DummyCandidate candidate;

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->requestTouchOwnership(0, &candidate);

    QVERIFY(candidate.ownedTouches.contains(0));
}

void tst_TouchRegistry::lateCandidateRequestGetsNothing()
{
    DummyCandidate earlyCandidate;
    earlyCandidate.setObjectName("early");
    DummyCandidate lateCandidate;
    lateCandidate.setObjectName("late");

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addCandidateOwnerForTouch(0, &earlyCandidate);
    touchRegistry->addCandidateOwnerForTouch(0, &lateCandidate);

    QVERIFY(earlyCandidate.ownedTouches.isEmpty());
    QVERIFY(lateCandidate.ownedTouches.isEmpty());

    touchRegistry->requestTouchOwnership(0, &lateCandidate);

    QVERIFY(earlyCandidate.ownedTouches.isEmpty());
    QVERIFY(lateCandidate.ownedTouches.isEmpty());

    touchRegistry->requestTouchOwnership(0, &earlyCandidate);

    QVERIFY(earlyCandidate.ownedTouches.contains(0));
    QVERIFY(lateCandidate.ownedTouches.isEmpty());
}

void tst_TouchRegistry::lateCandidateGestOwnershipOnceEarlyCandidateQuits()
{
    DummyCandidate earlyCandidate;
    DummyCandidate lateCandidate;

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addCandidateOwnerForTouch(0, &earlyCandidate);
    touchRegistry->addCandidateOwnerForTouch(0, &lateCandidate);

    QVERIFY(earlyCandidate.ownedTouches.isEmpty());
    QVERIFY(lateCandidate.ownedTouches.isEmpty());

    touchRegistry->requestTouchOwnership(0, &lateCandidate);

    QVERIFY(earlyCandidate.ownedTouches.isEmpty());
    QVERIFY(lateCandidate.ownedTouches.isEmpty());

    touchRegistry->removeCandidateOwnerForTouch(0, &earlyCandidate);

    QVERIFY(earlyCandidate.ownedTouches.isEmpty());
    QVERIFY(lateCandidate.ownedTouches.contains(0));
}

void tst_TouchRegistry::dispatchesTouchEventsToCandidates()
{
    QQuickItem rootItem;

    DummyCandidate candidate0;
    candidate0.setObjectName("0");
    candidate0.setParentItem(&rootItem);
    candidate0.setX(1);
    candidate0.setY(2);

    DummyCandidate candidate1;
    candidate1.setObjectName("1");
    candidate0.setParentItem(&rootItem);
    candidate1.setX(3);
    candidate1.setY(4);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        touchPoints[0].setRect(QRect(10, 10, 0, 0));
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addCandidateOwnerForTouch(0, &candidate0);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        touchPoints[0].setRect(QRect(11, 11, 0, 0));
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointPressed);
        touchPoints[1].setRect(QRect(20, 20, 0, 0));
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed | Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    // candidate0 should have received an update on the touch he's interested on.
    QCOMPARE(candidate0.unownedTouchEvents.count(), 1);
    // make sure only touch 0 is there (i.e. no mention of touch 1)
    QCOMPARE(candidate0.unownedTouchEvents[0].touchPoints.count(), 1);
    QCOMPARE(candidate0.unownedTouchEvents[0].touchPoints[0].id(), 0);
    // Check that the points local coordinates have been mapped to candidate0's coordinate system.
    QCOMPARE(candidate0.unownedTouchEvents[0].touchPoints[0].rect().x(), 11 - candidate0.x());
    QCOMPARE(candidate0.unownedTouchEvents[0].touchPoints[0].rect().y(), 11 - candidate0.y());

    touchRegistry->addCandidateOwnerForTouch(1, &candidate1);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        touchPoints[0].setRect(QRect(12, 12, 0, 0));
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointMoved);
        touchPoints[1].setRect(QRect(21, 21, 0, 0));
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed | Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    // candidate0 gets updates only for touch 0 and
    // candidate1 gets updates only for touch 1

    QCOMPARE(candidate0.unownedTouchEvents.count(), 2);
    QCOMPARE(candidate0.unownedTouchEvents[1].touchPoints.count(), 1);
    QCOMPARE(candidate0.unownedTouchEvents[1].touchPoints[0].id(), 0);

    QCOMPARE(candidate1.unownedTouchEvents.count(), 1);
    QCOMPARE(candidate1.unownedTouchEvents[0].touchPoints.count(), 1);
    QCOMPARE(candidate1.unownedTouchEvents[0].touchPoints[0].id(), 1);
}

void tst_TouchRegistry::dispatchesTouchEventsToWatchers()
{
    QQuickItem rootItem;

    DummyCandidate watcher;
    watcher.setObjectName("watcher");
    watcher.setParentItem(&rootItem);
    watcher.setX(1);
    watcher.setY(2);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        touchPoints[0].setRect(QRect(10, 10, 0, 0));
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addTouchWatcher(0, &watcher);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        touchPoints[0].setRect(QRect(11, 11, 0, 0));
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointPressed);
        touchPoints[1].setRect(QRect(20, 20, 0, 0));
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed | Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    // watcher should have received an update on the touch he's interested on.
    QCOMPARE(watcher.unownedTouchEvents.count(), 1);
    // make sure only touch 0 is there (i.e. no mention of touch 1)
    QCOMPARE(watcher.unownedTouchEvents[0].touchPoints.count(), 1);
    QCOMPARE(watcher.unownedTouchEvents[0].touchPoints[0].id(), 0);
    // Check that the points local coordinates have been mapped to watcher's coordinate system.
    QCOMPARE(watcher.unownedTouchEvents[0].touchPoints[0].rect().x(), 11 - watcher.x());
    QCOMPARE(watcher.unownedTouchEvents[0].touchPoints[0].rect().y(), 11 - watcher.y());

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        touchPoints[0].setRect(QRect(12, 12, 0, 0));
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointMoved);
        touchPoints[1].setRect(QRect(21, 21, 0, 0));
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed | Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    // watcher gets updates only for touch 0

    QCOMPARE(watcher.unownedTouchEvents.count(), 2);
    QCOMPARE(watcher.unownedTouchEvents[1].touchPoints.count(), 1);
    QCOMPARE(watcher.unownedTouchEvents[1].touchPoints[0].id(), 0);
}

void tst_TouchRegistry::keepDispatchingToWatchersAfterLastCandidateGivesUp()
{
    DummyCandidate item;

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addCandidateOwnerForTouch(0, &item);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed | Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    QCOMPARE(item.unownedTouchEvents.count(), 1);
    QCOMPARE(item.unownedTouchEvents[0].touchPoints.count(), 1);
    QCOMPARE(item.unownedTouchEvents[0].touchPoints[0].id(), 0);
    item.unownedTouchEvents.clear();

    touchRegistry->addTouchWatcher(1, &item);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointMoved);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    QCOMPARE(item.unownedTouchEvents.count(), 1);
    QCOMPARE(item.unownedTouchEvents[0].touchPoints.count(), 2);
    QVERIFY(item.unownedTouchEvents[0].containsTouchWithId(0));
    QVERIFY(item.unownedTouchEvents[0].containsTouchWithId(1));
    item.unownedTouchEvents.clear();

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointReleased);
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointMoved);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointReleased | Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    QCOMPARE(item.unownedTouchEvents.count(), 1);
    QCOMPARE(item.unownedTouchEvents[0].touchPoints.count(), 2);
    QVERIFY(item.unownedTouchEvents[0].containsTouchWithId(0));
    QVERIFY(item.unownedTouchEvents[0].containsTouchWithId(1));
    item.unownedTouchEvents.clear();

    touchRegistry->removeCandidateOwnerForTouch(0, &item);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[0].setState(Qt::TouchPointReleased);
        QTouchEvent touchEvent(QEvent::TouchEnd,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointReleased,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    QCOMPARE(item.unownedTouchEvents.count(), 1);
    QCOMPARE(item.unownedTouchEvents[0].touchPoints.count(), 1);
    QVERIFY(item.unownedTouchEvents[0].containsTouchWithId(1));
    item.unownedTouchEvents.clear();

    QVERIFY(touchRegistry->m_touchInfoPool.isEmpty());
}

/*
  Regression test that reproduces a problematic scenario that came up during manual testing.
  It reproduces the interaction between TouchRegistry and a DirectionalDragArea
 */
void tst_TouchRegistry::candidatesAndWatchers_1()
{
    DummyCandidate item;

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addCandidateOwnerForTouch(0, &item);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed | Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addTouchWatcher(1, &item);

    touchRegistry->removeCandidateOwnerForTouch(0, &item);

    touchRegistry->addTouchWatcher(0, &item);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointReleased);
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointMoved);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointReleased | Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[0].setState(Qt::TouchPointReleased);
        QTouchEvent touchEvent(QEvent::TouchEnd,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointReleased,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    QVERIFY(touchRegistry->m_touchInfoPool.isEmpty());

    item.unownedTouchEvents.clear();

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    // Haven't made any subscription for that new touch 0.
    QCOMPARE(item.unownedTouchEvents.count(), 0);
}

/*
  Regression test that reproduces a problematic scenario that came up during manual testing.
  It reproduces the interaction between TouchRegistry, DirectionalDragArea and a TouchGate.
 */
void tst_TouchRegistry::candidatesAndWatchers_2()
{
    DummyCandidate directionalDragArea;
    directionalDragArea.setObjectName("DirectionalDragArea");

    DummyCandidate touchGate;
    touchGate.setObjectName("TouchGate");

    // [DDA] 1298 TouchBegin (id:0, state:pressed, scenePos:(147,1023))
    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    // [TouchRegistry] addCandidateOwnerForTouch id 0 candidate DirectionalDragArea
    touchRegistry->addCandidateOwnerForTouch(0, &directionalDragArea);

    // [TouchRegistry] requestTouchOwnership id  0 candidate TouchGate
    touchRegistry->requestTouchOwnership(0, &touchGate);

    //[TouchRegistry] got TouchUpdate (id:0, state:moved, scenePos:(147,1023)) (id:1, state:pressed, scenePos:(327,792))
    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed | Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    // [TouchRegistry] addTouchWatcher id 1 watcher DirectionalDragArea
    touchRegistry->addTouchWatcher(1, &directionalDragArea);

    // [TouchRegistry] removeCandidateOwnerForTouch id 0 candidate DirectionalDragArea
    touchRegistry->removeCandidateOwnerForTouch(0, &directionalDragArea);

    //[TouchRegistry] sending TouchWonershipEvent(id = 0  gained) to candidate TouchGate
    QCOMPARE(touchGate.ownedTouches.count(), 1);
    QVERIFY(touchGate.ownedTouches.contains(0));

    // [TouchRegistry] addTouchWatcher id 0 watcher DirectionalDragArea
    touchRegistry->addTouchWatcher(0, &directionalDragArea);

    // [TouchRegistry] requestTouchOwnership id  1 candidate TouchGate
    touchRegistry->requestTouchOwnership(1, &touchGate);

    //[TouchRegistry] sending TouchWonershipEvent(id = 1  gained) to candidate TouchGate
    QCOMPARE(touchGate.ownedTouches.count(), 2);
    QVERIFY(touchGate.ownedTouches.contains(1));

    directionalDragArea.unownedTouchEvents.clear();
    touchGate.unownedTouchEvents.clear();

    //[TouchRegistry] got TouchUpdate (id:0, state:moved, scenePos:(148,1025)) (id:1, state:moved, scenePos:(329,795))
    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointMoved);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    //vvvvv  DDA Watchers are being ignored from now on vvvvvvv

    QCOMPARE(directionalDragArea.unownedTouchEvents.count(), 1);
    QCOMPARE(directionalDragArea.unownedTouchEvents.first().touchPoints.count(), 2);
    QVERIFY(directionalDragArea.unownedTouchEvents.first().containsTouchWithId(0));
    QVERIFY(directionalDragArea.unownedTouchEvents.first().containsTouchWithId(1));

    QVERIFY(touchGate.unownedTouchEvents.isEmpty());

    directionalDragArea.unownedTouchEvents.clear();

    //[TouchRegistry] got TouchUpdate (id:0, state:moved, scenePos:(151,1029)) (id:1, state:released, scenePos:(329,795))
    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        touchPoints.append(QTouchEvent::TouchPoint(1));
        touchPoints[1].setState(Qt::TouchPointReleased);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointMoved | Qt::TouchPointReleased,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    QCOMPARE(directionalDragArea.unownedTouchEvents.count(), 1);
    QCOMPARE(directionalDragArea.unownedTouchEvents.first().touchPoints.count(), 2);
    QVERIFY(directionalDragArea.unownedTouchEvents.first().containsTouchWithId(0));
    QVERIFY(directionalDragArea.unownedTouchEvents.first().containsTouchWithId(1));

    QVERIFY(touchGate.unownedTouchEvents.isEmpty());

    directionalDragArea.unownedTouchEvents.clear();

    //[TouchRegistry] got TouchEnd (id:0, state:released, scenePos:(157,1034))
    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointReleased);
        QTouchEvent touchEvent(QEvent::TouchEnd,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointReleased,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    QCOMPARE(directionalDragArea.unownedTouchEvents.count(), 1);
    QCOMPARE(directionalDragArea.unownedTouchEvents.first().touchPoints.count(), 1);
    QVERIFY(directionalDragArea.unownedTouchEvents.first().containsTouchWithId(0));

    QVERIFY(touchGate.unownedTouchEvents.isEmpty());
}

void tst_TouchRegistry::rejectingTouchfterItsEnd()
{
    DummyCandidate earlyCandidate;
    DummyCandidate lateCandidate;

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addCandidateOwnerForTouch(0, &earlyCandidate);
    touchRegistry->addCandidateOwnerForTouch(0, &lateCandidate);

    QVERIFY(earlyCandidate.ownedTouches.isEmpty());
    QVERIFY(lateCandidate.ownedTouches.isEmpty());

    touchRegistry->requestTouchOwnership(0, &lateCandidate);

    QVERIFY(earlyCandidate.ownedTouches.isEmpty());
    QVERIFY(lateCandidate.ownedTouches.isEmpty());

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointReleased);
        QTouchEvent touchEvent(QEvent::TouchEnd,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    QVERIFY(earlyCandidate.ownedTouches.isEmpty());
    QVERIFY(lateCandidate.ownedTouches.isEmpty());

    touchRegistry->removeCandidateOwnerForTouch(0, &earlyCandidate);

    QCOMPARE(lateCandidate.ownedTouches.count(), 1);
    QCOMPARE(lateCandidate.ownedTouches.contains(0), 1);

    // Check that there's no trace left of touch 0 as we no longer need to keep tabs on it.
    QVERIFY(!touchRegistry->findTouchInfo(0));
}

void tst_TouchRegistry::removeOldUndecidedCandidates()
{
    FakeTimerFactory *fakeTimerFactory = new FakeTimerFactory;
    touchRegistry->setTimerFactory(fakeTimerFactory);

    DummyCandidate undecidedCandidate;
    undecidedCandidate.setObjectName("undecided");

    DummyCandidate candidateThatWantsTouch;
    candidateThatWantsTouch.setObjectName("wantsTouch");

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addCandidateOwnerForTouch(0, &undecidedCandidate);

    touchRegistry->requestTouchOwnership(0, &candidateThatWantsTouch);

    QVERIFY(undecidedCandidate.ownedTouches.isEmpty());
    QVERIFY(undecidedCandidate.lostTouches.isEmpty());
    QVERIFY(candidateThatWantsTouch.ownedTouches.isEmpty());
    QVERIFY(candidateThatWantsTouch.lostTouches.isEmpty());

    // Simulate that enough time has passed to cause the CandidateInactivityTimer to timeout,
    // making TouchRegistry consider that undecidedCantidate defaulted.
    fakeTimerFactory->updateTime(10000);

    QVERIFY(undecidedCandidate.ownedTouches.isEmpty());
    QVERIFY(undecidedCandidate.lostTouches.contains(0));
    QVERIFY(candidateThatWantsTouch.ownedTouches.contains(0));
    QVERIFY(candidateThatWantsTouch.lostTouches.isEmpty());
}

/*
    An item that calls requestTouchOwnership() without first having called addCandidateOwnerForTouch()
    is assumed to be the interim owner of the touch point, thus there's no point in sending
    UnownedTouchEvents to him as he already gets proper QTouchEvents from QQuickWindow because
    he didn't ignore the first QTouchEvent with that touch point.
 */
void tst_TouchRegistry::interimOwnerWontGetUnownedTouchEvents()
{
    FakeTimerFactory *fakeTimerFactory = new FakeTimerFactory;
    touchRegistry->setTimerFactory(fakeTimerFactory);

    DummyCandidate undecidedCandidate;
    undecidedCandidate.setObjectName("undecided");

    DummyCandidate interimOwner;
    interimOwner.setObjectName("interimOwner");

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addCandidateOwnerForTouch(0, &undecidedCandidate);
    touchRegistry->requestTouchOwnership(0, &interimOwner);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    QCOMPARE(undecidedCandidate.unownedTouchEvents.count(), 1);
    QCOMPARE(interimOwner.unownedTouchEvents.count(), 0);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    QCOMPARE(undecidedCandidate.unownedTouchEvents.count(), 2);
    QCOMPARE(interimOwner.unownedTouchEvents.count(), 0);
}

/*
  Regression test for https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1473492

  Bug caused by candidates getting deleted before ownership resolution
 */
void tst_TouchRegistry::candidateVanishes()
{
    DummyCandidate mainCandidate;
    DummyCandidate *missingCandidate = new DummyCandidate;

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->addCandidateOwnerForTouch(0, &mainCandidate);
    touchRegistry->addCandidateOwnerForTouch(0, missingCandidate);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    // This candidate suddenly disappears without having removed its candidacy.
    delete missingCandidate;
    missingCandidate = nullptr;

    touchRegistry->requestTouchOwnership(0, &mainCandidate);

    QVERIFY(mainCandidate.ownedTouches.contains(0));
}

/*
  Regression test for canidate reentrance

  Bug caused by candidates getting removed during ownership resolution
 */
void tst_TouchRegistry::candicateOwnershipReentrace()
{
    DummyCandidate mainCandidate;
    DummyCandidate candicate2;
    DummyCandidate candicate3;

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointPressed);
        QTouchEvent touchEvent(QEvent::TouchBegin,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointPressed,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    // Re-entrance!
    connect(&candicate2, &DummyCandidate::lostOwnership, this, [&]() {
        touchRegistry->removeCandidateOwnerForTouch(0, &candicate2);
    });

    touchRegistry->addCandidateOwnerForTouch(0, &mainCandidate);
    touchRegistry->addCandidateOwnerForTouch(0, &candicate2);
    touchRegistry->addCandidateOwnerForTouch(0, &candicate3);

    {
        QList<QTouchEvent::TouchPoint> touchPoints;
        touchPoints.append(QTouchEvent::TouchPoint(0));
        touchPoints[0].setState(Qt::TouchPointMoved);
        QTouchEvent touchEvent(QEvent::TouchUpdate,
                               0 /* device */,
                               Qt::NoModifier,
                               Qt::TouchPointMoved,
                               touchPoints);
        touchRegistry->update(&touchEvent);
    }

    touchRegistry->requestTouchOwnership(0, &mainCandidate);

    QCOMPARE(mainCandidate.ownedTouches.count(), 1);
    QCOMPARE(candicate2.lostTouches.count(), 1);
    QCOMPARE(candicate3.lostTouches.count(), 1);
}


////////////// TouchMemento //////////

TouchMemento::TouchMemento(const QTouchEvent *touchEvent)
    : touchPointStates(touchEvent->touchPointStates()), touchPoints(touchEvent->touchPoints())
{
}

bool TouchMemento::containsTouchWithId(int touchId) const
{
    for (int i = 0; i < touchPoints.count(); ++i) {
        if (touchPoints.at(i).id() == touchId) {
            return true;
        }
    }
    return false;
}

////////////// DummyCandidate //////////

bool DummyCandidate::event(QEvent *e)
{
    if (e->type() == TouchOwnershipEvent::touchOwnershipEventType()) {
        TouchOwnershipEvent *touchOwnershipEvent = static_cast<TouchOwnershipEvent *>(e);

        // NB: Cannot use QVERIFY here because the macro doesn't return a boolean and is
        //     meant for use only directly in the body of a test function
        if (ownedTouches.contains(touchOwnershipEvent->touchId()))
            qFatal("Sent ownership event for a touch that is already owned.");
        if (lostTouches.contains(touchOwnershipEvent->touchId()))
            qFatal("Sent ownership event for a touch that has already been lost.");

        if (touchOwnershipEvent->gained()) {
            ownedTouches.insert(touchOwnershipEvent->touchId());
            Q_EMIT gainedOwnership();
        } else {
            lostTouches.insert(touchOwnershipEvent->touchId());
            Q_EMIT lostOwnership();
        }
        return true;
    } else if (e->type() == UnownedTouchEvent::unownedTouchEventType()) {
        UnownedTouchEvent *unownedTouchEvent = static_cast<UnownedTouchEvent *>(e);
        unownedTouchEvents.append(TouchMemento(unownedTouchEvent->touchEvent()));
        return true;
    } else {
        return QObject::event(e);
    }
}

QTEST_GUILESS_MAIN(tst_TouchRegistry)

#include "tst_TouchRegistry.moc"
