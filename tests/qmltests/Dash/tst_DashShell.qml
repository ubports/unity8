/*
 * Copyright 2015 Canonical Ltd.
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

import QtQuick 2.4
import QtTest 1.0
import "../../../qml/Dash"
import "../../../qml/"
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(80)
    height: units.gu(80)

    Shell {
        id: shell
        width: parent.width / 2
        height: parent.height
    }

    Dash {
        id: dash
        width: parent.width / 2
        height: parent.height
        x: width
        clip: true
    }

    UT.UnityTestCase {
        name: "DashShell"
        when: windowShown

        readonly property Item dashContent: findChild(dash, "dashContent");
        readonly property var scopes: dashContent.scopes

        function init() {
            dash.windowActive = true;

            var greeter = findChild(shell, "greeter");
            greeter.forceShow();

            // clear and reload the scopes.
            scopes.clear();
            var dashContentList = findChild(dash, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(dashContentList, "count", 0);
            scopes.load();
            tryCompare(dashContentList, "currentIndex", 0);
            tryCompare(dashContentList, "count", 28);
            tryCompare(scopes, "loaded", true);
            tryCompareFunction(function() {
                var mockScope1Loader = findChild(dash, "scopeLoader0");
                return mockScope1Loader && mockScope1Loader.item != null; },
                true, 15000);
            tryCompareFunction(function() {
                var mockScope1Loader = findChild(dash, "scopeLoader0");
                return mockScope1Loader && mockScope1Loader.status === Loader.Ready; },
                true, 15000);
            waitForRendering(findChild(dash, "scopeLoader0").item);
        }

        function test_setShellHome() {
            var dashContentList = findChild(dash, "dashContentList");
            var startX = dash.width - units.gu(1);
            var startY = dash.height / 2;
            var stopX = units.gu(1)
            var stopY = startY;
            waitForRendering(dashContentList);
            touchFlick(dash, startX, startY, stopX, stopY);
            touchFlick(dash, startX, startY, stopX, stopY);
            compare(dashContentList.currentIndex, 2, "Could not flick to scope id 2");

            // Flick the greeter away
            var startX = shell.width - units.gu(1);
            var startY = shell.height / 2;
            var stopX = units.gu(1)
            var stopY = startY;
            touchFlick(shell, startX, startY, stopX, stopY);

            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "shown", false);

            // bring in the launcher
            var startX = units.gu(1);
            var startY = shell.height / 2;
            var stopX = shell.width / 3;
            var stopY = startY;
            touchFlick(shell, startX, startY, stopX, stopY);

            var launcher = findChild(shell, "launcher");
            var buttonShowDashHome = findChild(launcher, "buttonShowDashHome");
            tryCompare(buttonShowDashHome, "enabled", true);
            tryCompare(launcher, "visibleWidth", launcher.panelWidth);

            // Make sure that opening the launcher doesn't change the scope
            compare(dashContentList.currentIndex, 2, "Opening the launcher changed the current scope");

            mouseClick(buttonShowDashHome);
            tryCompare(dashContentList, "currentIndex", 0);
        }

        function test_setShortLauncherMoveResetNonActiveDash() {
            var dashContentList = findChild(dash, "dashContentList");
            var startX = dash.width - units.gu(1);
            var startY = dash.height / 2;
            var stopX = units.gu(1)
            var stopY = startY;
            waitForRendering(dashContentList);
            touchFlick(dash, startX, startY, stopX, stopY);
            touchFlick(dash, startX, startY, stopX, stopY);
            compare(dashContentList.currentIndex, 2, "Could not flick to scope id 2");

            // Pretend the dash is not active
            dash.windowActive = false;

            // Flick the greeter away
            var startX = shell.width - units.gu(1);
            var startY = shell.height / 2;
            var stopX = units.gu(1)
            var stopY = startY;
            touchFlick(shell, startX, startY, stopX, stopY);

            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "shown", false);

            // Now do a small launcher movement
            touchFlick(shell, stopX, startY, startX, stopY);
            compare(dashContentList.currentIndex, 0, "Small launcher move did not reset dash on non active window");
        }
    }
}
