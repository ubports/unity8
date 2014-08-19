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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import "../Components"

Column {
    id: root
    anchors.centerIn: parent
    spacing: units.gu(2)

    property string infoText
    property string retryText
    property string errorText
    property int padWidth: units.gu(34)
    property int padHeight: units.gu(28)
    property int minPinLength: -1
    property int maxPinLength: -1

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

    Column {
        id: shakeContainer
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: units.gu(2)

        Label {
            id: infoField
            objectName: "infoTextLabel"
            fontSize: "large"
            color: "#f3f3e7"
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
                        color: "#f3f3e7"
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
                color: "#f3f3e7"
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.errorText
                visible: pinentryField.incorrectOverride
            }

            AbstractButton {
                objectName: "backspaceIcon"
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: height

                Icon {
                    anchors.fill: parent
                    name: "erase"
                    color: "#f3f3e7"
                }

                opacity: (pinentryField.text.length && !pinentryField.incorrectOverride) > 0 ? 1 : 0

                Behavior on opacity {
                    UbuntuNumberAnimation {}
                }

                onClicked: pinentryField.backspace()
            }
        }

        Label {
            objectName: "retryLabel"
            fontSize: "x-small"
            color: "#f3f3e7"
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.retryText || " "
        }
    }

    ThinDivider {
        anchors { left: parent.left; right: parent.right; margins: units.gu(2) }
    }

    Grid {
        id: numbersGrid
        anchors { horizontalCenter: parent.horizontalCenter }
        columns: 3

        property int buttonHeight: units.gu(8)
        property int buttonWidth: units.gu(12)

        Repeater {
            model: 9

            PinPadButton {
                objectName: "pinPadButton" + text
                text: index + 1
                height: numbersGrid.buttonHeight
                width: numbersGrid.buttonWidth
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
            iconName: "close"
            height: numbersGrid.buttonHeight
            width: numbersGrid.buttonWidth

            onClicked: root.cancel()
        }
        Item {
            height: numbersGrid.buttonHeight
            width: numbersGrid.buttonWidth
        }
        PinPadButton {
            iconName: "tick"
            objectName: "confirmButton"
            height: numbersGrid.buttonHeight
            width: numbersGrid.buttonWidth
            enabled: root.enabled && pinentryField.text.length >= root.minPinLength

            onClicked: root.entered(pinentryField.text)
        }
    }
    WrongPasswordAnimation {
        id: wrongPasswordAnimation
        objectName: "wrongPasswordAnimation"
        target: shakeContainer
    }
}
