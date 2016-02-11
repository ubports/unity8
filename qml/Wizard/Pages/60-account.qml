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
import Ubuntu.Components 1.3
import AccountsService 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "accountPage"
    title: i18n.tr("User Details")

    forwardButtonSourceComponent: forwardButton

    Component.onCompleted: {
        theme.palette.normal.backgroundText = "#cdcdcd";
    }

    QtObject {
        id: d

        readonly property bool validInput: true //nameInput.text !== ""
                                           // && pass2Input.text.length > 7 && passInput.text === pass2Input.text

        function advance() {
            //root.password = passInput.text;
            AccountsService.realName = nameInput.text;
            pageStack.next();
        }
    }

    Flickable {
        id: column
        clip: true
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: content
        anchors.leftMargin: parent.leftMargin
        anchors.rightMargin: parent.rightMargin
        anchors.topMargin: customMargin
        height: contentHeight - buttonBarHeight - (Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0) - titleRectHeight
        contentHeight: contentItem.childrenRect.height

        Behavior on contentY { UbuntuNumberAnimation{} }

        // notice
        Label {
            id: noticeLabel
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Lorem ipsum dolor sit amet, consectetuer adipiscing elit.")
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
            text: i18n.tr("Your name")
            color: textColor
            font.weight: Font.Light
        }

        LocalComponents.WizardTextField {
            id: nameInput
            objectName: "nameInput"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: nameLabel.bottom
            anchors.topMargin: units.gu(1)
//            onActiveFocusChanged: {
//                if (activeFocus) {
//                    column.contentY = nameLabel.y
//                }
//            }
            inputMethodHints: Qt.ImhNoPredictiveText
            //onAccepted: passInput.forceActiveFocus()
        }

//        // password
//        Label {
//            id: passLabel
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: nameInput.bottom
//            anchors.topMargin: units.gu(2)
//            text: i18n.tr("Password")
//            color: textColor
//            font.weight: Font.Light
//        }

//        LocalComponents.WizardTextField {
//            id: passInput
//            objectName: "passInput"
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: passLabel.bottom
//            anchors.topMargin: units.gu(1)
//            echoMode: TextInput.Password
//            placeholderText: i18n.tr("Use letters and numbers")
//            inputMethodHints: Qt.ImhNoPredictiveText
//            onActiveFocusChanged: {
//                if (activeFocus) {
//                    column.contentY = passLabel.y
//                }
//            }
//            onAccepted: pass2Input.forceActiveFocus()
//        }

//        // password meter
//        LocalComponents.PasswordMeter {
//            id: passMeter
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: passInput.bottom
//            anchors.topMargin: units.gu(1)
//            password: passInput.text
//        }

//        // repeat password
//        Label {
//            id: pass2Label
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: passMeter.bottom
//            anchors.topMargin: passInput.text !== "" ? units.gu(4) : units.gu(2)
//            wrapMode: Text.Wrap
//            text: i18n.tr("Repeat password")
//            color: textColor
//            font.weight: Font.Light
//        }

//        LocalComponents.WizardTextField {
//            id: pass2Input
//            objectName: "pass2Input"
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: pass2Label.bottom
//            anchors.topMargin: units.gu(1)
//            echoMode: TextInput.Password
//            inputMethodHints: Qt.ImhNoPredictiveText
//            onActiveFocusChanged: {
//                if (activeFocus) {
//                    column.contentY = pass2Label.y
//                }
//            }
//            onAccepted: if (d.validInput) d.advance();
//        }
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
