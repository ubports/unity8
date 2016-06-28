/*
 * Copyright (C) 2013,2014,2015 Canonical, Ltd.
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
    y: units.gu(4)
    height: shakeContainer.height
    focus: true

    property string infoText
    property string errorText
    property bool entryEnabled: true
    property color foregroundColor: "#000000"

    readonly property string passphrase: pinentryField.text

    signal entered(string passphrase)
    signal cancel()

    function clear(playAnimation) {
        pinentryField.text = "";
        pinentryField.incorrectOverride = false;
        pinentryField.forceActiveFocus();
        if (playAnimation) {
            wrongPasswordAnimation.start();
        }
    }

    function showText(text) {
        pinentryField.text = text;
    }

    Column {
        id: shakeContainer
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: units.gu(2)

        Label {
            id: infoField
            objectName: "infoTextLabel"
            fontSize: "x-large"
            color: root.foregroundColor
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.infoText
        }

        FocusScope {
            id: entryContainer
            anchors { left: parent.left; right: parent.right; margins: units.gu(2) }
            height: units.gu(4)
            focus: true

            TextInput {
                id: pinentryField
                objectName: "pinentryField"
                focus: true

                property bool incorrectOverride: false

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: FontUtils.sizeToPixels("large")
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData |
                                  Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                color: root.foregroundColor
                cursorDelegate: Item {} // disable cursor
                onCursorPositionChanged: {
                    // And because we don't show the cursor, always position the
                    // cursor at the end of the string (so backspace works like
                    // the user expects, even if they've clicked on us and
                    // thus accidentally moved the cursor)
                    if (cursorPosition !== length) {
                        cursorPosition = length
                    }
                }
                clip: true

                // This is so that we can draw our own dots, for we want
                // complete control over the pixel sizes.  (The ubuntu font
                // has oddly sized password characters that don't scale right)
                opacity: 0

                // simulate being disabled, but without removing OSK focus
                maximumLength: root.entryEnabled ? 32767 : length

                onTextChanged: incorrectOverride = true

                onAccepted: {
                    if (pinentryField.text) {
                        root.entered(pinentryField.text);
                    }
                }
            }

            Row {
                id: dotRow
                anchors.centerIn: entryContainer

                property real dotSize: Math.min(units.gu(2), entryContainer.width / pinentryField.length)
                spacing: Math.min(units.gu(2), Math.max(0, (entryContainer.width / pinentryField.length) - dotSize))

                Repeater {
                    model: pinentryField.length
                    delegate: Rectangle {
                        color: root.foregroundColor
                        width: dotRow.dotSize
                        height: width
                        radius: width / 2
                    }
                }
            }

            Label {
                id: wrongNoticeLabel
                objectName: "wrongNoticeLabel"
                fontSize: "large"
                color: root.foregroundColor
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.errorText
                visible: pinentryField.text.length == 0 && !pinentryField.incorrectOverride
            }
        }
    }

    WrongPasswordAnimation {
        id: wrongPasswordAnimation
        objectName: "wrongPasswordAnimation"
        target: shakeContainer
    }
}
