/*
 * Copyright (C) 2014 Canonical, Ltd.
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

Rectangle {
    id: handle
    color: "#5d5d5d"
    height: units.gu(2)
    property bool active: false

    Row {
        id: dots
        width: childrenRect.width
        height: childrenRect.height
        anchors.centerIn: parent
        spacing: units.gu(0.5)
        Repeater {
            model: 3
            delegate: Rectangle {
                id: dot
                width: units.dp(3)
                height: width
                color: handle.active ? UbuntuColors.orange : "#888888"
                radius: units.dp(1)
            }
        }
    }
}
