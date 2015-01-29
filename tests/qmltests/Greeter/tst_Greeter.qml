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
import QtTest 1.0
import ".."
import "../../../qml/Greeter"
import Ubuntu.Components 0.1
import AccountsService 0.1
import LightDM 0.1 as LightDM
import Unity.Test 0.1 as UT

Item {
    width: units.gu(120)
    height: units.gu(80)

    property url defaultBackground: Qt.resolvedUrl("../../../qml/graphics/tablet_background.jpg")

    Row {
        anchors.fill: parent
        Loader {
            id: loader
            width: parent.width - controls.width
            height: parent.height

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

        Rectangle {
            id: controls
            color: "white"
            width: units.gu(40)
            height: parent.height

            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                spacing: units.gu(1)

                Row {
                    Button {
                        text: "Show Greeter"
                        onClicked: loader.item.show()
                    }
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
        id: emergencyCallSpy
        target: loader.item
        signalName: "emergencyCall"
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
            id: viewAuthenticatedSpy
            target: testCase.view
            signalName: "_authenticatedCalled"
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
            teaseSpy.clear();
            sessionStartedSpy.clear();
            emergencyCallSpy.clear();
            viewShowMessageSpy.clear();
            viewShowPromptSpy.clear();
            viewShowLastChanceSpy.clear();
            viewHideSpy.clear();
            viewAuthenticatedSpy.clear();
            viewResetSpy.clear();
            viewTryToUnlockSpy.clear();
            tryCompare(greeter, "waiting", false);
            view = findChild(greeter, "testView");
            verifySelected(LightDM.Users.data(0, LightDM.UserRoles.NameRole));
        }

        function cleanup() {
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
            verify(viewAuthenticatedSpy.count > 0);
            compare(viewAuthenticatedSpy.signalArguments[viewAuthenticatedSpy.count - 1][0], true);
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
            tryCompare(viewAuthenticatedSpy, "count", 1);
            compare(viewAuthenticatedSpy.signalArguments[0][0], false);

            tryCompare(viewShowPromptSpy, "count", 2);
            compare(viewShowPromptSpy.signalArguments[0][0], "Password");
            compare(viewShowPromptSpy.signalArguments[0][1], true);
            compare(viewShowPromptSpy.signalArguments[0][2], true);
        }

        function test_promptless() {
            selectUser("no-password");
            tryCompare(viewAuthenticatedSpy, "count", 1);
            compare(viewAuthenticatedSpy.signalArguments[0][0], true);
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
            tryCompare(viewAuthenticatedSpy, "count", 1);
            compare(viewAuthenticatedSpy.signalArguments[0][0], false);

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
            tryCompare(viewAuthenticatedSpy, "count", 1);
            compare(viewAuthenticatedSpy.signalArguments[0][0], false);

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
            compare(view.locked, false);
            greeter.forcedUnlock = false;

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
            tryCompare(viewAuthenticatedSpy, "count", 1);
            compare(viewAuthenticatedSpy.signalArguments[0][0], false);
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
            tryCompare(viewShowPromptSpy, "count", 1);
            viewShowPromptSpy.clear();
            LightDM.Greeter.showGreeter();
            compare(viewResetSpy.count, 1);
            tryCompare(viewShowPromptSpy, "count", 1);
        }
    }
}
