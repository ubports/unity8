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
import Lomiri.Components 1.3
import Lomiri.Gestures 0.1
import "../../Components"

Item {
    id: root

    property bool closeable: true
    readonly property real minSpeedToClose: units.gu(40)
    property bool zeroVelocityCounts: false

    readonly property alias distance: d.distance

    property var stage: null
    property var dragDelegate: null

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

    MultiPointTouchArea {
        anchors.fill: parent
        maximumTouchPoints: 1
        property int offset: 0

        // tp.startY seems to be broken for mouse interaction... lets track it ourselves
        property int startY: 0

        touchPoints: [
            TouchPoint {
                id: tp
            }
        ]

        onPressed: {
            startY = tp.y
        }

        onTouchUpdated: {
            if (!d.moving || !tp.pressed) {
                if (Math.abs(startY - tp.y) > d.threshold) {
                    d.moving = true;
                    d.dragEvents = []
                    offset = tp.y - tp.startY;
                } else {
                    return;
                }
            }


            var value = tp.y - tp.startY - offset;
            if (value < 0 && stage.workspaceEnabled) {
                var coords = mapToItem(stage, tp.x, tp.y);
                dragDelegate.Drag.hotSpot.x = dragDelegate.width / 2
                dragDelegate.Drag.hotSpot.y = units.gu(2)
                dragDelegate.x = coords.x - dragDelegate.Drag.hotSpot.x
                dragDelegate.y = coords.y - dragDelegate.Drag.hotSpot.y
                dragDelegate.Drag.active = true;
                dragDelegate.surface = model.window.surface;

            } else {
                if (root.closeable) {
                    d.distance = value
                } else {
                    d.distance = Math.sqrt(Math.abs(value)) * (value < 0 ? -1 : 1) * 3
                }
            }

            d.pushDragEvent(tp);
        }

        onReleased: {
            var result = dragDelegate.Drag.drop();
            dragDelegate.surface = null;

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

        onCanceled: {
            dragDelegate.Drag.active = false;
            dragDelegate.surface = null;
            d.moving = false
            animation.animate("center");
        }
    }

    LomiriNumberAnimation {
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
