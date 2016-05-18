/*
 * Copyright (C) 2016 Canonical, Ltd.
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

FocusScope {
    id: root
    implicitHeight: units.gu(4)

    property bool isPrompt
    property bool isAlphanumeric
    property string text
    property bool isSecret

    signal clicked()
    signal canceled()
    signal responded(string text)

    function reset() {
        passwordInput.text = "";
        passwordInput.focus = false;
        passwordInput.enabled = true;
    }

    Rectangle {
        anchors.fill: parent
        border.width: units.dp(1)
        border.color: UbuntuColors.porcelain
        radius: units.gu(0.5)
        color: "transparent"
    }

    AbstractButton {
        anchors.fill: parent
        visible: !root.isPrompt

        onClicked: root.clicked()

        Label {
            anchors.centerIn: parent
            color: UbuntuColors.porcelain
            text: root.text
        }
    }

    TextField {
        id: passwordInput
        anchors.fill: parent
        visible: root.isPrompt

        inputMethodHints: root.isAlphanumeric ? Qt.ImhNone : Qt.ImhDigitsOnly
        echoMode: root.isSecret ? TextInput.Password : TextInput.Normal
        placeholderText: "  " + root.text // add some spacing here
        hasClearButton: false

        style: Item {
            property color color: UbuntuColors.porcelain
            property color selectedTextColor: UbuntuColors.jet
            property color selectionColor: UbuntuColors.porcelain
            property color borderColor: "transparent"
            property color backgroundColor: "transparent"
            property color errorColor: UbuntuColors.red
            property real frameSpacing: units.gu(0.5)
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: "white"
                opacity: 0.1
            }
        }

        secondaryItem: [
            Icon {
                name: "keyboard-caps-enabled"
                height: units.gu(2)
                width: units.gu(2)
                color: UbuntuColors.porcelain
                visible: false // TODO: detect when caps lock is on
            }
        ]

        onAccepted: {
            if (!enabled)
                return;
            root.focus = true; // so that it can handle Escape presses for us
            enabled = false;
            root.responded(text);
        }

        Keys.onEscapePressed: root.canceled()

        Connections {
            target: Qt.inputMethod
            onVisibleChanged: {
                if (!Qt.inputMethod.visible) {
                    passwordInput.focus = false;
                }
            }
        }
    }
}
