/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import QtTest 1.0
import AccountsService 0.1
import GSettings 1.0
import LightDMController 0.1
import LightDM.FullLightDM 0.1 as LightDM
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
import Unity.Test 0.1 as UT
import Powerd 0.1

import "../../qml"

Item {
    id: root
    width: contentRow.width
    height: contentRow.height

    Component.onCompleted: {
        // must set the mock mode before loading the Shell
        LightDMController.userMode = "single-pin";
        shellLoader.active = true;
    }

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
            active: false

            width: units.gu(40)
            height: units.gu(71)

            property bool itemDestroyed: false
            sourceComponent: Component {
                Shell {
                    hasTouchscreen: true
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
                    onClicked: LightDM.Greeter.showGreeter()
                }
            }
        }
    }

    SignalSpy {
        id: sessionSpy
        signalName: "sessionStarted"
    }

    Telephony.CallEntry {
        id: phoneCall
        phoneNumber: "+447812221111"
    }

    Item {
        id: fakeDismissTimer
        property bool running: false
        signal triggered

        function stop() {
            running = false;
        }

        function restart() {
            running = true;
        }
    }

    UT.StageTestCase {
        id: testCase
        name: "ShellWithPin"
        when: windowShown

        property Item shell: shellLoader.status === Loader.Ready ? shellLoader.item : null

        function init() {
            tryCompare(shell, "waitingOnGreeter", false); // will be set when greeter is all ready
            var greeter = findChild(shell, "greeter");
            sessionSpy.target = greeter;
            swipeAwayGreeter(true);
            greeter.failedLoginsDelayAttempts = -1;

            var launcher = findChild(shell, "launcher");
            var panel = findChild(launcher, "launcherPanel");
            verify(!!panel);
            panel.dismissTimer = fakeDismissTimer;

            // from StageTestCase
            stage = findChild(shell, "stage");
            topLevelSurfaceList = findInvisibleChild(shell, "topLevelSurfaceList");
            verify(topLevelSurfaceList);

            startApplication("unity8-dash");
        }

        function cleanup() {
            tryCompare(shell, "waitingOnGreeter", false); // make sure greeter didn't leave us in disabled state

            topLevelSurfaceList = null;

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
            removeTimeConstraintsFromSwipeAreas(shellLoader.item)
        }

        function swipeAwayGreeter(waitForCoverPage) {
            var greeter = findChild(shell, "greeter");
            waitForRendering(greeter)
            var coverPage = findChild(shell, "coverPage");
            tryCompare(coverPage, "showProgress", 1);

            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;
            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY);

            if (waitForCoverPage) {
                // wait until the animation has finished
                var coverPage = findChild(shell, "coverPage");
                tryCompare(coverPage, "showProgress", 0);
            }
        }

        function enterPin(pin) {
            typeString(pin);
        }

        function showGreeter() {
            LightDM.Greeter.showGreeter();
            tryCompare(shell, "waitingOnGreeter", false);
            var coverPage = findChild(shell, "coverPage");
            tryCompare(coverPage, "showProgress", 1);
            removeTimeConstraintsFromSwipeAreas(shell);
        }

        function confirmLockedApp(app) {
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "shown", false)
            tryCompare(greeter, "hasLockedApp", true)
            tryCompare(greeter, "lockedApp", app)
            tryCompare(LightDM.Greeter, "active", true)
            tryCompare(ApplicationManager, "focusedApplicationId", app)
        }

        function test_greeterChangesIndicatorProfile() {
            skip("Not supported yet, waiting on design for new settings panel");

            var panel = findChild(shell, "panel");
            tryCompare(panel.indicators.indicatorsModel, "profile", shell.indicatorProfile + "_greeter");

            LightDM.Greeter.hideGreeter();
            tryCompare(panel.indicators.indicatorsModel, "profile", shell.indicatorProfile);

            showGreeter();
            tryCompare(panel.indicators.indicatorsModel, "profile", shell.indicatorProfile + "_greeter");

            LightDM.Greeter.hideGreeter();
            tryCompare(panel.indicators.indicatorsModel, "profile", shell.indicatorProfile);
        }

        function test_login() {
            sessionSpy.clear()
            tryCompare(sessionSpy, "count", 0)
            enterPin("1234")
            tryCompare(sessionSpy, "count", 1)
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
            showGreeter()

            tryCompare(greeter, "shown", true)
            tryCompare(greeter, "lockedApp", "")
            tryCompare(greeter, "hasLockedApp", false)
            tryCompare(greeter, "fullyShown", true);
            tryCompare(panel, "fullscreenMode", false)
            tryCompare(indicators, "available", true)
            tryCompare(launcher, "available", true)
            tryCompare(stage, "spreadEnabled", false)
        }

        function test_emergencyCallCrash() {
            var dialerSurfaceId = topLevelSurfaceList.nextId;
            var greeter = findChild(shell, "greeter");
            var emergencyButton = findChild(greeter, "emergencyCallLabel");
            tap(emergencyButton)
            tryCompare(topLevelSurfaceList, "count", 2);
            waitUntilAppWindowIsFullyLoaded(dialerSurfaceId);

            tryCompare(greeter, "shown", false);
            ApplicationManager.stopApplication("dialer-app"); // kill dialer-app, as if it crashed
            tryCompare(greeter, "shown", true);
            tryCompare(findChild(greeter, "lockscreen"), "shown", true);
            tryCompare(findChild(greeter, "coverPage"), "shown", false);
        }

        function test_emergencyCallAppLaunch() {
            var greeter = findChild(shell, "greeter");
            var emergencyButton = findChild(greeter, "emergencyCallLabel");
            tap(emergencyButton)

            tryCompare(greeter, "shown", false);
            startApplication("gallery-app");
            tryCompare(greeter, "shown", true);
        }

        function test_emergencyCallPausesTutorial() {
            var greeter = findChild(shell, "greeter");
            var tutorial = findChild(shell, "tutorial");

            AccountsService.demoEdges = true;
            enterPin("1234");
            tryCompare(tutorial, "paused", false);

            showGreeter();
            verify(tutorial.paused);

            swipeAwayGreeter(true);
            tap(findChild(greeter, "emergencyCallLabel"));
            verify(tutorial.paused);
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

            var wrongPasswordAnimation = findInvisibleChild(shell, "wrongPasswordAnimation");

            enterPin("1111")
            verify(wrongPasswordAnimation.running);

            enterPin("1111")
            verify(wrongPasswordAnimation.running);

            var delayedLockscreen = findChild(shell, "delayedLockscreen");
            tryCompare(delayedLockscreen, "delayMinutes", 0);
            enterPin("1111")
            tryCompare(delayedLockscreen, "delayMinutes", greeter.failedLoginsDelayMinutes);
        }

        function test_emergencyDialerLockOut() {
            // This is a theoretical attack on the lockscreen: Enter emergency
            // dialer mode on a phone, then plug into a larger screen,
            // switching to a tablet interface.  This would in theory move the
            // dialer to a side stage and give access to other apps.  So just
            // confirm that such an attack doesn't work.

            var stage = findChild(shell, "stage")

            // We start in phone mode
            compare(stage.usageScenario, "phone");

            tap(findChild(shell, "emergencyCallLabel"));
            confirmLockedApp("dialer-app")

            // OK, we're in. Now try (but fail) to switch to tablet mode
            shell.usageScenario = "tablet";
            compare(stage.usageScenario, "phone");

            // And when we kill the app, we go back to locked tablet mode
            ApplicationManager.stopApplication("dialer-app");
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "fullyShown", true)
            compare(stage.usageScenario, "tablet");
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

            tap(findChild(shell, "emergencyCallLabel"));
            confirmLockedApp("dialer-app");
            callManager.foregroundCall = phoneCall;

            showGreeter();
            var lockscreen = findChild(shell, "lockscreen");
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

            startApplication("dialer-app");
            tryCompare(ApplicationManager, "focusedApplicationId", "dialer-app");
            callManager.foregroundCall = phoneCall;

            ApplicationManager.requestFocusApplication("unity8-dash");
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");
            var callHint = findChild(panel, "callHint");
            tryCompare(callHint, "visible", true);
            wait(10000)

            // simulate a callHint press, the real thing requires dialer: url support
            ApplicationManager.requestFocusApplication("dialer-app");

            tryCompare(ApplicationManager, "focusedApplicationId", "dialer-app");
            tryCompare(greeter, "shown", false);
            tryCompare(LightDM.Greeter, "active", false);
        }

        function test_focusRequestedHidesCoverPage() {
            showGreeter();

            startApplication("gallery-app");

            // New app hides coverPage?
            var greeter = findChild(shell, "greeter");
            var coverPage = testCase.findChild(shell, "coverPage");
            tryCompare(coverPage, "showProgress", 0);
            tryCompare(greeter, "fullyShown", true);

            showGreeter();

            // Make sure focusing same app triggers same behavior
            ApplicationManager.requestFocusApplication("gallery-app");
            tryCompare(coverPage, "showProgress", 0);
            tryCompare(greeter, "fullyShown", true);
        }

        function test_suspend() {
            var greeter = findChild(shell, "greeter");
            var stage = findChild(shell, "stage")

            // Put it to sleep
            Powerd.setStatus(Powerd.Off, Powerd.Unknown);

            // If locked, stage.suspended should be true
            tryCompare(stage, "suspended", true);

            // And wake up
            Powerd.setStatus(Powerd.On, Powerd.Unknown);
            tryCompare(greeter, "fullyShown", true);

            // Swipe away greeter to focus app
            swipeAwayGreeter(true);

            // We have a lockscreen, make sure we're still suspended
            tryCompare(stage, "suspended", true);

            enterPin("1234")

            // Now that the lockscreen has gone too, make sure we're waking up
            tryCompare(stage, "suspended", false);
        }

        /* We had a bug (1395075) where if a user kept swiping as the greeter
           loaded, they would be able to get into the session before the
           lockscreen appeared. Make sure that doesn't happen. */
        function test_earlyDisable() {
            // Kill current shell
            shellLoader.itemDestroyed = false;
            shellLoader.active = false;
            tryCompare(shellLoader, "itemDestroyed", true);

            // Create new shell
            shellLoader.active = true;
            tryCompareFunction(function() {return shell !== null}, true);

            // Confirm that we start disabled
            compare(LightDM.Prompts.count, 0);
            verify(shell.waitingOnGreeter);
            var coverPageDragHandle = findChild(shell, "coverPageDragHandle");
            verify(!coverPageDragHandle.enabled);

            // And that we only become enabled once the lockscreen is up
            tryCompare(shell, "waitingOnGreeter", false);
            verify(LightDM.Prompts.count > 0);
            var lockscreen = findChild(shell, "lockscreen");
            verify(lockscreen.shown);
        }

        function test_bfbOnLockedDevice() {
            var launcher = findChild(shell, "launcher");
            touchFlick(shell, units.gu(.5), shell.height / 2, units.gu(10), shell.height / 2);

            tryCompare(launcher, "x", 0);
            tryCompare(launcher, "state", "visible");

            waitForRendering(shell)

            var bfb = findChild(launcher, "buttonShowDashHome");
            mouseClick(bfb, bfb.width / 2, bfb.height / 2);

            enterPin("1234")

            tryCompare(launcher, "state", "drawer");
        }
    }
}
