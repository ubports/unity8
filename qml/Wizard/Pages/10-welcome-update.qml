/*
 * Copyright (C) 2018 The UBports project
 *
 * Written by: Marius Gripsgard <marius@ubports.com>
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
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "welcomeUpdate"

    hasBackButton: false
    customTitle: true
    buttonBarVisible: false
    onlyOnUpdate: true

    Component.onCompleted: {
        state = "reanchored";
    }

    states: State {
        name: "reanchored"
        AnchorChanges { target: bgImage; anchors.top: parent.top; anchors.bottom: parent.bottom }
        AnchorChanges { target: column;
            anchors.verticalCenter: parent.verticalCenter;
            anchors.top: undefined
        }
    }

    SequentialAnimation {
        id: splashAnimation
        PauseAnimation { duration: UbuntuAnimation.BriskDuration }
        SmoothedAnimation {
            target: bgImage
            property: "height"
            to: units.gu(16)
            duration: UbuntuAnimation.BriskDuration
        }
        NumberAnimation {
            target: bgImage
            property: 'opacity'
            from: 1
            to: 0
        }
    }

    Image {
        id: bgImage
        source: wideMode ? "data/Desktop_splash_screen_bkg.png" : "data/Phone_splash_screen_bkg.png"
        scale: Image.PreserveAspectFit
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.top // outside to let it slide down
        visible: opacity > 0
    }

    Item {
        id: column
        anchors.leftMargin: leftMargin
        anchors.rightMargin: rightMargin
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.bottom // outside to let it slide in
        height: childrenRect.height
        visible: opacity > 0

        Label {
            id: welcomeLabel
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            fontSize: "x-large"
            font.weight: Font.Light
            lineHeight: 1.2
            text: i18n.tr("Welcome to ") + System.version.split("Base-Version: ")[1]
            color: whiteColor
        }

        Label {
            id: welcomeText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: welcomeLabel.bottom
            anchors.topMargin: units.gu(2)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            fontSize: "large"
            font.weight: Font.Light
            lineHeight: 1.2
            text: i18n.tr("We will make sure your device is ready to use ") + System.version.split("Base-Version: ")[1]
            color: whiteColor
        }

        Rectangle {
            anchors {
                top: welcomeText.bottom
                horizontalCenter: parent.horizontalCenter
                topMargin: units.gu(4)
            }
            color: "transparent"
            border.width: units.dp(1)
            border.color: whiteColor
            radius: units.dp(4)
            width: buttonLabel.paintedWidth + units.gu(6)
            height: buttonLabel.paintedHeight + units.gu(1.8)

            Label {
                id: buttonLabel
                color: whiteColor
                text: i18n.tr("Next")
                fontSize: "medium"
                anchors.centerIn: parent
            }
            AbstractButton {
                objectName: "nextButton"
                anchors.fill: parent
                onClicked: pageStack.next();
            }
        }
    }
}
