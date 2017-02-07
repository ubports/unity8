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
    color: "white"
    implicitWidth: width
    implicitHeight: height

    property var surface

    Column {
        Button {
            text: "Open Menu"
            property real nextY: y
            property real menuHeight: units.gu(5)
            onClicked: {
                surface.openMenu(x+width, nextY, units.gu(10), menuHeight);
                nextY += menuHeight + units.gu(.5)
            }
        }

        Button {
            text: "Open Dialog"
            property real dialogWidth: units.gu(30)
            property real dialogHeight: units.gu(20)
            onClicked: {
                surface.openDialog(root.x+(root.width/2)-(dialogWidth/2), root.y+(root.height/2)-(dialogHeight/2),
                                   dialogWidth, dialogHeight);
            }
        }
    }
}
