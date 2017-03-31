/*
 * Copyright 2015-2016 Canonical Ltd.
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
import Biometryd 0.0
import GSettings 1.0
import LightDMController 0.1
import LightDM.FullLightDM 0.1 as LightDM
import Unity.Test 0.1 as UT

Item {
    width: units.gu(120)
    height: units.gu(80)

    property url defaultBackground: "/usr/share/backgrounds/warty-final-ubuntu.png"

    Component.onCompleted: {
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

    SignalSpy {
        id: authStartedSpy
        target: LightDM.Greeter
        signalName: "authenticationStarted"
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
            id: viewHideSpy
            target: testCase.view
            signalName: "_hideCalled"
        }

        SignalSpy {
            id: viewShowFakePasswordSpy
            target: testCase.view
            signalName: "_showFakePasswordCalled"
        }

        SignalSpy {
            id: viewAuthenticationFailedSpy
            target: testCase.view
            signalName: "_notifyAuthenticationFailedCalled"
        }

        SignalSpy {
            id: viewShowErrorMessageSpy
            target: testCase.view
            signalName: "_showErrorMessageCalled"
        }

        SignalSpy {
            id: viewForceShowSpy
            target: testCase.view
            signalName: "_forceShowCalled"
        }

        SignalSpy {
            id: viewTryToUnlockSpy
            target: testCase.view
            signalName: "_tryToUnlockCalled"
        }

        function init() {
            greeterSettings.lockedOutTime = 0;
            LightDMController.reset();
            greeter.failedLoginsDelayAttempts = 7;
            greeter.failedLoginsDelayMinutes = 5;
            teaseSpy.clear();
            sessionStartedSpy.clear();
            activeChangedSpy.clear();
            Biometryd.available = true;
            AccountsService.enableFingerprintIdentification = true;
            AccountsService.failedFingerprintLogins = 0;
            viewHideSpy.clear();
            viewShowFakePasswordSpy.clear();
            viewAuthenticationFailedSpy.clear();
            viewShowErrorMessageSpy.clear();
            viewForceShowSpy.clear();
            viewTryToUnlockSpy.clear();
            resetLoader();
            authStartedSpy.clear();
        }

        function resetLoader() {
            loader.itemDestroyed = false;
            loader.active = false;
            tryCompare(loader, "status", Loader.Null);
            tryCompare(loader, "item", null);
            tryCompare(loader, "itemDestroyed", true);
            loader.active = true;
            tryCompare(loader, "status", Loader.Ready);
            removeTimeConstraintsFromSwipeAreas(loader.item);
            tryCompare(greeter, "waiting", false);
            view = findChild(greeter, "testView");
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
            compare(greeter.waiting, true);
            tryCompare(greeter, "waiting", false);
            return i;
        }

        function verifySelected(name) {
            var i = getIndexOf(name);
            compare(view.currentIndex, i);
            compare(AccountsService.user, name);
            if (name[0] === "*") // custom rows have no authenticationUser set
                compare(LightDM.Greeter.authenticationUser, "");
            else
                compare(LightDM.Greeter.authenticationUser, name);
            return i;
        }

        function verifyLoggedIn() {
            tryCompare(sessionStartedSpy, "count", 1);
            compare(LightDM.Greeter.authenticated, true);
            compare(greeter.shown, false);
        }

        function unlockAndShowGreeter() {
            // useful to enable "lockscreen mode" in greeter
            greeter.forcedUnlock = true;
            LightDM.Greeter.showGreeter();
            tryCompare(greeter, "waiting", false);
            view = findChild(greeter, "testView");
        }

        function test_unlockPass() {
            selectUser("has-password");
            view.responded("password");
            verifyLoggedIn();
        }

        function test_unlockFail() {
            selectUser("has-password");
            tryCompare(authStartedSpy, "count", 1);

            view.responded("wr0ng p4ssw0rd");
            tryCompare(viewAuthenticationFailedSpy, "count", 1);

            tryCompare(authStartedSpy, "count", 2);
        }

        function test_promptless() {
            selectUser("no-password");
            tryCompare(view, "locked", false);
            compare(viewHideSpy.count, 0);
        }

        function test_twoFactorPass() {
            selectUser("two-factor");
            view.responded("password");
            view.responded("otp");
            verifyLoggedIn();
        }

        function test_twoFactorFailOnFirst() {
            selectUser("two-factor");
            tryCompare(authStartedSpy, "count", 1);

            view.responded("wr0ng p4ssw0rd");
            tryCompare(viewAuthenticationFailedSpy, "count", 1);

            tryCompare(authStartedSpy, "count", 2);
        }

        function test_twoFactorFailOnSecond() {
            selectUser("two-factor");
            tryCompare(authStartedSpy, "count", 1);

            view.responded("password");
            view.responded("wr0ng p4ssw0rd");
            tryCompare(viewAuthenticationFailedSpy, "count", 1);

            tryCompare(authStartedSpy, "count", 2);
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

        function test_hasCustomBackground() {
            verify(!view.hasCustomBackground);
            greeter.hasCustomBackground = true;
            verify(view.hasCustomBackground);
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

        function test_authError() {
            selectUser("auth-error");
            tryCompare(viewAuthenticationFailedSpy, "count", 1);
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

            compare(viewForceShowSpy.count, 0);
            LightDM.Greeter.showGreeter();
            compare(viewForceShowSpy.count, 1);
        }

        function test_selectUserHint() {
            LightDMController.selectUserHint = "info-prompt";
            resetLoader();
            var i = verifySelected("info-prompt");
            verify(i != 0); // sanity-check that info-prompt isn't default 0 answer
        }

        function test_selectUserHintUnset() {
            LightDMController.selectUserHint = "";
            resetLoader();
            verifySelected(LightDM.Users.data(0, LightDM.UserRoles.NameRole));
        }

        function test_selectUserHintInvalid() {
            LightDMController.selectUserHint = "not-a-real-user";
            resetLoader();
            verifySelected(LightDM.Users.data(0, LightDM.UserRoles.NameRole));
        }

        function test_selectUserHintGuest() {
            LightDMController.hasGuestAccountHint = true;
            LightDMController.selectGuestHint = true;
            LightDMController.selectUserHint = "info-prompt";
            resetLoader();
            verifySelected("*guest");
        }

        function test_selectUserHintGuestWithNoGuest() {
            LightDMController.selectGuestHint = true;
            LightDMController.selectUserHint = "info-prompt";
            resetLoader();
            verifySelected("info-prompt");
        }

        function test_hasGuestAccountHint() {
            LightDMController.hasGuestAccountHint = true;
            resetLoader();
            var i = selectUser("*guest");
            compare(i, LightDM.Users.count - 1); // guest should be last
            verify(!view.locked);
        }

        function test_showManualLoginHint() {
            LightDMController.showManualLoginHint = true;
            resetLoader();
            var i = selectUser("*other");
            compare(i, LightDM.Users.count - 1); // manual should be last
            verify(view.locked);
        }

        function test_fingerprintSuccess() {
            var index = selectUser("has-password");
            unlockAndShowGreeter(); // turn on lockscreen mode

            var biometryd = findInvisibleChild(greeter, "biometryd");
            verify(biometryd.operation);
            verify(biometryd.operation.running);

            biometryd.operation.mockSuccess(LightDM.Users.data(index, LightDM.UserRoles.UidRole));
            verify(!greeter.active);
        }

        function test_fingerprintFirstLoginDisabled() {
            var index = selectUser("has-password");
            // don't hide/show greeter, we want to test behavior before lockscreen mode is on

            var biometryd = findInvisibleChild(greeter, "biometryd");
            verify(biometryd.operation);
            verify(biometryd.operation.running);

            biometryd.operation.mockSuccess(LightDM.Users.data(index, LightDM.UserRoles.UidRole));
            compare(viewTryToUnlockSpy.count, 1);
            verify(greeter.locked);
        }

        function test_forcedDisallowedFingerprint() {
            var index = selectUser("has-password");
            unlockAndShowGreeter(); // turn on lockscreen mode

            var biometryd = findInvisibleChild(greeter, "biometryd");
            verify(biometryd.operation);
            verify(biometryd.operation.running);

            greeter.allowFingerprint = false;
            verify(!biometryd.operation);
        }

        function test_fingerprintFailureMessage() {
            var index = selectUser("has-password");
            unlockAndShowGreeter(); // turn on lockscreen mode

            var biometryd = findInvisibleChild(greeter, "biometryd");
            verify(biometryd.operation);
            verify(biometryd.operation.running);

            biometryd.operation.mockFailure("error");
            compare(viewShowErrorMessageSpy.count, 1);
            compare(viewShowErrorMessageSpy.signalArguments[0][0], i18n.tr("Try again"));
        }

        function test_fingerprintTooManyFailures() {
            var index = selectUser("has-password");
            unlockAndShowGreeter(); // turn on lockscreen mode

            var biometryd = findInvisibleChild(greeter, "biometryd");
            biometryd.operation.mockFailure("error");
            biometryd.operation.mockFailure("error");
            compare(viewTryToUnlockSpy.count, 0);

            biometryd.operation.mockFailure("error");
            compare(viewTryToUnlockSpy.count, 1);

            // Confirm that we are stuck in this mode until next login
            biometryd.operation.mockSuccess(LightDM.Users.data(index, LightDM.UserRoles.UidRole));
            compare(viewTryToUnlockSpy.count, 2);

            unlockAndShowGreeter();

            biometryd.operation.mockSuccess(LightDM.Users.data(index, LightDM.UserRoles.UidRole));
            verify(!greeter.active);
        }

        function test_fingerprintFailureCountReset() {
            selectUser("has-password");
            unlockAndShowGreeter(); // turn on lockscreen mode

            var biometryd = findInvisibleChild(greeter, "biometryd");
            biometryd.operation.mockFailure("error");
            biometryd.operation.mockFailure("error");
            compare(viewTryToUnlockSpy.count, 0);

            unlockAndShowGreeter();
            biometryd.operation.mockFailure("error");
            biometryd.operation.mockFailure("error");
            compare(viewTryToUnlockSpy.count, 0);

            biometryd.operation.mockFailure("error");
            compare(viewTryToUnlockSpy.count, 1);
        }

        function test_fingerprintWrongUid() {
            selectUser("has-password");
            unlockAndShowGreeter(); // turn on lockscreen mode

            var biometryd = findInvisibleChild(greeter, "biometryd");
            biometryd.operation.mockSuccess(0);

            verify(greeter.active);
            compare(viewShowErrorMessageSpy.count, 1);
            compare(viewShowErrorMessageSpy.signalArguments[0][0], i18n.tr("Try again"));
        }

        function test_fingerprintNotEnabled() {
            AccountsService.enableFingerprintIdentification = false;
            selectUser("has-password");
            unlockAndShowGreeter(); // turn on lockscreen mode

            var biometryd = findInvisibleChild(greeter, "biometryd");
            verify(!biometryd.operation);

            AccountsService.enableFingerprintIdentification = true;
            verify(biometryd.operation);
            verify(biometryd.operation.running);

            AccountsService.enableFingerprintIdentification = false;
            verify(!biometryd.operation);
        }

        function test_fingerprintReaderNotPresent() {
            Biometryd.available = false;
            selectUser("has-password");
            unlockAndShowGreeter(); // turn on lockscreen mode

            verify(!Biometryd.available);

            var biometryd = findInvisibleChild(greeter, "biometryd");
            verify(!biometryd.operation);

            Biometryd.available = true;
            verify(biometryd.operation);
            verify(biometryd.operation.running);

            Biometryd.available = false;
            verify(!biometryd.operation);
        }

        function test_fingerprintGreeterNotActive() {
            selectUser("has-password");
            unlockAndShowGreeter(); // turn on lockscreen mode

            var biometryd = findInvisibleChild(greeter, "biometryd");
            verify(biometryd.operation);
            verify(biometryd.operation.running);

            greeter.hideNow();
            verify(!biometryd.operation);

            greeter.showNow();
            verify(biometryd.operation);
            verify(biometryd.operation.running);
        }
    }
}
