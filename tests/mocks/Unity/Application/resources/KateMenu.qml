/*
 * Copyright (C) 2016 Canonical, Ltd.
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
    id: root
    color: "grey"
    implicitWidth: width
    implicitHeight: height

    property var surface

    Text {
        anchors.centerIn: parent
        text: "menu"
    }
    MouseArea {
        anchors.fill: parent
        property real nextY: 0
        onClicked: {
            // ensure some overlap with is parent in order to visually check for nested opacity artifacts
            root.surface.openMenu(x+(width*0.6), nextY, units.gu(10), root.height);
            nextY += root.height
        }
    }
}
