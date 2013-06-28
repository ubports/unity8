/*
 * Copyright (C) 2013 Canonical, Ltd.
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
#include "AxisVelocityCalculator.h"
#include "UbuntuGesturesGlobal.h"
#include "Damper.h"
#include "Direction.h"

namespace UbuntuGestures {
/* Defines an interface for a Timer. */
class UBUNTUGESTURES_EXPORT AbstractTimer : public QObject {
    Q_OBJECT
public:
    AbstractTimer(QObject *parent) : QObject(parent), m_isRunning(false) {}
    virtual int interval() const = 0;
    virtual void setInterval(int msecs) = 0;
    virtual void start() { m_isRunning = true; };
    virtual void stop() { m_isRunning = false; }
    bool isRunning() const { return m_isRunning; }
Q_SIGNALS:
    void timeout();
private:
    bool m_isRunning;
};
}

/*
 An area that detects axis-aligned single-finger drag gestures

 If a drag deviates too much from the components' direction recognition will
 fail. It will also fail if the drag or flick is too short. E.g. a noisy or
 fidgety click

 See doc/DirectionalDragArea.svg
 */
class UBUNTUGESTURES_EXPORT DirectionalDragArea : public QQuickItem {
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

    // The current status of the directional drag gesture area.
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)

    // Whether a drag gesture is taking place
    // This will be true as long as status is Undecided or Recognized
    // When a gesture gets rejected, dragging turns to false.
    Q_PROPERTY(bool dragging READ dragging NOTIFY draggingChanged)

    /////
    // stuff that will be set in stone at some point

    // How far the touch point can move away from its expected position before
    // it causes a rejection in the gesture recognition. This is to compensate
    // for both noise in the touch input signal and for the natural irregularities
    // in the finger movement.
    // Proper value is likely device-specific.
    Q_PROPERTY(qreal maxDeviation READ maxDeviation WRITE setMaxDeviation NOTIFY maxDeviationChanged)

    // Widening angle, in degrees
    // It's roughly the maximum angle a touch point can make relative to the
    // axis defined by the compoment's direction for it to be recognized as a
    // directional drag.
    Q_PROPERTY(qreal wideningAngle READ wideningAngle WRITE setWideningAngle
               NOTIFY wideningAngleChanged)

    // How far a touch point has to move from its initial position in order for
    // it to be recognized as a directional drag.
    Q_PROPERTY(qreal distanceThreshold READ distanceThreshold WRITE setDistanceThreshold
               NOTIFY distanceThresholdChanged)

    // Minimum speed a gesture needs to have in order to be recognized as a
    // directional drag.
    // In pixels per second
    Q_PROPERTY(qreal minSpeed READ minSpeed WRITE setMinSpeed NOTIFY minSpeedChanged)

    // A gesture will be rejected if more than maxSilenceTime milliseconds has
    // passed since we last got an input event from it (during Undecided state).
    //
    // Silence (i.e., lack of new input events) doesn't necessarily mean that the user's
    // finger is still (zero drag speed). In some cases the finger might be moving but
    // the driver's high noise filtering might cause those silence periods, specially
    // in the moments succeeding a press (talking about Galaxy Nexus here).
    Q_PROPERTY(int maxSilenceTime READ maxSilenceTime
                                  WRITE setMaxSilenceTime
                                  NOTIFY maxSilenceTimeChanged)
    //
    /////

    Q_ENUMS(Direction)
    Q_ENUMS(Status)
