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

#include "TouchRegistry.h"

#include <QCoreApplication>
#include <QDebug>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-pedantic"
#include <private/qquickitem_p.h>
#pragma GCC diagnostic pop

#include "CandidateInactivityTimer.h"
#include "Timer.h"
#include "TouchOwnershipEvent.h"
#include "UnownedTouchEvent.h"

#define TOUCHREGISTRY_DEBUG 0

#if TOUCHREGISTRY_DEBUG
    #include "DebugHelpers.h"
    #define UG_DEBUG qDebug() << "[TouchRegistry]"
#endif // TOUCHREGISTRY_DEBUG

using namespace UbuntuGestures;

TouchRegistry *TouchRegistry::m_instance = nullptr;

TouchRegistry::TouchRegistry(QObject *parent)
    : QObject(parent)
    , m_inDispatchLoop(false)
    , m_timerFactory(new TimerFactory)
{
}

TouchRegistry::~TouchRegistry()
{
    Q_ASSERT(m_instance != nullptr);
    m_instance = nullptr;
    delete m_timerFactory;
}

TouchRegistry *TouchRegistry::instance()
{
    if (m_instance == nullptr) {
        m_instance = new TouchRegistry;
    }
    return m_instance;
}

void TouchRegistry::setTimerFactory(AbstractTimerFactory *timerFactory)
{
    delete m_timerFactory;
    m_timerFactory = timerFactory;
}

void TouchRegistry::update(const QTouchEvent *event)
{
    #if TOUCHREGISTRY_DEBUG
    UG_DEBUG << "got" << qPrintable(touchEventToString(event));
    #endif

    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();
    for (int i = 0; i < touchPoints.count(); ++i) {
        const QTouchEvent::TouchPoint &touchPoint = touchPoints.at(i);
        if (touchPoint.state() == Qt::TouchPointPressed) {
            TouchInfo &touchInfo = m_touchInfoPool.getEmptySlot();
            touchInfo.init(touchPoint.id());
        } else if (touchPoint.state() == Qt::TouchPointReleased) {
            Pool<TouchInfo>::Iterator touchInfo = findTouchInfo(touchPoint.id());

            touchInfo->physicallyEnded = true;
        }
    }

    deliverTouchUpdatesToUndecidedCandidatesAndWatchers(event);

    freeEndedTouchInfos();
}

void TouchRegistry::deliverTouchUpdatesToUndecidedCandidatesAndWatchers(const QTouchEvent *event)
{
    // TODO: Look into how we could optimize this whole thing.
    //       Although it's not really a problem as we should have at most two candidates
    //       for each point and there should not be many active points at any given moment.
    //       But having three nested for-loops does scare.

    const QList<QTouchEvent::TouchPoint> &updatedTouchPoints = event->touchPoints();

    // Maps an item to the touches in this event he should be informed about.
    // E.g.: a QTouchEvent might have three touches but a given item might be interested in only
    // one of them. So he will get a UnownedTouchEvent from this QTouchEvent containing only that
    // touch point.
    QHash<QQuickItem*, QList<int>> touchIdsForItems;

    // Build touchIdsForItems
    m_touchInfoPool.forEach([&](Pool<TouchInfo>::Iterator &touchInfo) {
        if (touchInfo->isOwned() && touchInfo->watchers.isEmpty())
            return true;

        for (int j = 0; j < updatedTouchPoints.count(); ++j) {
            if (updatedTouchPoints[j].id() == touchInfo->id) {
                if (!touchInfo->isOwned()) {
                    for (int i = 0; i < touchInfo->candidates.count(); ++i) {
                        CandidateInfo &candidate = touchInfo->candidates[i];
                        Q_ASSERT(!candidate.item.isNull());
                        if (candidate.state != CandidateInfo::InterimOwner) {
                            touchIdsForItems[candidate.item.data()].append(touchInfo->id);
                        }
                    }
                }

                const QList<QPointer<QQuickItem>> &watchers = touchInfo->watchers;
                for (int i = 0; i < watchers.count(); ++i) {
                    if (!watchers[i].isNull()) {
                        touchIdsForItems[watchers[i].data()].append(touchInfo->id);
                    }
                }

                return true;
            }
        }

        return true;
    });

    // TODO: Consider what happens if an item calls any of TouchRegistry's public methods
    // from the event handler callback.
    m_inDispatchLoop = true;
    auto it = touchIdsForItems.constBegin();
    while (it != touchIdsForItems.constEnd()) {
        QQuickItem *item = it.key();
        const QList<int> &touchIds = it.value();
        dispatchPointsToItem(event, touchIds, item);
        ++it;
    };
    m_inDispatchLoop = false;
}

