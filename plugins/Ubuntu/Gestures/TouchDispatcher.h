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

#ifndef UBUNTU_TOUCH_DISPATCHER_H
#define UBUNTU_TOUCH_DISPATCHER_H

#include "UbuntuGesturesQmlGlobal.h"

#include <QPointer>
#include <QQuickItem>

/*
   Dispatches touches to the given target, converting the touch point
   coordinates accordingly.

   Also takes care of synthesizing mouse events in case the target
   doesn't work with touch events.
 */
class UBUNTUGESTURESQML_EXPORT TouchDispatcher {
public:
    TouchDispatcher();

    void setTargetItem(QQuickItem *target);
    QQuickItem *targetItem() { return m_targetItem; }

    void dispatch(QTouchDevice *device,
            Qt::KeyboardModifiers modifiers,
            const QList<QTouchEvent::TouchPoint> &touchPoints,
            QWindow *window,
            ulong timestamp);

    void reset();

    enum Status {
        NoActiveTouch,
        DeliveringTouchEvents,
        DeliveringMouseEvents,
        TargetRejectedTouches
    };
private:
    void dispatchTouchBegin(
            QTouchDevice *device,
            Qt::KeyboardModifiers modifiers,
            const QList<QTouchEvent::TouchPoint> &touchPoints,
            QWindow *window,
            ulong timestamp);
    void dispatchAsTouch(QEvent::Type eventType,
            QTouchDevice *device,
            Qt::KeyboardModifiers modifiers,
            const QList<QTouchEvent::TouchPoint> &touchPoints,
            QWindow *window,
            ulong timestamp);
    void dispatchAsMouse(
            QTouchDevice *device,
            Qt::KeyboardModifiers modifiers,
            const QList<QTouchEvent::TouchPoint> &touchPoints,
            ulong timestamp);

    static void transformTouchPoints(QList<QTouchEvent::TouchPoint> &touchPoints, const QTransform &transform);
    QTouchEvent *createQTouchEvent(QEvent::Type eventType,
            QTouchDevice *device,
            Qt::KeyboardModifiers modifiers,
            const QList<QTouchEvent::TouchPoint> &touchPoints,
            QWindow *window,
            ulong timestamp);
    QMouseEvent *touchToMouseEvent(QEvent::Type type, const QTouchEvent::TouchPoint &p,
            ulong timestamp, Qt::KeyboardModifiers modifiers, bool transformNeeded = true);

    bool checkIfDoubleClicked(ulong newPressEventTimestamp);

    void setStatus(Status status);

    static QEvent::Type resolveEventType(const QList<QTouchEvent::TouchPoint> &touchPoints);

    QPointer<QQuickItem> m_targetItem;

    Status m_status;

    int m_touchMouseId;
    ulong m_touchMousePressTimestamp;
};

#endif // UBUNTU_TOUCH_DISPATCHER_H
