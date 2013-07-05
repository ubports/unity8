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
    id: root
    width: units.gu(50)
    height: units.gu(55)

    Launcher {
        id: launcher
        x: 0
        y: 0
        width: units.gu(40)
        height: parent.height

        property string lastSelectedApplication

        onLauncherApplicationSelected: {
            lastSelectedApplication = desktopFile
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
        id: revealer

        function dragLauncherIntoView() {
            var startX = launcher.dragAreaWidth/2;
            var startY = launcher.height/2;
            touchFlick(launcher,
                       startX, startY,
                       startX+units.gu(8), startY);

            var panel = findChild(launcher, "launcherPanel");
            verify(panel != undefined);

            // wait until it gets fully extended
            tryCompare(panel, "x", 0);
            tryCompare(launcher, "state", "visible");
        }

        function waitUntilLauncherDisappears() {
            var panel = findChild(launcher, "launcherPanel");
            tryCompare(panel, "x", -panel.width, 1000);
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "Launcher"
        when: windowShown && initTestCase.completed

        // Drag from the left edge of the screen rightwards and check that the launcher
        // appears (as if being dragged by the finger/pointer)
        function test_dragLeftEdgeToRevealLauncherAndTapCenterToDismiss() {
            var panel = findChild(launcher, "launcherPanel")
            verify(panel != undefined)

            // it starts out hidden just left of the left launcher edge
            compare(panel.x, -panel.width)

            revealer.dragLauncherIntoView()

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
            launcher.lastSelectedApplication = ""

            revealer.dragLauncherIntoView()

            var listView = findChild(launcher, "launcherListView");
            listView.flick(0, units.gu(500));
            tryCompare(listView, "flicking", false);

            var appIcon = findChild(launcher, "launcherDelegate0")

            verify(appIcon != undefined)

            mouseClick(appIcon, appIcon.width/2, appIcon.height/2)

            tryCompare(launcher, "lastSelectedApplication",
                       "/usr/share/applications/phone-app.desktop")

            // Tapping on an application icon also dismisses the launcher
            revealer.waitUntilLauncherDisappears()
        }

        /* If I click on the dash icon on the launcher
           Launcher::dashItemSelected signal should be emitted */
        function test_clickingOnDashIconCausesSignalEmission() {
            launcher.dashItemSelected_count = 0

            revealer.dragLauncherIntoView()

            var dashIcon = findChild(launcher, "dashItem")
            verify(dashIcon != undefined)

            mouseClick(dashIcon, dashIcon.width/2, dashIcon.height/2)

            tryCompare(launcher, "dashItemSelected_count", 1)

            // Tapping on the dash icon also dismisses the launcher
            revealer.waitUntilLauncherDisappears()
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
            revealer.waitUntilLauncherDisappears();
            launcher.available = true;
        }
    }

    UT.UnityTestCase {
        id: clickFlickTestCase
        when: windowShown && testCase.completed

        function test_clickFlick_data() {
            var listView = findChild(launcher, "launcherListView");
            return [
                {tag: "unfolded top", flickSpeed: units.gu(200), clickY: listView.topMargin + units.gu(2), expectFlick: false},
                {tag: "folded top", flickSpeed: -units.gu(200), clickY: listView.topMargin + units.gu(2), expectFlick: true},
                {tag: "unfolded bottom", flickSpeed: -units.gu(200), clickY: listView.height - listView.topMargin - units.gu(1), expectFlick: false},
                {tag: "folded bottom", flickSpeed: units.gu(200), clickY: listView.height - listView.topMargin - units.gu(1), expectFlick: true},
            ];
        }

        function test_clickFlick(data) {
            launcher.lastSelectedApplication = "";
            revealer.dragLauncherIntoView();
            var listView = findChild(launcher, "launcherListView");

            listView.flick(0, data.flickSpeed);
            tryCompare(listView, "flicking", false);

            var oldY = listView.contentY;

            mouseClick(listView, listView.width / 2, data.clickY);
            tryCompare(listView, "flicking", false);

            if (data.expectFlick) {
                verify(listView.contentY != oldY);
                compare(launcher.lastSelectedApplication, "", "Launcher app clicked signal emitted even though it should only flick");
            } else {
                verify(launcher.lastSelectedApplication != "");
                compare(listView.contentY, oldY, "Launcher was flicked even though it should only launch an app");
            }

            // Restore position on top
            listView.flick(0, units.gu(200));
            tryCompare(listView, "flicking", false)
            // Click somewhere in the empty space to make it hide in case it isn't
            mouseClick(launcher, launcher.width - units.gu(1), units.gu(1));
            revealer.waitUntilLauncherDisappears();
        }
    }

    UT.UnityTestCase {
        id: initTestCase
        name: "LauncherInit"
        when: windowShown

        /*
         * FIXME: There is a bug in ListView which makes it snap to an item
         * instead of the edge at startup. Enable this test once our patch for
         * ListView has landed upstream.
         * https://bugreports.qt-project.org/browse/QTBUG-32251

        function test_initFirstUnfolded() {

            // Make sure noone changed the height of the window. The issue this test case
            // is verifying only happens on certain heights of the Launcher
            compare(root.height, units.gu(55));

            var listView = findChild(launcher, "launcherListView");
            wait(1000);
            print("humppa", listView.contentY, listView.topMargin)
            compare(listView.contentY, -listView.topMargin, "Launcher did not start up with first item unfolded");

            // Now do check that snapping is in fact enabled
            compare(listView.snapMode, ListView.SnapToItem, "Snapping is not enabled");
        }
        */
    }
}