void TouchRegistry::freeEndedTouchInfos()
{
    m_touchInfoPool.forEach([&](Pool<TouchInfo>::Iterator &touchInfo) {
        if (touchInfo->ended()) {
            m_touchInfoPool.freeSlot(touchInfo);
        }
        return true;
    });
}

/*
   Extracts the touches with the given touchIds from event and send them in a
   UnownedTouchEvent to the given item
 */
void TouchRegistry::dispatchPointsToItem(const QTouchEvent *event, const QList<int> &touchIds,
        QQuickItem *item)
{
    Qt::TouchPointStates touchPointStates = 0;
    QList<QTouchEvent::TouchPoint> touchPoints;

    const QList<QTouchEvent::TouchPoint> &allTouchPoints = event->touchPoints();

    QTransform windowToCandidateTransform = QQuickItemPrivate::get(item)->windowToItemTransform();
    QMatrix4x4 windowToCandidateMatrix(windowToCandidateTransform);

    for (int i = 0; i < allTouchPoints.count(); ++i) {
        const QTouchEvent::TouchPoint &originalTouchPoint = allTouchPoints[i];
        if (touchIds.contains(originalTouchPoint.id())) {
            QTouchEvent::TouchPoint touchPoint = originalTouchPoint;

            translateTouchPointFromScreenToWindowCoords(touchPoint);

            // Set the point's local coordinates to that of the item
            touchPoint.setRect(windowToCandidateTransform.mapRect(touchPoint.sceneRect()));
            touchPoint.setStartPos(windowToCandidateTransform.map(touchPoint.startScenePos()));
            touchPoint.setLastPos(windowToCandidateTransform.map(touchPoint.lastScenePos()));
            touchPoint.setVelocity(windowToCandidateMatrix.mapVector(touchPoint.velocity()).toVector2D());

            touchPoints.append(touchPoint);
            touchPointStates |= touchPoint.state();
        }
    }

    QTouchEvent *eventForItem = new QTouchEvent(event->type(),
                                                event->device(),
                                                event->modifiers(),
                                                touchPointStates,
                                                touchPoints);
    eventForItem->setWindow(event->window());
    eventForItem->setTimestamp(event->timestamp());
    eventForItem->setTarget(event->target());

    UnownedTouchEvent unownedTouchEvent(eventForItem);

    #if TOUCHREGISTRY_DEBUG
    UG_DEBUG << "Sending unowned" << qPrintable(touchEventToString(eventForItem))
        << "to" << item;
    #endif

    QCoreApplication::sendEvent(item, &unownedTouchEvent);
}

void TouchRegistry::translateTouchPointFromScreenToWindowCoords(QTouchEvent::TouchPoint &touchPoint)
{
    touchPoint.setScreenRect(touchPoint.sceneRect());
    touchPoint.setStartScreenPos(touchPoint.startScenePos());
    touchPoint.setLastScreenPos(touchPoint.lastScenePos());

    touchPoint.setSceneRect(touchPoint.rect());
    touchPoint.setStartScenePos(touchPoint.startPos());
    touchPoint.setLastScenePos(touchPoint.lastPos());
}

