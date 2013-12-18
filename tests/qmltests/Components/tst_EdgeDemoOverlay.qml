/*
 * Copyright 2013 Canonical Ltd.
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
import QtTest 1.0
import Unity.Test 0.1 as UT
import "../../../qml/Components"

Item {
    id: root
    width: boxWidth * 3
    height: boxHeight * 2

    property int boxWidth: 250
    property int boxHeight: 250

    EdgeDemoOverlay {
        id: top
        edge: "top"
        title: "Top"
        text: "Displayed on top left"
        anchors.left: parent.left
        anchors.top: parent.top
        width: boxWidth
        height: boxHeight
    }

    EdgeDemoOverlay {
        id: right
        edge: "right"
        title: "Right"
        text: "Displayed on top right"
        anchors.right: parent.right
        anchors.top: parent.top
        width: boxWidth
        height: boxHeight
    }

    EdgeDemoOverlay {
        id: left
        edge: "left"
        title: "Left"
        text: "Displayed on bottom right"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: boxWidth
        height: boxHeight
        available: false
    }

    EdgeDemoOverlay {
        id: bottom
        edge: "bottom"
        title: "Bottom"
        text: "Displayed on bottom left"
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: boxWidth
        height: boxHeight
    }

    EdgeDemoOverlay {
        id: none
        edge: "none"
        title: "None"
        text: "Displayed on top middle"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: boxWidth
        height: boxHeight
    }

    SignalSpy {
        id: signalSpy
    }

    UT.UnityTestCase {
        name: "EdgeDemoOverlay"
        when: windowShown

        function test_animations() {
            compare(right.running, true)

            compare(left.running, false)
            left.available = true
            compare(left.running, true)
        }

        function test_skip() {
            signalSpy.target = bottom
            signalSpy.signalName = "skip"
            signalSpy.clear()
            var bottomSkip = findChild(bottom, "skipLabel")
            mousePress(bottomSkip, 1, 1)
            mouseRelease(bottomSkip, 1, 1)
            signalSpy.wait()
            compare(bottom.available, false)

            // Test that the 'none' edge skips anywhere
            signalSpy.target = none
            signalSpy.clear()
            var backgroundShade = findChild(none, "backgroundShadeMouseArea")
            tryCompare(backgroundShade, "enabled", true)
            mousePress(backgroundShade, 1, 1)
            mouseRelease(backgroundShade, 1, 1)
            signalSpy.wait()
            compare(none.available, false)
        }
    }
}
