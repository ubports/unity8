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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import ".." as LocalComponents

/**
 * See the main passwd-type page for an explanation of why we don't actually
 * directly set the password here.
 */

LocalComponents.Page {
    id: passwdSetPage
    objectName: "passwdSetPage"
    title: i18n.tr("Lock Screen Password")
    forwardButtonSourceComponent: forwardButton

    readonly property alias password: passwordField.text
    readonly property alias password2: password2Field.text
    readonly property bool passwordsMatching: password == password2 && password.trim().length > 7

    ColumnLayout {
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
            text: i18n.tr("Enter at least 8 characters")
        }

        ColumnLayout {
            id: innerLayout
            Label {
                text: i18n.tr("Choose password")
                color: textColor
            }
            LocalComponents.WizardTextField {
                Layout.fillWidth: true
                id: passwordField
                objectName: "passwordField"
                echoMode: TextInput.Password
                onAccepted: password2Field.forceActiveFocus()
            }

            Label {
                text: i18n.tr("Confirm password")
                color: textColor
                anchors.topMargin: units.gu(1)
            }
            LocalComponents.WizardTextField {
                Layout.fillWidth: true
                id: password2Field
                objectName: "password2Field"
                echoMode: TextInput.Password
            }
        }

        // password meter
        LocalComponents.PasswordMeter {
            id: passMeter
            anchors {
                left: parent.left
                right: parent.right
                top: innerLayout.bottom
                topMargin: units.gu(1)
            }

            password: passwordField.text
            matching: passwordsMatching
        }

        Item { // spacer
            Layout.fillHeight: true
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: passwordsMatching
            onClicked: {
                root.password = password;
                pageStack.next();
            }
        }
    }
}
