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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators

BaseMenuItem {
    id: menuItem
    objectName: menuAction.name
    implicitHeight: units.gu(7)
    enabled: menuAction.active

    Button {
        id: button
        enabled: menuAction.enabled
        text: menu ? menu.label : ""
        anchors.centerIn: parent
        height: units.gu(4)
        width: units.gu(16)
        color: "#1b1817"

        onClicked: {
            menuItem.activate();
        }
    }

    Indicators.MenuAction {
        id: menuAction
        menu: menuItem.menu
    }
}
