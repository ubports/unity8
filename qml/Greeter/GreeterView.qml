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
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12
import Ubuntu.Components 1.3
import Ubuntu.Telephony 0.1 as Telephony
import "../Components"

FocusScope {
    id: root
    objectName: "GreeterView"

    focus: true

    property url background
    property real backgroundSourceSize
    property real panelHeight
    property bool hasCustomBackground
    property alias dragHandleLeftMargin: coverPage.dragHandleLeftMargin
    property var infographicModel
    property alias launcherOffset: coverPage.launcherOffset
    property alias currentIndex: loginList.currentIndex
    property alias delayMinutes: delayedLockscreen.delayMinutes // TODO
    property alias alphanumeric: loginList.alphanumeric
    property alias hasKeyboard: loginList.hasKeyboard
    property bool locked
    property bool waiting
    property var userModel // Set from outside
    property bool multiUser: false
    property int orientation
    property bool isLandscape: root.orientation == Qt.LandscapeOrientation ||
                               root.orientation == Qt.InvertedLandscapeOrientation ||
                               usageMode == "desktop"
    property bool isPortrait: (root.orientation == Qt.PortraitOrientation ||
                              root.orientation == Qt.InvertedPortraitOrientation) &&
                              usageMode != "desktop"

    property string usageMode

    readonly property bool animating: coverPage.showAnimation.running || coverPage.hideAnimation.running
    readonly property bool fullyShown: coverPage.showProgress === 1 || lockscreen.shown
    readonly property bool required: coverPage.required || lockscreen.required
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
        coverPage.show();
    }

    function tryToUnlock(toTheRight) {
        var coverChanged = coverPage.shown;
        if (toTheRight) {
            coverPage.hideRight();
        } else {
            coverPage.hide();
        }
        if (root.locked) {
            lockscreen.show();
            loginList.tryToUnlock();
            return false;
        } else {
            root.responded("");
            return coverChanged;
        }
    }

    function hide() {
        lockscreen.hide();
        coverPage.hide();
    }

    function showFakePassword() {
        loginList.showFakePassword();
    }

    function showErrorMessage(msg) {
        coverPage.showErrorMessage(msg);
    }

    onLockedChanged: changeLockscreenState()
    onMultiUserChanged: changeLockscreenState()

    function changeLockscreenState() {
        if (locked || multiUser) {
            lockscreen.maybeShow();
        } else {
            lockscreen.hide();
        }
    }

    Keys.onSpacePressed: coverPage.hide();
    Keys.onReturnPressed: coverPage.hide();
    Keys.onEnterPressed: coverPage.hide();

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: lockscreen.showProgress * 0.8
    }

    CoverPage {
        id: lockscreen
        objectName: "lockscreen"
        height: parent.height
        width: parent.width
        draggable: false
        state: "LoginList"

        blurAreaHeight: loginList.highlightedHeight + units.gu(4.5)
        blurAreaWidth: loginList.width + units.gu(3)
        blurAreaX: loginList.x - units.gu(1.5)
        blurAreaY: loginList.boxVerticalOffset + loginList.y - units.gu(3)
        blurRadius: root.usageMode != "phone" && root.usageMode != "tablet" ? 64 : 0

        background: root.background
        backgroundSourceSize: root.backgroundSourceSize
        panelHeight: root.panelHeight
        hasCustomBackground: root.hasCustomBackground

        showInfographic: root.usageMode != "phone" && isLandscape && !delayedLockscreen.visible
        infographicModel: root.infographicModel

        shown: false
        opacity: 0

        showAnimation: StandardAnimation { property: "opacity"; to: 1 }
        hideAnimation: StandardAnimation { property: "opacity"; to: 0 }

        infographicsTopMargin: parent.height * 0.125
        infographicsBottomMargin: parent.height * 0.125
        infographicsLeftMargin: loginList.x + loginList.width

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
                top: parent.top
                bottom: parent.bottom
            }

            boxVerticalOffset: (height - highlightedHeight -
                               inputMethodRect.height) / 2
            Behavior on boxVerticalOffset { UbuntuNumberAnimation {} }

            enabled: !coverPage.shown && visible
            visible: !delayedLockscreen.visible

            model: root.userModel
            onResponded: root.responded(response)
            onSelected: root.selected(index)
            onSessionChooserButtonClicked: parent.state = "SessionsList"
            onCurrentIndexChanged: setCurrentSession()

            locked: root.locked
            waiting: root.waiting

            Keys.forwardTo: [sessionChooserLoader.item]

            Component.onCompleted: setCurrentSession()

            function setCurrentSession() {
                currentSession = LightDMService.users.data(currentIndex, LightDMService.userRoles.SessionRole);
            }
        }

        DelayedLockscreen {
            id: delayedLockscreen
            objectName: "delayedLockscreen"
            anchors.fill: parent
            visible: delayMinutes > 0
            alphaNumeric: loginList.alphanumeric
        }

        function maybeShow() {
            if ((root.locked || root.multiUser) && !shown) {
                showNow();
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
                    lockscreen.state = "LoginList"
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
                UbuntuNumberAnimation {
                    property: "opacity";
                }
            }
        ]

        Component.onCompleted: if (root.multiUser) showNow()
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
        background: root.background
        hasCustomBackground: root.hasCustomBackground
        panelHeight: root.panelHeight
        draggable: !root.waiting
        onTease: root.tease()
        onClicked: hide()
        backgroundSourceSize: root.backgroundSourceSize
        infographicModel: root.infographicModel

        showInfographic: !root.multiUser && (!isLandscape || root.usageMode == "phone")

        onShowProgressChanged: {
            if (showProgress === 0) {
                if (lockscreen.shown) {
                    loginList.tryToUnlock();
                } else {
                    root.responded("");
                }
            }
        }

        Clock {
            id: clock
            anchors.centerIn: parent
        }

        states: [
            State {
                name: "landscape-with-infographics"
                when: isLandscape && coverPage.showInfographic
                AnchorChanges {
                    target: clock
                    anchors.top: undefined
                    anchors.horizontalCenter: undefined
                    anchors.verticalCenter: undefined
                }
                PropertyChanges {
                    target: clock;
                    anchors.topMargin: undefined
                    anchors.centerIn: coverPage
                    anchors.horizontalCenterOffset: - coverPage.width / 2 + clock.width / 2 + units.gu(8)
                }
                PropertyChanges {
                    target: coverPage
                    infographicsLeftMargin: clock.width + units.gu(8)
                }
            },
            State {
                name: "portrait"
                when: isPortrait && coverPage.showInfographic
                AnchorChanges {
                    target: clock;
                    anchors.top: coverPage.top
                    anchors.horizontalCenter: coverPage.horizontalCenter
                    anchors.verticalCenter: undefined
                }
                PropertyChanges {
                    target: clock;
                    anchors.topMargin: units.gu(2) + panelHeight
                    anchors.centerIn: undefined
                    anchors.horizontalCenterOffset: 0
                }
                PropertyChanges {
                    target: coverPage
                    infographicsLeftMargin: 0
                }
            },
            State {
                name: "without-infographics"
                when: !coverPage.showInfographic
                AnchorChanges {
                    target: clock
                    anchors.top: undefined
                    anchors.horizontalCenter: coverPage.horizontalCenter
                    anchors.verticalCenter: coverPage.verticalCenter
                }
                PropertyChanges {
                    target: clock;
                    anchors.topMargin: 0
                    anchors.centerIn: undefined
                    anchors.horizontalCenterOffset: 0
                }
                PropertyChanges {
                    target: coverPage
                    infographicsLeftMargin: 0
                }
            }
        ]
    }

    StyledItem {
        id: bottomBar
        visible: usageMode == "phone" && lockscreen.shown
        height: units.gu(4)

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.bottom
        anchors.topMargin: - height * (1 - coverPage.showProgress)
                           - ( inputMethodRect.height )

        Label {
            text: i18n.tr("Cancel")
            anchors.left: parent.left
            anchors.leftMargin: units.gu(2)
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.Light
            fontSize: "small"
            color: theme.palette.normal.raisedSecondaryText

            AbstractButton {
                anchors.fill: parent
                anchors.leftMargin: -units.gu(2)
                anchors.rightMargin: -units.gu(2)
                onClicked: coverPage.show()
            }
        }

        Label {
            objectName: "emergencyCallLabel"
            text: callManager.hasCalls ? i18n.tr("Return to Call") : i18n.tr("Emergency")
            anchors.right: parent.right
            anchors.rightMargin: units.gu(2)
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.Light
            fontSize: "small"
            color: theme.palette.normal.raisedSecondaryText
            // TODO: uncomment once bug 1616538 is fixed
            // visible: telepathyHelper.ready && telepathyHelper.emergencyCallsAvailable
            enabled: visible

            AbstractButton {
                anchors.fill: parent
                anchors.leftMargin: -units.gu(2)
                anchors.rightMargin: -units.gu(2)
                onClicked: root.emergencyCall()
            }
        }
    }

    states: [
        State {
            name: "phone"
            when: root.usageMode == "phone" || (root.usageMode == "tablet" && isPortrait)
            AnchorChanges {
                target: loginList;
                anchors.horizontalCenter: lockscreen.horizontalCenter;
                anchors.left: undefined;
            }
            PropertyChanges {
                target: loginList;
                anchors.leftMargin: 0;
            }
        },
        State {
            name: "tablet"
            when: root.usageMode == "tablet" && isLandscape
            AnchorChanges {
                target: loginList;
                anchors.horizontalCenter: undefined;
                anchors.left: lockscreen.left;
            }
            PropertyChanges {
                target: loginList;
                anchors.leftMargin: Math.min(lockscreen.width * 0.16, units.gu(8));
            }
        },
        State {
            name: "desktop"
            when: root.usageMode == "desktop"
            AnchorChanges {
                target: loginList;
                anchors.horizontalCenter: undefined;
                anchors.left: lockscreen.left;
            }
            PropertyChanges {
                target: loginList;
                anchors.leftMargin: Math.min(lockscreen.width * 0.16, units.gu(20));
            }
        }
    ]
}
