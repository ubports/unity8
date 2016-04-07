/*
 * Copyright 2016 Canonical Ltd.
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
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

Rectangle {
    id: root

    height: units.gu(4)
    radius: units.dp(4)
    border.width: outline ? units.dp(1) : 0
    border.color: outline ? theme.palette.normal.base : "transparent"

    // to be set from outside
    property bool outline: true
    property alias text: label.text
    property alias iconName: icon.name

    signal clicked()

    AbstractButton {
        id: button
        anchors.fill: root
        onClicked: root.clicked()

        Label {
            id: label
            fontSize: "medium"
            font.weight: Font.Light
            anchors.centerIn: parent
            color: outline ? theme.palette.normal.backgroundSecondaryText : "white"
            visible: text !== ""
        }

        Icon {
            id: icon
            height: units.gu(3)
            width: height
            anchors.centerIn: parent
            color: "white"
            visible: !label.visible
        }
    }

    transformOrigin: Item.Top
    scale: button.pressed ? 0.98 : 1.0
    Behavior on scale {
        ScaleAnimator {
            duration: UbuntuAnimation.SnapDuration
            easing.type: Easing.Linear
        }
    }
}
