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

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Get Started")
            color: "transparent"
            strokeColor: "white"
            font.weight: Font.Normal
            font.pixelSize: FontUtils.sizeToPixels("medium")
            width: Math.max(parent.width/2, implicitWidth)
            onClicked: {
                root.quitWizard();
            }
        }
    }
}
