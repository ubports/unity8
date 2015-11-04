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

import QtQuick 2.4
import Ubuntu.Components 1.3

MouseArea {
    id: draggingArea

    property int orientation: Qt.Vertical
    property bool dragging
    property real dragVelocity: 0
    property real dragValue: (orientation == Qt.Vertical ? (mouseY - __pressedPosition.y)
                                                            : (mouseX - __pressedPosition.x))
    property real lateralPosition: orientation == Qt.Horizontal ? MathUtils.clamp(mouseY, 0, height) : MathUtils.clamp(mouseX, 0, width)
    property point __pressedPosition: Qt.point(0, 0)
    property var __dragEvents: []
    property bool clickValidated: true
    property bool zeroVelocityCounts: false

    // Can be replaced with a fake implementation during tests
    // property var __getCurrentTimeMs: function () { return new Date().getTime() }
    property var __dateTime: new function() {
        this.getCurrentTimeMs = function() {return new Date().getTime()}
    }


    signal dragStart
    signal dragEnd

    onDragValueChanged: {
        if (dragValue != 0 && pressed) {
            dragging = true
        }
    }

    onDraggingChanged: {
        if (dragging) {
            dragStart()
        }
        else {
            dragEnd()
        }
    }

    function updateSpeed() {
        var totalSpeed = 0
        for (var i=0; i<__dragEvents.length; i++) {
            totalSpeed += __dragEvents[i][3]
        }

        if (zeroVelocityCounts || Math.abs(totalSpeed) > 0.001) {
            dragVelocity = totalSpeed / __dragEvents.length * 1000
        }
    }

    function cullOldDragEvents(currentTime) {
        // cull events older than 50 ms but always keep the latest 2 events
        for (var numberOfCulledEvents=0; numberOfCulledEvents<__dragEvents.length-2; numberOfCulledEvents++) {
            // __dragEvents[numberOfCulledEvents][0] is the dragTime
            if (currentTime - __dragEvents[numberOfCulledEvents][0] <= 50) break
        }

        __dragEvents.splice(0, numberOfCulledEvents)
    }

    function getEventSpeed(currentTime, event) {
        if (__dragEvents.length != 0) {
            var lastDrag = __dragEvents[__dragEvents.length-1]
            var duration = Math.max(1, currentTime - lastDrag[0])
            if (orientation == Qt.Vertical) {
                return (event.y - lastDrag[2]) / duration
            } else {
                return (event.x - lastDrag[1]) / duration
            }
        } else {
            return 0
        }
    }

    function pushDragEvent(event) {
        var currentTime = __dateTime.getCurrentTimeMs()
        __dragEvents.push([currentTime, event.x, event.y, getEventSpeed(currentTime, event)])
        cullOldDragEvents(currentTime)
        updateSpeed()
    }

    onPositionChanged: {
        if (dragging) {
            pushDragEvent(mouse)
        }
        if (!draggingArea.containsMouse)
            clickValidated = false
    }

    onPressed: {
        __pressedPosition = Qt.point(mouse.x, mouse.y)
        __dragEvents = []
        pushDragEvent(mouse)
        clickValidated = true
    }

    onReleased: {
        dragging = false
        __pressedPosition = Qt.point(mouse.x, mouse.y)
    }

    onCanceled: {
        dragging = false
    }
}
