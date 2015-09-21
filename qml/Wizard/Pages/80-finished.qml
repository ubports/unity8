/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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

import QtQuick 2.3
import Ubuntu.Components 1.2
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "finishedPage"

    hasBackButton: false
    customTitle: true
    lastPage: true

    Image {
        source: "data/Phone Splash Screen bkg.png"
        anchors.fill: parent
        scale: Image.PreserveAspectFit
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: leftMargin
        anchors.rightMargin: rightMargin
        spacing: units.gu(2)

        Label {
            id: welcomeLabel
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            fontSize: "x-large"
            font.weight: Font.Light
            text: i18n.tr("Welcome to Ubuntu")
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            fontSize: "large"
            font.weight: Font.Light
            text: i18n.tr("You are ready to use your device now")
        }

        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            color: 'transparent'
            border.width: units.dp(1)
            border.color: 'white'
            radius: units.dp(4)
            width: buttonLabel.paintedWidth + units.gu(3)
            height: buttonLabel.paintedHeight + units.gu(1.5)

            Label {
                id: buttonLabel
                color: 'white'
                text: i18n.tr("Get Started")
                fontSize: "medium"
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: root.quitWizard()
            }
        }
    }
}
