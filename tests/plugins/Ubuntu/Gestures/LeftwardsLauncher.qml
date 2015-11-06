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

    function reset() { launcher.x = Qt.binding(function(){return root.width;}); }

    Rectangle {
        id: launcher
        color: "blue"
        width: units.gu(15)
        height: parent.height
        x: root.width
        y: 0

        function followDragArea() {
            return dragArea.distance > -width ?
                        root.width + dragArea.distance
                    :
                        root.width - width
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
        objectName: "hnDragArea"

        width: units.gu(5)

        direction: Direction.Leftwards

        onDraggingChanged: {
            if (dragging) {
                launcher.x = Qt.binding(launcher.followDragArea)
            }
        }

        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
    }

    Label {
        text: "Leftwards"
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: units.gu(1)
    }
}
