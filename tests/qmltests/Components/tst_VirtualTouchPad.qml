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
import QtTest 1.0
import Unity.Test 0.1
import UInput 0.1
import "../../../qml/Components"


Item {
    id: root
    width: units.gu(70)
    height: units.gu(70)

    VirtualTouchPad {
        id: touchScreenPad
        anchors.fill: parent
    }

    SignalSpy {
        id: mouseEventSpy1
        target: touchScreenPad.uinput
    }
    SignalSpy {
        id: mouseEventSpy2
        target: touchScreenPad.uinput
    }

    UnityTestCase {
        id: testCase
        name: "VirtualTouchPad"
        when: windowShown

        function init() {
            mouseEventSpy1.clear();
            mouseEventSpy2.clear();
        }

        function test_click() {
            mouseEventSpy1.signalName = "mousePressed"
            mouseEventSpy2.signalName = "mouseReleased"

            var touchPadArea = findChild(touchScreenPad, "touchPadArea");

            tap(touchPadArea)
            tryCompare(mouseEventSpy1, "count", 1)
            tryCompare(mouseEventSpy2, "count", 1)
        }

        function test_doubleClick() {
            mouseEventSpy1.signalName = "mousePressed"
            mouseEventSpy2.signalName = "mouseReleased"

            var touchPadArea = findChild(touchScreenPad, "touchPadArea");

            tap(touchPadArea)
            tap(touchPadArea)

            tryCompare(mouseEventSpy1, "count", 2)
            tryCompare(mouseEventSpy2, "count", 2)
        }

        function test_move() {
            mouseEventSpy1.signalName = "mouseMoved"

            var touchPadArea = findChild(touchScreenPad, "touchPadArea");

            var moveDiff = units.gu(2);
            var moveSteps = 5;

            touchFlick(touchPadArea, units.gu(1), units.gu(1), units.gu(1) + moveDiff, units.gu(1) + moveDiff, true, true, 10, moveSteps)

            tryCompare(mouseEventSpy1, "count", moveSteps)
            var movedX = 0;
            var movedY = 0
            for (var i = 0; i < 5; i++) {
                movedX += mouseEventSpy1.signalArguments[i][0]
                movedY += mouseEventSpy1.signalArguments[i][1]
            }
            compare(movedX, moveDiff)
            compare(movedY, moveDiff)
        }

        function test_doubleTapAndHoldToDrag() {
            mouseEventSpy1.signalName = "mousePressed"
            mouseEventSpy2.signalName = "mouseReleased"

            var touchPadArea = findChild(touchScreenPad, "touchPadArea");

            mouseClick(touchPadArea)
            mousePress(touchPadArea)
            mouseMove(touchPadArea, touchPadArea.width / 4, touchPadArea.height / 4)

            tryCompare(mouseEventSpy1, "count", 1)
            tryCompare(mouseEventSpy2, "count", 0)
            mouseRelease(touchPadArea)
            tryCompare(mouseEventSpy2, "count", 1)
        }

        function test_twoFingerScroll() {
            var touchPadArea = findChild(touchScreenPad, "touchPadArea");

            mouseEventSpy1.signalName = "mouseScrolled"

            var startX = touchPadArea.width / 2;
            var startY = touchPadArea.height / 2;

            var startX1 = startX - units.gu(1);
            var startX2 = startX + units.gu(1);

            var event = touchEvent(touchPadArea)
            event.press(0, startX1, startY)
            event.press(1, startX2, startY);
            event.commit()

            for (var i = 0; i < 10; i++) {
                event.move(0, startX1, startY + units.gu(i))
                event.move(1, startX2, startY + units.gu(i));
                event.commit();

                tryCompare(mouseEventSpy1, "count", i + 1);
            }

            event.release(0, startX1, startY + units.gu(11))
            event.release(1, startX2, startY + units.gu(11));
            event.commit();
        }
    }
}
