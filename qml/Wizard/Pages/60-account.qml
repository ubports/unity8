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

    QtObject {
        id: d
        readonly property string validName: nameInput.text.trim()
    }

    Column {
        id: column
        spacing: units.gu(1)
        anchors {
            fill: content
            leftMargin: parent.leftMargin
            rightMargin: parent.rightMargin
            topMargin: customMargin
        }

        // name
        Label {
            id: nameLabel
            anchors.left: parent.left
            anchors.right: parent.right
            text: i18n.tr("Preferred Name")
            color: textColor
            font.weight: Font.Light
        }

        LocalComponents.WizardTextField {
            id: nameInput
            objectName: "nameInput"
            anchors.left: parent.left
            anchors.right: parent.right
            inputMethodHints: Qt.ImhNoPredictiveText
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: d.validName ? i18n.tr("Next") : i18n.tr("Skip")
            onClicked: {
                if (d.validName) {
                    AccountsService.realName = d.validName;
                }
                pageStack.next();
            }
        }
    }
}
