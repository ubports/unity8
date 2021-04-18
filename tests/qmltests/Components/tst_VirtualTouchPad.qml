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


Rectangle {
    id: root
    width: units.gu(70)
    height: units.gu(70)
    color: "black"

    VirtualTouchPad {
        id: touchScreenPad
        anchors.fill: parent
        property int internalGu: units.gu(1)
        settings: QtObject {
            property bool touchpadTutorialHasRun: true
            property bool oskEnabled: true
        }
    }

    SignalSpy {
        id: mouseEventSpy1
        target: UInput
    }
    SignalSpy {
        id: mouseEventSpy2
        target: UInput
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

        function test_tutorial() {
            var oskButton = findChild(touchScreenPad, "oskButton");
            var leftButton = findChild(touchScreenPad, "leftButton");
            var rightButton = findChild(touchScreenPad, "rightButton");
            var touchPad = findChild(touchScreenPad, "virtualTouchPad")
            var tutorial = findInvisibleChild(touchScreenPad, "tutorialAnimation")
            var tutorialFinger1 = findChild(touchScreenPad, "tutorialFinger1");
            var tutorialFinger2 = findChild(touchScreenPad, "tutorialFinger2");
            var tutorialLabel = findChild(touchScreenPad, "tutorialLabel");
            var tutorialImage = findChild(touchScreenPad, "tutorialImage");

            mouseEventSpy1.signalName = "mousePressed"
            mouseEventSpy2.signalName = "mouseReleased"

            mouseEventSpy1.clear();
            mouseEventSpy2.clear();

            // run the tutorial
            touchScreenPad.runTutorial();
            tryCompare(tutorial, "running", true)

            // Wait for it to pause
            tryCompare(tutorial, "paused", true)

            // Click somewhere to make it continue
            mouseClick(root, root.width / 2, root.height /2)
            tryCompare(tutorial, "paused", false)

            // Verify that the touchpad does NOT accept input while the tutorial is running
            mouseClick(root, root.width / 2, root.height /2)
            compare(mouseEventSpy1.count, 0)
            compare(mouseEventSpy2.count, 0)

            // Wait for it to finish
            tryCompare(tutorial, "running", false, 60000)

            // Make sure after the tutorial, all the visible states are proper
            tryCompare(oskButton, "visible", true)
            tryCompare(leftButton, "visible", true)
            tryCompare(rightButton, "visible", true)

            tryCompare(tutorialFinger1, "visible", false)
            tryCompare(tutorialFinger2, "visible", false)
            tryCompare(tutorialImage, "visible", false)
            tryCompare(tutorialLabel, "visible", false)
        }

    }
}
