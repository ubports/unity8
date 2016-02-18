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
    title: i18n.tr("Personalize Your Device")

    forwardButtonSourceComponent: forwardButton

    Component.onCompleted: {
        theme.palette.normal.backgroundText = "#cdcdcd";
    }

    QtObject {
        id: d

        function advance() {
            var tmp = nameInput.text + " " + surnameInput.text;
            var realName = tmp.trim();
            if (realName !== "") {
                AccountsService.realName = realName;
            }
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

        height: contentHeight - buttonBarHeight - Qt.inputMethod.keyboardRectangle.height - titleRectHeight
        contentHeight: childrenRect.height

        Behavior on contentY { UbuntuNumberAnimation{} }

        // name
        Label {
            id: nameLabel
            anchors.left: parent.left
            anchors.right: parent.right
            text: i18n.tr("Your Name")
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
            inputMethodHints: Qt.ImhNoPredictiveText
            onAccepted: surnameInput.forceActiveFocus()
            onActiveFocusChanged: {
                if (activeFocus) {
                    column.contentY = nameLabel.y
                }
            }
        }

        // surname
        Label {
            id: surnameLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: nameInput.bottom
            anchors.topMargin: units.gu(3)
            text: i18n.tr("Your Surname")
            color: textColor
            font.weight: Font.Light
        }

        LocalComponents.WizardTextField {
            id: surnameInput
            objectName: "surnameInput"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: surnameLabel.bottom
            anchors.topMargin: units.gu(1)
            inputMethodHints: Qt.ImhNoPredictiveText
            onAccepted: d.advance()
            onActiveFocusChanged: {
                if (activeFocus) {
                    column.contentY = surnameLabel.y
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            onClicked: d.advance();
        }
    }
}
