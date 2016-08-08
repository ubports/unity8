/*
 * Copyright (C) 2013 - Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License, as
 * published by the  Free Software Foundation; either version 2.1 or 3.0
 * of the License.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the applicable version of the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of both the GNU Lesser General Public
 * License along with this program. If not, see <http://www.gnu.org/licenses/>
 *
 * Authored by: Daniel d'Andrada <daniel.dandrada@canonical.com>
 */

#ifndef VELOCITY_CALCULATOR_H
#define VELOCITY_CALCULATOR_H

#include "UbuntuGesturesQmlGlobal.h"
#include <stdint.h>
#include <QtCore/QObject>
#include <UbuntuGestures/private/timesource_p.h>

/*
  Estimates the current velocity of a finger based on recent movement along an axis

  Taking an estimate from a reasonable number of samples, instead of only
  from its last movement, removes wild variations in velocity caused
  by the jitter normally present in input from a touchscreen.

  Usage example:

    AxisVelocityCalculator {
        id: velocityCalculator
        trackedPosition: myMouseArea.mouseX
    }

    MouseArea {
        id: myMouseArea

        onReleased: {
            console.log("Drag velocity along the X axis before release was: "
                        + velocityCalculator.calculate())
        }
    }
 */
class UBUNTUGESTURESQML_EXPORT AxisVelocityCalculator : public QObject
{
    Q_OBJECT

    /*
        Position whose movement will be tracked to calculate its velocity
     */
    Q_PROPERTY(qreal trackedPosition READ trackedPosition WRITE setTrackedPosition
               NOTIFY trackedPositionChanged)
public:

    /*
      Regular, simple, constructor
     */
    AxisVelocityCalculator(QObject *parent = 0);

    /*
      Constructor that takes a TimeSource
     */
    AxisVelocityCalculator(const UG_PREPEND_NAMESPACE(SharedTimeSource) &timeSource, QObject *parent = 0);

    virtual ~AxisVelocityCalculator();

    qreal trackedPosition() const;
    void setTrackedPosition(qreal value);

    /*
      Calculates the finger velocity, in axis units/millisecond
    */
    Q_INVOKABLE qreal calculate();

    /*
      Removes all stored movements from previous calls to setTrackedPosition()
    */
    Q_INVOKABLE void reset();

    int numSamples() const;

    /*
        Replaces the TimeSource with the given one. Useful for testing purposes.
     */
    void setTimeSource(const UG_PREPEND_NAMESPACE(SharedTimeSource) &timeSource);

    /*
        The minimum amount of samples needed for a velocity calculation.
     */
    static const int MIN_SAMPLES_NEEDED = 2;

    /*
      Maximum number of movement samples stored
    */
    static const int MAX_SAMPLES = 50;

    /*
      Age of the oldest sample considered in the velocity calculations, in
      milliseconds, compared to the most recent one.
    */
    static const int AGE_OLDEST_SAMPLE = 100;

Q_SIGNALS:
    void trackedPositionChanged(qreal value);

private:

    /*
        Inform that trackedPosition remained motionless since the time it was
        last changed.

        It's the same as calling setTrackedPosition(trackedPosition())
     */
    void updateIdleTime();

    /*
      How much the finger has moved since processMovement() was last called.
    */
    void processMovement(qreal movement);

    class Sample
    {
        public:
            qreal mov; /* movement distance since last sample */
            qint64 time; /* time, in milliseconds */
    };

    /* a circular buffer of samples */
    Sample m_samples[MAX_SAMPLES];
    int m_samplesRead; /* index of the oldest sample available. -1 if buffer is empty */
    int m_samplesWrite; /* index where the next sample will be written */

    UG_PREPEND_NAMESPACE(SharedTimeSource) m_timeSource;

    qreal m_trackedPosition;
};

#endif // VELOCITY_CALCULATOR_H