bool TouchRegistry::eventFilter(QObject *watched, QEvent *event)
{
    Q_UNUSED(watched);

    switch (event->type()) {
    case QEvent::TouchBegin:
    case QEvent::TouchUpdate:
    case QEvent::TouchEnd:
    case QEvent::TouchCancel:
        update(static_cast<QTouchEvent*>(event));
        break;
    default:
        // do nothing
        break;
    }

    // Do not filter out the event. i.e., let it be handled further as
    // we're just monitoring events
    return false;
}

void TouchRegistry::addCandidateOwnerForTouch(int id, QQuickItem *candidate)
{
    #if TOUCHREGISTRY_DEBUG
    UG_DEBUG << "addCandidateOwnerForTouch id" << id << "candidate" << candidate;
    #endif

    Pool<TouchInfo>::Iterator touchInfo = findTouchInfo(id);
    if (!touchInfo) { qFatal("TouchRegistry: Failed to find TouchInfo"); }

    if (touchInfo->isOwned()) {
        qWarning("TouchRegistry: trying to add candidate owner for a touch that's already owned");
        return;
    }

    // TODO: Check if candidate already exists

    CandidateInfo candidateInfo;
    candidateInfo.state = CandidateInfo::Undecided;
    candidateInfo.item = candidate;
    candidateInfo.inactivityTimer = new CandidateInactivityTimer(id, candidate,
                                                                 m_timerFactory->createTimer(),
                                                                 this);
    connect(candidateInfo.inactivityTimer, &CandidateInactivityTimer::candidateDefaulted,
            this, &TouchRegistry::rejectCandidateOwnerForTouch);

    touchInfo->candidates.append(candidateInfo);

    connect(candidate, &QObject::destroyed, this, [=](){ pruneNullCandidatesForTouch(id); });
}

void TouchRegistry::addTouchWatcher(int touchId, QQuickItem *watcher)
{
    #if TOUCHREGISTRY_DEBUG
    UG_DEBUG << "addTouchWatcher id" << touchId << "watcher" << watcher;
    #endif

    Pool<TouchInfo>::Iterator touchInfo = findTouchInfo(touchId);
    if (!touchInfo) { qFatal("TouchRegistry: Failed to find TouchInfo"); }

    // TODO: Check if watcher already exists

    touchInfo->watchers.append(watcher);
}

void TouchRegistry::removeCandidateOwnerForTouch(int id, QQuickItem *candidate)
{
    #if TOUCHREGISTRY_DEBUG
    UG_DEBUG << "removeCandidateOwnerForTouch id" << id << "candidate" << candidate;
    #endif

    Pool<TouchInfo>::Iterator touchInfo = findTouchInfo(id);
    if (!touchInfo) { qFatal("TouchRegistry: Failed to find TouchInfo"); }


    // TODO: check if the candidate is in fact the owner of the touch

    bool removed = false;
    for (int i = 0; i < touchInfo->candidates.count() && !removed; ++i) {
        if (touchInfo->candidates[i].item == candidate) {
            removeCandidateOwnerForTouchByIndex(touchInfo, i);
            removed = true;
        }
    }
}

void TouchRegistry::pruneNullCandidatesForTouch(int touchId)
{
    #if TOUCHREGISTRY_DEBUG
    UG_DEBUG << "pruneNullCandidatesForTouch touchId" << touchId;
    #endif

    Pool<TouchInfo>::Iterator touchInfo = findTouchInfo(touchId);
    if (!touchInfo) {
        // doesn't matter as touch is already gone.
        return;
    }

    int i = 0;
    while (i < touchInfo->candidates.count()) {
        if (touchInfo->candidates[i].item.isNull()) {
            removeCandidateOwnerForTouchByIndex(touchInfo, i);
        } else {
            ++i;
        }
    }
}

