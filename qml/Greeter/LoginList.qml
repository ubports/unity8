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
import "../Components"

Item {
    id: root

    property alias model: userList.model
    property bool alphanumeric: true
    property int currentIndex
    property bool locked

    readonly property int numAboveBelow: 4
    readonly property int cellHeight: units.gu(5)
    readonly property int highlightedHeight: units.gu(10)
    readonly property int moveDuration: 200
    readonly property string currentUser: userList.currentItem.username
    property bool wasPrompted: false

    signal selected(int index)
    signal responded(string response)
    signal promptlessLogin()

    function tryToUnlock() {
        if (wasPrompted) {
            passwordInput.forceActiveFocus();
        } else {
            if (root.locked) {
                root.selected(currentIndex);
            } else {
                promptlessLogin();
                root.responded("");
            }
        }
    }

    function showMessage(html) {
        if (infoLabel.text === "") {
            infoLabel.text = html;
        } else {
            infoLabel.text += "<br>" + html;
        }
    }

    function showPrompt(text, isSecret, isDefaultPrompt) {
        passwordInput.text = "";
        passwordInput.promptText = text;
        passwordInput.enabled = true;
        passwordInput.echoMode = isSecret ? TextInput.Password : TextInput.Normal;
        if (wasPrompted) // stay in text field if second prompt
            passwordInput.focus = true;
        wasPrompted = true;
    }

    function showError() {
        wrongPasswordAnimation.start();
        root.resetAuthentication();
        if (wasPrompted) {
            passwordInput.focus = true;
        }
    }

    function reset() {
        root.resetAuthentication();
    }

    Keys.onEscapePressed: {
        selected(currentIndex);
    }

    onCurrentIndexChanged: {
        userList.currentIndex = currentIndex;
    }

    Rectangle {
        id: highlightItem
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: root.highlightedHeight
        color: Qt.rgba(0.1, 0.1, 0.1, 0.4)
        border.color: Qt.rgba(0.4, 0.4, 0.4, 0.4)
        border.width: units.dp(1)
        radius: units.gu(1.5)
        antialiasing: true
    }

    ListView {
        id: userList
        objectName: "userList"

        anchors.fill: parent

        preferredHighlightBegin: userList.height / 2 - root.highlightedHeight / 2
        preferredHighlightEnd: userList.height / 2 - root.highlightedHeight / 2
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: root.moveDuration
        flickDeceleration: 10000

        readonly property bool movingInternally: moveTimer.running || userList.moving
        onMovingInternallyChanged: {
            if (!movingInternally) {
                root.selected(currentIndex);
            }
        }

        onCurrentIndexChanged: {
            root.resetAuthentication();
            moveTimer.start();
        }

        delegate: Item {
            width: parent.width
            height: root.cellHeight

            readonly property bool belowHighlight: (userList.currentIndex < 0 && index > 0) || (userList.currentIndex >= 0 && index > userList.currentIndex)
            readonly property int belowOffset: root.highlightedHeight - root.cellHeight
            readonly property string username: name

            opacity: {
                // The goal here is to make names less and less opaque as they
                // leave the highlight area.  Can't simply use index, because
                // that can change quickly if the user clicks at edges of
                // list.  So we use actual pixel distance.
                var highlightDist = 0;
                var realY = y - userList.contentY;
                if (belowHighlight)
                    realY += belowOffset;
                if (realY + height <= highlightItem.y)
                    highlightDist = realY + height - highlightItem.y;
                else if (realY >= highlightItem.y + root.highlightedHeight)
                    highlightDist = realY - highlightItem.y - root.highlightedHeight;
                else
                    return 1;
                return 1 - Math.min(1, (Math.abs(highlightDist) + root.cellHeight) / ((root.numAboveBelow + 1) * root.cellHeight))
            }

            Label {
                objectName: "username" + index

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                    top: parent.top
                    // Add an offset to topMargin for any items below the highlight
                    topMargin: units.gu(1) + (parent.belowHighlight ? parent.belowOffset : 0)
                }
                text: realName
                color: "white"
                elide: Text.ElideRight

                Behavior on anchors.topMargin { NumberAnimation { duration: root.moveDuration; easing.type: Easing.InOutQuad; } }
            }

            MouseArea {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    // Add an offset to topMargin for any items below the highlight
                    topMargin: parent.belowHighlight ? parent.belowOffset : 0
                }
                height: parent.height
                enabled: userList.currentIndex !== index && parent.opacity > 0
                onClicked: root.selected(index)

                Behavior on anchors.topMargin { NumberAnimation { duration: root.moveDuration; easing.type: Easing.InOutQuad; } }
            }
        }

        // This is needed because ListView.moving is not true if the ListView
        // moves because of an internal event (e.g. currentIndex has changed)
        Timer {
            id: moveTimer
            running: false
            repeat: false
            interval: root.moveDuration
        }
    }

    Label {
        id: infoLabel
        objectName: "infoLabel"
        anchors {
            bottom: passwordInput.top
            left: parent.left
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
            leftMargin: units.gu(2)
            rightMargin: units.gu(1)
        }

        color: "white"
        width: root.width - anchors.leftMargin - anchors.rightMargin
        fontSize: "small"
        textFormat: Text.StyledText
        clip: true

        opacity: (userList.movingInternally || text == "") ? 0 : 1
        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    TextField {
        id: passwordInput
        objectName: "passwordInput"
        anchors {
            bottom: highlightItem.bottom
            horizontalCenter: parent.horizontalCenter
            margins: units.gu(1)
        }
        height: units.gu(4.5)
        width: parent.width - anchors.margins * 2
        opacity: userList.movingInternally ? 0 : 1

        inputMethodHints: root.alphanumeric ? Qt.ImhNone : Qt.ImhDigitsOnly

        property string promptText
        placeholderText: root.wasPrompted ? promptText
                                          : (root.locked ? i18n.tr("Retry")
                                                         : i18n.tr("Tap to unlock"))

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }

        onAccepted: {
            if (!enabled)
                return;
            root.focus = true; // so that it can handle Escape presses for us
            enabled = false;
            root.responded(text);
        }
        Keys.onEscapePressed: {
            root.selected(currentIndex);
        }

        Image {
            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }
            visible: !root.wasPrompted
            source: "graphics/icon_arrow.png"
        }

        WrongPasswordAnimation {
            id: wrongPasswordAnimation
            target: passwordInput
        }

        Connections {
            target: Qt.inputMethod
            onVisibleChanged: {
                if (!Qt.inputMethod.visible) {
                    passwordInput.focus = false;
                }
            }
        }

    }

    MouseArea {
        id: passwordMouseArea
        objectName: "passwordMouseArea"
        anchors.fill: passwordInput
        enabled: !root.wasPrompted
        onClicked: root.tryToUnlock()
    }

    function resetAuthentication() {
        if (!userList.currentItem) {
            return;
        }
        infoLabel.text = "";
        passwordInput.promptText = "";
        passwordInput.text = "";
        passwordInput.focus = false;
        passwordInput.enabled = true;
        root.wasPrompted = false;
    }
}
