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
import LightDM 0.1 as LightDM

Showable {
    id: root

    // Determine if a numeric or alphanumeric pad is used.
    property bool alphaNumeric: false

    // Placeholder text
    property string placeholderText: ""

    // In case the Lockscreen can show a greeter message, this is the username
    property string username: ""

    // As the numeric PIN pad doesn't have a OK button by design, we need to auto-confirm on a certain length.
    // This is ignored by the alphaNumeric lockscreen as that one is confirmed with pressing enter on the OSK.
    property int pinLength: 4

    property url background: ""

    signal unlocked()
    signal cancel()
    signal emergencyCall()

    onRequiredChanged: {
        if (required) {
            pinPadLoader.item.clear(false);
        }
    }

    function reset() {
        // This causes the loader below to destry and recreate the source
        pinPadLoader.resetting = true;
        pinPadLoader.resetting = false;
    }

    Image {
        anchors.fill: parent
        source: root.required ? root.background : ""
    }

    MouseArea {
        anchors.fill: root
    }

    Loader {
        id: pinPadLoader
        objectName: "pinPadLoader"
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: root.alphaNumeric ? -units.gu(10) : 0
        }
        property bool resetting: false

        source: (!resetting && root.required) ? (root.alphaNumeric ? "PassphraseLockscreen.qml" : "PinLockscreen.qml") : ""

        Connections {
            target: pinPadLoader.item

            onEntered: {
                LightDM.Greeter.respond(passphrase);
            }

            onCancel: {
                root.cancel()
            }
        }

        Binding {
            target: pinPadLoader.item
            property: "pinLength"
            value: root.pinLength
        }
        Binding {
            target: pinPadLoader.item
            property: "placeholderText"
            value: root.placeholderText
        }
        Binding {
            target: pinPadLoader.item
            property: "username"
            value: root.username
        }
    }

    Column {
        anchors {
            left: parent.left
            top: pinPadLoader.bottom
            topMargin: units.gu(4)
            right: parent.right
            bottom: parent.bottom
        }
        spacing: units.gu(1)

        Icon {
            objectName: "emergencyCallIcon"
            height: units.gu(3)
            width: height
            anchors.horizontalCenter: parent.horizontalCenter
            name: "phone-app-call-symbolic"
            color: "white"
            opacity: 0.9

            MouseArea {
                anchors.fill: parent
                onClicked: root.emergencyCall()
            }
        }

        Label {
            text: i18n.tr("Emergency call")
            color: "white"
            opacity: 0.9
            fontSize: "medium"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Connections {
        target: LightDM.Greeter

        onAuthenticationComplete: {
            if (LightDM.Greeter.promptless) {
                return;
            }
            if (LightDM.Greeter.authenticated) {
                root.unlocked();
            } else {
                pinPadLoader.item.clear(true);
            }
        }
    }
}
