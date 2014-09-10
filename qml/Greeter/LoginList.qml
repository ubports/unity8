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
import LightDM 0.1 as LightDM
import "../Components"

Item {
    id: root

    property alias userList: userList
    property alias model: userList.model
    property alias currentIndex: userList.currentIndex

    readonly property int numAboveBelow: 4
    readonly property int cellHeight: units.gu(5)
    readonly property int highlightedHeight: units.gu(10)
    readonly property int moveDuration: 200
    property bool wasPrompted: false

    signal selected(int uid)
    signal unlocked(int uid)

    function tryToUnlock() {
        if (LightDM.Greeter.promptless) {
            if (LightDM.Greeter.authenticated) {
                root.unlocked(userList.currentIndex)
            } else {
                root.resetAuthentication()
            }
        } else {
            passwordInput.forceActiveFocus()
        }
    }

    function reset() {
        root.resetAuthentication()
    }

    Keys.onEscapePressed: root.resetAuthentication()

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

        onCurrentIndexChanged: {
            if (LightDM.Greeter.authenticationUser != userList.model.data(currentIndex, LightDM.UserRoles.NameRole)) {
                root.resetAuthentication();
            }
        }

        onMovingInternallyChanged: {
            // Only emit the selected signal once we stop moving to avoid frequent background changes
            if (!movingInternally) {
                root.selected(userList.currentIndex);
            }
        }

        delegate: Item {
            width: parent.width
            height: root.cellHeight

            readonly property bool belowHighlight: (userList.currentIndex < 0 && index > 0) || (userList.currentIndex >= 0 && index > userList.currentIndex)
            readonly property int belowOffset: root.highlightedHeight - root.cellHeight

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
                enabled: userList.currentIndex !== index
                onClicked: {
                    moveTimer.start();
                    userList.currentIndex = index;
                }

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

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }

        onAccepted: {
            if (text == "") return; // Might be useful anyway, but mainly workaround for LP 1324159
            if (!enabled)
                return;
            root.focus = true; // so that it can handle Escape presses for us
            enabled = false;
            LightDM.Greeter.respond(text);
        }
        Keys.onEscapePressed: root.resetAuthentication()

        Image {
            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }
            visible: LightDM.Greeter.promptless
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
        anchors.fill: passwordInput
        enabled: LightDM.Greeter.promptless
        onClicked: root.tryToUnlock()
    }

    function resetAuthentication() {
        if (!userList.currentItem) {
            return;
        }
        infoLabel.text = "";
        passwordInput.placeholderText = "";
        passwordInput.text = "";
        passwordInput.focus = false;
        passwordInput.enabled = true;
        root.wasPrompted = false;
        LightDM.Greeter.authenticate(userList.model.data(currentIndex, LightDM.UserRoles.NameRole));
    }

    Connections {
        target: LightDM.Greeter

        onShowMessage: {
            // inefficient, but we only rarely deal with messages
            var html = text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\n/g, "<br>")
            if (isError)
                html = "<font color=\"#df382c\">" + html + "</font>"
            if (infoLabel.text == "")
                infoLabel.text = html
            else
                infoLabel.text = infoLabel.text + "<br>" + html
        }

        onShowPrompt: {
            passwordInput.text = "";
            passwordInput.placeholderText = text;
            passwordInput.enabled = true;
            passwordInput.echoMode = isSecret ? TextInput.Password : TextInput.Normal;
            if (root.wasPrompted) // stay in text field if second prompt
                passwordInput.focus = true;
            root.wasPrompted = true;
        }

        onAuthenticationComplete: {
            if (LightDM.Greeter.promptless) {
                passwordInput.placeholderText = LightDM.Greeter.authenticated ? "Tap to unlock" : "Retry";
                return;
            }
            if (LightDM.Greeter.authenticated) {
                root.unlocked(userList.currentIndex);
            } else {
                wrongPasswordAnimation.start();
                root.resetAuthentication();
                passwordInput.focus = true;
            }
            passwordInput.text = "";
        }

        onRequestAuthenticationUser: {
            // Find index for requested user, if it exists
            for (var i = 0; i < userList.model.count; i++) {
                if (user == userList.model.data(i, LightDM.UserRoles.NameRole)) {
                    moveTimer.start();
                    userList.currentIndex = i;
                    return;
                }
            }
        }
    }
}
