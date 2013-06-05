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
import "../../../Greeter"
import Ubuntu.Components 0.1
import LightDM 0.1 as LightDM
import Unity.Test 0.1 as UT

Item {
    width: units.gu(60)
    height: units.gu(80)

    Greeter {
        id: greeter
        anchors.fill: parent
    }

    SignalSpy {
        id: unlockSpy
        target: greeter
        signalName: "unlocked"
    }

    UT.UnityTestCase {
        name: "Greeter"
        when: windowShown

        function test_properties() {
            compare(greeter.multiUser, false)
            compare(greeter.narrowMode, true)
        }

        function test_teasingArea() {
            tryCompare(greeter, "leftTeaserPressed", false)
            mousePress(greeter, units.gu(2), greeter.height - units.gu(1))
            tryCompare(greeter, "leftTeaserPressed", true)
            mouseRelease(greeter, units.gu(2), greeter.height - units.gu(1))
            tryCompare(greeter, "leftTeaserPressed", false)

            mousePress(greeter, greeter.width - units.gu(2), greeter.height - units.gu(1))
            tryCompare(greeter, "leftTeaserPressed", false)
            mouseRelease(greeter, units.gu(2), greeter.height - units.gu(1))
            tryCompare(greeter, "leftTeaserPressed", false)
        }
    }
}
