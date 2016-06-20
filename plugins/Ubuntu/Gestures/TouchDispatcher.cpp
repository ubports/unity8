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

#include "TouchDispatcher.h"

#include <QGuiApplication>
#include <QScopedPointer>
#include <QStyleHints>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-pedantic"
#include <private/qquickitem_p.h>
#pragma GCC diagnostic pop

#define TOUCHDISPATCHER_DEBUG 0

#if TOUCHDISPATCHER_DEBUG
#define ugDebug(params) qDebug().nospace() << "[TouchDispatcher(" << this << ")] " << params
#include <DebugHelpers.h>
#else // TOUCHDISPATCHER_DEBUG
#define ugDebug(params) ((void)0)
#endif // TOUCHDISPATCHER_DEBUG

TouchDispatcher::TouchDispatcher()
    : m_status(NoActiveTouch)
    , m_touchMouseId(-1)
    , m_touchMousePressTimestamp(0)
{
}

void TouchDispatcher::setTargetItem(QQuickItem *target)
{
    if (target != m_targetItem) {
        m_targetItem = target;
        if (m_status != NoActiveTouch) {
            qWarning("[TouchDispatcher] Changing target item in the middle of a touch stream");
            setStatus(TargetRejectedTouches);
        }
    }
}

void TouchDispatcher::dispatch(QTouchDevice *device,
                               Qt::KeyboardModifiers modifiers,
                               const QList<QTouchEvent::TouchPoint> &touchPoints,
                               QWindow *window,
                               ulong timestamp)
{
    if (m_targetItem.isNull()) {
        qWarning("[TouchDispatcher] Cannot dispatch touch event because target item is null");
        return;
    }

    QEvent::Type eventType = resolveEventType(touchPoints);

    if (eventType == QEvent::TouchBegin) {
        dispatchTouchBegin(device, modifiers, touchPoints, window, timestamp);

    } else if (eventType == QEvent::TouchUpdate || eventType == QEvent::TouchEnd) {

        if (m_status == DeliveringTouchEvents) {
            dispatchAsTouch(eventType, device, modifiers, touchPoints, window, timestamp);
        } else if (m_status == DeliveringMouseEvents) {
            dispatchAsMouse(device, modifiers, touchPoints, timestamp);
        } else {
            Q_ASSERT(m_status == TargetRejectedTouches);
            ugDebug("Not dispatching touch event to " << m_targetItem.data()
                << "because it already rejected the touch stream.");
            // Do nothing
        }

        if (eventType == QEvent::TouchEnd) {
            setStatus(NoActiveTouch);
            m_touchMouseId = -1;
        }

    } else {
        // Should never happen
        qCritical() << "[TouchDispatcher] Unexpected event type" << eventType;
        Q_ASSERT(false);
        return;
    }
}

void TouchDispatcher::dispatchTouchBegin(
            QTouchDevice *device,
            Qt::KeyboardModifiers modifiers,
            const QList<QTouchEvent::TouchPoint> &touchPoints,
            QWindow *window,
            ulong timestamp)
{
    Q_ASSERT(m_status == NoActiveTouch);
    QQuickItem *targetItem = m_targetItem.data();

    if (!targetItem->isEnabled() || !targetItem->isVisible()) {
        ugDebug("Cannot dispatch touch event to " << targetItem << " because it's disabled or invisible.");
        return;
    }

    // Map touch points to targetItem coordinates
    QList<QTouchEvent::TouchPoint> targetTouchPoints = touchPoints;
    transformTouchPoints(targetTouchPoints, QQuickItemPrivate::get(targetItem)->windowToItemTransform());

    QScopedPointer<QTouchEvent> touchEvent(
            createQTouchEvent(QEvent::TouchBegin, device, modifiers, targetTouchPoints, window, timestamp));


    ugDebug("dispatching " << qPrintable(touchEventToString(touchEvent.data()))
            << " to " << targetItem);
    QCoreApplication::sendEvent(targetItem, touchEvent.data());


    if (touchEvent->isAccepted()) {
        ugDebug("Item accepted the touch event.");
        setStatus(DeliveringTouchEvents);
    } else if (targetItem->acceptedMouseButtons() & Qt::LeftButton) {
        ugDebug("Item rejected the touch event. Trying a QMouseEvent");
        // NB: Arbitrarily chose the first touch point to emulate the mouse pointer
        QScopedPointer<QMouseEvent> mouseEvent(
                touchToMouseEvent(QEvent::MouseButtonPress, targetTouchPoints.at(0), timestamp,
                                  modifiers, false /* transformNeeded */));
        Q_ASSERT(targetTouchPoints.at(0).state() == Qt::TouchPointPressed);

        ugDebug("dispatching " << qPrintable(mouseEventToString(mouseEvent.data()))
                << " to " << m_targetItem.data());
        QCoreApplication::sendEvent(targetItem, mouseEvent.data());
        if (mouseEvent->isAccepted()) {
            ugDebug("Item accepted the QMouseEvent.");
            setStatus(DeliveringMouseEvents);
            m_touchMouseId = targetTouchPoints.at(0).id();

            if (checkIfDoubleClicked(timestamp)) {
                QScopedPointer<QMouseEvent> doubleClickEvent(
                        touchToMouseEvent(QEvent::MouseButtonDblClick, targetTouchPoints.at(0), timestamp,
                                          modifiers, false /* transformNeeded */));
                ugDebug("dispatching " << qPrintable(mouseEventToString(doubleClickEvent.data()))
                        << " to " << m_targetItem.data());
                QCoreApplication::sendEvent(targetItem, doubleClickEvent.data());
            }

        } else {
            ugDebug("Item rejected the QMouseEvent.");
            setStatus(TargetRejectedTouches);
        }
    } else {
        ugDebug("Item rejected the touch event and does not accept mouse buttons.");
        setStatus(TargetRejectedTouches);
    }
}

