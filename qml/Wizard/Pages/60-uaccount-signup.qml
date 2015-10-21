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
import Ubuntu.Web 0.2
import AccountsService 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "ubuntuAccountSignUpPage"

    title: i18n.tr("Create Device Account")
    customTitle: true
    buttonBarVisible: false

    Flickable
    {
        id: column
        clip: true
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: content
        anchors.leftMargin: parent.leftMargin
        anchors.rightMargin: parent.rightMargin

        // email
        Label {
            id: emailLabel
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Email")
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
            KeyNavigation.tab: nameInput
        }

        // name
        Label {
            id: nameLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: emailInput.bottom
            anchors.topMargin: units.gu(2)
            wrapMode: Text.Wrap
            text: i18n.tr("Your name")
            color: textColor
            font.weight: Font.Light
        }

        LocalComponents.WizardTextField {
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
            anchors.topMargin: units.gu(2)
            wrapMode: Text.Wrap
            text: i18n.tr("Password")
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
            KeyNavigation.tab: pass2Input
        }

        // password meter
        LocalComponents.PasswordMeter {
            id: passMeter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: passInput.bottom
            anchors.topMargin: units.gu(1)
            password: passInput.text
        }

        // repeat password
        Label {
            id: pass2Label
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: passMeter.bottom
            anchors.topMargin: passInput.text !== "" ? units.gu(4) : units.gu(2)
            wrapMode: Text.Wrap
            text: i18n.tr("Repeat password")
            color: textColor
            font.weight: Font.Light
        }

        LocalComponents.WizardTextField {
            id: pass2Input
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: pass2Label.bottom
            anchors.topMargin: units.gu(1)
            echoMode: TextInput.Password
            KeyNavigation.tab: cancelButton
        }

        // buttons
        Button {
            id: cancelButton
            anchors {
                top: pass2Input.bottom
                left: parent.left
                right: parent.horizontalCenter
                rightMargin: units.gu(1)
                topMargin: units.gu(4)
            }
            text: i18n.tr("Cancel")
            onClicked: pageStack.prev()
            KeyNavigation.tab: okButton
        }

        Button {
            id: okButton
            anchors {
                top: pass2Input.bottom
                left: parent.horizontalCenter
                right: parent.right
                leftMargin: units.gu(1)
                topMargin: units.gu(4)
            }
            text: i18n.tr("Sign Up")
            enabled: emailInput.acceptableInput && nameInput.text !== "" &&
                     pass2Input.text.length > 7 && passInput.text === pass2Input.text
            onClicked: {
                root.password = passInput.text;
                AccountsService.realName = nameInput.text;
                AccountsService.email = emailInput.text;
                pageStack.next() // TODO sign up against U1 in Phase 2
            }
            KeyNavigation.tab: emailInput
        }
    }
}
