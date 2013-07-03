/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

MenuItem {
    id: textMenu

    property alias text: textField.text
    property alias password: showPassword.visible

    implicitHeight: password ? units.gu(10) : units.gu(7)

    Column {
        id: _contentColumn
        spacing: units.gu(0.5)
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: units.gu(3)
        }

        TextField {
            id: textField

            anchors {
                left: parent.left
                right: parent.right
            }

            placeholderText: "Password"
            echoMode: textMenu.password && !_checkBox.checked ? TextInput.Password : TextInput.Normal
        }

        Row {
            id: showPassword

            visible: false
            anchors {
                left: parent.left
                right: parent.right

            }

            spacing: units.gu(1)

            CheckBox {
                id: _checkBox
            }

            Label {
                text: "Show password"
                anchors.verticalCenter: _checkBox.verticalCenter
            }
        }
    }

    MenuActionBinding {
        actionGroup: textMenu.actionGroup
        action: menu ? menu.action : ""
        target: textField
        property: "text"
    }
}
