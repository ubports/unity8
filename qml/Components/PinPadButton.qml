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
    opacity: enabled ? 1 : 0.6

    property alias text: label.text
    property alias subText: subTextLabel.text
    property string iconName

    signal clicked()

    Column {
        anchors.centerIn: parent
        width: parent.width
        height: childrenRect.height

        Item {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: label.visible || icon.visible ? Math.max(label.height, icon.height) : 0

            Label {
                id: label
                anchors.centerIn: parent
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: "#f3f3e7"
                fontSize: "large"
                font.weight: Font.DemiBold
                visible: text.length > 0
            }

            Icon {
                id: icon
                height: units.gu(3)
                width: height
                anchors.centerIn: parent
                name: root.iconName
                color: "#f3f3e7"
                visible: name.length > 0
            }
        }
        Label {
            id: subTextLabel
            fontSize: "small"
            color: "#f3f3e7"
            anchors.horizontalCenter: parent.horizontalCenter
            visible: text.length > 0
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
