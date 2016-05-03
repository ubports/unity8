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
import ".."
import "../../../qml/Greeter"
import Ubuntu.Components 1.3
import AccountsService 0.1
import GSettings 1.0
import IntegratedLightDM 0.1 as LightDM
import Unity.Test 0.1 as UT

Item {
    width: units.gu(120)
    height: units.gu(80)

    property url defaultBackground: Qt.resolvedUrl("../../../qml/graphics/tablet_background.jpg")

    Component.onCompleted: {
        // set the mock mode before loading
        LightDM.Greeter.mockMode = "full";
        LightDM.Users.mockMode = "full";
        loader.active = true;
    }

    Loader {
        id: loader

        active: false
        anchors.fill: parent

        property bool itemDestroyed: false
        sourceComponent: Component {
            Greeter {
                width: loader.width
                height: loader.height
                background: defaultBackground
                viewSource: Qt.resolvedUrl("TestView.qml")

                Component.onDestruction: {
                    loader.itemDestroyed = true;
                }
            }
        }
    }

    SignalSpy {
        id: teaseSpy
        target: loader.item
        signalName: "tease"
    }

    SignalSpy {
        id: sessionStartedSpy
        target: loader.item
        signalName: "sessionStarted"
    }

    SignalSpy {
        id: activeChangedSpy
        target: loader.item
        signalName: "activeChanged"
    }

    GSettings {
        id: greeterSettings
        schema.id: "com.canonical.Unity8.Greeter"
    }

    UT.UnityTestCase {
        id: testCase
        name: "Greeter"
        when: windowShown

        property Item greeter: loader.status === Loader.Ready ? loader.item : null
        property Item view

        SignalSpy {
            id: viewShowMessageSpy
            target: testCase.view
            signalName: "_showMessageCalled"
        }

        SignalSpy {
            id: viewShowPromptSpy
            target: testCase.view
            signalName: "_showPromptCalled"
        }

        SignalSpy {
            id: viewShowLastChanceSpy
            target: testCase.view
            signalName: "_showLastChanceCalled"
        }

        SignalSpy {
            id: viewHideSpy
            target: testCase.view
            signalName: "_hideCalled"
        }

        SignalSpy {
            id: viewAuthenticationSucceededSpy
            target: testCase.view
            signalName: "_notifyAuthenticationSucceededCalled"
        }

        SignalSpy {
            id: viewAuthenticationFailedSpy
            target: testCase.view
            signalName: "_notifyAuthenticationFailedCalled"
        }

        SignalSpy {
            id: viewResetSpy
            target: testCase.view
            signalName: "_resetCalled"
        }

        SignalSpy {
            id: viewTryToUnlockSpy
            target: testCase.view
            signalName: "_tryToUnlockCalled"
        }

        function init() {
            greeterSettings.lockedOutTime = 0;
            resetLoader();
            teaseSpy.clear();
            sessionStartedSpy.clear();
            activeChangedSpy.clear();
            viewShowMessageSpy.clear();
            viewShowPromptSpy.clear();
            viewShowLastChanceSpy.clear();
            viewHideSpy.clear();
            viewAuthenticationSucceededSpy.clear();
            viewAuthenticationFailedSpy.clear();
            viewResetSpy.clear();
            viewTryToUnlockSpy.clear();
            tryCompare(greeter, "waiting", false);
            view = findChild(greeter, "testView");
            verifySelected(LightDM.Users.data(0, LightDM.UserRoles.NameRole));
            greeter.failedLoginsDelayAttempts = 7;
            greeter.failedLoginsDelayMinutes = 5;
        }

        function resetLoader() {
            loader.itemDestroyed = false;
            loader.active = false;
            tryCompare(loader, "status", Loader.Null);
            tryCompare(loader, "item", null);
            tryCompare(loader, "itemDestroyed", true);
            loader.active = true;
            tryCompare(loader, "status", Loader.Ready);
            removeTimeConstraintsFromDirectionalDragAreas(loader.item);
        }

        function getIndexOf(name) {
            for (var i = 0; i < LightDM.Users.count; i++) {
                if (name === LightDM.Users.data(i, LightDM.UserRoles.NameRole)) {
                    return i;
                }
            }
            fail("Didn't find name")
            return -1;
        }

        function selectUser(name) {
            var i = getIndexOf(name);
            view.selected(i);
            verifySelected(name);
            return i;
        }

        function verifySelected(name) {
            var i = getIndexOf(name);
            compare(view.currentIndex, i);
            compare(AccountsService.user, name);
            compare(LightDM.Greeter.authenticationUser, name);
        }

        function verifyLoggedIn() {
            tryCompare(sessionStartedSpy, "count", 1);
            verify(viewAuthenticationSucceededSpy.count > 0);
            compare(LightDM.Greeter.authenticated, true);
            compare(greeter.shown, false);
        }

        function test_unlockPass() {
            selectUser("has-password");
            tryCompare(viewShowPromptSpy, "count", 1);
            compare(viewShowPromptSpy.signalArguments[0][0], "Password");
            compare(viewShowPromptSpy.signalArguments[0][1], true);
            compare(viewShowPromptSpy.signalArguments[0][2], true);

            view.responded("password");
            verifyLoggedIn();
        }

        function test_unlockFail() {
            selectUser("has-password");
            tryCompare(viewShowPromptSpy, "count", 1);
            compare(viewShowPromptSpy.signalArguments[0][0], "Password");
            compare(viewShowPromptSpy.signalArguments[0][1], true);
            compare(viewShowPromptSpy.signalArguments[0][2], true);

            view.responded("wr0ng p4ssw0rd");
            tryCompare(viewAuthenticationFailedSpy, "count", 1);

            tryCompare(viewShowPromptSpy, "count", 2);
            compare(viewShowPromptSpy.signalArguments[0][0], "Password");
            compare(viewShowPromptSpy.signalArguments[0][1], true);
            compare(viewShowPromptSpy.signalArguments[0][2], true);
        }

        function test_promptless() {
            selectUser("no-password");
            tryCompare(viewAuthenticationSucceededSpy, "count", 1);
            compare(sessionStartedSpy.count, 1);
            compare(viewShowPromptSpy.count, 0);
            compare(viewHideSpy.count, 0);
            compare(view.locked, false);
        }

        function test_twoFactorPass() {
            selectUser("two-factor");
            tryCompare(viewShowPromptSpy, "count", 1);
            compare(viewShowPromptSpy.signalArguments[0][0], "Password");
            compare(viewShowPromptSpy.signalArguments[0][1], true);
            compare(viewShowPromptSpy.signalArguments[0][2], true);

            view.responded("password");
            tryCompare(viewShowPromptSpy, "count", 2);
            compare(viewShowPromptSpy.signalArguments[1][0], "otp");
            compare(viewShowPromptSpy.signalArguments[1][1], false);
            compare(viewShowPromptSpy.signalArguments[1][2], false);

            view.responded("otp");
            verifyLoggedIn();
        }

        function test_twoFactorFailOnFirst() {
            selectUser("two-factor");
            tryCompare(viewShowPromptSpy, "count", 1);
            compare(viewShowPromptSpy.signalArguments[0][0], "Password");
            compare(viewShowPromptSpy.signalArguments[0][1], true);
            compare(viewShowPromptSpy.signalArguments[0][2], true);

            view.responded("wr0ng p4ssw0rd");
            tryCompare(viewAuthenticationFailedSpy, "count", 1);

            tryCompare(viewShowPromptSpy, "count", 2);
            compare(viewShowPromptSpy.signalArguments[0][0], "Password");
            compare(viewShowPromptSpy.signalArguments[0][1], true);
            compare(viewShowPromptSpy.signalArguments[0][2], true);
        }

        function test_twoFactorFailOnSecond() {
            selectUser("two-factor");
            tryCompare(viewShowPromptSpy, "count", 1);
            compare(viewShowPromptSpy.signalArguments[0][0], "Password");
            compare(viewShowPromptSpy.signalArguments[0][1], true);
            compare(viewShowPromptSpy.signalArguments[0][2], true);

            view.responded("password");
            tryCompare(viewShowPromptSpy, "count", 2);
            compare(viewShowPromptSpy.signalArguments[1][0], "otp");
            compare(viewShowPromptSpy.signalArguments[1][1], false);
            compare(viewShowPromptSpy.signalArguments[1][2], false);

            view.responded("wr0ng p4ssw0rd");
            tryCompare(viewAuthenticationFailedSpy, "count", 1);

            tryCompare(viewShowPromptSpy, "count", 3);
            compare(viewShowPromptSpy.signalArguments[0][0], "Password");
            compare(viewShowPromptSpy.signalArguments[0][1], true);
            compare(viewShowPromptSpy.signalArguments[0][2], true);
        }

        function test_htmlInfoPrompt() {
            selectUser("html-info-prompt");
            tryCompare(viewShowPromptSpy, "count", 1);
            compare(viewShowMessageSpy.count, 1);
            compare(viewShowMessageSpy.signalArguments[0][0], "&lt;b&gt;&amp;&lt;/b&gt;");
        }

        function test_multiInfoPrompt() {
            selectUser("multi-info-prompt");
            tryCompare(viewShowPromptSpy, "count", 1);
            compare(viewShowMessageSpy.count, 3);
            compare(viewShowMessageSpy.signalArguments[0][0], "Welcome to Unity Greeter");
            compare(viewShowMessageSpy.signalArguments[1][0], "<font color=\"#df382c\">This is an error</font>");
            compare(viewShowMessageSpy.signalArguments[2][0], "You should have seen three messages");
        }

        function test_waiting() {
            // Make sure we unset 'waiting' on prompt
            selectUser("has-password");
            compare(greeter.waiting, true);
            tryCompare(greeter, "waiting", false);

            // Make sure we unset 'waiting' on authentication
            selectUser("no-password");
            compare(greeter.waiting, true);
            tryCompare(greeter, "waiting", false);
        }

        function test_locked() {
            selectUser("has-password");
            compare(view.locked, true);

            LightDM.Greeter.active = false;
            compare(view.locked, false);
            LightDM.Greeter.active = true;

            greeter.forcedUnlock = true;
            compare(greeter.required, false);
            greeter.forcedUnlock = false;

            // Now recover from tearing down the view above
            LightDM.Greeter.showGreeter();
            tryCompare(greeter, "required", true);
            tryCompare(greeter, "waiting", false);
            view = findChild(greeter, "testView");

            selectUser("no-password");
            tryCompare(view, "locked", false);
            selectUser("has-password");
        }

        function test_fullyShown() {
            compare(greeter.fullyShown, true);
            view.hide();
            compare(greeter.fullyShown, false);
        }

        function test_alphanumeric() {
            selectUser("has-password");
            compare(view.alphanumeric, true);
            selectUser("has-pin");
            compare(view.alphanumeric, false);
        }

        function test_background() {
            greeter.background = "testing";
            compare(view.background, Qt.resolvedUrl("testing"));
        }

        function test_notifyAboutToFocusApp() {
            greeter.notifyUserRequestedApp("fake-app");
            compare(viewTryToUnlockSpy.count, 1);
            compare(viewTryToUnlockSpy.signalArguments[0][0], false);
        }

        function test_notifyShowingDashFromDrag() {
            compare(greeter.notifyShowingDashFromDrag("fake-app"), true);
            compare(viewTryToUnlockSpy.count, 1);
            compare(viewTryToUnlockSpy.signalArguments[0][0], true);
        }

        function test_dragHandleLeftMargin() {
            compare(view.dragHandleLeftMargin, 0);
            greeter.dragHandleLeftMargin = 5;
            compare(view.dragHandleLeftMargin, 5);
        }

        function test_launcherOffset() {
            compare(view.launcherOffset, 0);
            greeter.launcherOffset = 5;
            tryCompare(view, "launcherOffset", 5);
        }

        function test_laucherOffsetAnimation() {
            // Our logic for smoothing launcherOffset when it suddenly goes to
            // zero is a bit complicated.  Let's just make sure it works here.

            launcherOffsetWatcher.target = view;

            // should follow immediately
            launcherOffsetWatcher.values = [];
            greeter.launcherOffset = 100;
            compare(view.launcherOffset, 100);
            compare(launcherOffsetWatcher.values.length, 1);

            // should interpolate values until it reaches 0
            launcherOffsetWatcher.values = [];
            greeter.launcherOffset = 0;
            tryCompare(view, "launcherOffset", 0);
            verify(launcherOffsetWatcher.values.length > 1);
            for (var i = 0; i < launcherOffsetWatcher.values.length - 1; ++i) {
                verify(launcherOffsetWatcher.values[i] > 0.0);
                verify(launcherOffsetWatcher.values[i] < 100.0);
            }
        }
        Connections {
            id: launcherOffsetWatcher
            property var values: []
            onLauncherOffsetChanged: {
                values.push(target.launcherOffset);
            }
        }

        function test_backgroundTopMargin() {
            compare(view.backgroundTopMargin, 0);
            greeter.y = 5;
            compare(view.backgroundTopMargin, -5);
        }

        function test_differentPrompt() {
            selectUser("different-prompt");
            tryCompare(viewShowPromptSpy, "count", 1);
            compare(viewShowPromptSpy.signalArguments[0][0], "Secret word");
            compare(viewShowPromptSpy.signalArguments[0][1], true);
            compare(viewShowPromptSpy.signalArguments[0][2], false);
        }

        function test_authError() {
            selectUser("auth-error");
            tryCompare(viewAuthenticationFailedSpy, "count", 1);
            compare(viewShowPromptSpy.count, 0);
            compare(view.locked, true);
        }

        function test_statsWelcomeScreen() {
            // Test logic in greeter that turns statsWelcomeScreen setting into infographic changes
            selectUser("has-password");
            compare(LightDM.Infographic.username, "has-password");
            AccountsService.statsWelcomeScreen = false;
            compare(LightDM.Infographic.username, "");
            AccountsService.statsWelcomeScreen = true;
            compare(LightDM.Infographic.username, "has-password");
        }

        function test_forcedDelayIntoGSettings() {
            greeter.failedLoginsDelayAttempts = 1;
            greeter.failedLoginsDelayMinutes = 1;
            selectUser("has-password");
            tryCompare(viewShowPromptSpy, "count", 1);
            compare(greeterSettings.lockedOutTime, 0);
            view.responded("wr0ng p4ssw0rd");

            var timestamp = new Date().getTime();
            verify(Math.abs(greeterSettings.lockedOutTime - timestamp) < 2000);
        }

        function test_forcedDelayOnConstruction() {
            greeterSettings.lockedOutTime = new Date().getTime();
            resetLoader();
            view = findChild(greeter, "testView");
            compare(view.delayMinutes, greeter.failedLoginsDelayMinutes);
        }

        function test_forcedDelayOnConstructionIgnoredIfInFuture() {
            greeterSettings.lockedOutTime = new Date().getTime() + greeter.failedLoginsDelayMinutes * 60000 + 1;
            resetLoader();
            view = findChild(greeter, "testView");
            compare(view.delayMinutes, 0);
        }

        function test_forcedDelayOnConstructionIgnoredIfInPast() {
            greeterSettings.lockedOutTime = new Date().getTime() - greeter.failedLoginsDelayMinutes * 60000 - 1;
            resetLoader();
            view = findChild(greeter, "testView");
            compare(view.delayMinutes, 0);
        }

        function test_forcedDelayRoundTrip() {
            greeter.failedLoginsDelayAttempts = 1;
            greeter.failedLoginsDelayMinutes = 0.001; // make delay very short

            selectUser("has-password");
            tryCompare(viewShowPromptSpy, "count", 1);

            compare(view.delayMinutes, 0);
            view.responded("wr0ng p4ssw0rd");
            compare(view.delayMinutes, 1);
            tryCompare(view, "delayMinutes", 0);
        }

        function test_activeIsConstantDuringLockedApp() {
            // Regression test for bug 1525981: if we flicker active state even
            // briefly, the mpt-server will allow access to the device's drive.

            selectUser("has-password");
            verify(greeter.active);

            // Test opening a locked app
            greeter.lockedApp = "test-app";
            greeter.notifyAppFocusRequested("test-app");
            verify(greeter.hasLockedApp);
            verify(!greeter.shown);

            // Test going back to greeter from that locked app
            LightDM.Greeter.showGreeter();
            verify(!greeter.hasLockedApp);
            verify(greeter.shown);

            // Active state should never have changed
            compare(activeChangedSpy.count, 0);
        }

        function test_dbusRequestAuthenticationUser() {
            selectUser("no-password");
            LightDM.Greeter.requestAuthenticationUser("has-password");
            verifySelected("has-password");
        }

        function test_dbusHideGreeter() {
            compare(view.required, true);
            LightDM.Greeter.hideGreeter();
            compare(view.required, false);
            compare(greeter.required, false);
        }

        function test_dbusShowGreeterFromHiddenState() {
            greeter.hide();
            compare(greeter.required, false);

            LightDM.Greeter.showGreeter();
            compare(greeter.required, true);
            compare(greeter.fullyShown, true);
            view = findChild(greeter, "testView");
            compare(view.required, true);

            // Can't test some of the stuff called on 'view' here because
            // the view was torn down and created again.  So the spies missed
            // the good stuff while it down.  See next test for more.
        }

        function test_dbusShowGreeterFromShownState() {
            selectUser("has-password");
            compare(viewResetSpy.count, 1);
            tryCompare(viewShowPromptSpy, "count", 1);

            viewResetSpy.clear();
            viewShowPromptSpy.clear();

            LightDM.Greeter.showGreeter();
            compare(viewResetSpy.count, 1);
            tryCompare(viewShowPromptSpy, "count", 1);
        }
    }
}
