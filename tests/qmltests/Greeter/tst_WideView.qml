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
import LightDM.IntegratedLightDM 0.1 as LightDM
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT

StyledItem {
    id: root

    width: units.gu(120)
    height: units.gu(80)

    theme.name: "Ubuntu.Components.Themes.SuruDark"

    Binding {
        target: LightDM.Users
        property: "mockMode"
        value: "full"
    }

    Row {
        anchors.fill: parent
        Loader {
            id: loader
            width: root.width - controls.width
            height: parent.height

            property bool itemDestroyed: false
            sourceComponent: Component {
                WideView {
                    id: view

                    background: Qt.resolvedUrl("../../../qml/graphics/tablet_background.jpg")
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
                        text: "Show Last Chance"
                        onClicked: loader.item.showLastChance()
                    }
                }
                Row {
                    Button {
                        text: "Hide"
                        onClicked: loader.item.hide()
                    }
                }
                Row {
                    Button {
                        text: "Reset"
                        onClicked: loader.item.reset()
                    }
                }
                Row {
                    Button {
                        text: "Show Message"
                        onClicked: loader.item.showMessage(messageField.text)
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
                        onClicked: loader.item.showPrompt(promptField.text, isSecretCheckBox.checked, isDefaultPromptCheckBox.checked)
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
                    CheckBox {
                        id: isDefaultPromptCheckBox
                    }
                    Label {
                        text: "default"
                    }
                }
                Row {
                    Button {
                        text: "Authenticated"
                        onClicked: {
                            if (successCheckBox.checked) {
                                loader.item.notifyAuthenticationSucceeded(false);
                            } else {
                                loader.item.notifyAuthenticationFailed();
                            }
                        }
                    }
                    CheckBox {
                        id: successCheckBox
                    }
                    Label {
                        text: "success"
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
                                LightDM.Sessions.testScenario = "multipleSessions"
                            } else {
                                LightDM.Sessions.testScenario = "singleSession"
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
                        maximumValue: LightDM.Sessions.numAvailableSessions
                        value: LightDM.Sessions.numSessions
                        visible: LightDM.Sessions.testScenario === "multipleSessions"
                        Binding {
                            target: LightDM.Sessions
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
        property url testIconDirectory: "./test_session_badges"

        function init() {
            selectIndex(0); // break binding with text field
            selectedSpy.clear();
            respondedSpy.clear();
            teaseSpy.clear();
            emergencySpy.clear();
            LightDM.Sessions.testScenario = "multipleSessions"
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
            view.currentIndex = i;
            var userList = findChild(view, "userList");
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
            LightDM.Sessions.testScenario = "multipleSessions"
            var originalDirectories = LightDM.Sessions.iconSearchDirectories
            LightDM.Sessions.iconSearchDirectories = [testIconDirectory]

            // Test the login list icon is valid
            var sessionChooserButton = findChild(view, "sessionChooserButton");
            compare(sessionChooserButton.visible, true);

            var session = String(view.sessionToStart).toLowerCase();
            var icon = String(sessionChooserButton.icon);
            compare(icon.indexOf(session) > -1, true);

            // Test the session list icons are valid
            view.loginListShown = false;
            var sessionsList = findChild(view, "sessionsList");
            var sessionsListSelector = findChild(view, "sessionsListSelector");
            tryCompare(sessionsList, "visible", true);
            tryCompare(sessionsListSelector, "expanded", true);

        }

        function test_choosingNewSessionChangesLoginListIcon() {
            // Ensure the default session is selected (Ubuntu)
            loader.active = false;
            loader.active = true;

            LightDM.Sessions.testScenario = "multipleSessions";
            var sessionChooserButton = findChild(view, "sessionChooserButton");
            var icon = String(sessionChooserButton.icon);
            compare(icon.indexOf("ubuntu") > -1, true);

            tap(sessionChooserButton)
            var sessionsListSelector = findChild(view, "sessionsListSelector");
            waitForRendering(sessionsListSelector);
            for(var i = 0; i < LightDM.Sessions.count; i++) {
                var delegateName = "sessionDelegate" + String(i);
                var currentDelegate = findChild(view, delegateName);
                if (currentDelegate.text === "GNOME") {
                    tap(currentDelegate);
                    var sessionChooserButton = findChild(view, "sessionChooserButton");
                    waitForRendering(sessionChooserButton);
                    var icon = String(sessionChooserButton.icon);
                    break;
                }
            }

            compare(icon.indexOf("gnome") > -1, true,
                "Expected icon to contain gnome but it was " + icon);
        }

        function test_noSessionsDoesntBreakView() {
            LightDM.Sessions.testScenario = "noSessions"
            compare(LightDM.Sessions.count, 0)
        }

        function test_sessionIconNotShownWithOneSession() {
            LightDM.Sessions.testScenario = "singleSession"
            compare(LightDM.Sessions.count, 1);

            var sessionChooserButton = findChild(view, "sessionChooserButton");
            tryCompare(sessionChooserButton, "visible", false);
        }

        function test_sessionIconShownWithMultipleSessions() {
            LightDM.Sessions.testScenario = "multipleSessions"
            compare(LightDM.Sessions.count > 1, true);

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

        function test_respondedWithPassword() {
            view.locked = true;
            view.showPrompt("Prompt", true, true);
            var passwordInput = findChild(view, "passwordInput");
            compare(passwordInput.text, "Prompt");
            verify(passwordInput.isSecret);
            tap(passwordInput);
            typeString("password");
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "password");
        }

        function test_respondedWithNonSecret() {
            view.locked = true;
            view.showPrompt("otp", false, false);
            var passwordInput = findChild(view, "passwordInput");
            compare(passwordInput.text, "otp");
            verify(!passwordInput.isSecret);
            tap(passwordInput);
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

        function test_showMessage() {
            view.showMessage("Welcome to Unity Greeter");
            view.showMessage("<font color=\"#df382c\">This is an error</font>");
            view.showMessage("You should have seen three messages and this is a really long message too. wow so long much length");
            var infoLabel = findChild(view, "infoLabel");
            compare(infoLabel.text, "Welcome to Unity Greeter<br><font color=\"#df382c\">This is an error</font><br>You should have seen three messages and this is a really long message too. wow so long much length");
            compare(infoLabel.textFormat, Text.StyledText);
            verify(infoLabel.contentWidth > infoLabel.width);
            verify(infoLabel.opacity < 1);
            tryCompare(infoLabel, "opacity", 1);
        }

        // Escape is used to reset the authentication, especially if PAM is unresponsive
        function test_escape() {
            selectIndex(1);
            selectedSpy.clear();
            view.locked = true;
            view.showPrompt("Prompt", true, true);
            var promptField = findChild(view, "promptField");
            tap(promptField);
            compare(promptField.focus, true);
            compare(promptField.enabled, true);

            typeString("password");
            keyClick(Qt.Key_Enter);
            compare(promptField.focus, true);
            compare(promptField.enabled, false);

            compare(selectedSpy.count, 0);
            keyClick(Qt.Key_Escape);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], 1);

            view.reset();
            compare(promptField.focus, false);
            compare(promptField.enabled, true);
        }

        function test_unicode() {
            var index = selectUser("unicode");
            var label = findChild(view, "username" + index);
            tryCompare(label, "text", "가나다라마");
        }

        function test_promptless() {
            var passwordInput = findChild(view, "passwordInput");

            view.locked = true;
            compare(passwordInput.text, "Retry");
            tap(passwordInput);
            compare(respondedSpy.count, 0);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], 0);
            selectedSpy.clear();

            view.locked = false;
            compare(passwordInput.text, "Log In");
            tap(passwordInput);
            compare(selectedSpy.count, 0);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "");
        }

        function test_loginListNotCoveredByKeyboard() {
            var loginList = findChild(view, "loginAreaLoader").item;
            compare(loginList.height, view.height);

            // when the vkb shows up, loginList is moved up to remain fully uncovered

            keyboardVisibleCheckBox.checked = true;

            tryCompare(loginList, "height", view.height - view.inputMethod.keyboardRectangle.height);
            tryCompareFunction( function() {
                var loginListRect = loginList.mapToItem(view, 0, 0, loginList.width, loginList.height);
                return loginListRect.y + loginListRect.height <= view.inputMethod.keyboardRectangle.y;
            }, true);

            // once the vkb goes away, loginList goes back to its full height

            keyboardVisibleCheckBox.checked = false;

            tryCompare(loginList, "height", view.height);
        }

        function test_alphanumeric() {
            var passwordInput = findChild(view, "passwordInput");

            verify(view.alphanumeric);
            verify(passwordInput.isAlphanumeric);
            view.alphanumeric = false;
            verify(!passwordInput.isAlphanumeric);
        }
    }
}
