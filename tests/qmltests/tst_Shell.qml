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
import Ubuntu.Application 0.1
import Unity.Test 0.1 as UT

import "../.."

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

    UT.UnityTestCase {
        name: "Shell"
        when: windowShown

        function initTestCase() {
            // swipe away the greeter/lockscreen
            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;
            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY);

            var dash = findChild(shell, "dash");
            // wait until the animation has finished
            tryCompare(dash, "contentScale", 1.0);
            tryCompare(dash, "opacity", 1.0);
        }

        function cleanup() {
            // kill all (fake) running apps
            ApplicationManager.mainStageApplications.clear();
            ApplicationManager.sideStageApplications.clear();

            var dashHome = findChild(shell, "DashHome");
            swipeUntilScopeViewIsReached(dashHome);
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
            swipeFromLeftEdge();

            waitForUIToSettle();

            checkRightEdgeDragWithMinimizedApp();

            // Minimize that application once again
            swipeFromLeftEdge();

            // kill it
            ApplicationManager.mainStageApplications.clear();

            waitForUIToSettle();

            // Right edge behavior should now be the same as before that app was launched
            checkRightEdgeDragWithNoRunningApps();
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
                       true /* beginTouch */, false /* endTouch */);

            // check that Dash has been scaled down and had its opacity reduced
            tryCompareFunction(function() { return dash.contentScale <= 0.9; }, true);
            tryCompareFunction(function() { return dash.opacity <= 0.5; }, true);

            touchRelease(shell, shell.width * 0.1, touchY);

            // dash should have gone away, now that the app is on foreground
            tryCompare(dash, "visible", false);
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

        function test_wallpaper_data() {
            return [
                {tag: "red", url: "tests/data/unity/backgrounds/red.png", expectedUrl: "tests/data/unity/backgrounds/red.png"},
                {tag: "blue", url: "tests/data/unity/backgrounds/blue.png", expectedUrl: "tests/data/unity/backgrounds/blue.png"},
                {tag: "invalid", url: "invalid", expectedUrl: shell.defaultBackground},
                {tag: "empty", url: "", expectedUrl: shell.defaultBackground}
            ]
        }

        function test_wallpaper(data) {
            var backgroundImage = findChild(shell, "backgroundImage")
            GSettingsController.setPictureUri(data.url)
            tryCompareFunction(function() { return backgroundImage.source.toString().indexOf(data.expectedUrl) !== -1; }, true)
            tryCompare(backgroundImage, "status", Image.Ready)
        }
    }
}
