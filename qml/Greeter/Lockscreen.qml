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
import Ubuntu.Components 1.0
import Ubuntu.Components.Popups 1.0
import "../Components"

Showable {
    id: root

    // Determine if a numeric or alphanumeric pad is used.
    property bool alphaNumeric: false

    // Placeholder text
    property string placeholderText: ""

    // Informational text. (e.g. some text to tell which domain this is pin is entered for.
    property string infoText: ""

    // In case the Lockscreen can show a greeter message, this is the username
    property string username: ""

    // Set those to a value greater 0 to restrict the pin length.
    // If both are unset, the Lockscreen will show a confirm button and allow typing any length of pin before
    // confirming. If minPinLength is set to a value > 0, the confirm button will only become active when the
    // entered pin is at least that long. If maxPinLength is set, the lockscreen won't allow entering any
    // more numbers than that. If both are set to the same value, the lockscreen will enter auto confirming
    // behavior, hiding the confirmation button and triggering that automatically when the entered pin reached
    // that length. This is ignored by the alphaNumeric lockscreen as that one is always confirmed by pressing
    // enter on the OSK.
    property int minPinLength: -1
    property int maxPinLength: -1

    // Set this to a value greater 0 to show a label telling the user how many retries are left
    property int retryCount: -1

    property url background: ""

    signal entered(string passphrase)
    signal cancel()
    signal emergencyCall()

    onRequiredChanged: {
        if (required && pinPadLoader.item) {
            pinPadLoader.item.clear(false);
        }
    }

    function reset() {
        // This causes the loader below to destry and recreate the source
        pinPadLoader.resetting = true;
        pinPadLoader.resetting = false;
    }

    function clear(showAnimation) {
        pinPadLoader.item.clear(showAnimation);
    }

    function showInfoPopup(title, text) {
        PopupUtils.open(infoPopupComponent, root, {title: title, text: text})
    }

    Rectangle {
        // In case background fails to load or is undefined
        id: backgroundBackup
        anchors.fill: parent
        color: "black"
    }

    Image {
        id: backgroundImage
        objectName: "lockscreenBackground"
        anchors {
            fill: parent
        }
        source: root.required ? root.background : ""
        fillMode: Image.PreserveAspectCrop
    }

    MouseArea {
        anchors.fill: root
    }

    Column {
        spacing: units.gu(2)
        anchors {
            left: parent.left
            right: parent.right
            bottom: pinPadLoader.top
            bottomMargin: units.gu(2)
        }
        Label {
            objectName: "retryCountLabel"
            anchors {
                left: parent.left
                right: parent.right
            }
            text: i18n.tr("%1 retry remaining", "%1 retries remaining", root.retryCount).arg(root.retryCount)
            horizontalAlignment: Text.AlignHCenter
            color: "#f3f3e7"
            opacity: 0.6
            visible: root.retryCount >= 0
        }
        Label {
            id: infoTextLabel
            objectName: "infoTextLabel"
            anchors {
                left: parent.left
                right: parent.right
            }
            text: root.infoText
            horizontalAlignment: Text.AlignHCenter
            color: "#f3f3e7"
            opacity: 0.6
            visible: root.infoText.length > 0
        }
    }



    Loader {
        id: pinPadLoader
        objectName: "pinPadLoader"
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: root.alphaNumeric ? -units.gu(10) : -units.gu(4)
        }
        property bool resetting: false

        source: (!resetting && root.required) ? (root.alphaNumeric ? "PassphraseLockscreen.qml" : "PinLockscreen.qml") : ""

        Connections {
            target: pinPadLoader.item

            onEntered: {
                root.entered(passphrase);
            }

            onCancel: {
                root.cancel()
            }
        }

        Binding {
            target: pinPadLoader.item
            property: "minPinLength"
            value: root.minPinLength
        }
        Binding {
            target: pinPadLoader.item
            property: "maxPinLength"
            value: root.maxPinLength
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
            bottom: parent.bottom
            bottomMargin: units.gu(4)
            right: parent.right
        }
        height: childrenRect.height
        spacing: units.gu(1)

        Icon {
            objectName: "emergencyCallIcon"
            height: units.gu(3)
            width: height
            anchors.horizontalCenter: parent.horizontalCenter
            name: "phone-app-call-symbolic"
            color: "#f3f3e7"
            opacity: 0.6

            MouseArea {
                anchors.fill: parent
                onClicked: root.emergencyCall()
            }
        }

        Label {
            text: i18n.tr("Emergency Call")
            color: "#f3f3e7"
            opacity: 0.6
            fontSize: "medium"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Component {
        id: infoPopupComponent
        Dialog {
            id: dialog
            objectName: "infoPopup"

            Button {
                objectName: "infoPopupOkButton"
                text: i18n.tr("OK")
                onClicked: PopupUtils.close(dialog)
            }
        }
    }
}
