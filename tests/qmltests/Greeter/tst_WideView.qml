/*
 * Copyright 2014 Canonical Ltd.
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
import LightDM 0.1 as LightDM
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(120)
    height: units.gu(80)

    Row {
        anchors.fill: parent
        Loader {
            id: loader
            width: root.width - controls.width
            height: parent.height

            property bool itemDestroyed: false
            sourceComponent: Component {
                WideView {
                    background: Qt.resolvedUrl("../../../qml/graphics/tablet_background.jpg")
                    userModel: LightDM.Users
                    infographicModel: LightDM.Infographic

                    launcherOffset: parseFloat(launcherOffsetField.text)
                    currentIndex: parseInt(currentIndexField.text, 10)
                    delayMinutes: parseInt(delayMinutesField.text, 10)
                    backgroundTopMargin: parseFloat(backgroundTopMarginField.text)
                    locked: lockedCheckBox.checked

                    Component.onDestruction: {
                        loader.itemDestroyed = true
                    }

                    onSelected: {
                        currentIndexField.text = index;
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
                        onClicked: loader.item.authenticated(successCheckBox.checked)
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
            view.currentIndex = 0; // break binding with text field
            selectedSpy.clear();
            respondedSpy.clear();
            teaseSpy.clear();
            emergencySpy.clear();
        }

        function cleanup() {
            loader.itemDestroyed = false;
            loader.active = false;
            tryCompare(loader, "status", Loader.Null);
            tryCompare(loader, "item", null);
            tryCompare(loader, "itemDestroyed", true);
            loader.active = true;
            tryCompare(loader, "status", Loader.Ready);
        }

        function test_tease() {
            tap(view, 1, 1);
            compare(teaseSpy.count, 1);
        }

        function test_selected() {
            var delegate = findChild(view, "username2");
            tap(delegate);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], 2);
            compare(view.currentIndex, 0); // confirm we didn't change
        }

        function test_responded() {
            view.showPrompt("Prompt", true, true);
            var passwordInput = findChild(view, "passwordInput");
            tap(passwordInput);
            typeString("password");
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "password");
        }
    }
}
