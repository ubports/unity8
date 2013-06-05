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
import "../.."
import "../../../../Panel/Menus"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: testIndicatorMenuWindowItem
    width: units.gu(9)
    height: units.gu(3)

    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }

    IndicatorMenuWindow {
        id: indicatorMenuWindow
        name: "TestIndicatorMenuWindow"
        anchors.fill: parent
    }

    UT.UnityTestCase {
        name: "IndicatorMenuWindow"
        when: windowShown

        function test_mouseEvent_data() {
            return [
                {tag: "visible", shown: true, opacity: 1.0, mouseClicks: 0},
                {tag: "invisible", shown: false, opacity: 0.0, mouseClicks: 1},
            ]
        }

        function test_mouseEvent(data) {
            indicatorMenuWindow.shown = data.shown
            tryCompare(indicatorMenuWindow, "opacity", data.opacity)

            clickedSpy.clear()
            mouseClick(indicatorMenuWindow, indicatorMenuWindow.width / 2,
                       indicatorMenuWindow.height / 2)
            compare(clickedSpy.count, data.mouseClicks,
                  "Check for Mouse event eating by indicatorMenuWindow failed")
        }
    }

    SignalSpy {
        id: clickedSpy
        target: mouseArea
        signalName: "clicked"
    }
}
