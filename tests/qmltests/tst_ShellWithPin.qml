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
import AccountsService 0.1
import GSettings 1.0
import LightDM 0.1 as LightDM
import Ubuntu.SystemImage 0.1
import Unity.Application 0.1
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
        maxFailedLogins: 3
    }

    SignalSpy {
        id: sessionSpy
        signalName: "sessionStarted"
    }

    SignalSpy {
        id: resetSpy
        target: SystemImage
        signalName: "resettingDevice"
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

            sessionSpy.target = findChild(shell, "greeter")
        }

        function init() {
            swipeAwayGreeter()
        }

        function cleanup() {
            LightDM.Greeter.showGreeter()
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "showProgress", 1)

            // kill all (fake) running apps
            killApps()
        }

        function killApps() {
            while (ApplicationManager.count > 0) {
                ApplicationManager.stopApplication(ApplicationManager.get(0).appId)
            }
            compare(ApplicationManager.count, 0)
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

        function test_login() {
            tryCompare(sessionSpy, "count", 0)
            enterPin("1234")
            tryCompare(sessionSpy, "count", 1)
        }

        function test_emergencyCall() {
            var greeter = findChild(shell, "greeter")
            var lockscreen = findChild(shell, "lockscreen")
            var emergencyButton = findChild(lockscreen, "emergencyCallIcon")
            var panel = findChild(shell, "panel")
            var indicators = findChild(shell, "indicators")
            var launcher = findChild(shell, "launcher")
            var stage = findChild(shell, "stage")

            mouseClick(emergencyButton, units.gu(1), units.gu(1))

            tryCompare(greeter, "fakeActiveForApp", "dialer-app")
            tryCompare(lockscreen, "shown", false)
            tryCompare(panel, "fullscreenMode", true)
            tryCompare(indicators, "available", false)
            tryCompare(launcher, "available", false)
            tryCompare(stage, "spreadEnabled", false)

            // Cancel emergency mode, and go back to normal
            waitForRendering(greeter)
            LightDM.Greeter.showGreeter()

            tryCompare(greeter, "shown", true)
            tryCompare(greeter, "fakeActiveForApp", "")
            tryCompare(lockscreen, "shown", true)
            tryCompare(panel, "fullscreenMode", false)
            tryCompare(indicators, "available", true)
            tryCompare(launcher, "available", true)
            tryCompare(stage, "spreadEnabled", true)
        }

        function test_emergencyCallCrash() {
            var lockscreen = findChild(shell, "lockscreen")
            var emergencyButton = findChild(lockscreen, "emergencyCallIcon")
            mouseClick(emergencyButton, units.gu(1), units.gu(1))

            tryCompare(lockscreen, "shown", false)
            killApps() // kill dialer-app, as if it crashed
            tryCompare(lockscreen, "shown", true)
        }

        function test_emergencyCallAppLaunch() {
            var lockscreen = findChild(shell, "lockscreen")
            var emergencyButton = findChild(lockscreen, "emergencyCallIcon")
            mouseClick(emergencyButton, units.gu(1), units.gu(1))

            tryCompare(lockscreen, "shown", false)
            ApplicationManager.startApplication("gallery-app", ApplicationManager.NoFlag)
            tryCompare(lockscreen, "shown", true)
        }

        function test_failedLoginsCount() {
            AccountsService.failedLogins = 0

            enterPin("1111")
            tryCompare(AccountsService, "failedLogins", 1)

            enterPin("1234")
            tryCompare(AccountsService, "failedLogins", 0)
        }

        function test_factoryReset() {
            resetSpy.clear()

            enterPin("1111")

            enterPin("1111")
            tryCompareFunction(function() {return findChild(root, "factoryResetWarningDialog") !== null}, true)

            var dialog = findChild(root, "factoryResetWarningDialog")
            var button = findChild(dialog, "button")
            mouseClick(button, units.gu(1), units.gu(1))
            tryCompareFunction(function() {return findChild(root, "factoryResetWarningDialog")}, null)

            tryCompare(resetSpy, "count", 0)
            enterPin("1111")
            tryCompare(resetSpy, "count", 1)
        }
    }
}
