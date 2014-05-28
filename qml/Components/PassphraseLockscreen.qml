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

Item {
    id: root
    height: highlightItem.height

    property string placeholderText
    property string wrongPlaceholderText
    property string username: ""

    signal entered(string passphrase)
    signal cancel()

    function clear(playAnimation) {
        pinentryField.text = "";
        if (playAnimation) {
            wrongPasswordAnimation.start();
        } else {
            pinentryField.focus = false
        }
    }

    Rectangle {
        id: highlightItem
        width: units.gu(32)
        height: units.gu(10)
        anchors.centerIn: parent
        color: Qt.rgba(0.1, 0.1, 0.1, 0.4)
        border.color: Qt.rgba(0.4, 0.4, 0.4, 0.4)
        border.width: units.dp(1)
        radius: units.gu(1.5)
        antialiasing: true

        Label {
            objectName: "greeterLabel"
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
                margins: units.gu(1.5)
            }
            text: root.username.length > 0 ? i18n.tr("Hello %1").arg(root.username) : i18n.tr("Hello")
            color: "white"
        }

        TextField {
            id: pinentryField
            objectName: "pinentryField"
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                margins: units.gu(1)
            }
            height: units.gu(4.5)
            width: parent.width - units.gu(2)
            echoMode: TextInput.Password
            opacity: 0.9
            hasClearButton: false
            placeholderText: wrongPasswordAnimation.running ? root.wrongPlaceholderText : root.placeholderText

            onAccepted: {
                if (pinentryField.text) {
                    root.entered(pinentryField.text);
                }
            }
        }
    }

    WrongPasswordAnimation {
        id: wrongPasswordAnimation
        objectName: "wrongPasswordAnimation"
        target: pinentryField
    }
}
