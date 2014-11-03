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

    Loader {
        id: greeterLoader
        anchors.fill: parent

        property bool itemDestroyed: false

        sourceComponent: Component {
            Greeter {
                anchors.fill: greeterLoader

                property int minX: 0

                onXChanged: {
                    if (x < minX) {
                        minX = x;
                    }
                }

                Component.onDestruction: {
                    greeterLoader.itemDestroyed = true;
                }
                SignalSpy {
                    objectName: "selectedSpy"
                    target: parent
                    signalName: "selected"
                }
            }
        }
    }

    SignalSpy {
        id: unlockSpy
        target: greeterLoader.item
        signalName: "unlocked"
    }

    SignalSpy {
        id: teaseSpy
        target: greeterLoader.item
        signalName: "tease"
    }

    UT.UnityTestCase {
        name: "SingleGreeter"
        when: windowShown

        property Greeter greeter: greeterLoader.item

        function cleanup() {
            AccountsService.statsWelcomeScreen = true

            // force a reload so that we get a fresh Greeter for the next test
            greeterLoader.itemDestroyed = false;
            greeterLoader.active = false;
            tryCompare(greeterLoader, "itemDestroyed", true);

            unlockSpy.clear();
            teaseSpy.clear();

            greeterLoader.active = true;
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
            teaseSpy.clear()
            tap(greeter, data.posX, greeter.height - units.gu(1))
            teaseSpy.wait()
            tryCompare(teaseSpy, "count", 1)
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

        function test_initial_selected_signal() {
            var selectedSpy = findChild(greeter, "selectedSpy");
            selectedSpy.wait();
            tryCompare(selectedSpy, "count", 1);
        }
    }
}
