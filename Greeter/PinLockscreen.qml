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
import "../Components"

Column {
    id: root
    anchors.centerIn: parent
    spacing: units.gu(2.5)

    property alias placeholderText: pinentryField.placeholderText
    property int padWidth: units.gu(32)
    property int pinLength: 4

    signal entered(string passphrase)
    signal cancel()

    function clear(playAnimation) {
        pinentryField.text = "";
        if (playAnimation) {
            wrongPasswordAnimation.start();
        }
    }

    TextField {
        id: pinentryField
        objectName: "pinentryField"
        anchors.horizontalCenter: parent.horizontalCenter
        width: units.gu(32)
        height: units.gu(5)
        echoMode: TextInput.Password
        font.pixelSize: units.dp(44)
        color: "white"
        opacity: 0.9
        hasClearButton: false
        horizontalAlignment: Text.AlignHCenter

        onTextChanged: {
            if (pinentryField.text.length === root.pinLength) {
                root.entered(pinentryField.text);
            }
        }

        // Using a MouseArea to eat clicks. We don't want to disable the TextField for styling reasons
        MouseArea {
            anchors.fill: parent
        }
    }

    Grid {
        anchors {
            left: parent.left
            right: parent.right
            margins: (parent.width - root.padWidth) / 2
        }

        columns: 3
        spacing: units.gu(1)

        Repeater {
            model: 9

            PinPadButton {
                objectName: "pinPadButton" + (index + 1)
                text: index + 1

                onClicked: {
                    pinentryField.text = pinentryField.text + text
                }
            }
        }

        PinPadButton {
            objectName: "pinPadButtonBack"
            iconName: "back"
            onClicked: root.cancel();

        }
        PinPadButton {
            objectName: "pinPadButton0"
            text: "0"
            onClicked: pinentryField.text = pinentryField.text + text

        }
        PinPadButton {
            objectName: "pinPadButtonErase"
            iconName: "erase"
            onClicked: pinentryField.text = pinentryField.text.substring(0, pinentryField.text.length-1)
        }
    }

    WrongPasswordAnimation {
        id: wrongPasswordAnimation
        target: pinentryField
    }
}
