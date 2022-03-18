/*
 * Copyright (C) 2016 Canonical, Ltd.
 * Copyright (C) 2021 Capsia <43005909+capsia37@users.noreply.github.com>
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

    property string text
    property bool isSecret
    property bool interactive: true
    property bool loginError: false
    property bool hasKeyboard: false
    property alias enteredText: passwordInput.text

    signal clicked()
    signal canceled()
    signal accepted(string response)

    StyledItem {
        id: d

        readonly property color textColor: passwordInput.enabled ? theme.palette.normal.raisedText
                                                                 : theme.palette.disabled.raisedText
        readonly property color selectedColor: passwordInput.enabled ? theme.palette.normal.raised
                                                                     : theme.palette.disabled.raised
        readonly property color drawColor: passwordInput.enabled ? theme.palette.normal.raisedSecondaryText
                                                                 : theme.palette.disabled.raisedSecondaryText
        readonly property color errorColor: passwordInput.enabled ? theme.palette.normal.negative
                                                                  : theme.palette.disabled.negative
    }

    Rectangle {
        anchors.fill: parent
        radius: units.gu(0.5)
        color: "#7A111111"
        Behavior on border.color {
            ColorAnimation{}
        }
        border {
            color: root.loginError ? d.errorColor : d.drawColor
            width: root.loginError ? units.dp(2): units.dp(1)
        }
    }

    TextField {
        id: passwordInput
        objectName: "promptField"
        anchors.fill: parent
        focus: root.focus

        opacity: fakeLabel.visible ? 0 : 1
        activeFocusOnTab: true

        onSelectedTextChanged: passwordInput.deselect()

        validator: RegExpValidator {
            regExp: /^.*$/
        }

        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText |
                          Qt.ImhMultiLine // so OSK doesn't close on Enter
        echoMode: root.isSecret ? TextInput.Password : TextInput.Normal
        hasClearButton: false

        passwordCharacter: "●"
        color: d.drawColor

        readonly property real frameSpacing: units.gu(1)

        style: StyledItem {
            anchors.fill: parent
            styleName: "FocusShape"

            // Properties needed by TextField
            readonly property color color: d.textColor
            readonly property color selectedTextColor: d.selectedColor
            readonly property color selectionColor: d.textColor
            readonly property color borderColor: "transparent"
            readonly property color backgroundColor: "transparent"
            readonly property color errorColor: d.errorColor
            readonly property real frameSpacing: styledItem.frameSpacing

            // Properties needed by FocusShape
            readonly property bool enabled: styledItem.enabled
            readonly property bool keyNavigationFocus: styledItem.keyNavigationFocus
            property bool activeFocusOnTab
        }

        secondaryItem: [
            Row {
                id: extraIcons
                spacing: passwordInput.frameSpacing
                anchors.verticalCenter: parent.verticalCenter
                Icon {
                    name: "keyboard-caps-enabled"
                    height: units.gu(3)
                    width: units.gu(3)
                    color: d.drawColor
                    visible: root.isSecret && false // TODO: detect when caps lock is on
                    anchors.verticalCenter: parent.verticalCenter
                }
                Icon {
                    objectName: "greeterPromptKeyboardButton"
                    name: "input-keyboard-symbolic"
                    height: units.gu(3)
                    width: units.gu(3)
                    color: d.drawColor
                    visible: !unity8Settings.alwaysShowOsk && root.hasKeyboard
                    anchors.verticalCenter: parent.verticalCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: unity8Settings.alwaysShowOsk = true
                    }
                }
                Icon {
                    name: "dialog-warning-symbolic"
                    height: units.gu(3)
                    width: units.gu(3)
                    color: d.drawColor
                    visible: root.loginError
                    anchors.verticalCenter: parent.verticalCenter
                }
                Icon {
                    name: "toolkit_chevron-ltr_2gu"
                    height: units.gu(2.5)
                    width: units.gu(2.5)
                    color: d.drawColor
                    visible: !root.loginError
                    anchors.verticalCenter: parent.verticalCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.accepted(passwordInput.text)
                    }
                }
            }
        ]

        onDisplayTextChanged: {
            // We use onDisplayTextChanged instead of onTextChanged because
            // displayText changes after text and if we did this before it
            // updated, we would use the wrong displayText for fakeLabel.
            root.loginError = false;
        }

        onAccepted: respond()

        function respond() {
            if (root.interactive) {
                root.accepted(passwordInput.text);
            }
        }

        Keys.onEscapePressed: {
            root.canceled();
            event.accepted = true;
        }
    }

    // We use our own custom placeholder label instead of the standard
    // TextField one because the standard one hardcodes baseText as the
    // palette color, whereas we want raisedSecondaryText.
    Label {
        id: passwordHint
        objectName: "promptHint"
        anchors {
            left: passwordInput ? passwordInput.left : undefined
            right: passwordInput ? passwordInput.right : undefined
            verticalCenter: passwordInput ? passwordInput.verticalCenter  : undefined
            leftMargin: units.gu(2)
            rightMargin: anchors.leftMargin + extraIcons.width
        }
        text: root.text
        visible: passwordInput.text == "" && !passwordInput.inputMethodComposing
        enabled: visible
        color: d.drawColor
        elide: Text.ElideRight
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
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        anchors.left: parent ? parent.left : undefined
        anchors.right: parent ? parent.right : undefined
        anchors.leftMargin: passwordInput.frameSpacing * 2
        anchors.rightMargin: passwordInput.frameSpacing * 2 + extraIcons.width
        color: d.drawColor
        text: passwordInput.displayText
        visible: !root.interactive
        enabled: visible
    }
}
