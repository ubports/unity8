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

import QtQuick 2.4
import QtTest 1.0
import ".."
import "../../../qml/Components"
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(80)
    height: units.gu(76)
    color: "orange"

    Lockscreen {
        id: lockscreen
        anchors.fill: parent
        anchors.rightMargin: units.gu(40)
        infoText: infoTextTextField.text
        retryText: retryCountTextField.text
        errorText: errorTextTextField.text
        alphaNumeric: pinPadCheckBox.checked
        minPinLength: minPinLengthTextField.text
        maxPinLength: maxPinLengthTextField.text
        delayMinutes: delayMinutesTextField.text
        background: "../../../qml/graphics/phone_background.jpg"
    }

    Connections {
        target: lockscreen

        onEmergencyCall: emergencyCheckBox.checked = true
        onEntered: {
            enteredLabel.text = passphrase
            lockscreen.clear(true)
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: lockscreen.width
        color: "lightgray"

        Column {
            anchors.fill: parent
            anchors.margins: units.gu(1)
            spacing: units.gu(1)

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
                    id: minPinLengthTextField
                    width: units.gu(7)
                    text: "4"
                }
                Label {
                    text: "Min PIN length"
                }
            }
            Row {
                TextField {
                    id: maxPinLengthTextField
                    width: units.gu(7)
                    text: "4"
                }
                Label {
                    text: "Max PIN length"
                }
            }
            Row {
                TextField {
                    id: retryCountTextField
                    width: units.gu(7)
                    text: "3 retries left"
                }
                Label {
                    text: "Retries left"
                }
            }
            Row {
                TextField {
                    id: delayMinutesTextField
                    width: units.gu(7)
                    text: "0"
                }
                Label {
                    text: "Delay Minutes"
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
            TextField {
                id: infoTextTextField
                width: parent.width
                placeholderText: "Infotext"
                text: "Enter SIM1 PIN"
            }

            TextField {
                id: errorTextTextField
                width: parent.width
                placeholderText: "Error text"
                text: "Sorry, incorrect PIN"
            }

            TextField {
                id: infoPopupTitleTextField
                width: parent.width
                placeholderText: "Popup title"
                text: "This will be the last attempt"
            }

            TextArea {
                id: infoPopupTextArea
                width: parent.width
                text: "If the SIM PIN is entered incorrectly, your SIM will be blocked and would require the PUK code to unlock."
            }

            Button {
                text: "open info popup"
                width: parent.width
                onClicked: lockscreen.showInfoPopup(infoPopupTitleTextField.text, infoPopupTextArea.text)
            }
        }
    }

    UT.UnityTestCase {
        name: "Lockscreen"
        when: windowShown

        function cleanup() {
            lockscreen.clear(false);
            delayMinutesTextField.text = "0"
            enteredLabel.text = "";

            // Reset sizing
            root.width = units.gu(80)
            root.height = units.gu(76)
        }

        function waitForLockscreenReady() {
            var pinPadLoader = findChild(lockscreen, "pinPadLoader");
            tryCompare(pinPadLoader, "status", Loader.Ready)
            waitForRendering(lockscreen)
        }

        function test_loading_data() {
            return [
                {tag: "numeric", alphanumeric: false, pinPadAvailable: true },
                {tag: "alphanumeric", alphanumeric: true, pinPadAvailable: false }
            ]
        }

        function test_loading(data) {
            pinPadCheckBox.checked = data.alphanumeric
            waitForLockscreenReady();
            if (data.pinPadAvailable) {
                compare(findChild(lockscreen, "pinPadButton8").text, "8", "Could not find number 8 on PinPad")
            } else {
                compare(findChild(lockscreen, "pinPadButton8"), null, "Could find number 8 on PinPad even though it should be only OSK")
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
            pinPadCheckBox.checked = data.alphanumeric
            waitForLockscreenReady();
            var emergencyButton = findChild(lockscreen, "emergencyCallLabel")
            mouseClick(emergencyButton, units.gu(1), units.gu(1))
            tryCompare(emergencyCheckBox, "checked", true)

        }

        function test_labels_data() {
            return [
                {tag: "numeric", alphanumeric: false, infoText: "Please enter your PIN" },
                {tag: "alphanumeric", alphanumeric: true, infoText: "Please enter your password" }
            ]
        }

        function test_labels(data) {
            pinPadCheckBox.checked = data.alphanumeric
            lockscreen.infoText = data.infoText
            waitForLockscreenReady();
            compare(findChild(lockscreen, "infoTextLabel").text, data.infoText, "Placeholdertext is not what it should be")
        }

        function test_unlock_data() {
            return [
                {tag: "numeric", alphanumeric: false, password: "1234", minPinLength: 4, maxPinLength: 4, keyboard: false},
                {tag: "alphanumeric",  alphanumeric: true, password: "password", minPinLength: -1, maxPinLength: -1, keyboard: false},
                {tag: "numeric (wrong)",  alphanumeric: false, password: "4321", minPinLength: 4, maxPinLength: 4, keyboard: false},
                {tag: "alphanumeric (wrong)",  alphanumeric: true, password: "drowssap", minPinLength: -1, maxPinLength: -1, keyboard: false},
                {tag: "flexible length",  alphanumeric: false, password: "1234", minPinLength: -1, maxPinLength: -1, keyboard: false},
                {tag: "numeric", alphanumeric: false, password: "1234", minPinLength: 4, maxPinLength: 4, keyboard: true},
                {tag: "numeric (wrong)",  alphanumeric: false, password: "4321", minPinLength: 4, maxPinLength: 4, keyboard: true},
                {tag: "flexible length",  alphanumeric: false, password: "1234", minPinLength: -1, maxPinLength: -1, keyboard: true}
            ]
        }

        function test_unlock(data) {
            minPinLengthTextField.text = data.minPinLength
            maxPinLengthTextField.text = data.maxPinLength
            pinPadCheckBox.checked = data.alphanumeric
            infoTextTextField.text = "Enter " + (data.alphanumeric ? "passphrase" : "passcode")
            waitForLockscreenReady();

            var inputField = findChild(lockscreen, "pinentryField")
            if (data.alphanumeric) {
                tryCompare(inputField, "activeFocus", true);
                typeString(data.password)
                keyClick(Qt.Key_Enter)
            } else {
                for (var i = 0; i < data.password.length; ++i) {
                    var character = data.password.charAt(i)
                    if (data.keyboard) {
                        typeString(character)
                    } else {
                        var button = findChild(lockscreen, "pinPadButton" + character)
                        mouseClick(button, units.gu(1), units.gu(1))
                    }
                }
                var confirmButton = findChild(lockscreen, "confirmButton");
                mouseClick(confirmButton, units.gu(1), units.gu(1));
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
            waitForLockscreenReady();

            var inputField = findChild(lockscreen, "pinentryField")
            if (data.alphanumeric) {
                tryCompare(inputField, "activeFocus", true);
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
            if (data.animation) {
                if (!data.alphanumeric) {
                    var label = findChild(lockscreen, "wrongNoticeLabel");
                    tryCompare(label, "visible", true)
                }
            }

            // wait for animation to finish to not disturb other tests
            tryCompare(animation, "running", false)
        }

        function test_backspace_data() {
            return [
                {tag: "fixed length", minPinLength: 4, maxPinLength: 4},
                {tag: "variable undefined length", minPinLength: -1, maxPinLength: -1},
                {tag: "variable restricted length", minPinLength: 4, maxPinLength: 8}
            ];
        }

        function test_backspace(data) {
            pinPadCheckBox.checked = false
            minPinLengthTextField.text = data.minPinLength
            maxPinLengthTextField.text = data.maxPinLength
            waitForLockscreenReady();

            var backspaceIcon = findChild(lockscreen, "backspaceIcon");
            var pinEntryField = findChild(lockscreen, "pinentryField");

            compare(backspaceIcon.opacity, 0);

            var pinPadButton5 = findChild(lockscreen, "pinPadButton5");
            mouseClick(pinPadButton5, units.gu(1), units.gu(1));
            compare(pinEntryField.text, "5");

            tryCompare(backspaceIcon, "opacity", 1);

            mouseClick(backspaceIcon, units.gu(1), units.gu(1));
            compare(pinEntryField.text, "");

            tryCompare(backspaceIcon, "opacity", 0);
        }

        function test_minMaxLength_data() {
            return [
                {tag: "undefined", minPinLength: -1, maxPinLength: -1},
                {tag: "fixed", minPinLength: 4, maxPinLength: 4},
                {tag: "variable, limited", minPinLength: 4, maxPinLength: 8},
            ];
        }

        function test_minMaxLength(data) {
            pinPadCheckBox.checked = false
            minPinLengthTextField.text = data.minPinLength;
            maxPinLengthTextField.text = data.maxPinLength;
            waitForLockscreenReady();

            var pinPadButton5 = findChild(lockscreen, "pinPadButton5");
            var backspaceButton = findChild(lockscreen, "backspaceIcon");
            var confirmButton = findChild(lockscreen, "confirmButton");
            var inputField = findChild(lockscreen, "pinentryField");

            tryCompare(backspaceButton, "opacity", 0);

            tryCompare(confirmButton, "visible", (data.minPinLength != data.maxPinLength) || (data.minPinLength == -1));

            for (var i = 0; i < 10; i++) {
                mouseClick(pinPadButton5, units.gu(1), units.gu(1));
                tryCompare(backspaceButton, "opacity", 1)

                if (data.maxPinLength == data.minPinLength && data.minPinLength > 0) {
                    // Autoconfirm mode. This will automatically confirm (and with it reset)
                    // the textfield every data.minPinLength presses
                    if (i+1 < data.minPinLength) {
                        compare(inputField.text.length, i + 1);
                    } else {
                        compare(inputField.text.length, (i+1) % data.minPinLength)
                    }
                } else {
                    if (data.maxPinLength == -1) {
                        // Undefined maxLength... make sure all presses are recorded
                        compare(inputField.text.length, i+1);
                    } else {
                        // We have a max length. Make sure we're only accepting maxLength presses
                        compare(inputField.text.length, Math.min(data.maxPinLength, i+1));
                    }

                    if (data.minPinLength == -1) {
                        // Undefined minLength. Make sure confirm button is always enabled
                        compare(confirmButton.enabled, true);
                    } else {
                        // We have a min length. Make sure the confirm button is only enabled when met.
                        compare(confirmButton.enabled, (i+1) >= data.minPinLength);
                    }
                }
            }
        }

        function test_retryDisplay_data() {
            return [
                {tag: "empty", retryText: " "},
                {tag: "3 retries left", retryText: "3 retries left"},
            ]
        }

        function test_retryDisplay(data) {
            pinPadCheckBox.checked = false
            waitForLockscreenReady();

            retryCountTextField.text = data.retryText;
            var label = findChild(lockscreen, "retryLabel")
            compare(label.text, data.retryText);
        }

        function test_infoPopup() {
            verify(findChild(root, "infoPopup") === null);
            lockscreen.showInfoPopup("foo", "bar");
            tryCompareFunction(function() { return findChild(root, "infoPopup") !== null}, true);

            var infoPopup = findChild(root, "infoPopup");
            compare(infoPopup.title, "foo");
            compare(infoPopup.text, "bar");

            signalSpy.signalName = "infoPopupConfirmed"
            signalSpy.clear();

            var okButton = findChild(root, "infoPopupOkButton");
            mouseClick(okButton);

            tryCompareFunction(function() { return findChild(root, "infoPopup") === null}, true);

            tryCompare(signalSpy, "count", 1);
        }

        function test_infoTextDisplay_data() {
            return [
                {tag: "empty string", text: ""},
                {tag: "hello world", text: "hello world"},
            ]
        }

        function test_infoTextDisplay(data) {
            pinPadCheckBox.checked = false
            waitForLockscreenReady();

            infoTextTextField.text = data.text;
            var label = findChild(lockscreen, "infoTextLabel")
            compare(label.text, data.text);
        }

        function test_delayMinutes() {
            delayMinutesTextField.text = "4"
            waitForLockscreenReady()
            var label = findChild(lockscreen, "deviceLockedLabel")
            compare(label.text, "Device Locked")
        }

        function test_showText_data() {
            return [
                { tag: "alphanumeric", alphanumeric: true },
                { tag: "pinPad", alphanumeric: false },
            ]
        }

        function test_showText(data) {
            pinPadCheckBox.checked = data.alphanumeric;
            waitForLockscreenReady();

            lockscreen.showText("test");

            var pinPadLoader = findChild(lockscreen, "pinPadLoader");
            verify(pinPadLoader.waiting);
            compare(enteredLabel.text, ""); // no entered signal should occur
            compare(lockscreen.passphrase, "test");
        }

        function test_resize_data() {
            return [
                { tag: "small", width: units.gu(40), height: units.gu(76) },
                { tag: "medium", width: units.gu(50), height: units.gu(86) },
                { tag: "large", width: units.gu(60), height: units.gu(96) },
                { tag: "x-large", width: units.gu(80), height: units.gu(116) },
            ]
        }

        function test_resize(data) {
            var controlsAreaWidth = lockscreen.anchors.rightMargin;
            root.width = data.width + controlsAreaWidth;
            root.height = data.height;
            waitForRendering(root);

            var numbersGrid = findChild(lockscreen, "numbersGrid");
            // Make sure the numbers pad keeps a 4gu margin on left/right but doesn't grow larger than 50 gu's width.
            // For rounding reasons it might be off 1 pixel. Let's make sure it's within +/- 1 pixel of what we expect
            verify(numbersGrid.width >= Math.min(units.gu(50), data.width - units.gu(8)) - 1);
            verify(numbersGrid.width <= Math.min(units.gu(50), data.width - units.gu(8)) + 1);
        }
    }

    SignalSpy {
        id: signalSpy
        target: lockscreen
    }
}
