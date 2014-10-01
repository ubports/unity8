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

#include "TouchGate.h"

#include <QCoreApplication>
#include <QDebug>

#include <TouchOwnershipEvent.h>
#include <TouchRegistry.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-pedantic"
#include <private/qquickitem_p.h>
#pragma GCC diagnostic pop

#if TOUCHGATE_DEBUG
#include <DebugHelpers.h>
#endif


bool TouchGate::event(QEvent *e)
{
    if (e->type() == TouchOwnershipEvent::touchOwnershipEventType()) {
        touchOwnershipEvent(static_cast<TouchOwnershipEvent *>(e));
        return true;
    } else {
        return QQuickItem::event(e);
    }
}

void TouchGate::touchEvent(QTouchEvent *event)
{
    #if TOUCHGATE_DEBUG
    qDebug() << "[TouchGate] got touch event" << qPrintable(touchEventToString(event));
    #endif
    event->accept();

    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();
    bool goodToGo = true;
    for (int i = 0; i < touchPoints.count(); ++i) {
        const QTouchEvent::TouchPoint &touchPoint = touchPoints[i];

        if (touchPoint.state() == Qt::TouchPointPressed) {
            Q_ASSERT(!m_touchInfoMap.contains(touchPoint.id()));
            m_touchInfoMap[touchPoint.id()].ownership = OwnershipRequested;
            m_touchInfoMap[touchPoint.id()].ended = false;
            TouchRegistry::instance()->requestTouchOwnership(touchPoint.id(), this);
        }

        goodToGo &= m_touchInfoMap.contains(touchPoint.id())
            && m_touchInfoMap[touchPoint.id()].ownership == OwnershipGranted;

        if (touchPoint.state() == Qt::TouchPointReleased && m_touchInfoMap.contains(touchPoint.id())) {
            m_touchInfoMap[touchPoint.id()].ended = true;
        }

    }

    if (goodToGo) {
        if (m_storedEvents.isEmpty()) {
            // let it pass through
            dispatchTouchEventToTarget(event);
        } else {
            // Retain the event to ensure TouchGate dispatches them in order.
            // Otherwise the current event would come before the stored ones, which are older.
            #if TOUCHGATE_DEBUG
            qDebug("[TouchGate] Storing event because thouches %s are still pending ownership.",
                qPrintable(oldestPendingTouchIdsString()));
            #endif
            storeTouchEvent(event);
        }
    } else {
        // Retain events that have unowned touches
        storeTouchEvent(event);
    }
}

void TouchGate::touchOwnershipEvent(TouchOwnershipEvent *event)
{
    // TODO: Optimization: batch those actions as TouchOwnershipEvents
    //       might come one right after the other.

    Q_ASSERT(m_touchInfoMap.contains(event->touchId()));

    TouchInfo &touchInfo = m_touchInfoMap[event->touchId()];

    if (event->gained()) {
        #if TOUCHGATE_DEBUG
        qDebug() << "[TouchGate] Got ownership of touch " << event->touchId();
        #endif
        touchInfo.ownership = OwnershipGranted;
    } else {
        #if TOUCHGATE_DEBUG
        qDebug() << "[TouchGate] Lost ownership of touch " << event->touchId();
        #endif
        m_touchInfoMap.remove(event->touchId());
        removeTouchFromStoredEvents(event->touchId());
    }

    dispatchFullyOwnedEvents();
}

bool TouchGate::isTouchPointOwned(int touchId) const
{
    return m_touchInfoMap[touchId].ownership == OwnershipGranted;
}

void TouchGate::storeTouchEvent(const QTouchEvent *event)
{
    #if TOUCHGATE_DEBUG
    qDebug() << "[TouchGate] Storing" << qPrintable(touchEventToString(event));
    #endif

    QTouchEvent *clonedEvent = new QTouchEvent(event->type(),
            event->device(),
            event->modifiers(),
            event->touchPointStates(),
            event->touchPoints());

    m_storedEvents.append(clonedEvent);
}

void TouchGate::removeTouchFromStoredEvents(int touchId)
{
    int i = 0;
    while (i < m_storedEvents.count()) {
        QTouchEvent *event = m_storedEvents[i];
        bool removed = removeTouchFromEvent(touchId, event);

        if (removed && event->touchPoints().isEmpty()) {
            m_storedEvents.removeAt(i);
        } else {
            ++i;
        }
    }
}

bool TouchGate::removeTouchFromEvent(int touchId, QTouchEvent *event)
{
    const QList<QTouchEvent::TouchPoint> &eventTouchPoints = event->touchPoints();

    int indexToRemove = -1;
    for (int i = 0; i < eventTouchPoints.count() && indexToRemove < 0; ++i) {
        if (eventTouchPoints[i].id() == touchId) {
            indexToRemove = i;
        }
    }

    if (indexToRemove >= 0) {
        QList<QTouchEvent::TouchPoint> newTouchPointsList = eventTouchPoints;
        newTouchPointsList.removeAt(indexToRemove);
        event->setTouchPoints(newTouchPointsList);
        return true;
    } else {
        return false;
    }
}

