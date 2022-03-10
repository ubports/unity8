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
import Lomiri.Components 1.3
import "../Components"
import "." 0.1

StyledItem {
    id: root
    focus: true

    property alias model: userList.model
    property alias alphanumeric: promptList.alphanumeric
    property alias hasKeyboard: promptList.hasKeyboard
    property int currentIndex
    property bool locked
    property bool waiting
    property alias boxVerticalOffset: highlightItem.y
    property string _realName

    readonly property int numAboveBelow: 4
    readonly property int cellHeight: units.gu(5)
    readonly property int highlightedHeight: highlightItem.height
    readonly property int moveDuration: LomiriAnimation.FastDuration
    property string currentSession // Initially set by LightDM
    readonly property string currentUser: userList.currentItem.username

    readonly property alias currentUserIndex: userList.currentIndex

    signal responded(string response)
    signal selected(int index)
    signal sessionChooserButtonClicked()

    function tryToUnlock() {
        promptList.forceActiveFocus();
    }

    function showError() {
        promptList.loginError = true;
        wrongPasswordAnimation.start();
    }

    function showFakePassword() {
        promptList.interactive = false;
        promptList.showFakePassword();
    }

    theme: ThemeSettings {
        name: "Lomiri.Components.Themes.Ambiance"
    }

    Keys.onUpPressed: {
        if (currentIndex > 0) {
            selected(currentIndex - 1);
        }
        event.accepted = true;
    }
    Keys.onDownPressed: {
        if (currentIndex + 1 < model.count) {
            selected(currentIndex + 1);
        }
        event.accepted = true;
    }
    Keys.onEscapePressed: {
        selected(currentIndex);
        event.accepted = true;
    }

    onCurrentIndexChanged: {
        userList.currentIndex = currentIndex;
        promptList.loginError = false;
    }

    LoginAreaContainer {
        id: highlightItem
        objectName: "highlightItem"
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }

        height: Math.max(units.gu(15), promptList.height + units.gu(8))
        Behavior on height { NumberAnimation { duration: root.moveDuration; easing.type: Easing.InOutQuad; } }
    }

    ListView {
        id: userList
        objectName: "userList"

        anchors.fill: parent
        anchors.leftMargin: units.gu(2)
        anchors.rightMargin: units.gu(2)

        preferredHighlightBegin: highlightItem.y + units.gu(1.5)
        preferredHighlightEnd: highlightItem.y + units.gu(1.5)
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: root.moveDuration
        interactive: count > 1

        readonly property bool movingInternally: moveTimer.running || userList.moving

        onMovingChanged: if (!moving) root.selected(currentIndex)

        onCurrentIndexChanged: {
            moveTimer.start();
        }

        delegate: Item {
            width: userList.width
            height: root.cellHeight

            readonly property bool belowHighlight: (userList.currentIndex < 0 && index > 0) || (userList.currentIndex >= 0 && index > userList.currentIndex)
            readonly property bool aboveCurrent: (userList.currentIndex > 0 && index < 0) || (userList.currentIndex >= 0 && index < userList.currentIndex)
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

            Row {
                spacing: units.gu(1)
//                visible: userList.count != 1 // HACK Hide username label until someone sorts out the anchoring with the keyboard-dismiss animation, Work around https://github.com/ubports/unity8/issues/185

                anchors {
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.top
                    // Add an offset to bottomMargin for any items below the highlight
                    bottomMargin: -(units.gu(4) + (parent.belowHighlight ? parent.belowOffset : parent.aboveCurrent ? -units.gu(5) : 0))
                }

                Rectangle {
                    id: activeIndicator
                    anchors.verticalCenter: parent.verticalCenter
                    color: theme.palette.normal.raised
                    visible: userList.count > 1 && loggedIn
                    height: visible ? units.gu(0.5) : 0
                    width: height
                }

                Icon {
                    id: userIcon
                    name: "account"
                    height: userList.currentIndex === index ? units.gu(4.5) : units.gu(3)
                    width: height
                    color: theme.palette.normal.raisedSecondaryText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: units.gu(0.25)

                    FadingLabel {
                        objectName: "username" + index

                        text: userList.currentIndex === index
                              && name === "*other"
                              && LightDMService.greeter.authenticationUser !== ""
                              ?  LightDMService.greeter.authenticationUser : realName
                        color: userList.currentIndex !== index ? theme.palette.normal.raised
                                                               : theme.palette.normal.raisedSecondaryText
                        font.weight: userList.currentIndex === index ? Font.Normal : Font.Light
                        font.pointSize: units.gu(2)

                        width: highlightItem.width
                                && contentWidth > highlightItem.width - userIcon.width - units.gu(4)
                                    ? highlightItem.width - userIcon.width - units.gu(4)
                                    : contentWidth

                        Component.onCompleted: _realName = realName

                        Behavior on anchors.topMargin { NumberAnimation { duration: root.moveDuration; easing.type: Easing.InOutQuad; } }
                    }

                    Row {
                        spacing: units.gu(1)

                        FadingLabel {
                            text: root.alphanumeric ? "Login with password" : "Login with pin"
                            color: theme.palette.normal.raisedSecondaryText
                            visible: userList.currentIndex === index && false
                            font.weight: Font.Light
                            font.pointSize: units.gu(1.25)
                        }
                    }
                }
            }

            MouseArea {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    // Add an offset to topMargin for any items below the highlight
                    topMargin: parent.belowHighlight ? parent.belowOffset : parent.aboveCurrent ? -units.gu(5) : 0
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

    PromptList {
        id: promptList
        objectName: "promptList"
        anchors {
            bottom: highlightItem.bottom
            horizontalCenter: highlightItem.horizontalCenter
            margins: units.gu(2)
        }
        width: highlightItem.width - anchors.margins * 2

        focus: true

        onClicked: {
            interactive = false;
            if (root.locked) {
                root.selected(currentIndex);
            } else {
                root.responded("");
            }
        }
        onResponded: {
            interactive = false;
            root.responded(text);
        }
        onCanceled: {
            interactive = false;
            root.selected(currentIndex);
        }

        Connections {
            target: LightDMService.prompts
            onModelReset: promptList.interactive = true
        }
    }

    WrongPasswordAnimation {
        id: wrongPasswordAnimation
        objectName: "wrongPasswordAnimation"
        target: promptList
    }
}
