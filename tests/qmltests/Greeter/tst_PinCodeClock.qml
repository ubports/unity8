/*
 * Copyright 2022 Ubports Foundation
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
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT

import "../../../qml/Greeter"


Item {
    width: units.gu(60)
    height: units.gu(60)

    property url defaultBackground: "/usr/share/backgrounds/warty-final-ubuntu.png"

    Image {
        anchors.fill: parent
        source: defaultBackground
    }

    ClockPinPrompt {
        id: component
        width: parent.width
        height: parent.height
    }

    SignalSpy {
        id: acceptedSpy
        target: component
        signalName: "accepted"
    }

     UT.UnityTestCase {
        id: testCase
        name: "Greeter"
        when: windowShown

        function init() {
            component.forceActiveFocus()
            tryCompare(component, "state", "ENTRY_MODE")
            tryCompare(component, "enteredText", "")
        }

        function cleanup() {
            component.state = ""
            acceptedSpy.clear()
        }

        function test_pincodeByTapping() {

            tryCompare(acceptedSpy, "count", 0)

            var repeater = findChild(component, "dotRepeater");
            mouseClick(repeater.itemAt(1))
            mouseClick(repeater.itemAt(2))
            mouseClick(repeater.itemAt(3))
            mouseClick(repeater.itemAt(4))

            tryCompare(acceptedSpy, "count", 1)
            compare(acceptedSpy.signalArguments[0][0], '1234')
        }

        function test_pincodeByKeyboard() {

            tryCompare(acceptedSpy, "count", 0)

            typeString("1234");

            tryCompare(acceptedSpy, "count", 1)
            compare(acceptedSpy.signalArguments[0][0], '1234')
        }

        function test_pincodeFailByKeyboard() {

            tryCompare(acceptedSpy, "count", 0)

            typeString("4444");

            tryCompare(acceptedSpy, "count", 1)
            component.loginError = true
            compare(component.state, "WRONG_PASSWORD")
        }

        function test_pincodeBySwipping() {
            wait(600) // wait dots at their final position
            tryCompare(acceptedSpy, "count", 0)
            var selectArea = findChild(component, "SelectArea");
            var repeater = findChild(component, "dotRepeater");

            var dot1 = repeater.itemAt(1)
            var dotCenterWidth =  dot1.width /2

            var dot1Point = dot1.mapToItem(selectArea, 0 + dotCenterWidth , 0 + dotCenterWidth)
            var dot2 = repeater.itemAt(2)
            var dot2Point = dot2.mapToItem(selectArea, 0 + dotCenterWidth , 0 + dotCenterWidth)
            var dot3 = repeater.itemAt(3)
            var dot3Point = dot3.mapToItem(selectArea, 0 + dotCenterWidth , 0 + dotCenterWidth)
            var dot4 = repeater.itemAt(4)
            var dot4Point = dot4.mapToItem(selectArea, 0 + dotCenterWidth , 0 + dotCenterWidth)

            var touchX = selectArea.width / 2;
            var touchY = selectArea.height / 2;

            mousePress(selectArea)
            mouseMove(selectArea, dot1Point.x, dot1Point.y)
            mouseMove(selectArea, dot2Point.x, dot2Point.y)
            mouseMove(selectArea, dot3Point.x, dot3Point.y)
            mouseMove(selectArea, dot4Point.x, dot4Point.y)
            mouseRelease(selectArea)

            tryCompare(acceptedSpy, "count", 1)
            compare(acceptedSpy.signalArguments[0][0], '1234')
        }

        function test_erase() {
            var eraseBtn = findInvisibleChild(component, "EraseBtn");
            compare(eraseBtn.enabled, false)
            typeString("44");
            compare(eraseBtn.enabled, true)
            compare(component.enteredText, "44")
            mouseClick(eraseBtn)
            compare(component.enteredText, "4")
            mouseClick(eraseBtn)
            compare(component.enteredText, "")
            compare(eraseBtn.enabled, false)
        }
    }
}
