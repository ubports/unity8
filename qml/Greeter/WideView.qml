/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
 * Copyright (C) 2021 UBports Foundation
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
import Lomiri.Components 1.3
import "." 0.1

FocusScope {
    id: root
    objectName: "WideView"

    focus: true

    property alias background: coverPage.background
    property alias backgroundSourceSize: coverPage.backgroundSourceSize
    property alias panelHeight: coverPage.panelHeight
    property alias hasCustomBackground: coverPage.hasCustomBackground
    property alias dragHandleLeftMargin: coverPage.dragHandleLeftMargin
    property alias infographicModel: coverPage.infographicModel
    property alias launcherOffset: coverPage.launcherOffset
    property alias currentIndex: loginList.currentIndex
    property int delayMinutes // TODO
    property alias alphanumeric: loginList.alphanumeric
    property alias hasKeyboard: loginList.hasKeyboard
    property alias locked: loginList.locked
    property alias waiting: loginList.waiting
    property var userModel // Set from outside

    readonly property bool animating: coverPage.showAnimation.running || coverPage.hideAnimation.running
    readonly property bool fullyShown: coverPage.showProgress === 1
    readonly property bool required: coverPage.required
    readonly property alias sessionToStart: loginList.currentSession

    property rect inputMethodRect

    signal selected(int index)
    signal responded(string response)
    signal tease()
    signal emergencyCall() // unused

    function notifyAuthenticationFailed() {
        loginList.showError();
    }

    function forceShow() {
        // Nothing to do, we are always fully shown
    }

    function tryToUnlock(toTheRight) {
        if (root.locked) {
            coverPage.show();
            loginList.tryToUnlock();
            return false;
        } else {
            var coverChanged = coverPage.shown;
            if (toTheRight) {
                coverPage.hideRight();
            } else {
                coverPage.hide();
            }
            return coverChanged;
        }
    }

    function hide() {
        coverPage.hide();
    }

    function showFakePassword() {
        loginList.showFakePassword();
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: coverPage.showProgress * 0.8
    }

    CoverPage {
        id: coverPage
        objectName: "coverPage"
        height: parent.height
        width: parent.width
        draggable: !root.locked && !root.waiting
        state: "LoginList"
        blurAreaHeight: loginList.highlightedHeight + units.gu(4.5)
        blurAreaWidth: loginList.width + units.gu(3)
        blurAreaX: loginList.x - units.gu(1.5)
        blurAreaY: loginList.boxVerticalOffset + loginList.y - units.gu(3)

        // Darken background to match CoverPage
        Rectangle {
            objectName: "lockscreenShade"
            anchors.fill: parent
            color: "black"
            opacity: root.hasCustomBackground ? 0.1 : 0
        }

        infographics {
            anchors.topMargin: parent.height * 0.125
            anchors.bottomMargin: parent.height * 0.125
            anchors.leftMargin: loginList.x + loginList.width
        }

        onTease: root.tease()

        onShowProgressChanged: {
            if (showProgress === 0 && !root.locked) {
                root.responded("");
            }
        }

        LoginList {
            id: loginList
            objectName: "loginList"

            width: units.gu(40)
            anchors {
                left: parent.left
                leftMargin: Math.min(parent.width * 0.16, units.gu(20))
                top: parent.top
                bottom: parent.bottom
            }

            boxVerticalOffset: (height - highlightedHeight -
                               inputMethodRect.height) / 2
            Behavior on boxVerticalOffset { LomiriNumberAnimation {} }

            model: root.userModel
            onResponded: root.responded(response)
            onSelected: root.selected(index)
            onSessionChooserButtonClicked: parent.state = "SessionsList"
            onCurrentIndexChanged: setCurrentSession()

            Keys.forwardTo: [sessionChooserLoader.item]

            Component.onCompleted: setCurrentSession()

            function setCurrentSession() {
                currentSession = LightDMService.users.data(currentIndex, LightDMService.userRoles.SessionRole);
            }
        }

        Loader {
            id: sessionChooserLoader

            height: loginList.height
            width: loginList.width

            anchors {
                left: parent.left
                leftMargin: Math.min(parent.width * 0.16, units.gu(20))
                top: parent.top
            }

            active: false

            onLoaded: sessionChooserLoader.item.forceActiveFocus();
            onActiveChanged: {
                if (!active) return;
                item.updateHighlight(loginList.currentSession);
            }

            Connections {
                target: sessionChooserLoader.item
                onSessionSelected: loginList.currentSession = sessionKey
                onShowLoginList: {
                    coverPage.state = "LoginList"
                    loginList.tryToUnlock();
                }
                ignoreUnknownSignals: true
            }
        }

        // Use an AbstractButton due to icon limitations with Button
        AbstractButton {
            id: sessionChooser
            objectName: "sessionChooserButton"

            readonly property url icon: LightDMService.sessions.iconUrl(loginList.currentSession)

            visible: LightDMService.sessions.count > 1 &&
                !LightDMService.users.data(loginList.currentUserIndex, LightDMService.userRoles.LoggedInRole)

            height: units.gu(3.5)
            width: units.gu(3.5)

            activeFocusOnTab: true
            anchors {
                right: parent.right
                rightMargin: units.gu(2)

                bottom: parent.bottom
                bottomMargin: units.gu(1.5)
            }

            Rectangle {
                id: badgeHighlight

                anchors.fill: parent
                visible: parent.activeFocus
                color: "transparent"
                border.color: theme.palette.normal.focus
                border.width: units.dp(1)
                radius: 3
            }

            Icon {
                id: badge
                anchors.fill: parent
                anchors.margins: units.dp(3)
                keyColor: "#ffffff" // icon providers give us white icons
                color: theme.palette.normal.raisedSecondaryText
                source: sessionChooser.icon
            }

            Keys.onReturnPressed: {
                parent.state = "SessionsList";
            }

            onClicked: {
                parent.state = "SessionsList";
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

        states: [
            State {
                name: "SessionsList"
                PropertyChanges { target: loginList; opacity: 0 }
                PropertyChanges { target: sessionChooserLoader;
                                  active: true;
                                  opacity: 1
                                  source: "SessionsList.qml"
                                }
            },

            State {
                name: "LoginList"
                PropertyChanges { target: loginList; opacity: 1 }
                PropertyChanges { target: sessionChooserLoader;
                                  active: false;
                                  opacity: 0
                                  source: "";
                                }
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "*"
                LomiriNumberAnimation {
                    property: "opacity";
                }
            }
        ]
    }
}
