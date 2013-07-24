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
    }
}
