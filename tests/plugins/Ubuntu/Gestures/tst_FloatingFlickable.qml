/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import Ubuntu.Gestures 0.1
import Unity.Test 0.1
import "../../../../../qml/Components"

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(60)
    color: "white"

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: true
    }

    Grid {
        id: colorGrid
        readonly property bool horizontal: floatingFlickable.direction === Direction.Horizontal
        x: horizontal ? -floatingFlickable.contentX : 0
        y: horizontal ? 0 : -floatingFlickable.contentY
        rows: horizontal ? 1 : 100
        columns: horizontal ? 100 : 1
        Repeater {
            model: 100
            Rectangle {
                width: colorGrid.horizontal ? units.gu(12) : root.width
                height: colorGrid.horizontal ? root.height : units.gu(12)
                color: mouseArea.pressed ? "red"
                                         : Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                }
            }
        }
    }

    FloatingFlickable {
        id: floatingFlickable
        objectName: "floatingFlickable"
        anchors.fill: parent
        contentWidth: colorGrid.width
        contentHeight: colorGrid.height
    }

    Button {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: units.gu(1)

        text: floatingFlickable.direction === Direction.Horizontal ? "Horizontal" : "Vertical"
        activeFocusOnPress: false

        onClicked: {
            if (floatingFlickable.direction === Direction.Horizontal) {
                floatingFlickable.direction = Direction.Vertical;
            } else {
                floatingFlickable.direction = Direction.Horizontal;
            }
        }
    }
}
