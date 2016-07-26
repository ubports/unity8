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
    focus: true

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
            focus: true

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

        function init() {
            selectIndex(0); // break binding with text field
            selectedSpy.clear();
            respondedSpy.clear();
            teaseSpy.clear();
            emergencySpy.clear();
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
            view.showPrompt("Prompt", true, false);
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
            verify(promptField.activeFocus);
            compare(promptField.opacity, 1);

            typeString("password");
            keyClick(Qt.Key_Enter);
            verify(promptField.activeFocus);
            compare(promptField.opacity, 0); // hidden by fakeLabel

            compare(selectedSpy.count, 0);
            keyClick(Qt.Key_Escape);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], 1);

            view.reset();
            verify(promptField.activeFocus);
            compare(promptField.opacity, 1);
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

            view.reset();
            view.locked = false;
            compare(passwordInput.text, "Log In");
            tap(passwordInput);
            compare(selectedSpy.count, 0);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "");
        }

        function test_loginListNotCoveredByKeyboard() {
            var loginList = findChild(view, "loginList");
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

        function test_passphrase() {
            var promptField = findChild(view, "promptField");
            view.showPrompt("", true, true);

            verify(view.alphanumeric);
            compare(promptField.inputMethodHints & Qt.ImhDigitsOnly, 0);

            keyClick(Qt.Key_D);
            compare(promptField.text, "d");
        }

        function test_passcode() {
            var promptField = findChild(view, "promptField");
            view.showPrompt("", true, true);

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
                {tag: "up", key: Qt.Key_Up, result: -1},
                {tag: "down", key: Qt.Key_Down, result: 1},
            ]
        }

        function test_loginListMovement(data) {
            keyClick(data.key);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], data.result);
        }

        function test_focusStaysActive() {
            var promptField = findChild(view, "promptField");
            var promptButton = findChild(view, "promptButton");

            verify(promptButton.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(selectedSpy.count, 0);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "");
            verify(promptButton.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 1);

            view.showPrompt("", true, true);
            verify(promptField.activeFocus);
            keyClick(Qt.Key_D);
            keyClick(Qt.Key_Enter);
            compare(selectedSpy.count, 0);
            compare(respondedSpy.count, 2);
            compare(respondedSpy.signalArguments[1][0], "d");
            verify(promptField.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 2);

            view.reset();
            view.locked = true;
            verify(promptButton.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 2);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], 0);
            verify(promptButton.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(selectedSpy.count, 1);

            view.showPrompt("", true, true);
            verify(promptField.activeFocus);
        }
    }
}
