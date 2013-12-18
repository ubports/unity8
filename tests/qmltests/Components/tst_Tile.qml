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
import QtTest 1.0
import ".."
import "../../../qml/Components"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(20)
    height: units.gu(24)

    property bool helper: false

    Tile {
        id: tile
        anchors.fill: parent
        source: "../../../graphics/clock@18.png"
        text: "Testing rocks, debugging sucks!"
        imageWidth: width
        imageHeight: width
    }

    UT.UnityTestCase {
        name: "Tile"
        when: windowShown

        function test_click_highlight() {
            var border = findChild(tile, "borderPressed")
            compare(border.opacity, 0)
            mousePress(root, 1, 1)
            tryCompare(border, "opacity", 1)
            mouseRelease(root, 1, 1)
            tryCompare(border, "opacity", 0)
        }

        function test_resize_image_data() {
            return [
                {tag: "small", w: 1, h: 1, click: true},
                {tag: "large", w: units.gu(20), h: units.gu(20), click: true},
                // If image is too large to fit, text will be moved outside of the scene and click should fail
                {tag: "too large", w: units.gu(40), h: units.gu(40), click: false}
            ]
        }

        function test_resize_image(data) {
            tile.imageWidth = data.w
            tile.imageHeight = data.h
            var label = findChild(tile, "label")
            mousePress(label, 1, 1)
            tryCompare(tile, "pressed", data.click)
            mouseRelease(label, 1, 1)
        }
    }
}
