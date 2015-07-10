/*
 * Copyright (C) 2015 Canonical, Ltd.
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
    objectName: "ubuntuAccountPage"

    title: i18n.tr("Ubuntu Account")
    forwardButtonSourceComponent: forwardButton

    Column {
        id: column
        anchors.fill: content
        spacing: units.gu(3)
        anchors.topMargin: units.gu(4)

        Label {
            id: infoLabel
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Secure my device using Ubuntu account")
            color: "#525252"
            font.weight: Font.Light
            fontSize: "small"
        }

        Button {
            anchors {
                left: parent.left
                right: parent.right
            }
            text: i18n.tr("Create Account")
        }

        Button {
            anchors {
                left: parent.left
                right: parent.right
            }
            text: i18n.tr("Sign In")
        }

    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Skip")
            onClicked: pageStack.next()
        }
    }
}
