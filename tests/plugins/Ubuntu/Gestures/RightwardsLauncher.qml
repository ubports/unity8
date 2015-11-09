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
import Ubuntu.Gestures 0.1
import Ubuntu.Components 1.3

Item {
    objectName: "rightwardsLauncher"

    function reset() { launcher.x = -launcher.width }

    Rectangle {
        id: launcher
        color: "blue"
        width: units.gu(15)
        height: parent.height
        x: followDragArea()
        y: 0

        function followDragArea() {
            return dragArea.distance < width ? -width + dragArea.distance : 0
        }
    }

    Rectangle {
        id: dragAreaRect
        opacity: dragArea.dragging ? 0.5 : 0.0
        color: "green"
        anchors.fill: dragArea
    }

    DirectionalDragArea {
        id: dragArea
        objectName: "hpDragArea"

        // give some room for items to be dynamically stacked right behind him
        z: 10.0

        width: units.gu(5)

        direction: Direction.Rightwards

        onDraggingChanged: {
            if (dragging) {
                launcher.x = Qt.binding(launcher.followDragArea)
            }
        }

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
    }

    Label {
        text: "Rightwards"
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: units.gu(1)
    }
}