public:
    DirectionalDragArea(QQuickItem *parent = 0);

    Direction::Type direction() const;
    void setDirection(Direction::Type);

    // Describes the state of the directional drag gesture.
    enum Status {
        // There's no touch point over this area.
        WaitingForTouch,

        // A touch point has landed on this area but it's not know yet whether it is
        // performing a drag in the correct direction.
        Undecided, //Recognizing,

        // There's a touch point in this area and it performed a drag in the correct
        // direction.
        //
        // Once recognized, the gesture state will move back to Absent only once
        // that touch point ends. The gesture will remain in the Recognized state even if
        // the touch point starts moving in other directions or halts.
        Recognized,

        // A gesture was performed but it wasn't a single-touch drag in the correct
        // direction.
        // It will remain in this state until there are no more touch points over this
        // area, at which point it will move to Absent state.
        Rejected
    };
    Status status() const { return m_status; }

    qreal distance() const;
    qreal sceneDistance() const;

    qreal touchX() const;
    qreal touchY() const;

    qreal touchSceneX() const;
    qreal touchSceneY() const;

    bool dragging() const { return (m_status == Undecided) || (m_status == Recognized); }

    qreal maxDeviation() const { return m_dampedPos.maxDelta(); }
    void setMaxDeviation(qreal value);

    qreal wideningAngle() const;
    void setWideningAngle(qreal value);

    qreal distanceThreshold() const { return m_distanceThreshold; }
    void setDistanceThreshold(qreal value);

    qreal minSpeed() const { return m_minSpeed; }
    void setMinSpeed(qreal value);

    int maxSilenceTime() const { return m_maxSilenceTime; }
    void setMaxSilenceTime(int value);

    // Replaces the existing Timer with the given one.
    //
    // Useful for providing a fake timer when testing.
    void setRecognitionTimer(UbuntuGestures::AbstractTimer *timer);

    // Useful for testing, where a fake time source can be supplied
    void setTimeSource(UbuntuGestures::TimeSource *timeSource);

Q_SIGNALS:
    void directionChanged(Direction::Type direction);
    void statusChanged(Status value);
    void draggingChanged(bool value);
    void distanceChanged(qreal value);
    void sceneDistanceChanged(qreal value);
    void maxDeviationChanged(qreal value);
    void wideningAngleChanged(qreal value);
    void distanceThresholdChanged(qreal value);
    void minSpeedChanged(qreal value);
    void maxSilenceTimeChanged(int value);
    void touchXChanged(qreal value);
    void touchYChanged(qreal value);
    void touchSceneXChanged(qreal value);
    void touchSceneYChanged(qreal value);

protected:
    virtual void touchEvent(QTouchEvent *event);

private Q_SLOTS:
    void checkSpeed();

private:
    void touchEvent_absent(QTouchEvent *event);
    void touchEvent_undecided(QTouchEvent *event);
    void touchEvent_recognized(QTouchEvent *event);
    void touchEvent_rejected(QTouchEvent *event);
    bool pointInsideAllowedArea() const;
    bool movingInRightDirection() const;
    bool movedFarEnough(const QPointF &point) const;
    const QTouchEvent::TouchPoint *fetchTargetTouchPoint(QTouchEvent *event);
    void setStatus(Status newStatus);
    void setPreviousPos(QPointF point);
    void setPreviousScenePos(QPointF point);
    void updateVelocityCalculator(QPointF point);

    Status m_status;

    QPointF m_startPos;
    QPointF m_startScenePos;
    QPointF m_previousPos;
    QPointF m_previousScenePos;
    int m_touchId;

    // A movement damper is used in some of the gesture recognition calculations
    // to get rid of noise or small oscillations in the touch position.
    DampedPointF m_dampedPos;
    QPointF m_previousDampedPos;

    Direction::Type m_direction;
    qreal m_wideningAngle; // in degrees
    qreal m_wideningFactor; // it's tan(degreesToRadian(m_wideningAngle))
    qreal m_distanceThreshold;
    qreal m_minSpeed;
    int m_maxSilenceTime; // in milliseconds
    int m_silenceTime; // in milliseconds
    int m_numSamplesOnLastSpeedCheck;
    UbuntuGestures::AbstractTimer *m_recognitionTimer;
    AxisVelocityCalculator *m_velocityCalculator;
};

#endif // DIRECTIONAL_DRAG_AREA_H
