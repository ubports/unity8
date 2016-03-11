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

    Flickable {
        id: column
        clip: true
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: content
        anchors.leftMargin: parent.leftMargin
        anchors.rightMargin: parent.rightMargin
        anchors.topMargin: customMargin

        bottomMargin: Qt.inputMethod.keyboardRectangle.height - height

        Behavior on contentY { UbuntuNumberAnimation {} }

        // info label
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

        // password
        Label {
            id: pass1Label
            anchors {
                left: parent.left
                right: parent.right
                top: infoLabel.bottom
                topMargin: units.gu(3)
            }
            text: i18n.tr("Choose password")
            color: textColor
        }
        LocalComponents.WizardTextField {
            id: passwordField
            anchors {
                left: parent.left
                right: parent.right
                top: pass1Label.bottom
                topMargin: units.gu(1)
            }
            objectName: "passwordField"
            echoMode: TextInput.Password
            onAccepted: password2Field.forceActiveFocus()
            onActiveFocusChanged: {
                if (activeFocus) {
                    column.contentY = pass1Label.y
                }
            }
        }

        // password 2
        Label {
            id: pass2Label
            anchors {
                left: parent.left
                right: parent.right
                top: passwordField.bottom
                topMargin: units.gu(3)
            }
            text: i18n.tr("Confirm password")
            color: textColor
        }
        LocalComponents.WizardTextField {
            anchors {
                left: parent.left
                right: parent.right
                top: pass2Label.bottom
                topMargin: units.gu(1)
            }
            id: password2Field
            objectName: "password2Field"
            echoMode: TextInput.Password
            onActiveFocusChanged: {
                if (activeFocus) {
                    column.contentY = pass2Label.y
                }
            }
        }

        // password meter
        LocalComponents.PasswordMeter {
            id: passMeter
            anchors {
                left: parent.left
                right: parent.right
                top: password2Field.bottom
                topMargin: units.gu(1)
            }

            password: passwordField.text
            matching: passwordsMatching ? true : (password2.trim().length > 0 ? false : undefined)
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
