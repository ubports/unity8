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
        focus = false;
        d.enabled = true;
    }

    StyledItem {
        id: d

        property bool enabled: true
        readonly property color color: root.enabled ? theme.palette.normal.backgroundText
                                                    : theme.palette.disabled.backgroundText
        readonly property color inverseColor: root.enabled ? theme.palette.normal.background
                                                           : theme.palette.disabled.background
        readonly property color errorColor: root.enabled ? theme.palette.normal.negative
                                                         : theme.palette.disabled.negative
    }

    Rectangle {
        anchors.fill: parent
        border.width: units.dp(1)
        border.color: d.color
        radius: units.gu(0.5)
        color: "transparent"
    }

    AbstractButton {
        objectName: "promptButton"
        anchors.fill: parent
        visible: !root.isPrompt
        enabled: d.enabled

        onClicked: root.clicked()

        Label {
            anchors.centerIn: parent
            color: d.color
            text: root.text
        }
    }

    TextField {
        id: passwordInput
        objectName: "promptField"
        anchors.fill: parent
        visible: root.isPrompt
        enabled: d.enabled

        inputMethodHints: root.isAlphanumeric ? Qt.ImhNone : Qt.ImhDigitsOnly
        echoMode: root.isSecret ? TextInput.Password : TextInput.Normal
        placeholderText: "  " + root.text // add some spacing here
        hasClearButton: false

        style: Item {
            property color color: d.color
            property color selectedTextColor: d.inverseColor
            property color selectionColor: d.color
            property color borderColor: "transparent"
            property color backgroundColor: "transparent"
            property color errorColor: d.errorColor
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
                color: d.color
                visible: root.isSecret && false // TODO: detect when caps lock is on
            }
        ]

        cursorDelegate: Rectangle {
            width: units.dp(1)
            color: d.color
        }

        onAccepted: {
            if (!enabled)
                return;
            root.focus = true; // so that it can handle Escape presses for us
            d.enabled = false;
            root.responded(text);
        }

        Keys.onEscapePressed: root.canceled()

        Connections {
            target: Qt.inputMethod
            onVisibleChanged: {
                if (passwordInput.visible && !Qt.inputMethod.visible) {
                    passwordInput.focus = false;
                }
            }
        }
    }
}
