/*
 * Copyright (C) 2014 Canonical, Ltd.
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

    UT.UnityTestCase {
        name: "ShellWithPin"
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
            sessionSpy.clear()
        }

        function swipeAwayGreeter() {
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "showProgress", 1);

            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;
            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY);

            // wait until the animation has finished
            tryCompare(greeter, "showProgress", 0);

            // and for pin to be ready
            var lockscreen = findChild(shell, "lockscreen");
            var pinPadLoader = findChild(lockscreen, "pinPadLoader");
            tryCompare(pinPadLoader, "status", Loader.Ready)
            waitForRendering(lockscreen)
        }

        function enterPin(pin) {
            var inputField = findChild(shell, "pinentryField")
            for (var i = 0; i < pin.length; ++i) {
                var character = pin.charAt(i)
                var button = findChild(shell, "pinPadButton" + character)
                mouseClick(button, units.gu(1), units.gu(1))
            }
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

        function test_login() {
            tryCompare(sessionSpy, "count", 0)
            enterPin("1234")
            tryCompare(sessionSpy, "count", 1)
        }

        function test_emergencyCall() {
            dragLauncherIntoView()
            tapOnAppIconInLauncher()

            var lockscreen = findChild(shell, "lockscreen")
            tryCompare(lockscreen, "shown", true)
        }
    }
}
