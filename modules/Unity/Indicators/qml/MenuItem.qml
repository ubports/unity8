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
import Ubuntu.Components.ListItems 0.1 as ListItem

BasicMenuItem {
    objectName: menu ? menu.action : ""
    progression: menu && (menu.linkSubMenu !== undefined)
    text: menu && menu.label ? menu.label : ""
    color: "#221e1c"
    implicitHeight: units.gu(7)

    HLine {
        anchors.top: parent.top
        color: "#403b37"
    }

    HLine {
        anchors.bottom: parent.bottom
        color: "#060606"
    }
}
