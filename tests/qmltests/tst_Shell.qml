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
import Unity.Test 0.1 as UT
import Ubuntu.Application 0.1
import GSettings 1.0

import "../.."

Shell {
    id: shell
    UT.UnityTestCase {
        name: "Shell"
        when: windowShown

        function initTestCase() {
            // swipe away the greeter/lockscreen
            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;
            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY);

            // wait until the animation has finished

            var dash = findChild(shell, "dash");
            tryCompare(dash, "contentScale", 1.0);
            tryCompare(dash, "opacity", 1.0);

            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "x", -greeter.width);
        }

        function cleanup() {
            // kill all (fake) running apps
            ApplicationManager.mainStageApplications.clear();
            ApplicationManager.sideStageApplications.clear();

            var dashHome = findChild(shell, "DashHome");
            swipeUntilScopeViewIsReached(dashHome);
        }

        /*
            Perform a right-edge drag when the Dash is being show and there are
            no running/minimized apps to be restored.

            The expected behavior is that an animation should be played to hint the
            user that his right-edge drag gesture has been successfully recognized
            but there is no application to be brought to foreground.
         */
        function test_rightEdgeDragWithNoRunningApps() {
            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;

            var dash = findChild(shell, "dash");
            // check that dash has normal scale and opacity
            compare(dash.contentScale, 1.0);
            compare(dash.opacity, 1.0);

            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY,
                       true /* beginTouch */, false /* endTouch */);

            // check that Dash has been scaled down and had its opacity reduced
            tryCompareFunction(function() { return dash.contentScale <= 0.9; }, true);
            tryCompareFunction(function() { return dash.opacity <= 0.5; }, true);

            touchRelease(shell, shell.width * 0.1, touchY);

            // and now everything should have gone back to normal
            tryCompare(dash, "contentScale", 1.0);
            tryCompare(dash, "opacity", 1.0);
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
            var dashApps = findChild(shell, "DashApps");

            swipeUntilScopeViewIsReached(dashApps);

            // swipe finger up until the running/recent apps section (which we assume
            // it's the first one) is as far from view as possible.
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

            // Minimize the application we just launched
            swipeFromLeftEdge();

            // Wait for the whole UI to settle down
            waitUntilApplicationWindowIsFullyHidden();
            waitUntilItemStopsMoving(dashApps);
            tryCompare(appsCategoryListView, "moving", false);

            verify(itemIsOnScreen(dashApps));
            var runningApplicationsGrid = findChild(dashApps, "runningApplicationsGrid");
            verify(itemIsOnScreen(runningApplicationsGrid));
        }

        function dragLauncherIntoView() {
            var launcherPanel = findChild(shell, "launcherPanel");
            verify(launcherPanel.x = - launcherPanel.width);
            swipeFromLeftEdge();
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

        function swipeFromLeftEdge() {
            var touchStartX = 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, shell.width * 0.75, touchStartY);
        }

        function swipeLeftFromCenter() {
            var touchStartX = shell.width / 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, 0, touchStartY);
        }

        function swipeRightFromCenter() {
            var touchStartX = shell.width / 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, shell.width, touchStartY);
        }

        function swipeUpFromCenter() {
            var touchStartX = shell.width / 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, touchStartX, 0);
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

        function test_wallpaper() {

        }
    }
}