void TouchDispatcher::dispatchAsTouch(QEvent::Type eventType,
        QTouchDevice *device,
        Qt::KeyboardModifiers modifiers,
        const QList<QTouchEvent::TouchPoint> &touchPoints,
        QWindow *window,
        ulong timestamp)
{
    QQuickItem *targetItem = m_targetItem.data();

    // Map touch points to targetItem coordinates
    QList<QTouchEvent::TouchPoint> targetTouchPoints = touchPoints;
    transformTouchPoints(targetTouchPoints, QQuickItemPrivate::get(targetItem)->windowToItemTransform());

    QScopedPointer<QTouchEvent> eventForTargetItem(
            createQTouchEvent(eventType, device, modifiers, targetTouchPoints, window, timestamp));


    ugDebug("dispatching " << qPrintable(touchEventToString(eventForTargetItem.data()))
            << " to " << targetItem);
    QCoreApplication::sendEvent(targetItem, eventForTargetItem.data());
}

void TouchDispatcher::dispatchAsMouse(
        QTouchDevice * /*device*/,
        Qt::KeyboardModifiers modifiers,
        const QList<QTouchEvent::TouchPoint> &touchPoints,
        ulong timestamp)
{
    // TODO: Detect double clicks in order to synthesize QEvent::MouseButtonDblClick events accordingly

    Q_ASSERT(!touchPoints.isEmpty());

    const QTouchEvent::TouchPoint *touchMouse = nullptr;

    if (m_touchMouseId != -1) {
        for (int i = 0; i < touchPoints.count() && !touchMouse; ++i) {
            const auto &touchPoint = touchPoints.at(i);
            if (touchPoint.id() == m_touchMouseId) {
                touchMouse = &touchPoint;
            }
        }

        Q_ASSERT(touchMouse);
        if (!touchMouse) {
            // should not happen, but deal with it just in case.
            qWarning("[TouchDispatcher] Didn't find touch with id %d, used for mouse pointer emulation.",
                    m_touchMouseId);
            m_touchMouseId = touchPoints.at(0).id();
            touchMouse = &touchPoints.at(0);
        }
    } else {
        // Try to find a new touch for mouse emulation
        for (int i = 0; i < touchPoints.count() && !touchMouse; ++i) {
            const auto &touchPoint = touchPoints.at(i);
            if (touchPoint.state() == Qt::TouchPointPressed) {
                touchMouse = &touchPoint;
                m_touchMouseId = touchMouse->id();
            }
        }
    }

    if (touchMouse) {
        QEvent::Type eventType;
        if (touchMouse->state() == Qt::TouchPointPressed) {
            eventType = QEvent::MouseButtonPress;
        } else if (touchMouse->state() == Qt::TouchPointReleased) {
            eventType = QEvent::MouseButtonRelease;
            m_touchMouseId = -1;
        } else {
            eventType = QEvent::MouseMove;
        }

        QScopedPointer<QMouseEvent> mouseEvent(touchToMouseEvent(eventType, *touchMouse, timestamp, modifiers,
                    true /* transformNeeded */));

        ugDebug("dispatching " << qPrintable(mouseEventToString(mouseEvent.data()))
                << " to " << m_targetItem.data());
        QCoreApplication::sendEvent(m_targetItem.data(), mouseEvent.data());
    }
}

