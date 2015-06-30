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
    objectName: "finishedPage" // careful when renaming the page, see Page.qml

    hasBackButton: false
    customTitle: true

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: units.gu(3)

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.Wrap
            fontSize: "x-large"
            font.weight: Font.Light
            color: "black"
            text: i18n.tr("Welcome to Ubuntu")
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.Wrap
            fontSize: "large"
            font.weight: Font.Light
            color: "black"
            text: i18n.tr("You are ready to use your device now")
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Get Started")
            onClicked: {
                quit()
            }
        }
    }
}
