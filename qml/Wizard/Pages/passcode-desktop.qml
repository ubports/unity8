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
import ".." as LocalComponents

/**
 * See the main passwd-type page for an explanation of why we don't actually
 * directly set the password here.
 */

LocalComponents.Page {
    id: passwdSetPage
    objectName: "passcodeDesktopPage"
    title: i18n.tr("Lock Screen Passcode")
    forwardButtonSourceComponent: forwardButton

    property alias password: passwordField.text

    Column {
        id: column
        anchors.fill: content
        anchors.leftMargin: leftMargin
        anchors.rightMargin: rightMargin
        anchors.topMargin: customMargin
        spacing: units.gu(3)

        Label {
            id: infoLabel
            objectName: "infoLabel"
            anchors {
                left: parent.left
                right: parent.right
            }
            wrapMode: Text.Wrap
            font.weight: Font.Light
            color: textColor
            text: i18n.tr("Enter 4 numbers to setup your passcode")
        }

        Grid {
            columns: 2
            spacing: units.gu(2)
            verticalItemAlignment: Grid.AlignVCenter

            Label {
                text: i18n.tr("Choose passcode")
                color: textColor
            }
            LocalComponents.WizardTextField {
                id: passwordField
                objectName: "passwordField"
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegExpValidator { regExp: /^\d{4}$/ }
                maximumLength: 4
            }

            Label {
                text: i18n.tr("Confirm passcode")
                color: textColor
            }
            LocalComponents.WizardTextField {
                id: password2Field
                objectName: "password2Field"
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegExpValidator { regExp: /^\d{4}$/ }
                maximumLength: 4
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: password != "" && password == password2Field.text
            onClicked: {
                root.password = password;
                pageStack.next();
            }
        }
    }
}