void TouchRegistry::removeCandidateOwnerForTouchByIndex(Pool<TouchRegistry::TouchInfo>::Iterator &touchInfo,
        int candidateIndex)
{
    // TODO: check if the candidate is in fact the owner of the touch

    Q_ASSERT(candidateIndex < touchInfo->candidates.count());

    if (candidateIndex == 0 && touchInfo->candidates[candidateIndex].state != CandidateInfo::Undecided) {
        qCritical("TouchRegistry: touch owner is being removed.");
    }
    removeCandidateHelper(touchInfo, candidateIndex);

    if (candidateIndex == 0) {
        // the top candidate has been removed. if the new top candidate
        // wants the touch let him know he's now the owner.
        if (touchInfo->isOwned()) {
            touchInfo->notifyCandidatesOfOwnershipResolution();
        }
    }

    if (!m_inDispatchLoop && touchInfo->ended()) {
        m_touchInfoPool.freeSlot(touchInfo);
    }
}

void TouchRegistry::requestTouchOwnership(int id, QQuickItem *candidate)
{
    Pool<TouchInfo>::Iterator touchInfo = findTouchInfo(id);
    if (!touchInfo) { qFatal("TouchRegistry: Failed to find TouchInfo"); }

    Q_ASSERT(!touchInfo->isOwned());

    int candidateIndex = -1;
    for (int i = 0; i < touchInfo->candidates.count(); ++i) {
        CandidateInfo &candidateInfo = touchInfo->candidates[i];
        if (candidateInfo.item == candidate) {
            candidateInfo.state = CandidateInfo::Requested;
            delete candidateInfo.inactivityTimer;
            candidateInfo.inactivityTimer = nullptr;
            candidateIndex = i;
            break;
        }
    }
    #if TOUCHREGISTRY_DEBUG
    UG_DEBUG << "requestTouchOwnership id " << id << "candidate" << candidate << "index: " << candidateIndex;
    #endif

    // add it as a candidate if not present yet
    if (candidateIndex < 0) {
        CandidateInfo candidateInfo;
        candidateInfo.state = CandidateInfo::InterimOwner;
        candidateInfo.item = candidate;
        candidateInfo.inactivityTimer = nullptr;
        touchInfo->candidates.append(candidateInfo);
        // it's the last one
        candidateIndex = touchInfo->candidates.count() - 1;
        connect(candidate, &QObject::destroyed, this, [=](){ pruneNullCandidatesForTouch(id); });
    }

    // If it's the top candidate it means it's now the owner. Let
    // it know about it.
    if (candidateIndex == 0) {
        touchInfo->notifyCandidatesOfOwnershipResolution();
    }
}

Pool<TouchRegistry::TouchInfo>::Iterator TouchRegistry::findTouchInfo(int id)
{
    Pool<TouchInfo>::Iterator touchInfo;

    m_touchInfoPool.forEach([&](Pool<TouchInfo>::Iterator &someTouchInfo) -> bool {
        if (someTouchInfo->id == id) {
            touchInfo = someTouchInfo;
            return false;
        } else {
            return true;
        }
    });

    return touchInfo;
}


