/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1

UbuntuShape {
    id: root
    width: units.gu(10)
    height: units.gu(7)
    radius: "medium"

    property alias text: label.text
    property alias iconName: icon.name

    signal clicked()

    Behavior on color {
        ColorAnimation { duration: 100 }
    }

    Label {
        id: label
        anchors.centerIn: parent
        color: "white"
        fontSize: "x-large"
        font.weight: Font.Light
        opacity: 0.9
    }

    Icon {
        id: icon
        height: units.gu(3)
        width: height
        anchors.centerIn: parent
        color: "white"
        opacity: 0.9
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        onPressed: root.color = Qt.rgba(0, 0, 0, 0.3)
        onReleased: root.color = Qt.rgba(0, 0, 0, 0)
    }
}
