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
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
import Unity.Test 0.1 as UT
import Powerd 0.1

import "../../qml"

Item {
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

    SignalSpy {
        id: sessionSpy
        signalName: "sessionStarted"
    }

    Telephony.CallEntry {
        id: phoneCall
        phoneNumber: "+447812221111"
    }

    UT.UnityTestCase {
        name: "Shell"
        when: windowShown

        function initTestCase() {
            var ok = false;
            var attempts = 0;
            var maxAttempts = 1000;

            // Qt loads a qml scene asynchronously. So early on, some findChild() calls made in
            // tests may fail because the desired child item wasn't loaded yet.
            // Thus here we try to ensure the scene has been fully loaded before proceeding with the tests.
            // As I couldn't find an API in QQuickView & friends to tell me that the scene is 100% loaded
            // (all items instantiated, etc), I resort to checking the existence of some key items until
            // repeatedly until they're all there.
            do {
                var dashContentList = findChild(shell, "dashContentList");
                waitForRendering(dashContentList);
                var homeLoader = findChild(dashContentList, "clickscope loader");
                ok = homeLoader !== null
                    && homeLoader.item !== undefined;

                var greeter = findChild(shell, "greeter");
                ok &= greeter !== null;

                var launcherPanel = findChild(shell, "launcherPanel");
                ok &= launcherPanel !== null;

                attempts++;
                if (!ok) {
                    console.log("Attempt " + attempts + " failed. Waiting a bit before trying again.");
                    // wait a bit before retrying
                    wait(100);
                } else {
                    console.log("All seem fine after " + attempts + " attempts.");
                }
            } while (!ok && attempts <= maxAttempts);

            verify(ok);

            swipeAwayGreeter();

            sessionSpy.target = findChild(shell, "greeter")
        }

        function cleanup() {
            // If a test invoked the greeter, make sure we swipe it away again
            var greeter = findChild(shell, "greeter");
            if (greeter.shown) {
                swipeAwayGreeter();
            }

            // kill all (fake) running apps
            killApps(ApplicationManager);

            var dashContent = findChild(shell, "dashContent");
            dashContent.closePreview();

            var dashHome = findChild(shell, "clickscope loader");
            swipeUntilScopeViewIsReached(dashHome);

            hideIndicators();
        }

        function killApps(apps) {
            if (!apps) return;
            while (apps.count > 0) {
                ApplicationManager.stopApplication(apps.get(0).appId);
            }
            compare(ApplicationManager.count, 0)
        }

        /*
           Test the effect of a right-edge drag on the dash in 3 situations:
           1 - when no application has been launched yet
           2 - when there's a minimized application
           3 - after the last running application has been closed/stopped

           The behavior of Dash on 3 should be the same as on 1.
         */
        function test_rightEdgeDrag() {
            checkRightEdgeDragWithNoRunningApps();

            dragLauncherIntoView();

            // Launch an app from the launcher
            tapOnAppIconInLauncher();
            waitUntilApplicationWindowIsFullyVisible();

            // Minimize the application we just launched
            swipeFromLeftEdge(units.gu(27));

            waitForUIToSettle();

            checkRightEdgeDragWithMinimizedApp();

            // Minimize that application once again
            swipeFromLeftEdge(units.gu(27));

            // Right edge behavior should now be the same as before that app,
            // was launched.  Manually cleanup beforehand to get to initial
            // state.
            cleanup();
            waitForUIToSettle();
            checkRightEdgeDragWithNoRunningApps();
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
                waitUntilApplicationWindowIsFullyHidden();
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

            // Suspend while call is active...
            callManager.foregroundCall = phoneCall;
            Powerd.status = Powerd.Off;
            tryCompare(greeter, "showProgress", 0);

            // Now end call, triggering a greeter show
            callManager.foregroundCall = null;
            tryCompare(greeter, "showProgress", 1);

            tryCompare(ApplicationManager, "suspended", true);
            compare(mainApp.state, ApplicationInfo.Suspended);

            // And wake up
            Powerd.status = Powerd.On;
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
        }

        /*
            Perform a right-edge drag when the Dash is being show and there are
            no running/minimized apps to be restored.

            The expected behavior is that an animation should be played to hint the
            user that his right-edge drag gesture has been successfully recognized
            but there is no application to be brought to foreground.
         */
        function checkRightEdgeDragWithNoRunningApps() {
            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;

            var dash = findChild(shell, "dash");
            // check that dash has normal scale and opacity
            tryCompare(dash, "contentScale", 1.0);
            tryCompare(dash, "opacity", 1.0);

            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY,
                       true /* beginTouch */, false /* endTouch */, units.gu(10), 50);

            // check that Dash has been scaled down and had its opacity reduced
            tryCompareFunction(function() { return dash.contentScale <= 0.9; }, true);
            tryCompareFunction(function() { return dash.opacity <= 0.5; }, true);

            touchRelease(shell, shell.width * 0.1, touchY);

            // and now everything should have gone back to normal
            tryCompare(dash, "contentScale", 1.0);
            tryCompare(dash, "opacity", 1.0);
        }

        /*
            Perform a right-edge drag when the Dash is being show and there is
            a running/minimized app to be restored.

            The expected behavior is that the dash should fade away and ultimately be
            made invisible once the gesture is finished as the restored app will now
            be on foreground.
         */
        function checkRightEdgeDragWithMinimizedApp() {
            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;

            var dash = findChild(shell, "dash");
            // check that dash has normal scale and opacity
            tryCompare(dash, "contentScale", 1.0);
            tryCompare(dash, "opacity", 1.0);

            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY,
                       true /* beginTouch */, false /* endTouch */, units.gu(10), 50);

            // check that Dash has been scaled down and had its opacity reduced
            tryCompareFunction(function() { return dash.contentScale <= 0.9; }, true);
            tryCompareFunction(function() { return dash.opacity <= 0.5; }, true);

            touchRelease(shell, shell.width * 0.1, touchY);

            // dash should have gone away, now that the app is on foreground
            tryCompare(dash, "visible", false);
        }

        /*
          Regression test for bug https://bugs.launchpad.net/touch-preview-images/+bug/1193419

          When the user minimizes an application (left-edge swipe) he should always end up in the "Running Apps"
          category of the "Applications" scope view.

          Steps:
          - go to apps lens
          - scroll to the bottom
          - reveal launcher and launch an app
          - perform long left edge swipe to go minimize the app and go back to the dash.

          Expected Results
          - apps lens shown and Running Apps visible on screen
         */
        function test_minimizingAppTakesToRunningApps() {
            var dashApps = findChild(shell, "clickscope");
            swipeUntilScopeViewIsReached(dashApps);

            // swipe finger up until the running/recent apps section (which we assume
            // it's the first one) is as far from view as possible.
            // We also assume that DashApps is tall enough that it's scrollable
            var appsCategoryListView = findChild(dashApps, "categoryListView");
            while (!appsCategoryListView.atYEnd) {
                swipeUpFromCenter();
                tryCompare(appsCategoryListView, "moving", false);
            }

            // Switch away from the Applications scope.
            swipeRightFromCenter();
            waitUntilItemStopsMoving(dashApps);
            verify(!itemIsOnScreen(dashApps));

            dragLauncherIntoView();

            // Launch an app from the launcher
            tapOnAppIconInLauncher();

            waitUntilApplicationWindowIsFullyVisible();

            // Dragging launcher into view with a little bit of gap (units.gu(1)) should switch to Apps scope
            dragLauncherIntoView();
            verify(itemIsOnScreen(dashApps));

            // Minimize the application we just launched
            swipeFromLeftEdge(units.gu(27));

            // Wait for the whole UI to settle down
            waitUntilApplicationWindowIsFullyHidden();
            waitUntilItemStopsMoving(dashApps);
            tryCompare(appsCategoryListView, "moving", false);

            verify(itemIsOnScreen(dashApps));

            var runningApplicationsGrid = findChild(appsCategoryListView, "running.apps.category");
            verify(runningApplicationsGrid);
            verify(itemIsOnScreen(runningApplicationsGrid));
        }

        // Wait for the whole UI to settle down
        function waitForUIToSettle() {
            waitUntilApplicationWindowIsFullyHidden();
            var dashContentList = findChild(shell, "dashContentList");
            tryCompare(dashContentList, "moving", false);
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
            var underlay = findChild(shell, "underlay");
            tryCompare(underlay, "visible", false);
        }

        function waitUntilApplicationWindowIsFullyHidden() {
            var stages = findChild(shell, "stages");
            tryCompare(stages, "fullyHidden", true);
        }

        function swipeUntilScopeViewIsReached(scopeView) {
            while (!itemIsOnScreen(scopeView)) {
                if (itemIsToLeftOfScreen(scopeView)) {
                    swipeRightFromCenter();
                } else {
                    swipeLeftFromCenter();
                }
                waitUntilItemStopsMoving(scopeView);
            }
        }

        function swipeFromLeftEdge(swipeLength) {
            var touchStartX = 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, swipeLength, touchStartY);
        }

        function swipeLeftFromCenter() {
            var touchStartX = shell.width * 3 / 4;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, 0, touchStartY);
        }

        function swipeRightFromCenter() {
            var touchStartX = shell.width * 3 / 4;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, shell.width, touchStartY);
        }

        function swipeUpFromCenter() {
            var touchStartX = shell.width / 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, touchStartX, 0);
        }

        function itemIsOnScreen(item) {
            var itemRectInShell = item.mapToItem(shell, 0, 0, item.width, item.height);

            return itemRectInShell.x >= 0
                && itemRectInShell.y >= 0
                && itemRectInShell.x + itemRectInShell.width <= shell.width
                && itemRectInShell.y + itemRectInShell.height <= shell.height;
        }

        function itemIsToLeftOfScreen(item) {
            var itemRectInShell = item.mapToItem(shell, 0, 0, item.width, item.height);
            return itemRectInShell.x < 0;
        }

        function waitUntilItemStopsMoving(item) {
            var itemRectInShell = item.mapToItem(shell, 0, 0, item.width, item.height);
            var previousX = itemRectInShell.x;
            var previousY = itemRectInShell.y;
            var isStill = false;

            do {
                wait(100);
                itemRectInShell = item.mapToItem(shell, 0, 0, item.width, item.height);
                if (itemRectInShell.x == previousX && itemRectInShell.y == previousY) {
                    isStill = true;
                } else {
                    previousX = itemRectInShell.x;
                    previousY = itemRectInShell.y;
                }
            } while (!isStill);
        }

        function test_DashShown_data() {
            return [
                {tag: "in focus", greeter: false, app: false, launcher: false, indicators: false, expectedShown: true},
                {tag: "under greeter", greeter: true, app: false, launcher: false, indicators: false, expectedShown: false},
                {tag: "under app", greeter: false, app: true, launcher: false, indicators: false, expectedShown: false},
                {tag: "under launcher", greeter: false, app: false, launcher: true, indicators: false, expectedShown: true},
                {tag: "under indicators", greeter: false, app: false, launcher: false, indicators: true, expectedShown: true},
            ]
        }

        function test_DashShown(data) {
            if (data.greeter) {
                // Swipe the greeter in
                var greeter = findChild(shell, "greeter");
                LightDM.Greeter.showGreeter();
                tryCompare(greeter, "showProgress", 1);
            }

            if (data.app) {
                dragLauncherIntoView();
                tapOnAppIconInLauncher();
            }

            if (data.launcher) {
                dragLauncherIntoView();
            }

            if (data.indicators) {
                showIndicators();
            }

            var dash = findChild(shell, "dash");
            tryCompare(dash, "shown", data.expectedShown);
        }

        function test_focusRequestedHidesGreeter() {
            var greeter = findChild(shell, "greeter")

            greeter.show()
            tryCompare(greeter, "showProgress", 1)

            ApplicationManager.focusRequested("notes-app")
            tryCompare(greeter, "showProgress", 0)
            waitUntilApplicationWindowIsFullyVisible()
        }

        function test_showGreeterDBusCall() {
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "showProgress", 0)
            LightDM.Greeter.showGreeter()
            tryCompare(greeter, "showProgress", 1)
        }

        function test_login() {
            sessionSpy.clear()

            var greeter = findChild(shell, "greeter")
            greeter.show()
            tryCompare(greeter, "showProgress", 1)

            tryCompare(sessionSpy, "count", 0)
            swipeAwayGreeter()
            tryCompare(sessionSpy, "count", 1)
        }
    }
}
