/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Ubuntu.Components.ListItems 1.3
import "../Components"

FocusScope {
    id: root
    focus: true

    property string infoText
    property string retryText
    property string errorText
    property int minPinLength: -1
    property int maxPinLength: -1
    property bool showCancelButton: true
    property color foregroundColor: "#000000"

    readonly property string passphrase: pinentryField.text

    signal entered(string passphrase)
    signal cancel()

    property bool entryEnabled: true

    function clear(showAnimation) {
        pinentryField.text = "";
        if (showAnimation) {
            pinentryField.incorrectOverride = true;
            wrongPasswordAnimation.start();
        }
    }

    Keys.onPressed: {
        if (pinentryField.text.length == root.maxPinLength)
            return;

        if (event.key === Qt.Key_Backspace) {
            pinentryField.backspace();
        } else if (event.key === Qt.Key_Delete || event.key === Qt.Key_Escape) {
            closeButton.clicked()
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            confirmButton.clicked()
        } else {
            var digit = parseInt(event.text);
            if (!isNaN(digit) && typeof digit == "number") {
                pinentryField.appendNumber(digit);
            }
        }
    }

    Column {
        anchors {
            left: parent.left;
            right: parent.right;
            verticalCenter: parent.verticalCenter;
            verticalCenterOffset: Math.max(-units.gu(10), -(root.height - height) / 2) + units.gu(4)
        }
        spacing: units.gu(4)

        Column {
            id: shakeContainer
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            spacing: units.gu(1)

            Label {
                id: infoField
                objectName: "infoTextLabel"
                fontSize: "large"
                color: root.foregroundColor
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.infoText
            }

            Item {
                id: pinContainer
                anchors { left: parent.left; right: parent.right; margins: units.gu(2) }
                height: units.gu(4)

                Row {
                    id: pinentryField
                    objectName: "pinentryField"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Math.max(0, Math.min(units.gu(3), (parent.width / root.maxPinLength) - units.gu(3)))

                    property string text
                    property bool incorrectOverride: false

                    Repeater {
                        model: pinentryField.text.length
                        delegate: Rectangle {
                            color: root.foregroundColor
                            width: Math.min(units.gu(2), (pinContainer.width - pinContainer.height*2 ) / (root.maxPinLength >= 0 ? root.maxPinLength : 16))
                            height: width
                            radius: width / 2
                        }
                    }

                    function appendNumber(number) {
                        if (incorrectOverride) {
                            incorrectOverride = false;
                        }

                        pinentryField.text = pinentryField.text + number

                        if (root.minPinLength > 0 && root.maxPinLength > 0
                                && root.minPinLength == root.maxPinLength && pinentryField.text.length == root.minPinLength) {
                            root.entered(pinentryField.text)
                        }
                    }

                    function backspace() {
                        pinentryField.text = pinentryField.text.substring(0, pinentryField.text.length-1)
                    }
                }
                Label {
                    id: wrongNoticeLabel
                    objectName: "wrongNoticeLabel"
                    fontSize: "x-large"
                    color: root.foregroundColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: root.errorText
                    visible: pinentryField.incorrectOverride
                    scale: Math.min(1, parent.width / width)
                }

                AbstractButton {
                    objectName: "backspaceIcon"
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                    width: height
                    enabled: root.entryEnabled

                    Icon {
                        anchors.fill: parent
                        name: "erase"
                        color: root.foregroundColor
                    }

                    opacity: (pinentryField.text.length > 0 && !pinentryField.incorrectOverride) ? 1 : 0

                    Behavior on opacity {
                        UbuntuNumberAnimation {}
                    }

                    onClicked: pinentryField.backspace()
                }
            }

            Label {
                objectName: "retryLabel"
                fontSize: "x-small"
                color: root.foregroundColor
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.retryText || " "
            }
        }

        Grid {
            id: numbersGrid
            objectName: "numbersGrid"
            anchors { horizontalCenter: parent.horizontalCenter }
            columns: 3

            property int maxWidth: Math.min(units.gu(50), root.width - units.gu(8))
            property int buttonWidth: maxWidth / 3
            property int buttonHeight: buttonWidth * 2 / 3

            Repeater {
                model: 9

                PinPadButton {
                    objectName: "pinPadButton" + text
                    text: index + 1
                    height: numbersGrid.buttonHeight
                    width: numbersGrid.buttonWidth
                    foregroundColor: root.foregroundColor
                    enabled: root.entryEnabled && (root.maxPinLength == -1 ||
                             pinentryField.text.length < root.maxPinLength ||
                             pinentryField.incorrectOverride)

                    onClicked: {
                        pinentryField.appendNumber(index + 1)
                    }
                }
            }
            Item {
                height: numbersGrid.buttonHeight
                width: numbersGrid.buttonWidth
            }
            PinPadButton {
                text: "0"
                height: numbersGrid.buttonHeight
                width: numbersGrid.buttonWidth
                foregroundColor: root.foregroundColor
                enabled: root.entryEnabled && (root.maxPinLength == -1 ||
                         pinentryField.text.length < root.maxPinLength ||
                         pinentryField.incorrectOverride)

                onClicked: {
                    pinentryField.appendNumber(0)
                }
            }
            Item {
                height: numbersGrid.buttonHeight
                width: numbersGrid.buttonWidth
            }
            PinPadButton {
                id: closeButton
                iconName: "close"
                height: units.gu(5) // visual spec has this row a little closer in
                width: numbersGrid.buttonWidth
                foregroundColor: root.foregroundColor
                onClicked: root.cancel()
                visible: root.showCancelButton
            }
            Item {
                height: units.gu(5)
                width: numbersGrid.buttonWidth
            }
            PinPadButton {
                id: confirmButton
                iconName: "tick"
                objectName: "confirmButton"
                height: units.gu(5)
                width: numbersGrid.buttonWidth
                foregroundColor: root.foregroundColor
                enabled: root.enabled && pinentryField.text.length >= root.minPinLength
                visible: root.minPinLength == -1 || root.minPinLength !== root.maxPinLength

                onClicked: root.entered(pinentryField.text)
            }
        }
        WrongPasswordAnimation {
            id: wrongPasswordAnimation
            objectName: "wrongPasswordAnimation"
            target: shakeContainer
        }
    }
}