QTouchEvent *TouchDispatcher::createQTouchEvent(QEvent::Type eventType,
        QTouchDevice *device,
        Qt::KeyboardModifiers modifiers,
        const QList<QTouchEvent::TouchPoint> &touchPoints,
        QWindow *window,
        ulong timestamp)
{
    Qt::TouchPointStates eventStates = 0;
    for (int i = 0; i < touchPoints.count(); i++)
        eventStates |= touchPoints[i].state();
    // if all points have the same state, set the event type accordingly
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
    touchEvent->setWindow(window);
    touchEvent->setTarget(m_targetItem.data());
    touchEvent->setDevice(device);
    touchEvent->setModifiers(modifiers);
    touchEvent->setTouchPoints(touchPoints);
    touchEvent->setTouchPointStates(eventStates);
    touchEvent->setTimestamp(timestamp);
    touchEvent->accept();
    return touchEvent;
}

// NB: From QQuickWindow
void TouchDispatcher::transformTouchPoints(QList<QTouchEvent::TouchPoint> &touchPoints, const QTransform &transform)
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

// Copied with minor modifications from qtdeclarative/src/quick/items/qquickwindow.cpp
QMouseEvent *TouchDispatcher::touchToMouseEvent(
        QEvent::Type type, const QTouchEvent::TouchPoint &p,
        ulong timestamp, Qt::KeyboardModifiers modifiers,
        bool transformNeeded)
{
    QQuickItem *item = m_targetItem.data();

    // The touch point local position and velocity are not yet transformed.
    QMouseEvent *me = new QMouseEvent(type, transformNeeded ? item->mapFromScene(p.scenePos()) : p.pos(),
                                      p.scenePos(), p.screenPos(), Qt::LeftButton,
                                      (type == QEvent::MouseButtonRelease ? Qt::NoButton : Qt::LeftButton),
                                      modifiers);
    me->setAccepted(true);
    me->setTimestamp(timestamp);
    QVector2D transformedVelocity = p.velocity();
    if (transformNeeded) {
        QQuickItemPrivate *itemPrivate = QQuickItemPrivate::get(item);
        QMatrix4x4 transformMatrix(itemPrivate->windowToItemTransform());
        transformedVelocity = transformMatrix.mapVector(p.velocity()).toVector2D();
    }

    // Add these later if needed:
    //QGuiApplicationPrivate::setMouseEventCapsAndVelocity(me, event->device()->capabilities(), transformedVelocity);
    //QGuiApplicationPrivate::setMouseEventSource(me, Qt::MouseEventSynthesizedByQt);
    return me;
}

/*
    Copied from qquickwindow.cpp which has:
    Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies)
    Under GPL 3.0 license.
*/
bool TouchDispatcher::checkIfDoubleClicked(ulong newPressEventTimestamp)
{
    bool doubleClicked;

    if (m_touchMousePressTimestamp == 0) {
        // just initialize the variable
        m_touchMousePressTimestamp = newPressEventTimestamp;
        doubleClicked = false;
    } else {
        ulong timeBetweenPresses = newPressEventTimestamp - m_touchMousePressTimestamp;
        ulong doubleClickInterval = static_cast<ulong>(qApp->styleHints()->
                mouseDoubleClickInterval());
        doubleClicked = timeBetweenPresses < doubleClickInterval;
        if (doubleClicked) {
            m_touchMousePressTimestamp = 0;
        } else {
            m_touchMousePressTimestamp = newPressEventTimestamp;
        }
    }

    return doubleClicked;
}

void TouchDispatcher::setStatus(Status status)
{
    if (status != m_status) {
        #if TOUCHDISPATCHER_DEBUG
        switch (status) {
        case NoActiveTouch:
            ugDebug("status = NoActiveTouch");
            break;
        case DeliveringTouchEvents:
            ugDebug("status = DeliveringTouchEvents");
            break;
        case DeliveringMouseEvents:
            ugDebug("status = DeliveringMouseEvents");
            break;
        case TargetRejectedTouches:
            ugDebug("status = TargetRejectedTouches");
            break;
        default:
            ugDebug("status = " << status);
            break;
        }
        #endif
        m_status = status;
    }
}

void TouchDispatcher::reset()
{
    setStatus(NoActiveTouch);
    m_touchMouseId = -1;
    m_touchMousePressTimestamp =0;
}

QEvent::Type TouchDispatcher::resolveEventType(const QList<QTouchEvent::TouchPoint> &touchPoints)
{
    QEvent::Type eventType;

    Qt::TouchPointStates eventStates = 0;
    for (int i = 0; i < touchPoints.count(); i++)
        eventStates |= touchPoints[i].state();

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

    return eventType;
}
