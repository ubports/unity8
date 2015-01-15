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
import Ubuntu.Components 1.0
import QtTest 1.0
import AccountsService 0.1
import GSettings 1.0
import LightDM 0.1 as LightDM
import Ubuntu.SystemImage 0.1
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
import Unity.Test 0.1 as UT
import Powerd 0.1

import "../../qml"

Item {
    id: root
    width: contentRow.width
    height: contentRow.height

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

    Row {
        id: contentRow

        Loader {
            id: shellLoader

            width: units.gu(40)
            height: units.gu(71)

            property bool itemDestroyed: false
            sourceComponent: Component {
                Shell {
                    property string indicatorProfile: "phone"

                    Component.onDestruction: {
                        shellLoader.itemDestroyed = true
                    }
                }
            }
        }

        Rectangle {
            color: "white"
            width: units.gu(30)
            height: shellLoader.height

            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                spacing: units.gu(1)
                Button {
                    anchors { left: parent.left; right: parent.right }
                    text: "Show Greeter"
                    onClicked: {
                        if (shellLoader.status !== Loader.Ready)
                            return

                        var greeter = testCase.findChild(shellLoader.item, "greeter")
                        if (!greeter.shown) {
                            greeter.show()
                        }
                    }
                }

                Label {
                    text: "Max retries:"
                    color: "black"
                }
                TextField {
                    id: maxRetriesTextField
                    text: "-1"
                    onTextChanged: {
                        var greeter = testCase.findChild(shellLoader.item, "greeter");
                        greeter.maxFailedLogins = text;
                    }
                }
            }
        }
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

    SignalSpy {
        id: promptSpy
        target: LightDM.Greeter
        signalName: "showPrompt"
    }

    Telephony.CallEntry {
        id: phoneCall
        phoneNumber: "+447812221111"
    }

    UT.UnityTestCase {
        id: testCase
        name: "ShellWithPin"
        when: windowShown

        property Item shell: shellLoader.status === Loader.Ready ? shellLoader.item : null

        function init() {
            tryCompare(shell, "enabled", true); // will be enabled when greeter is all ready
            var greeter = findChild(shell, "greeter");
            sessionSpy.target = greeter;
            swipeAwayGreeter(true);
            waitForLockscreen()
            greeter.failedLoginsDelayAttempts = -1;
            greeter.maxFailedLogins = -1;
        }

        function cleanup() {
            tryCompare(shell, "enabled", true); // make sure greeter didn't leave us in disabled state

            shellLoader.itemDestroyed = false

            shellLoader.active = false

            tryCompare(shellLoader, "status", Loader.Null)
            tryCompare(shellLoader, "item", null)
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // item might still be alive. So if we set Loader.active back to true
            // again right now we will get the very same Shell instance back. So no reload
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(shellLoader, "itemDestroyed", true)

            // kill all (fake) running apps
            killApps()

            AccountsService.enableLauncherWhileLocked = true
            AccountsService.enableIndicatorsWhileLocked = true
            AccountsService.demoEdges = false
            callManager.foregroundCall = null
            LightDM.Greeter.authenticate(""); // reset greeter

            // reload our test subject to get it in a fresh state once again
            shellLoader.active = true

            tryCompare(shellLoader, "status", Loader.Ready)
            removeTimeConstraintsFromDirectionalDragAreas(shellLoader.item)
        }

        function killApps() {
            while (ApplicationManager.count > 1) {
                var appIndex = ApplicationManager.get(0).appId == "unity8-dash" ? 1 : 0
                ApplicationManager.stopApplication(ApplicationManager.get(appIndex).appId);
            }
            compare(ApplicationManager.count, 1)
        }

        function swipeAwayGreeter(waitForCoverPage) {
            var greeter = findChild(shell, "greeter");
            waitForRendering(greeter)
            tryCompare(greeter, "fullyShown", true);

            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;
            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY);

            if (waitForCoverPage) {
                // wait until the animation has finished
                var coverPage = findChild(shell, "coverPage");
                tryCompare(coverPage, "showProgress", 0);
            }
        }

        function waitForLockscreen() {
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
                tap(button)
            }
        }

        function confirmLockedApp(app) {
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "shown", false)
            tryCompare(greeter, "hasLockedApp", true)
            tryCompare(greeter, "lockedApp", app)
            tryCompare(LightDM.Greeter, "active", true)
            tryCompare(ApplicationManager, "focusedApplicationId", app)
        }

        function test_login() {
            sessionSpy.clear()
            tryCompare(sessionSpy, "count", 0)
            enterPin("1234")
            tryCompare(sessionSpy, "count", 1)
        }

        function test_edgeDemoHidesLockscreen() {
            LightDM.Greeter.showGreeter()
            sessionSpy.clear()
            var lockscreen = findChild(shell, "lockscreen")

            tryCompare(lockscreen, "shown", true)
            AccountsService.demoEdges = true
            tryCompare(lockscreen, "shown", false)

            var greeter = findChild(shell, "greeter");
            swipeAwayGreeter(false);
            tryCompare(greeter, "shown", false);
            tryCompare(sessionSpy, "count", 1)

            // Lockscreen is only hidden by the edge demo, so if we turn that
            // off and show greeter again, lockscreen should appear
            AccountsService.demoEdges = false
            LightDM.Greeter.showGreeter()
            lockscreen = findChild(shell, "lockscreen");
            tryCompare(lockscreen, "shown", true)
        }

        function test_disabledEdges() {
            var launcher = findChild(shell, "launcher")
            tryCompare(launcher, "available", true)
            AccountsService.enableLauncherWhileLocked = false
            tryCompare(launcher, "available", false)

            var indicators = findChild(shell, "indicators")
            tryCompare(indicators, "available", true)
            AccountsService.enableIndicatorsWhileLocked = false
            tryCompare(indicators, "available", false)
        }

        function test_emergencyCall() {
            var greeter = findChild(shell, "greeter")
            var panel = findChild(shell, "panel")
            var indicators = findChild(shell, "indicators")
            var launcher = findChild(shell, "launcher")
            var stage = findChild(shell, "stage")

            tap(findChild(greeter, "emergencyCallLabel"));

            tryCompare(greeter, "lockedApp", "dialer-app")
            tryCompare(greeter, "hasLockedApp", true)
            tryCompare(greeter, "shown", false);
            tryCompare(panel, "fullscreenMode", true)
            tryCompare(indicators, "available", false)
            tryCompare(launcher, "available", false)
            tryCompare(stage, "spreadEnabled", false)

            // Cancel emergency mode, and go back to normal
            waitForRendering(greeter)
            LightDM.Greeter.showGreeter()

            tryCompare(greeter, "shown", true)
            tryCompare(greeter, "lockedApp", "")
            tryCompare(greeter, "hasLockedApp", false)
            tryCompare(greeter, "fullyShown", true);
            tryCompare(panel, "fullscreenMode", false)
            tryCompare(indicators, "available", true)
            tryCompare(launcher, "available", true)
            tryCompare(stage, "spreadEnabled", true)
        }

        function test_emergencyCallCrash() {
            var greeter = findChild(shell, "greeter");
            var emergencyButton = findChild(greeter, "emergencyCallLabel");
            tap(emergencyButton)

            tryCompare(greeter, "shown", false);
            killApps() // kill dialer-app, as if it crashed
            tryCompare(greeter, "shown", true);
            tryCompare(findChild(greeter, "lockscreen"), "shown", true);
            tryCompare(findChild(greeter, "coverPage"), "shown", false);
        }

        function test_emergencyCallAppLaunch() {
            var greeter = findChild(shell, "greeter");
            var emergencyButton = findChild(greeter, "emergencyCallLabel");
            tap(emergencyButton)

            tryCompare(greeter, "shown", false);
            ApplicationManager.startApplication("gallery-app", ApplicationManager.NoFlag)
            tryCompare(greeter, "shown", true);
        }

        function test_failedLoginsCount() {
            AccountsService.failedLogins = 0

            enterPin("1111")
            tryCompare(AccountsService, "failedLogins", 1)

            enterPin("1234")
            tryCompare(AccountsService, "failedLogins", 0)
        }

        function test_wrongEntries() {
            var greeter = findChild(shell, "greeter");
            greeter.failedLoginsDelayAttempts = 3;

            var placeHolder = findChild(shell, "wrongNoticeLabel")
            tryCompare(placeHolder, "text", "")

            enterPin("1111")
            tryCompare(placeHolder, "text", "Sorry, incorrect passcode")

            enterPin("1111")
            tryCompare(placeHolder, "text", "Sorry, incorrect passcode")

            var lockscreen = findChild(shell, "lockscreen")
            tryCompare(lockscreen, "delayMinutes", 0)
            enterPin("1111")
            tryCompare(lockscreen, "delayMinutes", greeter.failedLoginsDelayMinutes);
        }

        function test_factoryReset() {
            maxRetriesTextField.text = "3"
            resetSpy.clear()

            enterPin("1111")
            enterPin("1111")
            tryCompareFunction(function() {return findChild(root, "infoPopup") !== null}, true)

            var dialog = findChild(root, "infoPopup")
            var button = findChild(dialog, "infoPopupOkButton")
            tap(button)
            tryCompareFunction(function() {return findChild(root, "infoPopup")}, null)

            tryCompare(resetSpy, "count", 0)
            enterPin("1111")
            tryCompare(resetSpy, "count", 1)
        }

        function test_emergencyDialerLockOut() {
            // This is a theoretical attack on the lockscreen: Enter emergency
            // dialer mode on a phone, then plug into a larger screen,
            // switching to a tablet interface.  This would in theory move the
            // dialer to a side stage and give access to other apps.  So just
            // confirm that such an attack doesn't work.

            var applicationsDisplayLoader = findChild(shell, "applicationsDisplayLoader")

            // We start in phone mode
            tryCompare(shell, "sideStageEnabled", false)
            tryCompare(applicationsDisplayLoader, "tabletMode", false)

            var lockscreen = findChild(shell, "lockscreen")
            lockscreen.emergencyCall()
            confirmLockedApp("dialer-app")

            // OK, we're in. Now try (but fail) to switch to tablet mode
            shell.tablet = true
            tryCompare(shell, "sideStageEnabled", true)
            tryCompare(applicationsDisplayLoader, "tabletMode", false)

            // And when we kill the app, we go back to locked tablet mode
            killApps()
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "fullyShown", true)
            tryCompare(shell, "sideStageEnabled", true)
            tryCompare(applicationsDisplayLoader, "tabletMode", true)
        }

        function test_emergencyDialerIncoming() {
            callManager.foregroundCall = phoneCall
            confirmLockedApp("dialer-app")
        }

        function test_emergencyDialerActiveCallPanel() {
            // Make sure that the following sequence works:
            // - Enter emergency mode call
            // - Return to greeter
            // - Click on active call panel
            // - Should be back in emergency mode dialer

            var greeter = findChild(shell, "greeter");
            var lockscreen = findChild(shell, "lockscreen");

            lockscreen.emergencyCall();
            confirmLockedApp("dialer-app");
            callManager.foregroundCall = phoneCall;

            LightDM.Greeter.showGreeter();
            tryCompare(lockscreen, "shown", true);
            tryCompare(greeter, "hasLockedApp", false);

            // simulate a callHint press, the real thing requires dialer: url support
            ApplicationManager.requestFocusApplication("dialer-app");

            confirmLockedApp("dialer-app");
        }

        function test_normalDialerActiveCallPanel() {
            // Make sure that the following sequence works:
            // - Log in
            // - Start a call
            // - Switch apps
            // - Click on active call panel
            // - Should be back in normal dialer
            // (we've had a bug where we locked screen in this case)

            var greeter = findChild(shell, "greeter");
            var panel = findChild(shell, "panel");

            enterPin("1234");
            tryCompare(greeter, "shown", false);
            tryCompare(LightDM.Greeter, "active", false);

            ApplicationManager.startApplication("dialer-app", ApplicationManager.NoFlag);
            tryCompare(ApplicationManager, "focusedApplicationId", "dialer-app");
            callManager.foregroundCall = phoneCall;

            ApplicationManager.requestFocusApplication("unity8-dash");
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");
            tryCompare(panel.callHint, "visible", true);

            // simulate a callHint press, the real thing requires dialer: url support
            ApplicationManager.requestFocusApplication("dialer-app");

            tryCompare(ApplicationManager, "focusedApplicationId", "dialer-app");
            tryCompare(greeter, "shown", false);
            tryCompare(LightDM.Greeter, "active", false);
        }

        function test_suspend() {
            var greeter = findChild(shell, "greeter");

            // Put it to sleep
            Powerd.status = Powerd.Off;

            // If locked, ApplicationManager.suspended should be true
            tryCompare(ApplicationManager, "suspended", true);

            // And wake up
            Powerd.status = Powerd.On;
            tryCompare(greeter, "fullyShown", true);

            // Swipe away greeter to focus app
            swipeAwayGreeter(true);

            // We have a lockscreen, make sure we're still suspended
            tryCompare(ApplicationManager, "suspended", true);

            enterPin("1234")

            // Now that the lockscreen has gone too, make sure we're waking up
            tryCompare(ApplicationManager, "suspended", false);

        }

        /* We had a bug (1395075) where if a user kept swiping as the greeter
           loaded, they would be able to get into the session before the
           lockscreen appeared. Make sure that doesn't happen. */
        function test_earlyDisable() {
            // Kill current shell
            shellLoader.itemDestroyed = false;
            shellLoader.active = false;
            tryCompare(shellLoader, "itemDestroyed", true);
            LightDM.Greeter.authenticate(""); // reset greeter

            // Create new shell
            promptSpy.clear();
            shellLoader.active = true;
            tryCompareFunction(function() {return shell !== null}, true);

            // Confirm that we start disabled
            compare(promptSpy.count, 0);
            verify(!shell.enabled);

            // And that we only become enabled once the lockscreen is up
            tryCompare(shell, "enabled", true);
            verify(promptSpy.count > 0);
            var lockscreen = findChild(shell, "lockscreen");
            verify(lockscreen.shown);
        }
    }
}