void TouchRegistry::rejectCandidateOwnerForTouch(int id, QQuickItem *candidate)
{
    // NB: It's technically possible that candidate is a dangling pointer at this point.
    // Although that would most likely be due to a bug in our code.
    // In any case, only dereference it after it's confirmed that it indeed exists.

    #if TOUCHREGISTRY_DEBUG
    UG_DEBUG << "rejectCandidateOwnerForTouch id" << id << "candidate" << (void*)candidate;
    #endif

    Pool<TouchInfo>::Iterator touchInfo = findTouchInfo(id);
    if (!touchInfo) {
        #if TOUCHREGISTRY_DEBUG
        UG_DEBUG << "Failed to find TouchInfo for id" << id;
        #endif
        return;
    }

    int rejectedCandidateIndex = -1;

    // Check if the given candidate is valid and still undecided
    for (int i = 0; i < touchInfo->candidates.count() && rejectedCandidateIndex == -1; ++i) {
        CandidateInfo &candidateInfo = touchInfo->candidates[i];
        if (candidateInfo.item == candidate) {
            Q_ASSERT(i > 0 || candidateInfo.state == CandidateInfo::Undecided);
            if (i == 0 && candidateInfo.state != CandidateInfo::Undecided) {
                qCritical() << "TouchRegistry: Can't reject item (" << (void*)candidate
                    << ") as it already owns touch" << id;
                return;
            } else {
                // we found the guy and it's all fine.
                rejectedCandidateIndex = i;
            }
        }
    }

    // If we reached this point it's because the given candidate exists and is indeed undecided.

    Q_ASSERT(rejectedCandidateIndex >= 0 && rejectedCandidateIndex < touchInfo->candidates.size());

    {
        TouchOwnershipEvent lostOwnershipEvent(id, false /*gained*/);
        QCoreApplication::sendEvent(candidate, &lostOwnershipEvent);
    }

    removeCandidateHelper(touchInfo, rejectedCandidateIndex);

    if (rejectedCandidateIndex == 0) {
        // the top candidate has been removed. if the new top candidate
        // wants the touch let him know he's now the owner.
        if (touchInfo->isOwned()) {
            touchInfo->notifyCandidatesOfOwnershipResolution();
        }
    }
}

void TouchRegistry::removeCandidateHelper(Pool<TouchInfo>::Iterator &touchInfo, int candidateIndex)
{
    {
        CandidateInfo &candidateInfo = touchInfo->candidates[candidateIndex];

        delete candidateInfo.inactivityTimer;
        candidateInfo.inactivityTimer = nullptr;

        if (candidateInfo.item) {
            disconnect(candidateInfo.item.data(), nullptr, this, nullptr);
        }
    }
    touchInfo->candidates.removeAt(candidateIndex);
}

////////////////////////////////////// TouchRegistry::TouchInfo ////////////////////////////////////

TouchRegistry::TouchInfo::TouchInfo(int id)
{
    init(id);
}

void TouchRegistry::TouchInfo::reset()
{
    id = -1;

    for (int i = 0; i < candidates.count(); ++i) {
        CandidateInfo &candidate = candidates[i];
        delete candidate.inactivityTimer;
        candidate.inactivityTimer.clear(); // shoundn't be needed but anyway...
    }
}

void TouchRegistry::TouchInfo::init(int id)
{
    this->id = id;
    physicallyEnded = false;
    candidates.clear();
    watchers.clear();
}

bool TouchRegistry::TouchInfo::isOwned() const
{
    return !candidates.isEmpty() && candidates.first().state != CandidateInfo::Undecided;
}

bool TouchRegistry::TouchInfo::ended() const
{
    Q_ASSERT(isValid());
    return physicallyEnded && (isOwned() || candidates.isEmpty());
}

void TouchRegistry::TouchInfo::notifyCandidatesOfOwnershipResolution()
{
    Q_ASSERT(isOwned());

    #if TOUCHREGISTRY_DEBUG
    UG_DEBUG << "sending TouchOwnershipEvent(id =" << id
        << " gained) to candidate" << candidates[0].item;
    #endif

    // need to take a copy of the item list in case
    // we call back in to remove candidate during the lost ownership event.
    QList<QPointer<QQuickItem>> items;
    Q_FOREACH(const CandidateInfo& info, candidates) {
        items << info.item;
    }

    TouchOwnershipEvent gainedOwnershipEvent(id, true /*gained*/);
    QCoreApplication::sendEvent(items[0], &gainedOwnershipEvent);

    TouchOwnershipEvent lostOwnershipEvent(id, false /*gained*/);
    for (int i = 1; i < items.count(); ++i) {
        #if TOUCHREGISTRY_DEBUG
        UG_DEBUG << "sending TouchOwnershipEvent(id =" << id << " lost) to candidate"
            << items[i];
        #endif
        QCoreApplication::sendEvent(items[i], &lostOwnershipEvent);
    }
}
