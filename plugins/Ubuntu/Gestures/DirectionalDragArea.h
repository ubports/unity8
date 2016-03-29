/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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

#ifndef DIRECTIONAL_DRAG_AREA_H
#define DIRECTIONAL_DRAG_AREA_H

#include <QtQuick/QQuickItem>
#include "UbuntuGesturesQmlGlobal.h"
#include "Damper.h"
#include "Direction.h"

// lib UbuntuGestures
#include <Pool.h>
#include <Timer.h>

class TouchOwnershipEvent;
class UnownedTouchEvent;
class DirectionalDragAreaPrivate;

/*
 An area that detects axis-aligned single-finger drag gestures

 If a drag deviates too much from the components' direction recognition will
 fail. It will also fail if the drag or flick is too short. E.g. a noisy or
 fidgety click

 See doc/DirectionalDragArea.svg
 */
class UBUNTUGESTURESQML_EXPORT DirectionalDragArea : public QQuickItem {
    Q_OBJECT

    // The direction in which the gesture should move in order to be recognized.
    Q_PROPERTY(Direction::Type direction READ direction WRITE setDirection NOTIFY directionChanged)

    // The distance travelled by the finger along the axis specified by
    // DirectionalDragArea's direction.
    Q_PROPERTY(qreal distance READ distance NOTIFY distanceChanged)

    // The distance travelled by the finger along the axis specified by
    // DirectionalDragArea's direction in scene coordinates
    Q_PROPERTY(qreal sceneDistance READ sceneDistance NOTIFY sceneDistanceChanged)

    // Position of the touch point performing the drag relative to this item.
    Q_PROPERTY(qreal touchX READ touchX NOTIFY touchXChanged)
    Q_PROPERTY(qreal touchY READ touchY NOTIFY touchYChanged)

    // Position of the touch point performing the drag, in scene's coordinate system
    Q_PROPERTY(qreal touchSceneX READ touchSceneX NOTIFY touchSceneXChanged)
    Q_PROPERTY(qreal touchSceneY READ touchSceneY NOTIFY touchSceneYChanged)

    // Whether a drag gesture is taking place
    Q_PROPERTY(bool dragging READ dragging NOTIFY draggingChanged)

    // Whether the drag area is pressed.
    Q_PROPERTY(bool pressed READ pressed NOTIFY pressedChanged)

    // Whether a gesture should be Recognized as soon a touch lands on the area.
    // With this property enabled it will work pretty much like a MultiPointTouchArea,
    // just with a different API.
    //
    // It's false by default. In most cases you will not want that enabled.
    Q_PROPERTY(bool immediateRecognition
            READ immediateRecognition
            WRITE setImmediateRecognition
            NOTIFY immediateRecognitionChanged)

    // Whether we are merely monitoring touch events (in which case, we don't
    // claim ownership of the touch).
    Q_PROPERTY(bool monitorOnly READ monitorOnly WRITE setMonitorOnly NOTIFY monitorOnlyChanged)

    Q_ENUMS(Direction)
public:
    DirectionalDragArea(QQuickItem *parent = 0);

    Direction::Type direction() const;
    void setDirection(Direction::Type);

    qreal distance() const;
    qreal sceneDistance() const;

    qreal touchX() const;
    qreal touchY() const;

    qreal touchSceneX() const;
    qreal touchSceneY() const;

    bool dragging() const;

    bool pressed() const;

    bool immediateRecognition() const;
    void setImmediateRecognition(bool enabled);

    bool monitorOnly() const;
    void setMonitorOnly(bool monitorOnly);

    bool event(QEvent *e) override;

    /*
      In qmltests, sequences of touch events are sent all at once, unlike in "real life".
      Also qmltests might run really slowly, e.g. when run from inside virtual machines.
      Thus to remove a variable that qmltests cannot really control, namely time, this
      function removes all constraints that are sensible to elapsed time.

      This effectively makes the DirectionalDragArea easier to fool.
     */
    Q_INVOKABLE void removeTimeConstraints();

Q_SIGNALS:
    void directionChanged(Direction::Type direction);
    void draggingChanged(bool value);
    void pressedChanged(bool value);
    void distanceChanged(qreal value);
    void sceneDistanceChanged(qreal value);
    void touchXChanged(qreal value);
    void touchYChanged(qreal value);
    void touchSceneXChanged(qreal value);
    void touchSceneYChanged(qreal value);
    void immediateRecognitionChanged(bool value);
    void monitorOnlyChanged(bool value);

protected:
    void touchEvent(QTouchEvent *event) override;
    void itemChange(ItemChange change, const ItemChangeData &value) override;

public: // so tests can access it
    DirectionalDragAreaPrivate *d;
};

#endif // DIRECTIONAL_DRAG_AREA_H
