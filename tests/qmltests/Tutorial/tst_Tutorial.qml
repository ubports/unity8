/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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
import AccountsService 0.1
import LightDM 0.1 as LightDM
import Ubuntu.Components 1.1
import Unity.Application 0.1
import Unity.Test 0.1 as UT

import "../../../qml"

Item {
    id: root
    width: shellLoader.width + buttons.width
    height: shellLoader.height

    QtObject {
        id: applicationArguments

        function hasGeometry() {
            return false;
        }

        function width() {
            return 0;
        }

        function height() {
            return 0;
        }
    }

    Row {
        spacing: 0
        anchors.fill: parent

        Loader {
            id: shellLoader

            width: units.gu(40)
            height: units.gu(71)

            property bool itemDestroyed: false
            sourceComponent: Component {
                Shell {
                    property string indicatorProfile: "phone"

                    Component.onDestruction: {
                        shellLoader.itemDestroyed = true;
                    }
                }
            }
        }

        Rectangle {
            id: buttons
            color: "white"
            width: units.gu(30)
            height: shellLoader.height

            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                spacing: units.gu(1)
                Row {
                    anchors { left: parent.left; right: parent.right }
                    Button {
                        text: "Restart Tutorial"
                        onClicked: {
                            if (shellLoader.status !== Loader.Ready)
                                return;

                            AccountsService.demoEdges = false;
                            AccountsService.demoEdges = true;
                        }
                    }
                }
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "Tutorial"
        when: windowShown

        property Item shell: shellLoader.status === Loader.Ready ? shellLoader.item : null
        property real halfWidth: shell ?  shell.width / 2 : 0
        property real halfHeight: shell ? shell.height / 2 : 0

        function init() {
            swipeAwayGreeter();
            AccountsService.demoEdges = false;
            AccountsService.demoEdges = true;
        }

        function cleanup() {
            shellLoader.itemDestroyed = false;

            shellLoader.active = false;

            tryCompare(shellLoader, "status", Loader.Null);
            tryCompare(shellLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // item might still be alive. So if we set Loader.active back to true
            // again right now we will get the very same Shell instance back. So no reload
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(shellLoader, "itemDestroyed", true);

            // kill all (fake) running apps
            killApps();

            // reload our test subject to get it in a fresh state once again
            shellLoader.active = true;

            tryCompare(shellLoader, "status", Loader.Ready);
            removeTimeConstraintsFromDirectionalDragAreas(shellLoader.item);
        }

        function killApps() {
            while (ApplicationManager.count > 1) {
                var appIndex = ApplicationManager.get(0).appId == "unity8-dash" ? 1 : 0
                ApplicationManager.stopApplication(ApplicationManager.get(appIndex).appId);
            }
            compare(ApplicationManager.count, 1)
        }

        function swipeAwayGreeter() {
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "showProgress", 1);

            touchFlick(shell, halfWidth, halfHeight, shell.width, halfHeight);

            // wait until the animation has finished
            tryCompare(greeter, "showProgress", 0);
            waitForRendering(greeter);
        }

        function waitForPage(name) {
            var page = findChild(shell, name);
            tryCompare(page, "shown", true);
            tryCompare(page.showAnimation, "running", false);
            return page;
        }

        function checkTopEdge() {
            touchFlick(shell, halfWidth, 0, halfWidth, halfHeight);

            var panel = findChild(shell, "panel");
            tryCompare(panel.indicators, "fullyClosed", true);
        }

        function checkLeftEdge() {
            touchFlick(shell, 0, halfHeight, halfWidth, halfHeight);

            var launcher = findChild(shell, "launcher");
            tryCompare(launcher, "state", "");
        }

        function checkRightEdge() {
            touchFlick(shell, shell.width, halfHeight, halfWidth, halfHeight);

            var stage = findChild(shell, "stage");
            var spreadView = findChild(stage, "spreadView");
            tryCompare(spreadView, "phase", 0);
        }

        function checkBottomEdge() {
            // Can't actually check effect of swipe, since dash isn't really loaded
            var applicationsDisplayLoader = findChild(shell, "applicationsDisplayLoader");
            tryCompare(applicationsDisplayLoader.item, "interactive", false);
        }

        function checkFinished() {
            tryCompare(AccountsService, "demoEdges", false);

            var tutorial = findChild(shell, "tutorial");
            tryCompare(tutorial, "running", false);

            var launcher = findChild(shell, "launcher");
            tryCompare(launcher, "shown", false);
        }

        function goToPage(name) {
            var page = waitForPage("tutorialLeft");
            checkTopEdge();
            checkRightEdge();
            checkBottomEdge();
            if (name === "tutorialLeft") return page;
            touchFlick(shell, 0, halfHeight, halfWidth, halfHeight);

            page = waitForPage("tutorialLeftFinish");
            if (name === "tutorialLeftFinish") return page;
            var tick = findChild(page, "tick");
            tap(tick);

            page = waitForPage("tutorialRight");
            checkTopEdge();
            checkLeftEdge();
            checkBottomEdge();
            if (name === "tutorialRight") return page;
            touchFlick(shell, shell.width, halfHeight, halfWidth, halfHeight);
            var overlay = findChild(page, "overlay");
            tryCompare(overlay, "shown", true);
            var tick = findChild(page, "tick");
            tap(tick);

            var page = waitForPage("tutorialBottom");
            checkTopEdge();
            checkLeftEdge();
            checkRightEdge();
            if (name === "tutorialBottom") return page;
            touchFlick(shell, halfWidth, shell.height, halfWidth, halfHeight);

            var page = waitForPage("tutorialBottomFinish");
            checkTopEdge();
            checkLeftEdge();
            checkRightEdge();
            checkBottomEdge();
            if (name === "tutorialBottomFinish") return page;
            var tick = findChild(page, "tick");
            tap(tick);

            checkFinished();
            return null;
        }

        function test_walkthrough() {
            goToPage(null);
        }

        function test_launcherShortDrag() {
            // goToPage does a normal launcher pull.  But here we want to test
            // just barely pulling the launcher out and letting go (i.e. not
            // triggering the "progress" property of Launcher).

            var left = goToPage("tutorialLeft");

            // Make sure we don't do anything if we don't pull the launcher
            // out much.
            var launcher = findChild(shell, "launcher");
            touchFlick(shell, 0, halfHeight, launcher.panelWidth * 0.4, halfHeight);
            tryCompare(launcher, "state", ""); // should remain hidden
            tryCompare(left, "shown", true); // and we should still be on left

            // Now drag out but not past launcher itself
            touchFlick(shell, 0, halfHeight, launcher.panelWidth * 0.9, halfHeight);

            waitForPage("tutorialLeftFinish");
        }

        function test_launcherLongDrag() {
            // goToPage does a normal launcher pull.  But here we want to test
            // a full pull across the page.

            var left = goToPage("tutorialLeft");

            var launcher = findChild(shell, "launcher");
            touchFlick(shell, 0, halfHeight, shell.width, halfHeight);

            var errorLabel = findChild(left, "errorLabel");
            tryCompare(launcher, "state", ""); // launcher goes away
            tryCompare(left, "shown", true); // still on left page
            tryCompare(errorLabel, "opacity", 1); // show error
        }

        function test_launcherDragBack() {
            // goToPage does a full launcher pull.  But here we test pulling
            // all the way out, then dragging back into place.

            var left = goToPage("tutorialLeft");
            touchFlick(shell, 0, halfHeight, halfWidth, halfHeight, true, false);
            touchFlick(shell, halfWidth, halfHeight, 0, halfHeight, false, true);

            tryCompare(left, "shown", true); // and we should still be on left
        }

        function test_interrupted() {
            goToPage("tutorialLeft");
            ApplicationManager.startApplication("dialer-app");
            checkFinished();
        }
    }
}
