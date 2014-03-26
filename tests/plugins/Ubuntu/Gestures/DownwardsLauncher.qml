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
import Ubuntu.Gestures 0.1
import Ubuntu.Components 0.1

Item {

    function reset() { launcher.y = -launcher.height }

    Rectangle {
        id: launcher
        color: "blue"
        width: parent.width
        height: units.gu(15)
        x: 0
        y: followDragArea()

        function followDragArea() {
            return dragArea.distance < height ? -height + dragArea.distance : 0
        }
    }

    Rectangle {
        id: dragAreaRect
        color: "yellow"
        opacity: 0.0
        anchors.fill: dragArea
    }

    DirectionalDragArea {
        id: dragArea
        objectName: "vpDragArea"

        height: units.gu(5)

        direction: Direction.Downwards
        maxDeviation: units.gu(2)
        wideningAngle: 10
        distanceThreshold: units.gu(4)

        onStatusChanged: {
            switch (status) {
                case DirectionalDragArea.WaitingForTouch:
                    dragAreaRect.opacity = 0.0
                    break;
                case DirectionalDragArea.Undecided:
                    dragAreaRect.color = "yellow"
                    dragAreaRect.opacity = 0.3
                    launcher.y = Qt.binding(launcher.followDragArea)
                    break;
                default: // DirectionalDragArea.Recognized:
                    dragAreaRect.color = "green"
                    dragAreaRect.opacity = 0.5
                    break;
            }
        }

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }

    Label {
        text: "Downwards"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: units.gu(1)
    }
}
