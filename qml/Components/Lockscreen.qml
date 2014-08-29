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

Showable {
    id: root

    // Determine if a numeric or alphanumeric pad is used.
    property bool alphaNumeric: false

    // Informational text. (e.g. some text to tell which domain this is pin is entered for)
    property string infoText: ""

    // Retries text (e.g. 3 retries left)
    property string retryText: ""

    // The text to be displayed in case the login failed
    property string errorText: ""

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

    property url background: ""

    signal entered(string passphrase)
    signal cancel()
    signal emergencyCall()
    signal infoPopupConfirmed()

    onRequiredChanged: {
        if (required && pinPadLoader.item) {
            clear(false)
        }
    }

    function forceDelay(delay) {
        forcedDelayTimer.interval = delay
        forcedDelayTimer.start()
    }

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

    Timer {
        id: forcedDelayTimer
        onTriggered: pinPadLoader.showWrongText = false
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
        property bool waiting: false
        property bool showWrongText: false

        source: (!resetting && root.required) ? (root.alphaNumeric ? "PassphraseLockscreen.qml" : "PinLockscreen.qml") : ""
        onSourceChanged: {
            waiting = false
            showWrongText = false
        }
        onLoaded: {
            if (forcedDelayTimer.running) {
                pinPadLoader.item.clear(true)
            }
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
            value: forcedDelayTimer.running ? i18n.tr("Please wait") : root.retryText
        }
        Binding {
            target: pinPadLoader.item
            property: "errorText"
            value: forcedDelayTimer.running ? i18n.tr("Too many incorrect attempts") :
                                              (pinPadLoader.showWrongText ? root.errorText : "")
        }
        Binding {
            target: pinPadLoader.item
            property: "username"
            value: root.username
        }
        Binding {
            target: pinPadLoader.item
            property: "entryEnabled"
            value: !pinPadLoader.waiting && !forcedDelayTimer.running
        }
    }

    Label {
        id: emergencyCallLabel
        objectName: "emergencyCallLabel"

        // FIXME: We *should* show emergency dialer if there is a SIM present,
        // regardless of whether the side stage is enabled.  But right now,
        // the assumption is that narrow screens are phones which have SIMs
        // and wider screens are tablets which don't.  When we do allow this
        // on devices with a side stage and a SIM, work should be done to
        // ensure that the main stage is disabled while the dialer is present
        // in the side stage.
        visible: !shell.sideStageEnabled

        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(4)
            horizontalCenter: parent.horizontalCenter
        }

        text: i18n.tr("Emergency Call")
        color: "#f3f3e7"
        opacity: 0.6
    }

    MouseArea {
        anchors.fill: emergencyCallLabel
        onClicked: root.emergencyCall()
        enabled: emergencyCallLabel.visible
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
