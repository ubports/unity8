/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.3
import "../Components"
import "." 0.1

StyledItem {
    id: root

    property alias model: userList.model
    property bool alphanumeric: true
    property int currentIndex
    property bool locked

    readonly property int numAboveBelow: 4
    readonly property int cellHeight: units.gu(5)
    readonly property int highlightedHeight: units.gu(15)
    readonly property int moveDuration: 200
    property string selectedSession
    property string currentSession: selectedSession ?
        selectedSession : userList.currentItem.userSession
    readonly property string currentUser: userList.currentItem.username
    property bool wasPrompted: false

    signal loginListSessionChanged(string session)
    signal promptlessLogin()
    signal responded(string response)
    signal selected(int index)
    signal sessionChooserButtonClicked()

    onCurrentSessionChanged: loginListSessionChanged(currentSession)
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
        d.promptText = text;
        passwordInput.reset();
        passwordInput.isSecret = isSecret;
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

    QtObject {
        id: d

        property string promptText
    }

    theme: ThemeSettings {
        name: "Ubuntu.Components.Themes.Ambiance"
    }

    Keys.onEscapePressed: {
        selected(currentIndex);
    }

    onCurrentIndexChanged: {
        userList.currentIndex = currentIndex;
    }

    LoginAreaContainer {
        id: highlightItem
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        height: root.highlightedHeight
    }

    ListView {
        id: userList
        objectName: "userList"

        anchors.fill: parent
        anchors.leftMargin: units.gu(2)
        anchors.rightMargin: units.gu(2)

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
            readonly property string userSession: session
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

            FadingLabel {
                objectName: "username" + index

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                    bottom: parent.top
                    // Add an offset to bottomMargin for any items below the highlight
                    bottomMargin: -(units.gu(4) + (parent.belowHighlight ? parent.belowOffset : 0))
                }
                text: realName
                color: userList.currentIndex !== index ? theme.palette.normal.raised : theme.palette.normal.raisedText

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

    // Use an AbstractButton due to icon limitations with Button
    AbstractButton {
        id: sessionChooser
        objectName: "sessionChooserButton"

        readonly property alias icon: badge.source

        visible: LightDMService.sessions.count > 1 &&
            !LightDMService.greeter.locked

        height: units.gu(3)
        width: units.gu(3)

        anchors {
            right: highlightItem.right
            rightMargin: units.gu(2)

            top: highlightItem.top
            topMargin: units.gu(1.5)
        }

        Icon {
            id: badge
            anchors.fill: parent
            keyColor: "#ffffff" // icon providers give us white icons
            color: theme.palette.normal.raisedSecondaryText
            source: LightDMService.sessions.iconUrl(root.currentSession)
        }

        onClicked: {
            sessionChooserButtonClicked();
        }

        // Refresh the icon path if looking at different places at runtime
        // this is mainly for testing
        Connections {
            target: LightDMService.sessions
            onIconSearchDirectoriesChanged: {
                badge.source = LightDMService.sessions.iconUrl(root.currentSession)
            }
        }
    }

    FadingLabel {
        id: infoLabel
        objectName: "infoLabel"
        anchors {
            bottom: passwordInput.top
            left: highlightItem.left
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
            leftMargin: units.gu(2)
            rightMargin: units.gu(1)
        }

        color: theme.palette.normal.raisedText
        width: root.width - anchors.leftMargin - anchors.rightMargin
        fontSize: "small"
        textFormat: Text.StyledText

        opacity: (userList.movingInternally || text == "") ? 0 : 1
        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    GreeterPrompt {
        id: passwordInput
        objectName: "passwordInput"
        anchors {
            bottom: highlightItem.bottom
            horizontalCenter: highlightItem.horizontalCenter
            margins: units.gu(2)
        }
        width: highlightItem.width - anchors.margins * 2
        opacity: userList.movingInternally ? 0 : 1

        isPrompt: root.wasPrompted
        isAlphanumeric: root.alphanumeric

        text: root.wasPrompted ? d.promptText
                               : (root.locked ? i18n.tr("Retry")
                                              : i18n.tr("Log In"))

        onClicked: root.tryToUnlock()
        onResponded: root.responded(text)
        onCanceled: root.selected(currentIndex)

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }

        WrongPasswordAnimation {
            id: wrongPasswordAnimation
            target: passwordInput
        }
    }

    function resetAuthentication() {
        if (!userList.currentItem) {
            return;
        }
        infoLabel.text = "";
        d.promptText = "";
        passwordInput.reset();
        root.wasPrompted = false;
    }
}
