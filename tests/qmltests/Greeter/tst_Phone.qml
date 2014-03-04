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
import "../../../qml/Greeter"
import AccountsService 0.1
import LightDM 0.1 as LightDM
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    width: units.gu(60)
    height: units.gu(80)

    Greeter {
        id: greeter
        width: parent.width
        height: parent.height
        x: 0; y: 0

        defaultBackground: Qt.resolvedUrl("../../../qml/graphics/phone_background.jpg")

        property int minX: 0

        onXChanged: {
            if (x < minX) {
                minX = x;
            }
        }
    }

    Component {
        id: greeterComponent
        Greeter {
            SignalSpy {
                objectName: "selectedSpy"
                target: parent
                signalName: "selected"
            }
        }
    }

    SignalSpy {
        id: unlockSpy
        target: greeter
        signalName: "unlocked"
    }

    UT.UnityTestCase {
        name: "Greeter"
        when: windowShown

        function cleanup() {
            AccountsService.statsWelcomeScreen = true
        }

        function test_properties() {
            compare(greeter.multiUser, false)
            compare(greeter.narrowMode, true)
        }

        function test_teasingArea_data() {
            return [
                {tag: "left", posX: units.gu(2), leftPressed: true, rightPressed: false},
                {tag: "right", posX: greeter.width - units.gu(2), leftPressed: false, rightPressed: true}
            ]
        }

        function test_teasingArea(data) {
            tryCompare(greeter, "leftTeaserPressed", false)
            tryCompare(greeter, "rightTeaserPressed", false)
            mousePress(greeter, data.posX, greeter.height - units.gu(1))
            tryCompare(greeter, "leftTeaserPressed", data.leftPressed)
            tryCompare(greeter, "rightTeaserPressed", data.rightPressed)
            mouseRelease(greeter, data.posX, greeter.height - units.gu(1))
            tryCompare(greeter, "leftTeaserPressed", false)
            tryCompare(greeter, "rightTeaserPressed", false)
        }

        function test_teaseLockedUnlocked_data() {
            return [
                {tag: "unlocked", locked: false, moved: false},
                {tag: "locked", locked: true, moved: false},
                {tag: "moved", locked: false, moved: true}
            ];
        }

        function test_teaseLockedUnlocked(data) {
            tryCompare(greeter, "rightTeaserPressed", false);
            tryCompare(greeter, "x", 0);
            greeter.locked = data.locked;

            // simulate greeter being in the middle of a swipe
            if (data.moved) {
                greeter.x = -units.gu(4);
                tryCompare(greeter, "x", -units.gu(4));
            }

            mouseClick(greeter, greeter.width - units.gu(5), greeter.height - units.gu(1));
            greeter.minX = 0; // This is needed because the transition actually makes x jump once before animating

            if (!data.moved) {
                // Check if it has been moved over by 2 GUs. Give it a 2 pixel grace area
                // because animation duration and teaseTimer are the same duration and
                // might cause slight offsets
                tryCompareFunction(function() { return greeter.minX <= -units.gu(2) + 2}, true);
            } else {
                // waiting 100ms to make sure nothing moves
                wait(100);
                compare(greeter.minX, 0, "Greeter teasing not disabled even though it's locked or moving.");
            }

            // Restore position in case we moved it for the test
            if (data.moved) {
                greeter.x = 0;
            }

            // Wait until we're back to 0
            tryCompareFunction(function() { return greeter.x;}, 0);
        }

        function test_statsWelcomeScreen() {
            // Test logic in greeter that turns statsWelcomeScreen setting into infographic changes
            compare(AccountsService.statsWelcomeScreen, true)
            tryCompare(LightDM.Infographic, "username", "single")
            AccountsService.statsWelcomeScreen = false
            tryCompare(LightDM.Infographic, "username", "")
            AccountsService.statsWelcomeScreen = true
            tryCompare(LightDM.Infographic, "username", "single")
        }

        function test_background_data() {
            return [
                {tag: "set", accounts: Qt.resolvedUrl("../../data/unity/backgrounds/blue.png"), expected: "blue.png"},
                {tag: "unset", accounts: "", expected: "background.jpg"},
                {tag: "invalid", accounts: "invalid", expected: "background.jpg"},
            ]
        }

        function test_background(data) {
            var loader = findChild(greeter, "greeterContentLoader")
            var background = findChild(loader.item, "greeterBackground")
            AccountsService.backgroundFile = data.accounts
            tryCompareFunction(function() { return background.source.toString().indexOf(data.expected) !== -1; }, true)
            tryCompare(background, "status", Image.Ready)
        }

        function test_initial_selected_signal() {
            var greeterObj = greeterComponent.createObject(this)
            var spy = findChild(greeterObj, "selectedSpy")
            spy.wait()
            tryCompare(spy, "count", 1)
            greeterObj.destroy()
        }
    }
}
