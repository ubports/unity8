/*
 * Copyright (C) 2013,2014,2015 Canonical, Ltd.
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
import IntegratedLightDM 0.1 as LightDM
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

    Component.onCompleted: {
        // must set the mock mode before loading the Shell
        LightDM.Greeter.mockMode = "single-pin";
        LightDM.Users.mockMode = "single-pin";
        shellLoader.active = true;
    }

    Row {
        spacing: 0
        anchors.fill: parent

        Loader {
            id: shellLoader

            active: false
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
            tryCompare(shell, "enabled", true); // enabled by greeter when ready

            AccountsService.demoEdges = false;
            AccountsService.demoEdges = true;
            swipeAwayGreeter();
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
            var coverPage = findChild(shell, "coverPage");
            tryCompare(coverPage, "showProgress", 1);

            touchFlick(shell, halfWidth, halfHeight, shell.width, halfHeight);

            // wait until the animation has finished
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "required", false);
            waitForRendering(greeter);
        }

        function waitForPage(name) {
            waitForRendering(findChild(shell, name));
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
            if (shell.usageScenario === "phone") {
                touchFlick(shell, shell.width, halfHeight, halfWidth, halfHeight);

                var stage = findChild(shell, "stage");
                var spreadView = findChild(stage, "spreadView");
                tryCompare(spreadView, "phase", 0);
            }
        }

        function checkBottomEdge() {
            // Can't actually check effect of swipe, since dash isn't really loaded
            var applicationsDisplayLoader = findChild(shell, "applicationsDisplayLoader");
            tryCompare(applicationsDisplayLoader, "interactive", false);
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
            touchFlick(shell,
                shell.width, halfHeight,
                halfWidth, halfHeight,
                true /* beginTouch */, true /* endTouch */,
                20 /* speed */, 50 /* iterations */);
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

        function test_skipOnDesktop() {
            var tutorial = findChild(shell, "tutorial");
            tryCompare(tutorial, "active", true);
            tryCompare(tutorial, "running", true);

            shell.usageScenario = "desktop";
            tryCompare(tutorial, "active", false);
            tryCompare(tutorial, "running", false);
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

            var errorTextLabel = findChild(left, "errorTextLabel");
            var errorTitleLabel = findChild(left, "errorTitleLabel");
            tryCompare(launcher, "state", ""); // launcher goes away
            tryCompare(left, "shown", true); // still on left page
            tryCompare(errorTextLabel, "opacity", 1); // show error
            tryCompare(errorTitleLabel, "opacity", 1); // show error
        }

        function test_launcherDragBack() {
            // goToPage does a full launcher pull.  But here we test pulling
            // all the way out, then dragging back into place.

            var left = goToPage("tutorialLeft");
            touchFlick(shell, 0, halfHeight, halfWidth, halfHeight, true, false);
            touchFlick(shell, halfWidth, halfHeight, 0, halfHeight, false, true);

            tryCompare(left, "shown", true); // and we should still be on left
        }

        function test_launcherNoDragGap() {
            // See bug 1454882, where if you dragged the launcher while it was
            // visible, you could pull it further than the edge of the screen.

            var left = goToPage("tutorialLeft");
            var launcher = findChild(shell, "launcher");
            var teaseAnimation = findInvisibleChild(left, "teaseAnimation");

            // Wait for launcher to be really out there
            tryCompareFunction(function() {return launcher.x > teaseAnimation.maxBounce/2}, true);
            verify(teaseAnimation.running);

            // Start a drag, make sure animation stops
            touchFlick(shell, 0, halfHeight, units.gu(4), halfHeight, true, false);
            verify(!teaseAnimation.running);
            verify(launcher.visibleWidth > 0);
            verify(launcher.x > 0);
            compare(launcher.x, teaseAnimation.bounce);

            // Continue drag, make sure we don't create a gap on the left hand side
            touchFlick(shell, units.gu(4), halfHeight, shell.width, halfHeight, false, false);
            verify(!teaseAnimation.running);
            compare(launcher.visibleWidth, launcher.panelWidth);
            compare(launcher.x, 0);

            // Finish and make sure we continue animation
            touchFlick(shell, shell.width, halfHeight, shell.width, halfHeight, false, true);
            tryCompare(teaseAnimation, "running", true);
        }

        function test_spread() {
            // Unfortunately, most of what we want to test of the spread is
            // "did it render correctly?" but that's hard to test.  So instead,
            // just poke and prod it a little bit to see if some of the values
            // we'd expect to be correct, are so.

            var right = goToPage("tutorialRight");
            var stage = findChild(right, "stage");
            var delegate0 = findChild(right, "appDelegate0");

            tryCompare(stage, "dragProgress", 0);
            touchFlick(shell, shell.width, halfHeight, shell.width * 0.8, halfHeight, true, false);
            verify(stage.dragProgress > 0);
            compare(stage.dragProgress, -delegate0.xTranslate);
            touchFlick(shell, shell.width * 0.8, halfHeight, shell.width, halfHeight, false, true);
            tryCompare(stage, "dragProgress", 0);

            tryCompare(delegate0, "x", shell.width);

            var screenshotImage = findChild(right, "screenshotImage");
            tryCompare(screenshotImage, "source", Qt.resolvedUrl("../../../qml/Tutorial/graphics/facebook.png"));
            tryCompare(screenshotImage, "visible", true);
        }

        function test_bottomShortDrag() {
            var bottom = goToPage("tutorialBottom");

            touchFlick(shell, halfWidth, shell.height, halfWidth, shell.height * 0.8);

            var errorTextLabel = findChild(bottom, "errorTextLabel");
            var errorTitleLabel = findChild(bottom, "errorTitleLabel");
            tryCompare(bottom, "shown", true); // still on bottom page
            tryCompare(errorTextLabel, "opacity", 1); // show error
            tryCompare(errorTitleLabel, "opacity", 1); // show error
        }

        function test_interrupted() {
            goToPage("tutorialLeft");
            ApplicationManager.startApplication("dialer-app");
            checkFinished();
        }
    }
}
