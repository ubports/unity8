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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1
import Unity.Test 0.1

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
        x: -floatingFlickable.contentX
        rows: 1
        Repeater {
            model: 100
            Rectangle {
                width: 100
                height: root.height
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
        anchors.fill: parent
        contentWidth: 100 * 100
        onContentXChanged: console.log(contentX);
    }
}
