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
import Unity.Test 0.1

Rectangle {
    width: units.gu(60)
    height: units.gu(60)
    color: "white"

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: true
    }

    Rectangle {
        id: blueRect
        objectName: "blueRect"
        color: "blue"
        width: units.gu(50)
        height: units.gu(50)

        Timer {
            id: resetColorTimer
            interval: 300
            repeat: false
            onTriggered: {
                blueRect.color = "blue";
            }
        }

        function blink(color) {
            blueRect.color = color;
            resetColorTimer.start();
        }

        TouchGestureArea {
            anchors.fill: parent
            objectName: "touchGestureAreaBottom"
            minimumTouchPoints: 1

            onStatusChanged: {
                if (status == TouchGestureArea.Recognized) {
                    blueRect.blink("red");
                }
            }
        }

        TouchGestureArea {
            anchors.fill: parent
            objectName: "touchGestureAreaMiddle"
            minimumTouchPoints: 2

            onStatusChanged: {
                if (status == TouchGestureArea.Recognized) {
                    blueRect.blink("yellow");
                }
            }
        }

        TouchGestureArea {
            anchors.fill: parent
            objectName: "touchGestureAreaTop"
            minimumTouchPoints: 3

            onStatusChanged: {
                if (status == TouchGestureArea.Recognized) {
                    blueRect.blink("green");
                }
            }
        }
    }
}
