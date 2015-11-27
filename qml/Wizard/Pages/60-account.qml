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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Web 0.2
import AccountsService 0.1
import ".." as LocalComponents
import "../../Components"

LocalComponents.Page {
    objectName: "accountPage"
    title: i18n.tr("Set Administrator Details")

    forwardButtonSourceComponent: forwardButton

    Component.onCompleted: {
        theme.palette.normal.backgroundText = "#cdcdcd";
    }

    QtObject {
        id: d

        readonly property bool validInput: /*emailInput.acceptableInput && */nameInput.text !== "" &&
                                           pass2Input.text.length > 7 && passInput.text === pass2Input.text

        function advance() {
            root.password = passInput.text;
            AccountsService.realName = nameInput.text;
            //AccountsService.email = emailInput.text;
            pageStack.next();
        }
    }

    Flickable
    {
        id: column
        clip: true
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: content
        anchors.leftMargin: parent.leftMargin
        anchors.rightMargin: parent.rightMargin
        anchors.topMargin: customMargin

        ListViewOSKScroller {
            id: oskScroller
            list: column
        }

//        // email
//        Label {
//            id: emailLabel
//            anchors.left: parent.left
//            anchors.right: parent.right
//            wrapMode: Text.Wrap
//            text: i18n.tr("Email")
//            color: textColor
//            font.weight: Font.Light
//        }

//        LocalComponents.WizardTextField {
//            id: emailInput
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: emailLabel.bottom
//            anchors.topMargin: units.gu(1)
//            inputMethodHints: Qt.ImhEmailCharactersOnly
//            validator: RegExpValidator {
//                regExp: /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i
//            }
//            KeyNavigation.tab: nameInput
//        }

        // notice
        Label {
            id: noticeLabel
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Please enter a password to create your user account. You need this password to administer your device.")
            color: textColor
            fontSize: "small"
            font.weight: Font.Light
            lineHeight: 1.2
            width: content.width
        }

        // username
        Label {
            id: nameLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: noticeLabel.bottom
            anchors.topMargin: units.gu(3)
            text: i18n.tr("User name")
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
            onActiveFocusChanged: if (activeFocus) oskScroller.setMakeSureVisibleItem(nameInput)
            inputMethodHints: Qt.ImhNoAutoUppercase
            onAccepted: passInput.forceActiveFocus()
        }

        // password
        Label {
            id: passLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: nameInput.bottom
            anchors.topMargin: units.gu(2)
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
            placeholderText: i18n.tr("Use a combination of letters and numbers")
            KeyNavigation.tab: pass2Input
            onActiveFocusChanged: if (activeFocus) oskScroller.setMakeSureVisibleItem(passInput)
            onAccepted: pass2Input.forceActiveFocus()
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
            KeyNavigation.tab: nameInput
            onActiveFocusChanged: if (activeFocus) oskScroller.setMakeSureVisibleItem(pass2Input)
            onAccepted: if (d.validInput) d.advance();
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            enabled: d.validInput
            text: i18n.tr("Next")
            onClicked: {
                d.advance();
            }
        }
    }
}
