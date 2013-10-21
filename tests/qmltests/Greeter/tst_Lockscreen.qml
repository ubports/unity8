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
import "../../../Greeter"
import Ubuntu.Components 0.1
import LightDM 0.1 as LightDM
import Unity.Test 0.1 as UT

Rectangle {
    width: units.gu(60)
    height: units.gu(80)
    color: "orange"

    Lockscreen {
        id: lockscreen
        anchors.fill: parent
        anchors.rightMargin: units.gu(18)
        placeholderText: "Please enter your PIN"
        alphaNumeric: pinPadCheckBox.checked
        pinLength: pinLengthTextField.text
        username: "Lola"
    }

    Connections {
        target: lockscreen

        onEmergencyCall: emergencyCheckBox.checked = true
        onEntered: enteredLabel.text = passphrase
    }

    Connections {
        target: LightDM.Greeter

        onShowPrompt: {
            if (text.indexOf("PIN") >= 0) {
                lockscreen.alphaNumeric = false
            } else {
                lockscreen.alphaNumeric = true
            }
            lockscreen.placeholderText = text;
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: lockscreen.width
        color: "lightgray"

        Column {
            anchors.fill: parent
            anchors.margins: units.gu(1)

            Row {
                CheckBox {
                    id: pinPadCheckBox
                }
                Label {
                    text: "Alphanumeric"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Row {
                CheckBox {
                    id: emergencyCheckBox
                }
                Label {
                    text: "Emergency Call"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Row {
                TextField {
                    id: pinLengthTextField
                    width: units.gu(7)
                    text: "4"
                }
                Label {
                    text: "PIN length"
                }
            }
            Label {
                id: pinLabel
                anchors.verticalCenter: parent.verticalCenter
            }
            Row {
                Label {
                    text: "Entered:"
                }
                Label {
                    id: enteredLabel
                }
            }
            Button {
                text: "start auth (1234)"
                onClicked: LightDM.Greeter.authenticate("has-pin")
            }
            Button {
                text: "start auth (password)"
                onClicked: LightDM.Greeter.authenticate("has-password")
            }
        }
    }

    UT.UnityTestCase {
        name: "Lockscreen"
        when: windowShown

        function test_loading_data() {
            return [
                {tag: "numeric", alphanumeric: false, pinPadAvailable: true },
                {tag: "alphanumeric", alphanumeric: true, pinPadAvailable: false }
            ]
        }

        function test_loading(data) {
            lockscreen.alphaNumeric = data.alphanumeric
            waitForRendering(lockscreen)
            if (data.pinPadAvailable) {
                compare(findChild(lockscreen, "pinPadButton8").text, "8", "Could not find number 8 on PinPad")
            } else {
                compare(findChild(lockscreen, "pinPadButton8"), undefined, "Could find number 8 on PinPad even though it should be only OSK")
            }
        }

        function test_emergency_call_data() {
            return [
                {tag: "numeric", alphanumeric: false },
                {tag: "alphanumeric", alphanumeric: true }
            ]
        }

        function test_emergency_call(data) {
            emergencyCheckBox.checked = false
            lockscreen.alphaNumeric = data.alphanumeric
            waitForRendering(lockscreen)
            var emergencyButton = findChild(lockscreen, "emergencyCallIcon")
            mouseClick(emergencyButton, units.gu(1), units.gu(1))
            tryCompare(emergencyCheckBox, "checked", true)

        }

        function test_labels_data() {
            return [
                {tag: "numeric", alphanumeric: false, placeholderText: "Please enter your PIN", username: "foobar" },
                {tag: "alphanumeric", alphanumeric: true, placeholderText: "Please enter your password", username: "Lola" }
            ]
        }

        function test_labels(data) {
            lockscreen.alphaNumeric = data.alphanumeric
            lockscreen.placeholderText = data.placeholderText
            waitForRendering(lockscreen)
            compare(findChild(lockscreen, "pinentryField").placeholderText, data.placeholderText, "Placeholdertext is not what it should be")
            if (data.alphanumeric) {
                compare(findChild(lockscreen, "greeterLabel").text, "Hello " + data.username, "Greeter is not set correctly")
            }
        }


        function test_unlock_data() {
            return [
                {tag: "numeric", alphanumeric: false, username: "has-pin", password: "1234"},
                {tag: "alphanumeric",  alphanumeric: true, username: "has-password", password: "password"},
                {tag: "numeric (wrong)",  alphanumeric: false, username: "has-pin", password: "4321"},
                {tag: "alphanumeric (wrong)",  alphanumeric: true, username: "has-password", password: "drowssap"},
            ]
        }

        function test_unlock(data) {
            enteredLabel.text = ""
            LightDM.Greeter.authenticate(data.username)
            waitForRendering(lockscreen)

            var inputField = findChild(lockscreen, "pinentryField")
            if (data.alphanumeric) {
                mouseClick(inputField, units.gu(1), units.gu(1))
                typeString(data.password)
                keyClick(Qt.Key_Enter)
            } else {
                for (var i = 0; i < data.password.length; ++i) {
                    var character = data.password.charAt(i)
                    var button = findChild(lockscreen, "pinPadButton" + character)
                    mouseClick(button, units.gu(1), units.gu(1))
                }
            }
            tryCompare(enteredLabel, "text", data.password)
        }

        function test_clear_data() {
            return [
                {tag: "animated PIN", animation: true, alphanumeric: false},
                {tag: "not animated PIN", animation: false, alphanumeric: false},
                {tag: "animated passphrase", animation: true, alphanumeric: true},
                {tag: "not animated passphrase", animation: false, alphanumeric: true}
            ];
        }

        function test_clear(data) {
            pinPadCheckBox.checked = data.alphanumeric
            waitForRendering(lockscreen)

            var inputField = findChild(lockscreen, "pinentryField")
            if (data.alphanumeric) {
                mouseClick(inputField, units.gu(1), units.gu(1))
                typeString("1")
            } else {
                var button = findChild(lockscreen, "pinPadButton1")
                mouseClick(button, units.gu(1), units.gu(1))
            }

            var animation = findInvisibleChild(lockscreen, "wrongPasswordAnimation")

            tryCompare(inputField, "text", "1")

            lockscreen.clear(data.animation)
            tryCompare(inputField, "text", "")

            wait(0) // Trigger event loop to make sure the animation would start running
            compare(animation.running, data.animation)

            // wait for animation to finish to not disturb other tests
            tryCompare(animation, "running", false)
        }
    }
}
