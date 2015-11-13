/*
 * Copyright (C) 2013,2015 Canonical, Ltd.
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
import MeeGo.QOfono 0.2
import Wizard 0.1

Item {
    readonly property real buttonMargin: units.gu(3)
    readonly property real buttonWidth: (width - buttonMargin * 2) / 2 -
                                        buttonMargin / 2
    readonly property real buttonBarHeight: units.gu(5)

    readonly property real topMargin: units.gu(11)
    readonly property real bottomMargin: units.gu(3)
    readonly property real leftMargin: units.gu(3)
    readonly property real rightMargin: units.gu(3)
    readonly property real customMargin: units.gu(4) // margin for the custom (w/o title image) pages

    // colors
    readonly property color backgroundColor: "#fdfdfd"
    readonly property color dividerColor: "#cdcdcd"
    readonly property color textColor: "#5d5d5d"
    readonly property color errorColor: "#e14141"
    readonly property color okColor: "#3fb24f"

    // If you want to skip a page, mark skipValid false while you figure out
    // whether to skip, then set it to true once you've determined the value
    // of the skip property.
    property bool skipValid: true
    property bool skip: false

    property bool mobileOnly: true
    property bool desktopOnly: false

    property bool hasBackButton: true
    property string backButtonText: i18n.ctr("Button: Go back one page in the Wizard", "Back")
    property bool customBack: false
    property bool customTitle: false
    property alias forwardButtonSourceComponent: forwardButton.sourceComponent
    property alias content: contentHolder
    property bool lastPage: false
    property bool buttonBarVisible: true

    property string title: ""

    signal backClicked()

    visible: false
    anchors.fill: parent

    property alias modemManager: modemManager
    property alias simManager0: simManager0
    property alias simManager1: simManager1

    OfonoManager { // need it here for the language and country detection
        id: modemManager
        readonly property bool gotSimCard: available && ((simManager0.ready && simManager0.present) || (simManager1.ready && simManager1.present))
        property bool ready: false
        onModemsChanged: {
            ready = true;
        }
        onAvailableChanged: {
            print("Modem manager available:", available);
        }
        onGotSimCardChanged: {
            print("Modem has a usable SIM CARD now:", gotSimCard);
        }
    }

    // Ideally we would query the system more cleverly than hardcoding two
    // sims.  But we don't yet have a more clever way.  :(
    OfonoSimManager {
        id: simManager0
        modemPath: modemManager.modems.length >= 1 ? modemManager.modems[0] : ""
        onPresentChanged: {
            print("SIM CARD 1 inserted!!!", present);
        }
    }

    OfonoSimManager {
        id: simManager1
        modemPath: modemManager.modems.length >= 2 ? modemManager.modems[1] : ""
        onPresentChanged: {
            print("SIM CARD 2 inserted!!!", present);
        }
    }

    Timer {
        id: indicatorTimer
        interval: 1000
        triggeredOnStart: true
        repeat: true
        running: System.wizardEnabled
        onTriggered: {
            indicatorTime.text = Qt.formatTime(new Date(), "h:mm")
        }
    }

    // page header
    Image {
        id: titleRect
        visible: !lastPage
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        source: customTitle ? "" : "Pages/data/Phone header bkg.png"
        height: customTitle ? units.gu(10) : units.gu(16)
        clip: true

        // page title
        Label {
            id: titleLabel
            property real animatedMargin: 0
            property real animatedTopMargin: 0
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: bottomMargin
                leftMargin: leftMargin + titleLabel.animatedMargin
                rightMargin: rightMargin
                topMargin: titleLabel.animatedTopMargin
            }
            text: title
            color: customTitle ? textColor : backgroundColor
            fontSize: customTitle ? "large" : "x-large"
            font.weight: Font.Light
        }

        // indicators
        Row {
            id: indicatorRow
            visible: !customTitle
            anchors {
                top: parent.top
                right: parent.right
                topMargin: units.gu(.5)
                rightMargin: units.gu(.5)
            }
            height: units.gu(2)
            spacing: units.gu(.5)

            Icon {
                id: indicatorSim
                anchors.verticalCenter: parent.verticalCenter
                name: "no-simcard"
                height: parent.height
                width: height
                visible: !(simManager0.present || simManager1.present)
                color: "white"
            }

            Icon {
                id: indicatorNet
                anchors.verticalCenter: parent.verticalCenter
                name: Status.networkIcon
                height: parent.height
                width: height
                color: "white"
            }

            Icon {
                id: indicatorBattery
                anchors.verticalCenter: parent.verticalCenter
                name: Status.batteryIcon
                height: parent.height
                width: height * 1.4 // the battery icon is not rectangular :/
                color: "white"
            }

            Label {
                id: indicatorTime
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                fontSize: "small"
            }
        }
    }

    // content
    Item {
        id: contentHolder
        property real animatedMargin: 0
        property real animatedTopMargin: 0
        anchors {
            top: titleRect.bottom
            left: parent.left
            right: parent.right
            bottom: buttonBarVisible ? buttonRect.top : parent.bottom
            leftMargin: content.animatedMargin
            rightMargin: -content.animatedMargin
            topMargin: content.animatedTopMargin
        }
        visible: opacity > 0
    }

    // button bar
    Rectangle {
        id: buttonRect
        visible: !lastPage && buttonBarVisible
        anchors {
            bottom: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.top : parent.bottom
            left: parent.left
            right: parent.right
        }
        height: buttonBarHeight
        color: "#f5f5f5"

        StackButton {
            id: backButton
            objectName: "backButton"
            width: buttonWidth
            anchors {
                left: parent.left
                bottom: parent.bottom
                leftMargin: leftMargin
                verticalCenter: parent.verticalCenter
            }
            z: 1
            text: backButtonText
            visible: pageStack.depth > 1 && hasBackButton
            backArrow: true

            onClicked: customBack ? backClicked() : pageStack.prev()
        }

        Loader {
            id: forwardButton
            objectName: "forwardButton"
            width: buttonWidth
            anchors {
                right: parent.right
                bottom: parent.bottom
                rightMargin: rightMargin
                verticalCenter: parent.verticalCenter
            }
            z: 1
        }
    }

    // transitions
    function aboutToShow(duration, direction) {
        startContentAnimation(duration, direction)
        startControlsAnimation(duration)
    }

    function aboutToShowSecondary(duration) {
        secondaryAnimation.restart()
        startControlsAnimation(duration)
    }

    function startContentAnimation(duration, direction) {
        contentAnimation.animationDurationBase = duration
        contentAnimation.direction = direction
        contentAnimation.restart()
    }

    function startControlsAnimation(showDuration) {
        actionsShowAnimation.showDuration = showDuration
        actionsShowAnimation.restart()
    }

    SequentialAnimation { // animation for the button bar
        id: actionsShowAnimation
        property int showDuration: 0
        PropertyAction {
            target: buttonRect
            property: 'opacity'
            value: 0
        }
        PauseAnimation { duration: Math.max(0, actionsShowAnimation.showDuration - UbuntuAnimation.SnapDuration) }
        NumberAnimation {
            target: buttonRect
            property: 'opacity'
            to: 1
            duration: UbuntuAnimation.SnapDuration
        }
    }

    SequentialAnimation { // animations for the content
        id: contentAnimation
        property int animationDurationBase: UbuntuAnimation.BriskDuration
        readonly property int additionalDuration: 200
        property int direction: Qt.LeftToRight
        ScriptAction { // direction of the effect
            script: {
                if (contentAnimation.direction === Qt.LeftToRight) {
                    titleLabel.animatedMargin = -content.width;
                    content.animatedMargin = -content.width;
                } else {
                    titleLabel.animatedMargin = content.width;
                    content.animatedMargin = content.width;
                }
            }
        }
        ParallelAnimation {
            NumberAnimation { // the slide-in animation
                targets: [titleLabel, content]
                property: 'animatedMargin'
                to: 0
                duration: contentAnimation.animationDurationBase + contentAnimation.additionalDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation { // opacity animation
                targets: [titleLabel,content]
                property: 'opacity'
                from: 0
                to: 1
                duration: contentAnimation.animationDurationBase
            }
        }
    }

    ParallelAnimation {  // animation for the secondary pages
        id: secondaryAnimation

        NumberAnimation { // the slide-up animation
            target: titleLabel
            property: 'animatedTopMargin'
            from: content.height
            to: customMargin
            duration: UbuntuAnimation.BriskDuration
            easing: UbuntuAnimation.StandardEasing
        }
        NumberAnimation {
            target: content
            property: 'animatedTopMargin'
            from: content.height
            to: 0
            duration: UbuntuAnimation.BriskDuration
            easing: UbuntuAnimation.StandardEasing
        }
        NumberAnimation { // opacity animation
            target: content
            property: 'opacity'
            from: 0
            to: 1
            duration: UbuntuAnimation.BriskDuration
        }
    }
}
