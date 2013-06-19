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
 Put a DragHandle inside a Showable to enable the user to drag it from that handle.
 Main use case is to drag fullscreen Showables into the screen or off the screen.

 This example shows a DragHandle placed on the right corner of a Showable, used
 to slide it away, off the screen.

  Showable {
    x: 0
    y: 0
    width: ... // screen width
    height: ... // screen height
    shown: true
    ...
    DragHandle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: units.gu(2)

        direction: DirectionalDragArea::Leftwards
    }
  }

 */
DirectionalDragArea {
    id: dragArea

    // Once we are satisfied with those values, make them the default
    // and remove them from here for the sake of consistency
    maxDeviation: units.gu(1)
    wideningAngle: 20
    distanceThreshold: units.gu(3)
    minSpeed: units.gu(5)

    // How far you can drag
    property real maxTotalDragDistance: Direction.isHorizontal(direction) ? parent.width : parent.height

    property var __previousStatus
    property real __totalDragDistance: 0

    property alias edgeDragEvaluator: dragEvaluator

    EdgeDragEvaluator {
        objectName: "edgeDragEvaluator"
        id: dragEvaluator
        trackedPosition: Direction.isHorizontal(direction) ? parent.x + touchX : parent.y + touchY
        maxDragDistance: maxTotalDragDistance
        direction: dragArea.direction
    }

    onDistanceChanged: {
        if (status === DirectionalDragArea.Recognized) {
            // don't go the whole distance in order to smooth out the movement
            var step = distance * 0.3

            step = __limitMovement(step)

            __totalDragDistance += step

            if (Direction.isHorizontal(direction)) {
                parent.x += step
            } else {
                parent.y += step
            }
        }
    }


    function __limitMovement(step) {
        if (Direction.isPositive(direction)) {
            if (__totalDragDistance + step > maxTotalDragDistance) {
                step = maxTotalDragDistance - __totalDragDistance
            } else if (__totalDragDistance + step < 0) {
                step = 0 - __totalDragDistance
            }
        } else {
            if (__totalDragDistance + step < -maxTotalDragDistance) {
                step = -maxTotalDragDistance - __totalDragDistance
            } else if (__totalDragDistance + step > 0) {
                step = 0 - __totalDragDistance
            }
        }

        return step
    }

    onStatusChanged: {
        if (status === DirectionalDragArea.WaitingForTouch) {
            dragEvaluator.updateIdleTime()
            if (__previousStatus === DirectionalDragArea.Recognized) {
                __onFinishedRecognizedGesture()
            }
            __totalDragDistance = 0
        }
        else if (status === DirectionalDragArea.Undecided) {
            dragEvaluator.reset()
        }
        else if (status === DirectionalDragArea.Recognized) {
            if (__previousStatus === DirectionalDragArea.WaitingForTouch)
                dragEvaluator.reset()
        }
        __previousStatus = status
    }

    function __onFinishedRecognizedGesture() {
        if (dragEvaluator.shouldAutoComplete())
            __completeDrag()
        else
            __rollbackDrag()
    }

    function __completeDrag() {
        if (parent.shown)
            parent.hide()
        else
            parent.show()
    }

    function __rollbackDrag() {
        if (parent.shown)
            parent.show()
        else
            parent.hide()
    }
}
