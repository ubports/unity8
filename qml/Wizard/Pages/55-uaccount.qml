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

    Item {
        id: column
        anchors.fill: content
        anchors.topMargin: units.gu(4)

        Label {
            id: infoLabel
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Secure my device using my Ubuntu account")
            color: "#525252"
            font.weight: Font.Light
            fontSize: "small"
        }

        Button {
            id: signinButton
            anchors {
                top: infoLabel.bottom
                left: parent.left
                right: parent.horizontalCenter
                rightMargin: units.gu(1)
                topMargin: units.gu(4)
            }
            text: i18n.tr("Sign In")
            onClicked: {
                pageStack.load(Qt.resolvedUrl("uaccount-signin.qml"))
            }
        }

        Button {
            id: signupButton
            anchors {
                top: infoLabel.bottom
                left: parent.horizontalCenter
                right: parent.right
                leftMargin: units.gu(1)
                topMargin: units.gu(4)
            }
            text: i18n.tr("Create Account")
            onClicked: {
                pageStack.load(Qt.resolvedUrl("uaccount-signup.qml"))
            }
        }

        LocalComponents.CheckableSetting {
            anchors {
                left: parent.left
                right: parent.right
                bottom: privacyLabel.top
                bottomMargin: units.gu(2)
            }

            id: reportCheck
            objectName: "reportCheck"
            showDivider: false
            text: i18n.tr("Improve system performance by sending us crashes and error reports.")
            checked: true
        }

        Label {
            id: privacyLabel
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                leftMargin: reportCheck.labelOffset
                bottomMargin: units.gu(4)
            }
            wrapMode: Text.Wrap
            text: i18n.tr("Privacy policy")
            color: UbuntuColors.orange
            font.weight: Font.Light
            fontSize: "small"
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
            text: i18n.tr("Skip")
            onClicked: pageStack.next()
        }
    }
}
