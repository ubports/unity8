/*
 * Copyright 2014-2016 Canonical Ltd.
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
import LightDMController 0.1
import LightDM.FullLightDM 0.1 as LightDM
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT

StyledItem {
    id: root

    width: units.gu(120)
    height: units.gu(80)
    focus: true

    theme.name: "Ubuntu.Components.Themes.SuruDark"

    Row {
        anchors.fill: parent
        Loader {
            id: loader
            width: root.width - controls.width
            height: parent.height
            focus: true

            property bool itemDestroyed: false
            sourceComponent: Component {
                WideView {
                    id: view

                    background: "/usr/share/backgrounds/warty-final-ubuntu.png"
                    userModel: LightDM.Users
                    infographicModel: LightDM.Infographic

                    launcherOffset: parseFloat(launcherOffsetField.text)
                    currentIndex: parseInt(currentIndexField.text, 10)
                    delayMinutes: parseInt(delayMinutesField.text, 10)
                    backgroundTopMargin: parseFloat(backgroundTopMarginField.text)
                    locked: lockedCheckBox.checked
                    inputMethod: fakeInputMethod

                    Component.onDestruction: {
                        loader.itemDestroyed = true
                    }

                    onSelected: {
                        if (index >= 0)
                            currentIndexField.text = index;
                    }

                    QtObject {
                        id: fakeInputMethod
                        property bool visible: fakeKeyboard.visible
                        property var keyboardRectangle: QtObject {
                            property real x: fakeKeyboard.x
                            property real y: fakeKeyboard.y
                            property real width: fakeKeyboard.width
                            property real height: fakeKeyboard.height
                        }
                    }

                    Rectangle {
                        id: fakeKeyboard
                        color: "green"
                        opacity: 0.7
                        anchors.bottom: view.bottom
                        width: view.width
                        height: view.height * 0.6
                        visible: keyboardVisibleCheckBox.checked
                        Text {
                            text: "Keyboard Rectangle"
                            color: "yellow"
                            font.bold: true
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 10; font.pixelSize: 200
                            verticalAlignment: Text.AlignVCenter
                            x: (parent.width - width) / 2
                            y: (parent.height - height) / 2
                            width: parent.width
                            height: parent.height
                        }
                    }

                }
            }
        }

        Rectangle {
            id: controls
            color: theme.palette.normal.background
            width: units.gu(40)
            height: parent.height
            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                spacing: units.gu(1)
                Row {
                    Button {
                        text: "Hide"
                        onClicked: loader.item.hide()
                    }
                }
                Row {
                    Button {
                        text: "Show Message"
                        onClicked: LightDMService.prompts.append(messageField.text, LightDMService.prompts.Message)
                    }
                    TextField {
                        id: messageField
                        width: units.gu(10)
                        text: ""
                    }
                }
                Row {
                    Button {
                        text: "Show Prompt"
                        onClicked: LightDMService.prompts.append(promptField.text, isSecretCheckBox.checked ? LightDMService.prompts.Secret : LightDMService.prompts.Question)
                    }
                    TextField {
                        id: promptField
                        width: units.gu(10)
                        text: ""
                    }
                    CheckBox {
                        id: isSecretCheckBox
                    }
                    Label {
                        text: "secret"
                    }
                }
                Row {
                    Button {
                        text: "Notify Auth Failure"
                        onClicked: {
                            loader.item.notifyAuthenticationFailed();
                        }
                    }
                }
                Row {
                    Button {
                        text: "Try To Unlock"
                        onClicked: loader.item.tryToUnlock(toTheRightCheckBox.checked)
                    }
                    CheckBox {
                        id: toTheRightCheckBox
                    }
                    Label {
                        text: "toTheRight"
                    }
                }
                Row {
                    TextField {
                        id: launcherOffsetField
                        width: units.gu(10)
                        text: "0"
                    }
                    Label {
                        text: "launcherOffset"
                    }
                }
                Row {
                    TextField {
                        id: currentIndexField
                        width: units.gu(10)
                        text: "0"
                    }
                    Label {
                        text: "currentIndex"
                    }
                }
                Row {
                    TextField {
                        id: delayMinutesField
                        width: units.gu(10)
                        text: "0"
                    }
                    Label {
                        text: "delayMinutes"
                    }
                }
                Row {
                    TextField {
                        id: backgroundTopMarginField
                        width: units.gu(10)
                        text: "0"
                    }
                    Label {
                        text: "backgroundTopMargin"
                    }
                }
                Row {
                    CheckBox {
                        id: lockedCheckBox
                    }
                    Label {
                        text: "locked"
                    }
                }
                Row {
                    Label {
                        text: "selected: " + selectedSpy.count
                    }
                }
                Row {
                    Label {
                        text: "responded: " + respondedSpy.count
                    }
                }
                Row {
                    Label {
                        text: "teased: " + teaseSpy.count
                    }
                }
                Row {
                    Label {
                        text: "emergency: " + emergencySpy.count
                    }
                }
                Row {
                    id: multipleSessions
                    CheckBox {
                        id: multipleSessionsCheckbox
                        onClicked: {
                            if (checked) {
                                LightDMController.sessionMode = "full";
                            } else {
                                LightDMController.sessionMode = "single";
                            }
                        }
                        Connections {
                            target: LightDMController
                            onSessionModeChanged: {
                                if (LightDMController.sessionMode === "full") {
                                    multipleSessionsCheckbox.checked = true;
                                } else {
                                    multipleSessionsCheckbox.checked = false;
                                }
                            }
                        }
                    }
                    Label {
                        text: "Multiple Sessions"
                    }
                }
                Row {
                    Slider {
                        id: numSessionsSlider

                        width: units.gu(10)
                        minimumValue: 0
                        maximumValue: LightDMController.numAvailableSessions
                        value: LightDMController.numSessions
                        visible: LightDMController.sessionMode === "full"
                        Binding {
                            target: LightDMController
                            property: "numSessions"
                            value: numSessionsSlider.value
                        }
                    }
                    Label {
                        text: "Available Sessions"
                    }
                }
                Row {
                    Button {
                        text: "Reload View"
                        onClicked: {
                            loader.active = false;
                            loader.active = true;
                        }
                    }
                }
                Row {
                    CheckBox {
                        id: keyboardVisibleCheckBox
                    }
                    Label {
                        text: "Keyboard Visible"
                    }
                }
            }
        }
    }

    SignalSpy {
        id: selectedSpy
        target: loader.item
        signalName: "selected"
    }

    SignalSpy {
        id: respondedSpy
        target: loader.item
        signalName: "responded"
    }

    SignalSpy {
        id: teaseSpy
        target: loader.item
        signalName: "tease"
    }

    SignalSpy {
        id: emergencySpy
        target: loader.item
        signalName: "emergencyCall"
    }

    UT.UnityTestCase {
        name: "WideView"
        when: windowShown

        property Item view: loader.status === Loader.Ready ? loader.item : null
        property url testIconDirectory: Qt.resolvedUrl("../../../qml/Greeter/graphics/session_icons")

        function init() {
            selectIndex(0); // break binding with text field
            tryCompare(LightDMService.prompts, "count", 1);
            selectedSpy.clear();
            respondedSpy.clear();
            teaseSpy.clear();
            emergencySpy.clear();
            LightDMController.reset();
            LightDM.Sessions.iconSearchDirectories = [testIconDirectory];

            waitForRendering(view);
            var userList = findChild(view, "userList");
            tryCompare(userList, "movingInternally", false);
        }

        function cleanup() {
            keyboardVisibleCheckBox.checked = false;

            loader.itemDestroyed = false;
            loader.active = false;
            tryCompare(loader, "status", Loader.Null);
            tryCompare(loader, "item", null);
            tryCompare(loader, "itemDestroyed", true);
            loader.active = true;
            tryCompare(loader, "status", Loader.Ready);
            removeTimeConstraintsFromSwipeAreas(loader.item);
            LightDMController.sessionMode = "single";
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

        function selectIndex(i) {
            var user = LightDM.Users.data(i, LightDM.UserRoles.NameRole);
            LightDM.Greeter.authenticate(user);

            var userList = findChild(view, "userList");
            var promptList = findChild(view, "promptList");

            view.currentIndex = i;
            tryCompare(promptList, "opacity", 1);
            tryCompare(userList, "movingInternally", false);
        }

        function selectUser(name) {
            var i = getIndexOf(name);
            selectIndex(i);
            return i;
        }

        function swipeAwayCover() {
            tryCompare(view, "fullyShown", true);
            var touchY = view.height / 2;
            touchFlick(view, view.width, touchY, 0, touchY);
            var coverPage = findChild(view, "coverPage");
            tryCompare(coverPage, "showProgress", 0);
            waitForRendering(view);
        }

        function test_sessionless_user_is_still_valid() {
            var loginList = findChild(view, "loginList")

            /*
             * If a user has never logged in before, or, for some reason
             * has no sessionHint, ensure that the model returns the default
             * session and that the view respects this
             */
            selectUser("no-session");
            compare(LightDM.Users.data(loginList.currentIndex, LightDM.UserRoles.SessionRole), LightDM.Greeter.defaultSession);

            tryCompare(loginList, "currentSession", LightDM.Greeter.defaultSession);
        }

        function test_changingSessionSticksToUser() {
            var loginList = findChild(view, "loginList");

            selectUser("invalid-session");
            tryCompare(loginList, "currentSession", "invalid");

            selectUser("has-password");
            tryCompare(loginList, "currentSession", "ubuntu");

            selectUser("invalid-session")
            tryCompare(loginList, "currentSession", "invalid");
        }

        function test_tease_data() {
            return [
                {tag: "locked", x: 0, offset: 0, count: 0, locked: true},
                {tag: "left", x: 0, offset: 0, count: 1, locked: false},
                {tag: "leftWithOffsetPass", x: 10, offset: 10, count: 1, locked: false},
                {tag: "leftWithOffsetFail", x: 9, offset: 10, count: 0, locked: false},
                {tag: "right", x: view.width, offset: 0, count: 1, locked: false},
            ]
        }

        function test_sessionIconsAreValid() {
            LightDMController.sessionMode = "full";
            selectUser("has-password");

            // Test the login list icon is valid
            var sessionChooserButton = findChild(view, "sessionChooserButton");
            compare(sessionChooserButton.visible, true);

            var loginList = findChild(view, "loginList");
            var session = String(loginList.currentSession).toLowerCase();
            var icon = String(sessionChooserButton.icon);
            compare(icon.indexOf(session) > -1, true);

            // Test the session list icons are valid
            var coverPage = findChild(view, "coverPage");
            coverPage.state = "SessionsList"
            var sessionsList = findChild(view, "sessionsList");
            tryCompare(sessionsList, "visible", true);
        }

        function test_choosingNewSessionChangesLoginListIcon() {
            // Ensure the default session is selected (Ubuntu)
            cleanup();

            LightDMController.sessionMode = "full";
            selectUser("has-password");

            var sessionChooserButton = findChild(view, "sessionChooserButton");
            var icon = String(sessionChooserButton.icon);
            compare(icon.indexOf("ubuntu") > -1, true);

            tap(sessionChooserButton)
            for(var i = 0; i < LightDM.Sessions.count; i++) {
                var delegateName = "sessionDelegate" + String(i);
                var currentDelegate = findChild(view, delegateName);
                var sessionKey = LightDM.Sessions.data(i,LightDM.SessionRoles.KeyRole);
                if (sessionKey === "gnome-classic") {
                    waitForRendering(currentDelegate);
                    tap(currentDelegate);
                    waitForRendering(sessionChooserButton);
                    break;
                }
            }

            icon = String(sessionChooserButton.icon);
            compare(icon.indexOf("gnome") > -1, true,
                "Expected icon to contain gnome but it was " + icon);
        }

        function test_noSessionsDoesntBreakView() {
            LightDMController.sessionMode = "none";
            compare(LightDM.Sessions.count, 0)
        }

        function test_sessionIconNotShownWithOneSession() {
            LightDMController.sessionMode = "single";
            compare(LightDM.Sessions.count, 1);

            var sessionChooserButton = findChild(view, "sessionChooserButton");
            tryCompare(sessionChooserButton, "visible", false);
        }

        function test_sessionIconNotShownWithActiveUser() {
            selectUser("active");

            var sessionChooserButton = findChild(view, "sessionChooserButton");
            tryCompare(sessionChooserButton, "visible", false);
        }

        function test_sessionIconShownWithMultipleSessions() {
            LightDMController.sessionMode = "full";
            selectUser("has-password");

            var sessionChooserButton = findChild(view, "sessionChooserButton");
            tryCompare(sessionChooserButton, "visible", true);
        }

        function test_tease(data) {
            view.locked = data.locked;
            view.dragHandleLeftMargin = data.offset;
            tap(view, data.x, 0);
            compare(teaseSpy.count, data.count);
        }

        function test_selected() {
            var delegate = findChild(view, "username2");
            tap(delegate);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], 2);
            compare(view.currentIndex, 0); // confirm we didn't change
        }

        function test_customBackground() {
            var coverPage = findChild(view, "coverPage");
            var backgroundShade = findChild(coverPage, "backgroundShade");

            verify(!view.hasCustomBackground);
            verify(!backgroundShade.visible);

            view.hasCustomBackground = true;
            verify(backgroundShade.visible);
        }

        function test_respondedWithPassword() {
            selectUser("has-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            verify(greeterPrompt.isSecret);
            typeString("password");
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "password");
        }

        function test_respondedWithNonSecret() {
            selectUser("question-prompt");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            verify(!greeterPrompt.isSecret);
            typeString("foo");
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "foo");
        }

        function test_respondedWithSwipe() {
            swipeAwayCover();
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "");
        }

        function test_fullyShown() {
            tryCompare(view, "fullyShown", true);
            swipeAwayCover();
            tryCompare(view, "fullyShown", false);
        }

        function test_required() {
            tryCompare(view, "required", true);
            swipeAwayCover();
            tryCompare(view, "required", false);
        }

        function test_infoPrompt() {
            selectUser("info-prompt");

            var infoLabel = findChild(view, "infoLabel0");
            compare(infoLabel.text, "Welcome to Unity Greeter");
            compare(infoLabel.textFormat, Text.PlainText);

            verify(findChild(view, "greeterPrompt1") != null);
        }

        function test_longInfoPrompt() {
            selectUser("long-info-prompt");

            var infoLabel = findChild(view, "infoLabel0");
            compare(infoLabel.text, "Welcome to Unity Greeter\n\nWe like to annoy you with super ridiculously long messages.\nLike this one\n\nThis is the last line of a multiple line message.");
            verify(infoLabel.contentWidth > infoLabel.width);

            verify(findChild(view, "greeterPrompt1") != null);
        }

        function test_multiInfoPrompt() {
            selectUser("multi-info-prompt");

            var infoLabel0 = findChild(view, "infoLabel0");
            compare(infoLabel0.text, "Welcome to Unity Greeter");

            var infoLabel1 = findChild(view, "infoLabel1");
            compare(infoLabel1.text, "This is an error");
            compare(infoLabel1.color, theme.palette.normal.negative);

            var infoLabel2 = findChild(view, "infoLabel2");
            compare(infoLabel2.text, "You should have seen three messages");

            verify(findChild(view, "greeterPrompt3") != null);
        }

        // Escape is used to reset the authentication, especially if PAM is unresponsive
        function test_escape() {
            var index = selectUser("has-password");
            selectedSpy.clear();
            view.locked = true;
            var promptField = findChild(view, "promptField");
            tap(promptField);
            verify(promptField.activeFocus);
            compare(promptField.opacity, 1);

            typeString("password");
            keyClick(Qt.Key_Enter);
            verify(promptField.activeFocus);
            compare(promptField.opacity, 0); // hidden by fakeLabel

            compare(selectedSpy.count, 0);
            keyClick(Qt.Key_Escape);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], index);

            selectIndex(index);
            var promptField = findChild(view, "promptField");
            verify(promptField.activeFocus);
            compare(promptField.opacity, 1);
        }

        function test_unicode() {
            var index = selectUser("unicode");
            var label = findChild(view, "username" + index);
            tryCompare(label, "text", "가나다라마");
        }

        function test_authError() {
            var index = selectUser("auth-error");
            var greeterPrompt = findChild(view, "greeterPrompt1"); // after error message
            view.locked = true;
            compare(greeterPrompt.text, "Retry");
            tap(greeterPrompt);
            compare(respondedSpy.count, 0);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], index);
        }

        function test_noPassword() {
            selectUser("no-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            compare(greeterPrompt.text, "Log In");
            tap(greeterPrompt);
            compare(selectedSpy.count, 0);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "");
        }

        function test_loginListNotCoveredByKeyboard() {
            var loginList = findChild(view, "loginList");
            compare(loginList.height, view.height);

            // when the vkb shows up, loginList is moved up to remain fully uncovered

            keyboardVisibleCheckBox.checked = true;

            var halfway = (view.height - loginList.highlightedHeight) / 2;
            var halfwayWithOsk = halfway - view.inputMethod.keyboardRectangle.height / 2;
            tryCompare(loginList, "boxVerticalOffset", halfwayWithOsk);

            var highlightItem = findChild(loginList, "highlightItem");
            tryCompareFunction( function() {
                var highlightRect = highlightItem.mapToItem(view, 0, 0, highlightItem.width, highlightItem.height);
                return highlightRect.y + highlightRect.height <= view.inputMethod.keyboardRectangle.y;
            }, true);

            // once the vkb goes away, loginList goes back to its full height

            keyboardVisibleCheckBox.checked = false;

            tryCompare(loginList, "boxVerticalOffset", halfway);
        }

        function test_passphrase() {
            var index = selectUser("has-password");
            var promptField = findChild(view, "promptField");

            verify(view.alphanumeric);
            compare(promptField.inputMethodHints & Qt.ImhDigitsOnly, 0);

            keyClick(Qt.Key_D);
            compare(promptField.text, "d");
        }

        function test_passcode() {
            var index = selectUser("has-pin");
            var promptField = findChild(view, "promptField");

            view.alphanumeric = false;
            compare(promptField.inputMethodHints & Qt.ImhDigitsOnly, Qt.ImhDigitsOnly);

            keyClick(Qt.Key_D);
            compare(promptField.text, "");

            keyClick(Qt.Key_0);
            keyClick(Qt.Key_0);
            keyClick(Qt.Key_0);
            keyClick(Qt.Key_0);
            compare(promptField.text, "0000");

            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "0000");

            compare(promptField.opacity, 0);
        }

        function test_loginListMovement_data() {
            return [
                {tag: "up", key: Qt.Key_Up, result: 1},
                {tag: "down", key: Qt.Key_Down, result: 3},
            ]
        }

        function test_loginListMovement(data) {
            selectIndex(2);
            selectedSpy.clear();

            keyClick(data.key);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], data.result);
        }

        function test_focusStaysActive() {
            selectUser("no-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(selectedSpy.count, 0);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "");
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 1);

            selectUser("has-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_D);
            keyClick(Qt.Key_Enter);
            compare(selectedSpy.count, 0);
            compare(respondedSpy.count, 2);
            compare(respondedSpy.signalArguments[1][0], "d");
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 2);

            var index = selectUser("no-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            view.locked = true;
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 2);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], index);
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(selectedSpy.count, 1);

            selectUser("no-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            verify(greeterPrompt.activeFocus);
        }
    }
}
