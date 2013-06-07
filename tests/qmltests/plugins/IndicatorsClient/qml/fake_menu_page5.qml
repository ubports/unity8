/*
 * Copyright 2013 Canonical Ltd.
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
import IndicatorsClient 0.1 as IndicatorsClient

IndicatorsClient.FakeMenuPage {
    id: menu_plugin5
    objectName: "menu_page5"

    Rectangle {
        id: contents
        color: "orange"

        height: 150
        width: 150

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        NumberAnimation on rotation {
            id: rotation_animation
            from: 0
            to: 360
            duration: 5000
            loops: Animation.Infinite
        }
    }
}
