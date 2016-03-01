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
import Ubuntu.Components.Popups 1.3
import Ubuntu.Telephony 0.1 as Telephony

Showable {
    id: root

    // Determine if a numeric or alphanumeric pad is used.
    property bool alphaNumeric: false

    // Whether to show an emergency call button
    property bool showEmergencyCallButton: true

    // Whether to show a cancel button (not all lockscreen types normally do anyway)
    property bool showCancelButton: true

    // Informational text. (e.g. some text to tell which domain this is pin is entered for)
    property string infoText: ""

    // Retries text (e.g. 3 retries left)
    // (This is not currently used, but will be necessary for SIM unlock screen)
    property string retryText: ""

    // The text to be displayed in case the login failed
    property string errorText: ""

    // If > 0, a forced delay is happening
    property int delayMinutes: 0

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

    property url background: ""
    // Use this to put a black overlay above the background
    // 0: normal background, 1: black background
    property real darkenBackground: 0

    property color foregroundColor: "#f3f3e7"

    readonly property string passphrase: (pinPadLoader.item && pinPadLoader.item.passphrase) ? pinPadLoader.item.passphrase : ""

    signal entered(string passphrase)
    signal cancel()
    signal emergencyCall()
    signal infoPopupConfirmed()

    onActiveFocusChanged: if (activeFocus && pinPadLoader.item) pinPadLoader.item.forceActiveFocus()

    function reset() {
        // This causes the loader below to destry and recreate the source
        pinPadLoader.resetting = true;
        pinPadLoader.resetting = false;
    }

    function clear(showAnimation) {
        if (pinPadLoader.item) {
            pinPadLoader.item.clear(showAnimation);
        }
        pinPadLoader.showWrongText = showAnimation
        pinPadLoader.waiting = false
    }

    function showInfoPopup(title, text) {
        var popup = PopupUtils.open(infoPopupComponent, root, {title: title, text: text})
        // FIXME: SDK will do this internally soonish
        popup.z = Number.MAX_VALUE
    }

    Rectangle {
        // In case background fails to load
        id: backgroundBackup
        anchors.fill: parent
        color: "black"
        visible: root.background.toString() !== ""
    }

    Image {
        id: backgroundImage
        objectName: "lockscreenBackground"
        anchors {
            fill: parent
        }
        // Limit how much memory we'll reserve for this image
        sourceSize.height: height
        sourceSize.width: width
        source: root.required ? root.background : ""
        fillMode: Image.PreserveAspectCrop
    }

    // This is to
    // a) align it with the greeter and
    // b) keep the white fonts readable on bright backgrounds
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.darkenBackground
    }

    Loader {
        id: pinPadLoader
        objectName: "pinPadLoader"
        anchors.fill: parent
        property bool resetting: false
        property bool waiting: false
        property bool showWrongText: false
        focus: true

        source: {
            if (resetting || !root.required) {
                return ""
            } else if (root.delayMinutes > 0) {
                return "DelayedLockscreen.qml"
            } else if (root.alphaNumeric) {
                return "PassphraseLockscreen.qml"
            } else {
                return "PinLockscreen.qml"
            }
        }
        onSourceChanged: {
            waiting = false
            showWrongText = false
        }

        Connections {
            target: pinPadLoader.item

            onEntered: {
                pinPadLoader.waiting = true
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
            property: "infoText"
            value: root.infoText
        }
        Binding {
            target: pinPadLoader.item
            property: "retryText"
            value: root.retryText
        }
        Binding {
            target: pinPadLoader.item
            property: "errorText"
            value: pinPadLoader.showWrongText ? root.errorText : ""
        }
        Binding {
            target: pinPadLoader.item
            property: "entryEnabled"
            value: !pinPadLoader.waiting
        }
        Binding {
            target: pinPadLoader.item
            property: "alphaNumeric"
            value: root.alphaNumeric
        }
        Binding {
            target: pinPadLoader.item
            property: "delayMinutes"
            value: root.delayMinutes
        }
        Binding {
            target: pinPadLoader.item
            property: "showCancelButton"
            value: root.showCancelButton
        }
        Binding {
            target: pinPadLoader.item
            property: "foregroundColor"
            value: root.foregroundColor
        }
    }

    Item {
        id: emergencyCallRow

        visible: showEmergencyCallButton

        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(7) + (Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0)
            left: parent.left
            right: parent.right
        }

        Label {
            id: emergencyCallLabel
            objectName: "emergencyCallLabel"
            anchors.horizontalCenter: parent.horizontalCenter

            text: callManager.hasCalls ? i18n.tr("Return to Call") : i18n.tr("Emergency Call")
            color: root.foregroundColor
        }

        Icon {
            id: emergencyCallIcon
            anchors.left: emergencyCallLabel.right
            anchors.leftMargin: units.gu(1)
            width: emergencyCallLabel.height
            height: emergencyCallLabel.height
            name: "call-start"
            color: root.foregroundColor
        }

        MouseArea {
            anchors.top: emergencyCallLabel.top
            anchors.bottom: emergencyCallLabel.bottom
            anchors.left: emergencyCallLabel.left
            anchors.right: emergencyCallIcon.right
            onClicked: root.emergencyCall()
        }
    }

    Component {
        id: infoPopupComponent
        Dialog {
            id: dialog
            objectName: "infoPopup"
            modal: true

            Button {
                objectName: "infoPopupOkButton"
                text: i18n.tr("OK")
                onClicked: {
                    PopupUtils.close(dialog)
                    root.infoPopupConfirmed();
                }
            }
        }
    }
}
