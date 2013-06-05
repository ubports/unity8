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
    id: item

    property int bottomMargin: units.gu(2)
    property bool mouseOver: contains(mouse)

    property point mouse: Qt.point(-1,-1)

    readonly property real scaleOnMouseOver: 1.2

    width: hudButton.width * scaleOnMouseOver
    height: hudButton.height * scaleOnMouseOver

    Item {
        id: hudButton
        property alias actionButton: actionButton

        anchors.centerIn: parent
        height: units.gu(12)
        width: height
        opacity: item.mouseOver ? 1 : 0.7
        scale: item.mouseOver ? scaleOnMouseOver : 1
        Behavior on opacity {NumberAnimation{duration: 200; easing.type: Easing.OutQuart}}
        Behavior on scale {NumberAnimation{duration: 200; easing.type: Easing.OutQuart}}

        UbuntuShape {
            id: actionButton
            anchors.fill: parent

            borderSource: ""
            image: Image {
                source: "graphics/hud_invoke_button_active.png"
            }
        }

        Image {
            width: units.gu(4)
            height: width
            source: "graphics/hud.png"
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
        }
    }
}
