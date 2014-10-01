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

#include <QQuickItem>
#include <QList>
#include <QPointer>
#include <QMap>

#define TOUCHGATE_DEBUG 0

class TouchOwnershipEvent;

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
    bool event(QEvent *e) override;

    QQuickItem *targetItem() { return m_targetItem; }
    void setTargetItem(QQuickItem *item);

Q_SIGNALS:
    void targetItemChanged(QQuickItem *item);

protected:
    void touchEvent(QTouchEvent *event) override;
private:
    void touchOwnershipEvent(TouchOwnershipEvent *event);
    bool isTouchPointOwned(int touchId) const;
    void storeTouchEvent(const QTouchEvent *event);
    void removeTouchFromStoredEvents(int touchId);
    void dispatchFullyOwnedEvents();
    bool removeTouchFromEvent(int touchId, QTouchEvent *event);
    bool eventIsFullyOwned(const QTouchEvent *event) const;
    void dispatchTouchEventToTarget(QTouchEvent* event);
    void transformTouchPoints(QList<QTouchEvent::TouchPoint> &touchPoints, const QTransform &transform);
    QTouchEvent *touchEventWithPoints(const QTouchEvent &event,
                                      const QList<QTouchEvent::TouchPoint> &newPoints);
    void removeTouchInfoForEndedTouches(QTouchEvent *event);

    #if TOUCHGATE_DEBUG
    QString oldestPendingTouchIdsString();
    #endif

    // TODO: Optimize storage of buffered events
    QList<QTouchEvent*> m_storedEvents;

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

    QPointer<QQuickItem> m_targetItem;

    friend class tst_TouchGate;
};

#endif // UBUNTU_TOUCH_GATE_H
