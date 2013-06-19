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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1

/*
   Evaluates end velocity (velocity at the moment the gesture ends) and travelled
   distance (delta between finger down and finger up positions) to determine
   whether the drag should continue by itself towards completion (auto-complete)
   after the finger has left the touchscreen.
 */
AxisVelocityCalculator {

    // How far the drag can go, or should go to achieve completion.
    property real maxDragDistance

    // Ending a drag at any point before this threshold will need some positive velocity
    // (i.e., towards the set direction) to get auto-completion (e.g. to get show()
    // called for a hidden Showable) and ending a drag at any point after this
    // threshold will need some negative velocity to avoid auto-completion.
    property real dragThreshold: maxDragDistance / 2

    property real minDragDistance: maxDragDistance * 0.1

    // Speed needed to get auto-completion for an hypothetical flick of length zero.
    //
    // This requirement is gradually reduced as flicks gets longer until it reaches
    // a value of zero for flicks of dragThreshold lenght.
    //
    // in pixels per second
    property real speedThreshold: units.gu(70)

    property int direction

    // Returns whether the drag should continue by itself until completed.
    function shouldAutoComplete() {
        var deltaPos = trackedPosition - __startPosition
        if (Math.abs(deltaPos) < minDragDistance) {
            return false
        }

        var minVelocity = __calculateMinimumVelocityForAutoCompletion(deltaPos)
        var velocity = calculate()

        if (Direction.isPositive(direction) && (velocity >= minVelocity)
            || !Direction.isPositive(direction) && (velocity <= minVelocity))
            return true
        else
            return false
    }

    property real __startPosition

    // speedThreshold in pixels per millisecond
    property real __speedThresholdMs: speedThreshold / 1000.0

    // Minimum velocity when a drag total distance is zero
    property real __v0: Direction.isPositive(direction) ? __speedThresholdMs : - __speedThresholdMs

    function __calculateMinimumVelocityForAutoCompletion(distance) {
        return __v0 - ((__speedThresholdMs / dragThreshold) * distance)
    }

    function reset() {
        __startPosition = trackedPosition
    }
}
