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

#ifndef UBUNTU_TOUCH_GATE_H
#define UBUNTU_TOUCH_GATE_H

#include "UbuntuGesturesQmlGlobal.h"
#include "TouchDispatcher.h"
#include <UbuntuGestures/ubuntugesturesglobal.h>

#include <QQuickItem>
#include <QList>
#include <QMap>

#define TOUCHGATE_DEBUG 0

UG_FORWARD_DECLARE_CLASS(TouchOwnershipEvent)

/*
  Blocks the passage of events until ownership over the related touch points is granted.

  Blocked touch events won't be discarded. Instead they will be buffered until ownership
  is granted. If ownership is given to another item, the event buffer is cleared.

  A TouchGate is useful as a mediator for items that do not understand, or gracefully handle,
  touch canceling. By having a TouchGate in front of them you guarantee that only owned touches (i.e.,
  touches that won't be canceled later) reaches them.
 */
class UBUNTUGESTURESQML_EXPORT TouchGate : public QQuickItem {
    Q_OBJECT

    // Item that's going to receive the touch events that make it through the gate.
    Q_PROPERTY(QQuickItem* targetItem READ targetItem WRITE setTargetItem NOTIFY targetItemChanged)

public:
    TouchGate(QQuickItem *parent = nullptr);

    bool event(QEvent *e) override;

    QQuickItem *targetItem() { return m_dispatcher.targetItem(); }
    void setTargetItem(QQuickItem *item);

Q_SIGNALS:
    void targetItemChanged(QQuickItem *item);

protected:
    void touchEvent(QTouchEvent *event) override;
    void itemChange(ItemChange change, const ItemChangeData &value) override;

private Q_SLOTS:
    void onEnabledChanged();

private:
    void reset();

    class TouchEvent {
    public:
        TouchEvent(QTouchDevice *device,
            Qt::KeyboardModifiers modifiers,
            const QList<QTouchEvent::TouchPoint> &touchPoints,
            QWindow *window,
            ulong timestamp);

        bool removeTouch(int touchId);

        QTouchDevice *device;
        Qt::KeyboardModifiers modifiers;
        QList<QTouchEvent::TouchPoint> touchPoints;
        QWindow *window;
        ulong timestamp;
    };

    void touchOwnershipEvent(UG_PREPEND_NAMESPACE(TouchOwnershipEvent) *event);
    bool isTouchPointOwned(int touchId) const;
    void storeTouchEvent(QTouchDevice *device,
            Qt::KeyboardModifiers modifiers,
            const QList<QTouchEvent::TouchPoint> &touchPoints,
            QWindow *window,
            ulong timestamp);
    void removeTouchFromStoredEvents(int touchId);
    void dispatchFullyOwnedEvents();
    bool eventIsFullyOwned(const TouchEvent &event) const;

    void dispatchTouchEventToTarget(const TouchEvent &event);

    void removeTouchInfoForEndedTouches(const QList<QTouchEvent::TouchPoint> &touchPoints);

    #if TOUCHGATE_DEBUG
    QString oldestPendingTouchIdsString();
    #endif

    QList<TouchEvent> m_storedEvents;

    enum {
        OwnershipUndefined,
        OwnershipRequested,
        OwnershipGranted,
    };
    class TouchInfo {
    public:
        TouchInfo() {ownership = OwnershipUndefined; ended = false;}
        int ownership;
        bool ended;
    };
    QMap<int, TouchInfo> m_touchInfoMap;

    TouchDispatcher m_dispatcher;

    friend class tst_TouchGate;
};

#endif // UBUNTU_TOUCH_GATE_H
