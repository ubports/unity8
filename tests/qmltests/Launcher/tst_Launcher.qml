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
import ".."
import "../../../Launcher"

/* Nothing is shown at first. If you drag from left edge you will bring up the
   launcher. */
Item {
    width: units.gu(50)
    height: units.gu(81)

    Launcher {
        id: launcher
        x: 0
        y: 0
        width: units.gu(40)
        height: units.gu(81)

        property string latestApplicationSelected

        onLauncherApplicationSelected: {
            latestApplicationSelected = desktopFile
        }

        property int dashItemSelected_count: 0
        onDashItemSelected: {
            dashItemSelected_count++;
        }

        property int maxPanelX: 0
    }

    Connections {
        target: testCase.findChild(launcher, "launcherPanel")

        onXChanged: {
            if (target.x > launcher.maxPanelX) {
                launcher.maxPanelX = target.x;
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "Launcher"
        when: windowShown

        // Drag from the left edge of the screen rightwards and check that the launcher
        // appears (as if being dragged by the finger/pointer)
        function test_dragLeftEdgeToRevealLauncherAndTapCenterToDismiss() {
            var panel = findChild(launcher, "launcherPanel")
            verify(panel != undefined)

            // it starts out hidden just left of the left launcher edge
            compare(panel.x, -panel.width)

            dragLauncherIntoView()

            // tapping on the center of the screen should dismiss the launcher
            mouseClick(launcher, launcher.width/2, launcher.height/2)

            // should eventually get fully retracted (hidden)
            tryCompare(panel, "x", -launcher.panelWidth, 1000)
        }

        /* If I click on the icon of an application on the launcher
           Launcher::launcherApplicationSelected signal should be emitted with the
           corresponding desktop file. E.g. clicking on phone icon should yield
           launcherApplicationSelected("[...]phone-app.desktop") */
        function test_clickingOnAppIconCausesSignalEmission() {
            launcher.latestApplicationSelected = ""

            dragLauncherIntoView()

            var appIcon = findChild(launcher, "launcherDelegate0")
            verify(appIcon != undefined)

            mouseClick(appIcon, appIcon.width/2, appIcon.height/2)

            tryCompare(launcher, "latestApplicationSelected",
                       "/usr/share/applications/phone-app.desktop")

            // Tapping on an application icon also dismisses the launcher
            waitUntilLauncherDisappears()
        }

        /* If I click on the dash icon on the launcher
           Launcher::dashItemSelected signal should be emitted */
        function test_clickingOnDashIconCausesSignalEmission() {
            launcher.dashItemSelected_count = 0

            dragLauncherIntoView()

            var dashIcon = findChild(launcher, "dashItem")
            verify(dashIcon != undefined)

            mouseClick(dashIcon, dashIcon.width/2, dashIcon.height/2)

            tryCompare(launcher, "dashItemSelected_count", 1)

            // Tapping on the dash icon also dismisses the launcher
            waitUntilLauncherDisappears()
        }

        function dragLauncherIntoView() {
            var startX = launcher.dragAreaWidth/2
            var startY = launcher.height/2
            touchFlick(launcher,
                       startX, startY,
                       startX+units.gu(8), startY)

            var panel = findChild(launcher, "launcherPanel")
            verify(panel != undefined)

            // wait until it gets fully extended
            tryCompare(panel, "x", 0)
            tryCompare(launcher, "state", "visible")
        }

        function waitUntilLauncherDisappears() {
            var panel = findChild(launcher, "launcherPanel")
            tryCompare(panel, "x", -panel.width, 1000)
        }


        function test_teaseLauncher_data() {
            return [
                {tag: "available", available: true},
                {tag: "not available", available: false}
            ];
        }

        function test_teaseLauncher(data) {
            launcher.available = data.available;
            launcher.maxPanelX = -launcher.panelWidth;
            launcher.tease();

            if (data.available) {
                // Check if the launcher slides in for units.gu(2). However, as the animation is 200ms
                // and the teaseTimer's timeout too, give it a 2 pixels grace distance
                tryCompareFunction(
                    function(){
                        return launcher.maxPanelX >= -launcher.panelWidth + units.gu(2) - 2;
                    },
                    true)
            } else {
                wait(100)
                compare(launcher.maxPanelX, -launcher.panelWidth, "Launcher moved even if it shouldn't")
            }
            waitUntilLauncherDisappears();
        }
    }
}
