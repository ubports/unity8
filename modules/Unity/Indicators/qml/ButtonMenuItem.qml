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

BasicMenuItem {
    id: _buttonMenu
    color: "#221e1b"
    implicitHeight: units.gu(7)

    Button {
        id: button
        enabled: menuAction.valid
        text: menu ? menu.label : ""
        anchors.centerIn: parent
        height: units.gu(4)
        width: units.gu(16)
        color: "#1b1817"

        onClicked: {
            menuAction.activate()
        }
    }

    MenuItemAction {
        id: menuAction
        actionGroup: _buttonMenu.actionGroup
        action: menu ? menu.action : ""
    }
}
