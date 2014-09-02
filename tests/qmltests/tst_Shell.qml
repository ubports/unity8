/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *   Daniel d'Andrada <daniel.dandrada@canonical.com>
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
import GSettings 1.0
import LightDM 0.1 as LightDM
import Unity.Application 0.1
import Unity.Connectivity 0.1
import Unity.Test 0.1 as UT
import Powerd 0.1

import "../../qml"

Item {
    id: root
    width: shell.width
    height: shell.height

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

    Shell {
        id: shell
    }

    Component {
        id: shellComponent
        Shell {}
    }

    SignalSpy {
        id: sessionSpy
        signalName: "sessionStarted"
    }

    SignalSpy {
        id: dashCommunicatorSpy
        signalName: "setCurrentScopeCalled"
    }

    SignalSpy {
        id: unlockAllModemsSpy
        target: Connectivity
        signalName: "unlockingAllModems"
    }

    UT.UnityTestCase {
        name: "Shell"
        when: windowShown

        function initTestCase() {
            swipeAwayGreeter();

            sessionSpy.target = findChild(shell, "greeter")
            dashCommunicatorSpy.target = findInvisibleChild(shell, "dashCommunicator");
        }

        function cleanup() {
            // If a test invoked the greeter, make sure we swipe it away again
            var greeter = findChild(shell, "greeter");
            if (greeter.shown) {
                swipeAwayGreeter();
            }

            // kill all (fake) running apps
            killApps(ApplicationManager);

            waitForUIToSettle();
            hideIndicators();
        }

        function killApps() {
            while (ApplicationManager.count > 1) {
                var appIndex = ApplicationManager.get(0).appId == "unity8-dash" ? 1 : 0
                ApplicationManager.stopApplication(ApplicationManager.get(appIndex).appId);
            }
            compare(ApplicationManager.count, 1)
        }

        function test_leftEdgeDrag_data() {
            return [
                {tag: "without launcher", revealLauncher: false, swipeLength: units.gu(27), appHides: true},
                {tag: "with launcher", revealLauncher: true, swipeLength: units.gu(27), appHides: true},
                {tag: "small swipe", revealLauncher: false, swipeLength: units.gu(25), appHides: false},
                {tag: "long swipe", revealLauncher: false, swipeLength: units.gu(27), appHides: true}
            ];
        }

        function test_leftEdgeDrag(data) {
            dragLauncherIntoView();
            tapOnAppIconInLauncher();
            waitUntilApplicationWindowIsFullyVisible();

            if (data.revealLauncher) {
                dragLauncherIntoView();
            }

            swipeFromLeftEdge(data.swipeLength);
            if (data.appHides)
                waitUntilDashIsFocused();
            else
                waitUntilApplicationWindowIsFullyVisible();
        }

        function test_suspend() {
            var greeter = findChild(shell, "greeter");

            // Launch an app from the launcher
            dragLauncherIntoView();
            tapOnAppIconInLauncher();
            waitUntilApplicationWindowIsFullyVisible();

            var mainAppId = ApplicationManager.focusedApplicationId;
            verify(mainAppId != "");
            var mainApp = ApplicationManager.findApplication(mainAppId);
            verify(mainApp);
            tryCompare(mainApp, "state", ApplicationInfo.Running);

            // Try to suspend while proximity is engaged...
            Powerd.displayPowerStateChange(Powerd.Off, Powerd.Proximity);
            tryCompare(greeter, "showProgress", 0);

            // Now really suspend
            print("suspending")
            Powerd.displayPowerStateChange(Powerd.Off, 0);
            print("done suspending")
            tryCompare(greeter, "showProgress", 1);

            tryCompare(ApplicationManager, "suspended", true);
            compare(mainApp.state, ApplicationInfo.Suspended);

            // And wake up
            Powerd.displayPowerStateChange(Powerd.On, 0);
            tryCompare(greeter, "showProgress", 1);

            // Swipe away greeter to focus app
            swipeAwayGreeter();
            tryCompare(ApplicationManager, "suspended", false);
            compare(mainApp.state, ApplicationInfo.Running);
            tryCompare(ApplicationManager, "focusedApplicationId", mainAppId);
        }

        function swipeAwayGreeter() {
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "showProgress", 1);

            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;
            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY);

            // wait until the animation has finished
            tryCompare(greeter, "showProgress", 0);
            waitForRendering(greeter);
        }

        /*
          Regression test for bug https://bugs.launchpad.net/touch-preview-images/+bug/1193419

          When the user minimizes an application (left-edge swipe) he should always end up in the
          "Applications" scope view.

          Steps:
          - reveal launcher and launch an app that covers the dash
          - perform long left edge swipe to go minimize the app and go back to the dash.
          - verify the setCurrentScope() D-Bus call to the dash has been called for the correct scope id.
         */
        function test_minimizingAppTakesToDashApps() {
            dragLauncherIntoView();

            // Launch an app from the launcher
            tapOnAppIconInLauncher();

            waitUntilApplicationWindowIsFullyVisible();

            verify(ApplicationManager.focusedApplicationId !== "unity8-dash")

            dashCommunicatorSpy.clear();
            // Minimize the application we just launched
            swipeFromLeftEdge(units.gu(27));

            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");

            compare(dashCommunicatorSpy.count, 1);
            compare(dashCommunicatorSpy.signalArguments[0][0], "clickscope");
        }

        function test_showInputMethod() {
            var item = findChild(shell, "inputMethod");
            var surface = SurfaceManager.inputMethodSurface();

            surface.setState(MirSurfaceItem.Minimized);
            tryCompare(item, "visible", false);

            surface.setState(MirSurfaceItem.Restored);
            tryCompare(item, "visible", true);

            surface.setState(MirSurfaceItem.Minimized);
            tryCompare(item, "visible", false);

            surface.setState(MirSurfaceItem.Maximized);
            tryCompare(item, "visible", true);

            surface.setState(MirSurfaceItem.Minimized);
            tryCompare(item, "visible", false);
        }

        function test_surfaceLosesFocusWhilePanelIsOpen() {
            var app = ApplicationManager.startApplication("dialer-app");
            // wait until the app is fully loaded (ie, real surface replaces splash screen)
            tryCompareFunction(function() { return app.surface != null }, true);

            tryCompare(app.surface, "focus", true);

            // Drag the indicators panel half-open
            var touchX = shell.width / 2;
            var indicators = findChild(shell, "indicators");
            touchFlick(indicators,
                    touchX /* fromX */, indicators.panelHeight * 0.5 /* fromY */,
                    touchX /* toX */, shell.height * 0.5 /* toY */,
                    true /* beginTouch */, false /* endTouch */);
            verify(indicators.partiallyOpened);

            tryCompare(app.surface, "focus", false);

            // And finish getting it open
            touchFlick(indicators,
                    touchX /* fromX */, shell.height * 0.5 /* fromY */,
                    touchX /* toX */, shell.height * 0.9 /* toY */,
                    false /* beginTouch */, true /* endTouch */);
            tryCompare(indicators, "fullyOpened", true);

            tryCompare(app.surface, "focus", false);

            dragToCloseIndicatorsPanel();

            tryCompare(app.surface, "focus", true);
        }

        // Wait for the whole UI to settle down
        function waitForUIToSettle() {
            var launcher = findChild(shell, "launcherPanel")
            tryCompareFunction(function() {return launcher.x === 0 || launcher.x === -launcher.width;}, true);
            if (launcher.x === 0) {
                mouseClick(shell, shell.width / 2, shell.height / 2)
            }
            tryCompare(launcher, "x", -launcher.width)

            waitForRendering(shell)
        }

        function dragToCloseIndicatorsPanel() {
            var indicators = findChild(shell, "indicators");

            var touchStartX = shell.width / 2;
            var touchStartY = shell.height - (indicators.panelHeight * 0.5);
            touchFlick(shell,
                    touchStartX, touchStartY,
                    touchStartX, shell.height * 0.1);

            tryCompare(indicators, "fullyClosed", true);
        }

        function dragLauncherIntoView() {
            var launcherPanel = findChild(shell, "launcherPanel");
            verify(launcherPanel.x = - launcherPanel.width);

            var touchStartX = 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, launcherPanel.width + units.gu(1), touchStartY);

            tryCompare(launcherPanel, "x", 0);
        }

        function tapOnAppIconInLauncher() {
            var launcherPanel = findChild(shell, "launcherPanel");

            // pick the first icon, the one at the bottom.
            var appIcon = findChild(launcherPanel, "launcherDelegate0")

            // Swipe upwards over the launcher to ensure that this icon
            // at the bottom is not folded and faded away.
            var touchStartX = launcherPanel.width / 2;
            var touchStartY = launcherPanel.height / 2;
            touchFlick(launcherPanel, touchStartX, touchStartY, touchStartX, 0);
            tryCompare(launcherPanel, "moving", false);

            // NB tapping (i.e., using touch events) doesn't activate the icon... go figure...
            mouseClick(appIcon, appIcon.width / 2, appIcon.height / 2);
        }

        function showIndicators() {
            var indicators = findChild(shell, "indicators");
            indicators.show();
            tryCompare(indicators, "fullyOpened", true);
        }

        function hideIndicators() {
            var indicators = findChild(shell, "indicators");
            if (indicators.fullyOpened) {
                indicators.hide();
            }
        }

        function waitUntilApplicationWindowIsFullyVisible() {
            var appDelegate = findChild(shell, "appDelegate0")
            var surfaceContainer = findChild(appDelegate, "surfaceContainer");
            tryCompareFunction(function() { return surfaceContainer.surface !== null; }, true);
        }

        function waitUntilDashIsFocused() {
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");
        }

        function swipeFromLeftEdge(swipeLength) {
            var touchStartX = 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, swipeLength, touchStartY);
        }

        function itemIsOnScreen(item) {
            var itemRectInShell = item.mapToItem(shell, 0, 0, item.width, item.height);

            return itemRectInShell.x >= 0
                && itemRectInShell.y >= 0
                && itemRectInShell.x + itemRectInShell.width <= shell.width
                && itemRectInShell.y + itemRectInShell.height <= shell.height;
        }

        function test_focusRequestedHidesGreeter() {
            var greeter = findChild(shell, "greeter");

            var app = ApplicationManager.startApplication("dialer-app");
            // wait until the app is fully loaded (ie, real surface replaces splash screen)
            tryCompareFunction(function() { return app.surface != null }, true);

            // Minimize the application we just launched
            swipeFromLeftEdge(units.gu(26) + 1);

            waitUntilDashIsFocused();

            greeter.show();
            tryCompare(greeter, "showProgress", 1);

            // The main point of this test
            ApplicationManager.requestFocusApplication("dialer-app");
            tryCompare(greeter, "showProgress", 0);
            waitForRendering(greeter);
        }

        function test_focusRequestedHidesIndicators() {
            var indicators = findChild(shell, "indicators");

            showIndicators();

            var oldCount = ApplicationManager.count;
            ApplicationManager.startApplication("camera-app");
            tryCompare(ApplicationManager, "count", oldCount + 1);

            tryCompare(indicators, "fullyClosed", true);
        }

        function test_showAndHideGreeterDBusCalls() {
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "showProgress", 0)
            waitForRendering(greeter);
            LightDM.Greeter.showGreeter()
            tryCompare(greeter, "showProgress", 1)
            LightDM.Greeter.hideGreeter()
            tryCompare(greeter, "showProgress", 0)
        }

        function test_login() {
            sessionSpy.clear()

            var greeter = findChild(shell, "greeter")
            waitForRendering(greeter)
            greeter.show()
            tryCompare(greeter, "showProgress", 1)

            tryCompare(sessionSpy, "count", 0)
            swipeAwayGreeter()
            tryCompare(sessionSpy, "count", 1)
        }

        function test_fullscreen() {
            var panel = findChild(shell, "panel");
            compare(panel.fullscreenMode, false);
            ApplicationManager.startApplication("camera-app");
            tryCompare(panel, "fullscreenMode", true);
            ApplicationManager.startApplication("dialer-app");
            tryCompare(panel, "fullscreenMode", false);
            ApplicationManager.requestFocusApplication("camera-app");
            tryCompare(panel, "fullscreenMode", true);
            ApplicationManager.requestFocusApplication("dialer-app");
            tryCompare(panel, "fullscreenMode", false);
        }

        function test_leftEdgeDragFullscreen() {
            var panel = findChild(shell, "panel");
            tryCompare(panel, "fullscreenMode", false)

            ApplicationManager.startApplication("camera-app");
            tryCompare(panel, "fullscreenMode", true)

            var touchStartX = 2;
            var touchStartY = shell.height / 2;

            touchFlick(shell, touchStartX, touchStartY, units.gu(2), touchStartY, true, false);

            compare(panel.fullscreenMode, true);

            touchFlick(shell, units.gu(2), touchStartY, units.gu(10), touchStartY, false, false);

            tryCompare(panel, "fullscreenMode", false);

            touchRelease(shell);
        }

        function test_unlockedProperties() {
            // Confirm that various properties have the correct values when unlocked
            tryCompare(shell, "locked", false)

            var launcher = findChild(shell, "launcher")
            tryCompare(launcher, "available", true)

            var indicators = findChild(shell, "indicators")
            tryCompare(indicators, "available", true)
        }

        function test_unlockAllModemsOnBoot() {
            unlockAllModemsSpy.clear()
            // actually create an object so we notice the onCompleted signal
            var greeter = shellComponent.createObject(root)
            // TODO reenable when service ready (LP: #1361074)
            expectFail("", "Unlock on boot temporarily disabled");
            tryCompare(unlockAllModemsSpy, "count", 1)
            greeter.destroy()
        }
    }
}
