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
    objectName: "ubuntuAccountSignUpPage"

    title: i18n.tr("Create Account")
    customTitle: true
    backButtonText: i18n.tr("Cancel")
    forwardButtonSourceComponent: forwardButton

    Component.onCompleted: {
        emailInput.forceActiveFocus()
    }

    Item {
        id: column
        anchors.fill: content

        // email
        Label {
            id: emailLabel
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Email:")
            color: "#525252"
            font.weight: Font.Light
        }

        TextField {
            id: emailInput
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: emailLabel.bottom
            anchors.topMargin: units.gu(1)
            inputMethodHints: Qt.ImhEmailCharactersOnly
            validator: RegExpValidator {
                regExp: /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i
            }
            KeyNavigation.tab: nameInput
        }

        // name
        Label {
            id: nameLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: emailInput.bottom
            anchors.topMargin: units.gu(3)
            wrapMode: Text.Wrap
            text: i18n.tr("Your name:")
            color: "#525252"
            font.weight: Font.Light
        }

        TextField {
            id: nameInput
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: nameLabel.bottom
            anchors.topMargin: units.gu(1)
            KeyNavigation.tab: passInput
        }

        // password
        Label {
            id: passLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: nameInput.bottom
            anchors.topMargin: units.gu(3)
            wrapMode: Text.Wrap
            text: i18n.tr("Password:")
            color: "#525252"
            font.weight: Font.Light
        }

        TextField {
            id: passInput
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: passLabel.bottom
            anchors.topMargin: units.gu(1)
            echoMode: TextInput.Password
            KeyNavigation.tab: pass2Input
        }

        // repeat password
        Label {
            id: pass2Label
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: passInput.bottom
            anchors.topMargin: units.gu(3)
            wrapMode: Text.Wrap
            text: i18n.tr("Repeat password:")
            color: "#525252"
            font.weight: Font.Light
        }

        TextField {
            id: pass2Input
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: pass2Label.bottom
            anchors.topMargin: units.gu(1)
            echoMode: TextInput.Password
            KeyNavigation.tab: optoutCheck
        }

        LocalComponents.CheckableSetting {
            id: optoutCheck
            objectName: "optoutCheck"
            showDivider: false
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: pass2Input.bottom
            anchors.topMargin: units.gu(3)
            text: i18n.tr("Opt out of cloud account (not recommended)")
            KeyNavigation.tab: termsCheck
        }

        LocalComponents.CheckableSetting {
            id: termsCheck
            objectName: "termsCheck"
            showDivider: false
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: optoutCheck.bottom
            anchors.topMargin: units.gu(1)
            text: i18n.tr("I have read and accept the Ubuntu account <a href='#'>terms of service</a>")
            //onLinkActivated: pageStack.load(Qt.resolvedUrl("here-terms.qml")) // TODO show terms
            KeyNavigation.tab: emailInput
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            enabled: emailInput.acceptableInput && passInput.text !== "" && pass2Input.text !== "" && passInput.text === pass2Input.text
            text: i18n.tr("Sign Up")
            onClicked: pageStack.next() // TODO sign up against U1
        }
    }
}