void TouchGate::dispatchFullyOwnedEvents()
{
    while (!m_storedEvents.isEmpty() && eventIsFullyOwned(m_storedEvents.first())) {
        QTouchEvent *event = m_storedEvents.takeFirst();
        dispatchTouchEventToTarget(event);
        delete event;
    }
}

#if TOUCHGATE_DEBUG
QString TouchGate::oldestPendingTouchIdsString()
{
    Q_ASSERT(!m_storedEvents.isEmpty());

    QString str;

    auto touchPoints = m_storedEvents.first()->touchPoints();
    for (int i = 0; i < touchPoints.count(); ++i) {
        if (!isTouchPointOwned(touchPoints[i].id())) {
            if (!str.isEmpty()) {
                str.append(", ");
            }
            str.append(QString::number(touchPoints[i].id()));
        }
    }

    return str;
}
#endif

bool TouchGate::eventIsFullyOwned(const QTouchEvent *event) const
{
    auto touchPoints = event->touchPoints();
    for (int i = 0; i < touchPoints.count(); ++i) {
        if (!isTouchPointOwned(touchPoints[i].id())) {
            return false;
        }
    }

    return true;
}

void TouchGate::setTargetItem(QQuickItem *item)
{
    // TODO: changing the target item while dispatch of touch events is taking place will
    //       create a mess

    if (item == m_targetItem.data())
        return;

    m_targetItem = item;
    Q_EMIT targetItemChanged(item);
}

void TouchGate::dispatchTouchEventToTarget(QTouchEvent* event)
{
    removeTouchInfoForEndedTouches(event);

    if (m_targetItem.isNull()) {
        qWarning("[TouchGate] Cannot dispatch touch event because target item is null");
        return;
    }

    QQuickItem *targetItem = m_targetItem.data();

    if (!targetItem->isEnabled() || !targetItem->isVisible()) {
        #if TOUCHGATE_DEBUG
        qDebug() << "[TouchGate] Cannot dispatch touch event to" << targetItem
            << "because it's disabled or invisible.";
        #endif
        return;
    }

    // Map touch points to targetItem coordinates
    QList<QTouchEvent::TouchPoint> touchPoints = event->touchPoints();
    transformTouchPoints(touchPoints, QQuickItemPrivate::get(targetItem)->windowToItemTransform());
    QTouchEvent *eventForTargetItem = touchEventWithPoints(*event, touchPoints);

    #if TOUCHGATE_DEBUG
    qDebug() << "[TouchGate] dispatching" << qPrintable(touchEventToString(eventForTargetItem))
            << "to" << targetItem;
    #endif

    QCoreApplication::sendEvent(targetItem, eventForTargetItem);

    delete eventForTargetItem;
}

// NB: From QQuickWindow
void TouchGate::transformTouchPoints(QList<QTouchEvent::TouchPoint> &touchPoints, const QTransform &transform)
{
    QMatrix4x4 transformMatrix(transform);
    for (int i=0; i<touchPoints.count(); i++) {
        QTouchEvent::TouchPoint &touchPoint = touchPoints[i];
        touchPoint.setRect(transform.mapRect(touchPoint.sceneRect()));
        touchPoint.setStartPos(transform.map(touchPoint.startScenePos()));
        touchPoint.setLastPos(transform.map(touchPoint.lastScenePos()));
        touchPoint.setVelocity(transformMatrix.mapVector(touchPoint.velocity()).toVector2D());
    }
}

// NB: From QQuickWindow
QTouchEvent *TouchGate::touchEventWithPoints(const QTouchEvent &event,
                                             const QList<QTouchEvent::TouchPoint> &newPoints)
{
    Qt::TouchPointStates eventStates = 0;
    for (int i=0; i<newPoints.count(); i++)
        eventStates |= newPoints[i].state();
    // if all points have the same state, set the event type accordingly
    QEvent::Type eventType = event.type();
    switch (eventStates) {
        case Qt::TouchPointPressed:
            eventType = QEvent::TouchBegin;
            break;
        case Qt::TouchPointReleased:
            eventType = QEvent::TouchEnd;
            break;
        default:
            eventType = QEvent::TouchUpdate;
            break;
    }

    QTouchEvent *touchEvent = new QTouchEvent(eventType);
    touchEvent->setWindow(event.window());
    touchEvent->setTarget(event.target());
    touchEvent->setDevice(event.device());
    touchEvent->setModifiers(event.modifiers());
    touchEvent->setTouchPoints(newPoints);
    touchEvent->setTouchPointStates(eventStates);
    touchEvent->setTimestamp(event.timestamp());
    touchEvent->accept();
    return touchEvent;
}

void TouchGate::removeTouchInfoForEndedTouches(QTouchEvent *event)
{
    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();

    for (int i = 0; i < touchPoints.size(); ++i) {\
        const QTouchEvent::TouchPoint &touchPoint = touchPoints.at(i);

        if (touchPoint.state() == Qt::TouchPointReleased) {
            Q_ASSERT(m_touchInfoMap.contains(touchPoint.id()));
            Q_ASSERT(m_touchInfoMap[touchPoint.id()].ended);
            Q_ASSERT(m_touchInfoMap[touchPoint.id()].ownership == OwnershipGranted);
            m_touchInfoMap.remove(touchPoint.id());
        }
    }
}
