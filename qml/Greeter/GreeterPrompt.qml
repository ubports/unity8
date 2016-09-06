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
import "../Components"

FocusScope {
    id: root
    implicitHeight: units.gu(5)
    focus: true

    property bool isPrompt
    property bool isAlphanumeric
    property string text
    property bool isSecret

    signal clicked()
    signal canceled()
    signal responded(string text)

    function reset() {
        passwordInput.text = "";
        fakeLabel.text = "";
        d.enabled = true;
    }

    function showFakePassword() {
        // Just a silly hack for looking like 4 pin numbers got entered, if
        // a fingerprint was used and we happen to be using a pin.  This was
        // a request from Design.
        if (isSecret && isPrompt && !isAlphanumeric) {
            d.enabled = false;
            text = "...."; // actual text doesn't matter
        }
    }

    StyledItem {
        id: d

        property bool enabled: true
        readonly property color textColor: passwordInput.enabled ? theme.palette.normal.raisedText
                                                                 : theme.palette.disabled.raisedText
        readonly property color selectedColor: passwordInput.enabled ? theme.palette.normal.raised
                                                                     : theme.palette.disabled.raised
        readonly property color drawColor: passwordInput.enabled ? theme.palette.normal.raisedSecondaryText
                                                                 : theme.palette.disabled.raisedSecondaryText
        readonly property color errorColor: passwordInput.enabled ? theme.palette.normal.negative
                                                                  : theme.palette.disabled.negative

        onEnabledChanged: {
            if (!enabled) {
                fakeLabel.text = passwordInput.displayText;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        border.width: units.dp(1)
        border.color: d.drawColor
        radius: units.gu(0.5)
        color: "transparent"
    }

    Component.onCompleted: updateFocus()
    onIsPromptChanged: updateFocus()
    function updateFocus() {
        if (root.isPrompt) {
            passwordInput.focus = true;
        } else {
            promptButton.focus = true;
        }
    }

    AbstractButton {
        id: promptButton
        objectName: "promptButton"
        anchors.fill: parent
        visible: !root.isPrompt

        onClicked: {
            if (d.enabled) {
                d.enabled = false;
                root.clicked();
            }
        }

        Label {
            anchors.centerIn: parent
            color: d.textColor
            text: root.text
        }
    }

    TextField {
        id: passwordInput
        objectName: "promptField"
        anchors.fill: parent
        visible: root.isPrompt
        opacity: fakeLabel.visible ? 0 : 1

        validator: RegExpValidator {
            regExp: root.isAlphanumeric ? /^.*$/ : /^\d{4}$/
        }

        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText |
                          Qt.ImhMultiLine | // so OSK doesn't close on Enter
                          (root.isAlphanumeric ? Qt.ImhNone : Qt.ImhDigitsOnly)
        echoMode: root.isSecret ? TextInput.Password : TextInput.Normal
        hasClearButton: false

        readonly property real frameSpacing: units.gu(0.5)

        style: Item {
            property color color: d.textColor
            property color selectedTextColor: d.selectedColor
            property color selectionColor: d.textColor
            property color borderColor: "transparent"
            property color backgroundColor: "transparent"
            property color errorColor: d.errorColor
            property real frameSpacing: passwordInput.frameSpacing
            anchors.fill: parent
        }

        secondaryItem: [
            Icon {
                id: capsIcon
                name: "keyboard-caps-enabled"
                height: units.gu(3)
                width: units.gu(3)
                color: d.textColor
                visible: root.isSecret && false // TODO: detect when caps lock is on
                readonly property real visibleWidth: visible ? width + passwordInput.frameSpacing : 0
            }
        ]

        onDisplayTextChanged: {
            // We use onDisplayTextChanged instead of onTextChanged because
            // displayText changes after text and if we did this before it
            // updated, we would use the wrong displayText for fakeLabel.
            if (!isAlphanumeric && text.length >= 4) {
                // hard limit of 4 for passcodes right now
                respond();
            }
        }

        onAccepted: respond()

        function respond() {
            if (d.enabled) {
                d.enabled = false;
                root.responded(text);
            }
        }

        Keys.onEscapePressed: {
            root.canceled();
            event.accepted = true;
        }

        // We use our own custom placeholder label instead of the standard
        // TextField one because the standard one hardcodes baseText as the
        // palette color, whereas we want raisedSecondaryText.
        Label {
            id: hint
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: units.gu(1.5)
                rightMargin: anchors.leftMargin + capsIcon.visibleWidth
            }
            text: root.text
            visible: passwordInput.text == "" && !passwordInput.inputMethodComposing
            color: d.drawColor
            elide: Text.ElideRight
        }
    }

    // Have a fake label that covers the text field after the user presses
    // enter.  What we *really* want is a disabled mode that doesn't lose OSK
    // focus.  Because our goal here is simply to keep the OSK up while
    // we wait for PAM to get back to us, and while waiting, we don't want
    // the user to be able to edit the field (simply because it would look
    // weird if we allowed that).  But until we have such a disabled mode,
    // we'll fake it by covering the real text field with a label.
    FadingLabel {
        id: fakeLabel
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: passwordInput.frameSpacing * 2
        anchors.rightMargin: passwordInput.frameSpacing * 2 + capsIcon.visibleWidth
        color: d.drawColor
        visible: root.isPrompt && !d.enabled
    }
}
