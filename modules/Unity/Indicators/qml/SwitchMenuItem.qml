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
    id: _switchMenu

    property alias checked: switcher.checked

    control: Switch {
        id: switcher
        enabled: menuAction.valid

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
    }

    MenuActionBinding {
        id: menuAction
        actionGroup: _switchMenu.actionGroup
        action: menu ? menu.action : ""
        target: switcher
        property: "checked"
    }
}
