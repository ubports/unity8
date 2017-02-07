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
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "This is a child dialog."
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        Button {
            text: "OK"
            onClicked: root.surface.close()
        }
        Button {
            text: "Cancel"
            onClicked: root.surface.close()
        }
    }
}
