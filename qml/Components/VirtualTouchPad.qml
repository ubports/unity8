/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import UInput 0.1

Item {
    property var uinput: UInput {
        Component.onCompleted: createMouse();
        Component.onDestruction: removeMouse();
    }

    readonly property bool pressed: point1.pressed || point2.pressed

    MultiPointTouchArea {
        objectName: "touchPadArea"
        anchors.fill: parent

        // FIXME: Once we have Qt DPR support, this should be Qt.styleHints.startDragDistance
        readonly property int clickThreshold: units.gu(1.5)
        property bool isClick: false
        property bool isDoubleClick: false
        property bool isDrag: false

        onPressed: {
            // If double-tapping *really* fast, it could happen that we end up having only point2 pressed
            // Make sure we check for both combos, only point1 or only point2
            if (((point1.pressed && !point2.pressed) || (!point1.pressed && point2.pressed))
                    && clickTimer.running) {
                clickTimer.stop();
                uinput.pressMouse(UInput.ButtonLeft)
                isDoubleClick = true;
            }
            isClick = true;
        }

        onUpdated: {
            switch (touchPoints.length) {
            case 1:
                moveMouse(touchPoints);
                return;
            case 2:
                scroll(touchPoints);
                return;
            }
        }

        onReleased: {
            if (isDoubleClick || isDrag) {
                uinput.releaseMouse(UInput.ButtonLeft)
                isDoubleClick = false;
            }
            if (isClick) {
                clickTimer.scheduleClick(point1.pressed ? UInput.ButtonRight : UInput.ButtonLeft)
            }
            isClick = false;
            isDrag = false;
        }

        Timer {
            id: clickTimer
            repeat: false
            interval: 200
            property int button: UInput.ButtonLeft
            onTriggered: {
                uinput.pressMouse(button);
                uinput.releaseMouse(button);
            }
            function scheduleClick(button) {
                clickTimer.button = button;
                clickTimer.start();
            }
        }

        function moveMouse(touchPoints) {
            var tp = touchPoints[0];
            if (isClick &&
                    (Math.abs(tp.x - tp.startX) > clickThreshold ||
                     Math.abs(tp.y - tp.startY) > clickThreshold)) {
                isClick = false;
                isDrag = true;
            }

            uinput.moveMouse(tp.x - tp.previousX, tp.y - tp.previousY);
        }

        function scroll(touchPoints) {
            var dh = 0;
            var dv = 0;
            var tp = touchPoints[0];
            if (isClick &&
                    (Math.abs(tp.x - tp.startX) > clickThreshold ||
                     Math.abs(tp.y - tp.startY) > clickThreshold)) {
                isClick = false;
            }
            dh += tp.x - tp.previousX;
            dv += tp.y - tp.previousY;

            tp = touchPoints[1];
            if (isClick &&
                    (Math.abs(tp.x - tp.startX) > clickThreshold ||
                     Math.abs(tp.y - tp.startY) > clickThreshold)) {
                isClick = false;
            }
            dh += tp.x - tp.previousX;
            dv += tp.y - tp.previousY;

            // As we added up the movement of the two fingers, let's divide it again by 2
            dh /= 2;
            dv /= 2;

            uinput.scrollMouse(dh, dv);
        }

        touchPoints: [
            TouchPoint {
                id: point1
            },
            TouchPoint {
                id: point2
            }
        ]
    }
}
