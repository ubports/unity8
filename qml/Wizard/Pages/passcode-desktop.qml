/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
    objectName: "passcodeDesktopPage"
    title: i18n.tr("Lock Screen Passcode")
    forwardButtonSourceComponent: forwardButton

    readonly property alias password: passwordField.text
    readonly property alias password2: password2Field.text

    Flickable {
        id: column
        clip: true
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: content
        anchors.leftMargin: parent.leftMargin
        anchors.rightMargin: parent.rightMargin
        anchors.topMargin: customMargin

        bottomMargin: Qt.inputMethod.keyboardRectangle.height - height - customMargin

        Behavior on contentY { UbuntuNumberAnimation {} }

        Label {
            id: infoLabel
            objectName: "infoLabel"
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            wrapMode: Text.Wrap
            font.weight: Font.Light
            color: textColor
            text: i18n.tr("Enter 4 numbers to setup your passcode")
        }

        GridLayout {
            anchors {
                left: parent.left
                right: parent.right
                top: infoLabel.bottom
                topMargin: units.gu(3)
            }

            columns: 2
            columnSpacing: units.gu(2)
            rowSpacing: units.gu(2)

            Label {
                text: i18n.tr("Choose passcode")
                color: textColor
            }
            LocalComponents.WizardTextField {
                Layout.fillWidth: true
                id: passwordField
                objectName: "passwordField"
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegExpValidator { regExp: /^\d{4}$/ }
                maximumLength: 4
                onAccepted: password2Field.forceActiveFocus()
                onActiveFocusChanged: {
                    if (activeFocus) {
                        column.contentY = y
                    }
                }
            }

            Label {
                text: i18n.tr("Confirm passcode")
                color: textColor
            }
            LocalComponents.WizardTextField {
                Layout.fillWidth: true
                id: password2Field
                objectName: "password2Field"
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegExpValidator { regExp: /^\d{4}$/ }
                maximumLength: 4
                onActiveFocusChanged: {
                    if (activeFocus) {
                        column.contentY = y
                    }
                }
            }

            Label {
                Layout.row: 2
                Layout.column: 1
                id: errorLabel
                property bool hasError: password && password != password2
                wrapMode: Text.Wrap
                color: hasError ? errorColor : UbuntuColors.ash
                visible: password && password2
                fontSize: "small"
                text: {
                    if (password) {
                        if (password2.length < password2Field.maximumLength)
                            return i18n.tr("Passcode too short");
                        else if (password == password2)
                            return i18n.tr("Passcodes match");
                        else if (password2)
                            return i18n.tr("Passcodes do not match");
                    }
                    return "";
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: password != "" && password == password2
            onClicked: {
                root.password = password;
                pageStack.next();
            }
        }
    }
}
