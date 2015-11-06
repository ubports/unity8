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

import QtQuick 2.4
import Ubuntu.Components 1.3

AbstractButton {
    id: root
    opacity: enabled ? 1 : 0.6

    property alias text: label.text
    property string iconName
    property color foregroundColor: "#000000"

    UbuntuShape {
        anchors.fill: parent
        opacity: root.pressed ? 1 : 0
        Behavior on opacity {
            UbuntuNumberAnimation {}
        }
    }

    Label {
        id: label
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        color: root.foregroundColor
        fontSize: "x-large"
        font.weight: Font.DemiBold
        visible: text.length > 0
        scale: root.pressed ? 0.9 : 1
        Behavior on scale {
            UbuntuNumberAnimation {}
        }
    }

    Icon {
        id: icon
        height: units.gu(3)
        width: height
        anchors.centerIn: parent
        name: root.iconName
        color: root.foregroundColor
        visible: name.length > 0
        scale: root.pressed ? 0.9 : 1
        Behavior on scale {
            UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration }
        }
    }
}
