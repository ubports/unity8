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
import ".."
import "../../../Panel"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    width: units.gu(9)
    height: units.gu(3)

    SignalSpy {
        id: clickedSpy
        target: searchIndicator
        signalName: "clicked"
    }

    SearchIndicator {
        id: searchIndicator
        anchors.fill: parent
    }

    UT.UnityTestCase {
        name: "SearchIndicator"
        when: windowShown

        function test_clickedSignal() {
            clickedSpy.clear()
            mouseClick(searchIndicator,
                       searchIndicator.width / 2, searchIndicator.height / 2);
            compare(clickedSpy.count, 1)
        }

        function test_hideUp() {
            var container = findChild(searchIndicator, "container")
            searchIndicator.state = "hiddenUp"
            tryCompare(container, "opacity", 0)
            tryCompare(container, "y", -container.height)
        }

        function test_show() {
            var container = findChild(searchIndicator, "container")
            searchIndicator.state = "visible"
            tryCompare(container, "opacity", 1)
            tryCompare(container, "y", 0)
        }
    }
}
