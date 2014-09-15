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
    anchors.top: parent.top
    anchors.topMargin: units.gu(4)
    height: shakeContainer.height

    property string infoText
    property string errorText
    property bool entryEnabled: true

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

    Column {
        id: shakeContainer
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: units.gu(2)

        Label {
            id: infoField
            objectName: "infoTextLabel"
            fontSize: "x-large"
            color: "#f3f3e7"
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.infoText
        }

        Item {
            id: entryContainer
            anchors { left: parent.left; right: parent.right; margins: units.gu(2) }
            height: units.gu(4)

            TextInput {
                id: pinentryField
                objectName: "pinentryField"

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
                color: "#f3f3e7"
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
                enabled: root.entryEnabled
                clip: true

                onTextChanged: incorrectOverride = true

                onActiveFocusChanged: if (!activeFocus) pinentryField.forceActiveFocus()
                onEnabledChanged: if (enabled) pinentryField.forceActiveFocus()

                onAccepted: {
                    if (pinentryField.text) {
                        root.entered(pinentryField.text);
                    }
                }
            }

            Label {
                id: wrongNoticeLabel
                objectName: "wrongNoticeLabel"
                fontSize: "large"
                color: "#f3f3e7"
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
