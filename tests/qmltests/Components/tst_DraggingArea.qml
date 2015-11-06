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

import QtQuick 2.4
import QtTest 1.0
import "../../../qml/Components"

/*
 There will be a green rectangle in the center of the
 application window. This marks the area occupied by the DraggingArea element.

 Press that rectangle and drag it and check that the values printed on the left
 side are updated accordingly.

 Click on the "Orientation: Horizontal" text to toggle the orientation.
*/
Item {
    id: root
    width: 700
    height: 500

    property int dragStartCount: 0
    property int dragEndCount: 0

    Column {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: draggingAreaRectangle.left

        Text {
            text: draggingArea.orientation === Qt.Vertical ?
                        "Orientation: Vertical" : "Orientation: Horizontal"
            font.pixelSize: units.gu(2)

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (draggingArea.orientation === Qt.Vertical) {
                        draggingArea.orientation = Qt.Horizontal
                    } else {
                        draggingArea.orientation = Qt.Vertical
                    }
                }
            }
        }

        Text {
            text: "Dragging: " + draggingArea.dragging
            font.pixelSize: units.gu(2)
        }

        Text {
            text: "Drag velocity: " + draggingArea.dragVelocity
            font.pixelSize: units.gu(2)
        }

        Text {
            text: "Drag value: " + draggingArea.dragValue
            font.pixelSize: units.gu(2)
        }

        Text {
            text: "dragStart count: " + dragStartCount
            font.pixelSize: units.gu(2)
        }

        Text {
            text: "dragEnd count: " + dragEndCount
            font.pixelSize: units.gu(2)
        }
    }

    Rectangle {
        id: draggingAreaRectangle
        width: 50
        height: 50
        anchors.centerIn: parent

        color: "green"

        DraggingArea {
            id: draggingArea
            anchors.fill: parent

            orientation: Qt.Horizontal

            onDragStart : { ++root.dragStartCount }
            onDragEnd : { ++root.dragEndCount }
        }
    }

    TestCase {
        name: "DraggingArea"
        when: windowShown

        function test_horizontalDrag() {
            draggingArea.orientation = Qt.Horizontal;

            dragStartCount = 0
            dragEndCount = 0

            compare(draggingArea.dragging, false);

            // (item, x, y, button, modifiers, delay)
            mousePress(draggingArea,
                       25, 25,
                       Qt.LeftButton, Qt.NoModifier, 0);

            compare(draggingArea.dragging, false);
            compare(dragStartCount, 0);
            compare(dragEndCount, 0);

            // (item, x, y, delay, button)
            mouseMove(draggingArea,
                      -100, 25,
                      0, Qt.LeftButton);

            compare(draggingArea.dragging, true);
            compare(draggingArea.dragValue, -125);
            compare(dragStartCount, 1);
            compare(dragEndCount, 0);

            // (item, x, y, button, modifiers, delay)
            mouseRelease(draggingArea,
                         -100, 25,
                         Qt.LeftButton, Qt.NoModifier, 0);

            compare(draggingArea.dragging, false);
            compare(dragStartCount, 1);
            compare(dragEndCount, 1);
        }

        function test_verticalDrag() {
            draggingArea.orientation = Qt.Vertical;

            dragStartCount = 0
            dragEndCount = 0

            compare(draggingArea.dragging, false);

            // (item, x, y, button, modifiers, delay)
            mousePress(draggingArea,
                       25, 25,
                       Qt.LeftButton, Qt.NoModifier, 0);

            compare(draggingArea.dragging, false);
            compare(dragStartCount, 0);
            compare(dragEndCount, 0);

            // (item, x, y, delay, button)
            mouseMove(draggingArea,
                      25, 125,
                      0, Qt.LeftButton);

            compare(draggingArea.dragging, true);
            compare(draggingArea.dragValue, 100);
            compare(dragStartCount, 1);
            compare(dragEndCount, 0);

            // (item, x, y, button, modifiers, delay)
            mouseRelease(draggingArea,
                         25, 125,
                         Qt.LeftButton, Qt.NoModifier, 0);

            compare(draggingArea.dragging, false);
            compare(dragStartCount, 1);
            compare(dragEndCount, 1);
        }
    }
}
