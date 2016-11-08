/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import Ubuntu.Gestures 0.1
import "../../Components"

Item {
    id: root

    property bool closeable: true
    readonly property real minSpeedToClose: units.gu(40)
    property bool zeroVelocityCounts: false

    readonly property alias distance: d.distance

    signal clicked()
    signal close()

    QtObject {
        id: d
        property real distance: 0
        property bool moving: false
        property var dragEvents: []
        property real dragVelocity: 0
        property int threshold: units.gu(2)

        // Can be replaced with a fake implementation during tests
        // property var __getCurrentTimeMs: function () { return new Date().getTime() }
        property var __dateTime: new function() {
            this.getCurrentTimeMs = function() {return new Date().getTime()}
        }

        function pushDragEvent(event) {
            var currentTime = __dateTime.getCurrentTimeMs()
            dragEvents.push([currentTime, event.x - event.startX, event.y - event.startY, getEventSpeed(currentTime, event)])
            cullOldDragEvents(currentTime)
            updateSpeed()
        }

        function cullOldDragEvents(currentTime) {
            // cull events older than 50 ms but always keep the latest 2 events
            for (var numberOfCulledEvents = 0; numberOfCulledEvents < dragEvents.length-2; numberOfCulledEvents++) {
                // dragEvents[numberOfCulledEvents][0] is the dragTime
                if (currentTime - dragEvents[numberOfCulledEvents][0] <= 50) break
            }

            dragEvents.splice(0, numberOfCulledEvents)
        }

        function updateSpeed() {
            var totalSpeed = 0
            for (var i = 0; i < dragEvents.length; i++) {
                totalSpeed += dragEvents[i][3]
            }

            if (zeroVelocityCounts || Math.abs(totalSpeed) > 0.001) {
                dragVelocity = totalSpeed / dragEvents.length * 1000
            }
        }

        function getEventSpeed(currentTime, event) {
            if (dragEvents.length != 0) {
                var lastDrag = dragEvents[dragEvents.length-1]
                var duration = Math.max(1, currentTime - lastDrag[0])
                return (event.y - event.startY - lastDrag[2]) / duration
            } else {
                return 0
            }
        }
    }

    // Event eater
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        onWheel: wheel.accepted = true
    }

    MultiPointTouchArea {
        anchors.fill: parent
        mouseEnabled: false
        maximumTouchPoints: 1
        property int offset: 0

        touchPoints: [
            TouchPoint {
                id: tp
            }
        ]

        onCanceled: {
            d.moving = false
            animation.animate("center");
        }

        onTouchUpdated: {
            if (!d.moving) {
                if (Math.abs(tp.startY - tp.y) > d.threshold) {
                    d.moving = true;
                    d.dragEvents = []
                    offset = tp.y - tp.startY;
                } else {
                    return;
                }
            }

            if (root.closeable) {
                d.distance = tp.y - tp.startY - offset
            } else {
                var value = tp.y - tp.startY - offset;
                d.distance = Math.sqrt(Math.abs(value)) * (value < 0 ? -1 : 1) * 3
            }

            d.pushDragEvent(tp);
        }

        onReleased: {
            if (!d.moving) {
                root.clicked()
            }

            if (!root.closeable) {
                animation.animate("center")
                return;
            }

            var touchPoint = touchPoints[0];

            if ((d.dragVelocity < -root.minSpeedToClose && d.distance < -units.gu(8)) || d.distance < -root.height / 2) {
                animation.animate("up")
            } else if ((d.dragVelocity > root.minSpeedToClose  && d.distance > units.gu(8)) || d.distance > root.height / 2) {
                animation.animate("down")
            } else {
                animation.animate("center")
            }
        }
    }

    UbuntuNumberAnimation {
        id: animation
        objectName: "closeAnimation"
        target: d
        property: "distance"
        property bool requestClose: false

        function animate(direction) {
            animation.from = dragArea.distance;
            switch (direction) {
            case "up":
                animation.to = -root.height * 1.5;
                requestClose = true;
                break;
            case "down":
                animation.to = root.height * 1.5;
                requestClose = true;
                break;
            default:
                animation.to = 0
            }
            animation.start();
        }

        onRunningChanged: {
            if (!running) {
                d.moving = false;
                if (requestClose) {
                    root.close();
                } else {
                    d.distance = 0;
                }
            }
        }
    }
}
