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

Item {
    id: root

    property alias text: label.text
    property alias iconName: icon.name

    signal clicked()

    Label {
        id: label
        anchors.centerIn: parent
        color: "#f3f3e7"
        fontSize: "large"
        font.weight: Font.DemiBold
    }

    Icon {
        id: icon
        height: units.gu(3)
        width: height
        anchors.centerIn: parent
        color: "#f3f3e7"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
