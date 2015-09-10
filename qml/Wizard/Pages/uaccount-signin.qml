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
    objectName: "ubuntuAccountSignInPage"

    title: i18n.tr("Sign In")
    customTitle: true
    backButtonText: i18n.tr("Cancel")
    forwardButtonSourceComponent: forwardButton

    Component.onCompleted: {
        emailInput.forceActiveFocus()
    }

    Item {
        id: column
        anchors.fill: content

        Label {
            id: emailLabel
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Email:")
            color: textColor
            font.weight: Font.Light
        }

        LocalComponents.WizardTextField {
            id: emailInput
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: emailLabel.bottom
            anchors.topMargin: units.gu(1)
            inputMethodHints: Qt.ImhEmailCharactersOnly
            validator: RegExpValidator {
                regExp: /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i
            }
            KeyNavigation.tab: passInput
        }

        Label {
            id: passLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: emailInput.bottom
            anchors.topMargin: units.gu(3)
            wrapMode: Text.Wrap
            text: i18n.tr("Password:")
            color: textColor
            font.weight: Font.Light
        }

        LocalComponents.WizardTextField {
            id: passInput
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: passLabel.bottom
            anchors.topMargin: units.gu(1)
            echoMode: TextInput.Password
            KeyNavigation.tab: emailInput
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            enabled: emailInput.acceptableInput && passInput.text !== ""
            text: i18n.tr("Sign In")
            onClicked: pageStack.next() // TODO sign in against U1
        }
    }
}
