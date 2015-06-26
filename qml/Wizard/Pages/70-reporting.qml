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
    objectName: "reportingPage"

    title: i18n.tr("Help us improve")
    forwardButtonSourceComponent: forwardButton

    Column {
        id: column
        anchors.fill: content
        spacing: units.gu(3)
        anchors.topMargin: units.gu(4)

        LocalComponents.CheckableSetting {
            id: reportCheck
            objectName: "reportCheck"
            showDivider: false
            text: i18n.tr("Improve your system performance by sending us crashes and error reports.")
            checked: true
        }

        Label {
            anchors.left: parent.left
            anchors.leftMargin: reportCheck.labelOffset
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Privacy policy")
            color: "#dd4814"
            font.weight: Font.Light
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // TODO
                    print("Display privacy policy")
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            // TODO save the policy somewhere?
            text: i18n.tr("Next")
            onClicked: pageStack.next()
        }
    }
}
