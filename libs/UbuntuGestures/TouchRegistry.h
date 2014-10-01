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

#ifndef UNITY_TOUCHREGISTRY_H
#define UNITY_TOUCHREGISTRY_H

#include <QQuickItem>
#include <QObject>
#include <QPointer>
#include <QTouchEvent>
#include <QVector>

#include "UbuntuGesturesGlobal.h"
#include "CandidateInactivityTimer.h"
#include "Pool.h"

namespace UbuntuGestures {
    class AbstractTimerFactory;
}

/*
  Where the ownership of touches is registered.

  Singleton used for adding a touch point ownership model analogous to the one
  described in the XInput 2.2 protocol[1] on top of the existing input dispatch logic in QQuickWindow.

  It provides a much more flexible and powerful way of dealing with pointer ownership than the existing
  mechanisms in Qt. Namely QQuickItem::grabTouchPoints, QuickItem::keepTouchGrab,
  QQuickItem::setFiltersChildMouseEvents, QQuickItem::ungrabTouchPoints and QQuickItem::touchUngrabEvent.

  Usage:

  1- An item receives a a new touch point. If he's not sure whether he wants it yet, he calls:
        TouchRegistry::instance()->addCandidateOwnerForTouch(touchId, this);
        touchEvent->ignore();
     Ignoring the event is crucial so that it can be seen by other interested parties, which will
     behave similarly.

  2- That item will then start receiving UnownedTouchEvents for that touch from step 1. Once he's
     made a decision he calls either:
        TouchRegistry::instance()->requestTouchOwnership(touchId, this);
     If he wants the touch point or:
        TouchRegistry::instance()->removeCandidateOwnerForTouch(touchId, this);
     if he does not want it.

  Candidates are put in a priority queue. The first one to call addCandidateOwnerForTouch() will
  take precedence over the others for receiving ownership over the touch point (from now on called
  simply top-candidate).

  If the top-candidate calls requestTouchOwnership() he will immediately receive a
  TouchOwnershipEvent(gained=true) for that touch point. He can then safely call
  QQuickItem::grabTouchPoints to actually get the owned touch points. The other candidates
  will receive TouchOwnershipEvent(gained=false) and will no longer receive UnownedTouchEvents
  for that touch point. They will have to undo whatever action they were performing with that
  touch point.

  But if the top-candidate calls removeCandidateOwnerForTouch() instead, he's popped from the
  candidacy queue and ownership is given to the new top-most candidate if he has already
  made his decision, that is.

  The TouchRegistry cannot enforce the results of this pointer ownership negotiation (i.e.,
  who gets to grab the touch points) as that would clash with QQuickWindow's input event
  dispatching logic. The candidates have to respect the decision and grab the touch points
  themselves.

  If an item wants ownership over touches as soon as he receives the TouchBegin for them, his step 1
  would be instead:
        TouchRegistry::instance()->requestTouchOwnership(touchId, this);
        return true;
  He would then be notified once ownership has been granted to him, from which point onwards he could
  safely assume other TouchRegistry users wouldn't snatch this touch away from him.

  Items oblivious to TouchRegistry will lose their touch points without warning, just like in plain Qt.

  [1] - http://www.x.org/releases/X11R7.7/doc/inputproto/XI2proto.txt (see multitouch-ownership)
 */
class UBUNTUGESTURES_EXPORT TouchRegistry : public QObject
{
    Q_OBJECT
public:
    TouchRegistry(QObject *parent = nullptr);

    virtual ~TouchRegistry();

    // Returns a pointer to the application's TouchRegistry instance.
    // If no instance has been allocated, null is returned.
    static TouchRegistry *instance() { return m_instance; }

    void update(const QTouchEvent *event);

    // Calls update() if the given event is a QTouchEvent
    bool eventFilter(QObject *watched, QEvent *event) override;

    // An item that might later request ownership over the given touch point.
    // He will be kept informed about that touch point through UnownedTouchEvents
    // All candidates must eventually decide whether they want to own the touch point
    // or not. That decision is informed through requestTouchOwnership() or
    // removeCandidateOwnerForTouch()
    void addCandidateOwnerForTouch(int id, QQuickItem *candidate);

    // The same as rejecting ownership of a touch
    void removeCandidateOwnerForTouch(int id, QQuickItem *candidate);

    // The candidate object wants to be the owner of the touch with the given id.
    // If he's currently the oldest/top-most candidate, he will get an ownership
    // event immediately. If not, he will get ownership if (or once) he becomes the
    // top-most candidate.
    void requestTouchOwnership(int id, QQuickItem *candidate);

    // An item that has no interest (effective or potential) in owning a touch point
    // but would nonetheless like to be kept up-to-date on its state.
    void addTouchWatcher(int touchId, QQuickItem *watcherItem);

private Q_SLOTS:
    void rejectCandidateOwnerForTouch(int id, QQuickItem *candidate);

private:
    // Useful for tests, where you should feed a fake timer
    TouchRegistry(QObject *parent, UbuntuGestures::AbstractTimerFactory *timerFactory);

    class CandidateInfo {
    public:
        bool undecided;
        // TODO: Prune candidates that become null and resolve ownership accordingly.
        QPointer<QQuickItem> item;
        QPointer<UbuntuGestures::CandidateInactivityTimer> inactivityTimer;
    };

    class TouchInfo {
    public:
        TouchInfo() : id(-1) {}
        TouchInfo(int id);
        bool isValid() const { return id >= 0; }
        void reset();
        void init(int id);
        int id;
        bool physicallyEnded;
        bool isOwned() const;
        bool ended() const;
        void notifyCandidatesOfOwnershipResolution();

        // TODO optimize storage (s/QList/Pool)
        QList<CandidateInfo> candidates;
        QList<QPointer<QQuickItem>> watchers;
    };

    Pool<TouchInfo>::Iterator findTouchInfo(int id);

    void deliverTouchUpdatesToUndecidedCandidatesAndWatchers(const QTouchEvent *event);

    static void translateTouchPointFromScreenToWindowCoords(QTouchEvent::TouchPoint &touchPoint);

    static void dispatchPointsToItem(const QTouchEvent *event, const QList<int> &touchIds,
                                     QQuickItem *item);
    void freeEndedTouchInfos();

    Pool<TouchInfo> m_touchInfoPool;

    // the singleton instance
    static TouchRegistry *m_instance;

    bool m_inDispatchLoop;

    UbuntuGestures::AbstractTimerFactory *m_timerFactory;

    friend class tst_TouchRegistry;
    friend class tst_DirectionalDragArea;
};

#endif // UNITY_TOUCHREGISTRY_H
