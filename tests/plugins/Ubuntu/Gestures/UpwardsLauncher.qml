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
    id: root

    function reset() { launcher.y = Qt.binding(function(){return root.height;}); }

    Rectangle {
        id: launcher
        color: "blue"
        width: parent.width
        height: units.gu(15)
        x: 0
        y: root.height

        function followDragArea() {
            return dragArea.distance > -height ?
                        root.height + dragArea.distance
                    :
                        root.height - height
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
        objectName: "vnDragArea"

        height: units.gu(5)

        direction: Direction.Upwards

        onDraggingChanged: {
            if (dragging) {
                launcher.y = Qt.binding(launcher.followDragArea)
            }
        }

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }

    Label {
        text: "Upwards"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: units.gu(1)
    }
}
