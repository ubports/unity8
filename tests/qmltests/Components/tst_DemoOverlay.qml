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
import "../../../Components"

Item {
    id: root
    width: 700
    height: 500

    DemoOverlay {
        id: top
        edge: "top"
        title: "Top"
        text: "Displayed on top left"
        x: 0
        y: 0
        width: parent.width/2
        height: parent.height/2
    }

    DemoOverlay {
        id: right
        edge: "right"
        title: "Right"
        text: "Displayed on top right"
        x: parent.width/2
        y: 0
        width: parent.width/2
        height: parent.height/2
    }

    DemoOverlay {
        id: left
        edge: "left"
        title: "Left"
        text: "Displayed on bottom right"
        x: parent.width/2
        y: parent.height/2
        width: parent.width/2
        height: parent.height/2
        available: false
    }

    DemoOverlay {
        id: bottom
        edge: "bottom"
        title: "Bottom"
        text: "Displayed on bottom left"
        x: 0
        y: parent.height/2
        width: parent.width/2
        height: parent.height/2
    }

    SignalSpy {
        id: signalSpy
        target: bottom
    }

    UT.UnityTestCase {
        name: "DemoOverlay"
        when: windowShown

        function test_animations() {
            compare(right.__anim_running, 1)

            compare(left.__anim_running, 0)
            left.available = true
            compare(left.__anim_running, 1)
        }

        function test_skip() {
            signalSpy.signalName = "skip"
            signalSpy.clear()
            var bottomSkip = findChild(bottom, "skipLabel")
            mousePress(bottomSkip, 1, 1)
            mouseRelease(bottomSkip, 1, 1)
            signalSpy.wait()
            compare(bottom.available, false)
        }
    }
}
