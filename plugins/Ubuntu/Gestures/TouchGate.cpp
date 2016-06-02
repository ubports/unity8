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

#include "TouchGate.h"

#include <QCoreApplication>
#include <QDebug>
#include <QQuickWindow>

#include <TouchOwnershipEvent>
#include <TouchRegistry>

#if TOUCHGATE_DEBUG
#define ugDebug(params) qDebug().nospace() << "[TouchGate(" << (void*)this << ")] " << params
#include <DebugHelpers.h>
#else // TOUCHGATE_DEBUG
#define ugDebug(params) ((void)0)
#endif // TOUCHGATE_DEBUG

TouchGate::TouchGate(QQuickItem *parent)
    : QQuickItem(parent)
{
    connect(this, &QQuickItem::enabledChanged,
            this, &TouchGate::onEnabledChanged);
}

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
    ugDebug("got touch event" << qPrintable(touchEventToString(event)));
    event->accept();

    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();
    QList<QTouchEvent::TouchPoint> validTouchPoints;
    bool ownsAllTouches = true;
    for (int i = 0; i < touchPoints.count(); ++i) {
        const QTouchEvent::TouchPoint &touchPoint = touchPoints[i];

        if (touchPoint.state() == Qt::TouchPointPressed) {
//            Q_ASSERT(!m_touchInfoMap.contains(touchPoint.id()));
            m_touchInfoMap[touchPoint.id()].ownership = OwnershipRequested;
            m_touchInfoMap[touchPoint.id()].ended = false;
            TouchRegistry::instance()->requestTouchOwnership(touchPoint.id(), this);
        }

        if (m_touchInfoMap.contains(touchPoint.id())) {
            validTouchPoints.append(touchPoint);

            ownsAllTouches &= m_touchInfoMap[touchPoint.id()].ownership == OwnershipGranted;

            if (touchPoint.state() == Qt::TouchPointReleased) {
                m_touchInfoMap[touchPoint.id()].ended = true;
            }
        }

    }

    if (validTouchPoints.isEmpty()) {
        // nothing to do.
        return;
    }

    if (ownsAllTouches) {
        if (m_storedEvents.isEmpty()) {
            // let it pass through
            removeTouchInfoForEndedTouches(validTouchPoints);
            m_dispatcher.dispatch(event->device(), event->modifiers(), validTouchPoints,
                    event->window(), event->timestamp());
        } else {
            // Retain the event to ensure TouchGate dispatches them in order.
            // Otherwise the current event would come before the stored ones, which are older.
            ugDebug("Storing event because thouches " << qPrintable(oldestPendingTouchIdsString())
                    << " are still pending ownership.");
            storeTouchEvent(event->device(), event->modifiers(), validTouchPoints,
                    event->window(), event->timestamp());
        }
    } else {
        // Retain events that have unowned touches
        storeTouchEvent(event->device(), event->modifiers(), validTouchPoints,
                event->window(), event->timestamp());
    }
}

void TouchGate::itemChange(ItemChange change, const ItemChangeData &value)
{
    if (change == QQuickItem::ItemSceneChange) {
        if (value.window != nullptr) {
            value.window->installEventFilter(TouchRegistry::instance());
        }
    }
}

void TouchGate::touchOwnershipEvent(TouchOwnershipEvent *event)
{
    // TODO: Optimization: batch those actions as TouchOwnershipEvents
    //       might come one right after the other.

    if (m_touchInfoMap.contains(event->touchId())) {
        TouchInfo &touchInfo = m_touchInfoMap[event->touchId()];

        if (event->gained()) {
            ugDebug("Got ownership of touch " << event->touchId());
            touchInfo.ownership = OwnershipGranted;
        } else {
            ugDebug("Lost ownership of touch " << event->touchId());
            m_touchInfoMap.remove(event->touchId());
            removeTouchFromStoredEvents(event->touchId());
        }

        dispatchFullyOwnedEvents();
    } else {
        // Ignore it. It probably happened because the TouchGate got disabled
        // between the time it requested ownership and the time it got it.
    }
}

bool TouchGate::isTouchPointOwned(int touchId) const
{
    return m_touchInfoMap[touchId].ownership == OwnershipGranted;
}

void TouchGate::storeTouchEvent(QTouchDevice *device,
            Qt::KeyboardModifiers modifiers,
            const QList<QTouchEvent::TouchPoint> &touchPoints,
            QWindow *window,
            ulong timestamp)
{
    ugDebug("Storing" << touchPoints);
    TouchEvent event(device, modifiers, touchPoints, window, timestamp);
    m_storedEvents.append(std::move(event));
}

void TouchGate::removeTouchFromStoredEvents(int touchId)
{
    int i = 0;
    while (i < m_storedEvents.count()) {
        TouchEvent &event = m_storedEvents[i];
        bool removed = event.removeTouch(touchId);

        if (removed && event.touchPoints.isEmpty()) {
            m_storedEvents.removeAt(i);
        } else {
            ++i;
        }
    }
}

void TouchGate::dispatchFullyOwnedEvents()
{
    while (!m_storedEvents.isEmpty() && eventIsFullyOwned(m_storedEvents.first())) {
        TouchEvent event = m_storedEvents.takeFirst();
        dispatchTouchEventToTarget(event);
    }
}

#if TOUCHGATE_DEBUG
QString TouchGate::oldestPendingTouchIdsString()
{
    Q_ASSERT(!m_storedEvents.isEmpty());

    QString str;

    const auto &touchPoints = m_storedEvents.first().touchPoints;
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

bool TouchGate::eventIsFullyOwned(const TouchGate::TouchEvent &event) const
{
    for (int i = 0; i < event.touchPoints.count(); ++i) {
        if (!isTouchPointOwned(event.touchPoints[i].id())) {
            return false;
        }
    }

    return true;
}

void TouchGate::setTargetItem(QQuickItem *item)
{
    // TODO: changing the target item while dispatch of touch events is taking place will
    //       create a mess

    if (item == m_dispatcher.targetItem())
        return;

    m_dispatcher.setTargetItem(item);
    Q_EMIT targetItemChanged(item);
}

void TouchGate::dispatchTouchEventToTarget(const TouchEvent &event)
{
    removeTouchInfoForEndedTouches(event.touchPoints);
    m_dispatcher.dispatch(event.device,
            event.modifiers,
            event.touchPoints,
            event.window,
            event.timestamp);
}

void TouchGate::removeTouchInfoForEndedTouches(const QList<QTouchEvent::TouchPoint> &touchPoints)
{
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

void TouchGate::onEnabledChanged()
{
    ugDebug(" enabled = " << isEnabled());
    if (!isEnabled()) {
        reset();
    }
}

void TouchGate::reset()
{
    m_storedEvents.clear();
    m_touchInfoMap.clear();
    m_dispatcher.reset();
}

TouchGate::TouchEvent::TouchEvent(QTouchDevice *device,
            Qt::KeyboardModifiers modifiers,
            const QList<QTouchEvent::TouchPoint> &touchPoints,
            QWindow *window,
            ulong timestamp)
    : device(device)
    , modifiers(modifiers)
    , touchPoints(touchPoints)
    , window(window)
    , timestamp(timestamp)
{
}

bool TouchGate::TouchEvent::removeTouch(int touchId)
{
    bool removed = false;
    for (int i = 0; i < touchPoints.count() && !removed; ++i) {
        if (touchPoints[i].id() == touchId) {
            touchPoints.removeAt(i);
            removed = true;
        }
    }

    return removed;
}
