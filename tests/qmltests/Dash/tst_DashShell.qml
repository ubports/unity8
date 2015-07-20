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
import QtQuick.Window 2.0
import QtTest 1.0
import "../../../qml/Dash"
import "../../../qml/"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(80)
    height: units.gu(80)

    // BEGIN To reduce warnings
    // TODO I think it we should pass down these variables
    // as needed instead of hoping they will be globally around
    property var greeter: null
    property var panel: null
    // BEGIN To reduce warnings


    Shell {
        id: shell
        height: root.height
        width: root.width / 2
    }

    Dash {
        id: dash
        height: root.height
        width: root.width / 2
        x: root.width / 2
        clip: true
    }

    SignalSpy {
        id: spy
    }

    UT.UnityTestCase {
        name: "DashShell"
        when: windowShown

        readonly property Item dashContent: findChild(dash, "dashContent");
        readonly property var scopes: dashContent.scopes

        function init() {
            // clear and reload the scopes.
            scopes.clear();
            var dashContentList = findChild(dash, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(dashContentList, "count", 0);
            scopes.load();
            tryCompare(dashContentList, "currentIndex", 0);
            tryCompare(dashContentList, "count", 6);
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
            mouseFlick(dash, startX, startY, stopX, stopY);
            mouseFlick(dash, startX, startY, stopX, stopY);
            compare(dashContentList.currentIndex, 2, "Could not flick to scope id 2");

            var launcher = findChild(shell, "launcher");
            launcher.switchToNextState("visible")
            var buttonShowDashHome = findChild(launcher, "buttonShowDashHome");
            tryCompare(buttonShowDashHome, "enabled", true);
            mouseClick(buttonShowDashHome);
            tryCompare(dashContentList, "currentIndex", 0);
        }

        function test_setLongSwipeOnDashNoChangeScope() {
            var dashContentList = findChild(dash, "dashContentList");
            var startX = dash.width - units.gu(1);
            var startY = dash.height / 2;
            var stopX = units.gu(1)
            var stopY = startY;
            waitForRendering(dashContentList);
            mouseFlick(dash, startX, startY, stopX, stopY);
            mouseFlick(dash, startX, startY, stopX, stopY);
            compare(dashContentList.currentIndex, 2, "Could not flick to scope id 2");

            var startX = shell.width - units.gu(1);
            var startY = shell.height / 2;
            var stopX = units.gu(1)
            var stopY = startY;
            touchFlick(shell, startX, startY, stopX, stopY);

            // Now do a long launcher movement

            touchFlick(shell, stopX, startY, startX, stopY);
            compare(dashContentList.currentIndex, 2, "Opening the launcher changed the current scope");
        }
    }
}
