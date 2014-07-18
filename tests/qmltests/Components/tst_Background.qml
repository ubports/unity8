/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.2
import QtTest 1.0
import Unity.Test 0.1

import "../../../qml/Components"

Rectangle {
    width: units.gu(40)
    height: units.gu(71)

    Background {
        id: background
    }

    UnityTestCase {
        id: testCase
        name: "Background"
        when: windowShown

        function cleanup() {
            background.style = "";
        }

        function test_style_data() {
            return [
                { tag: "empty", style: "" },
                { tag: "solid", style: "color:///black" },
                { tag: "gradient", style: "gradient:///black/red" },
                { tag: "image", style: "/some/path" },
            ];
        }

        function test_style(data) {
            background.style = data.style;
            expectFail("empty", "Empty style should not create a background.");
            tryCompareFunction(function() { return background.item === null }, false);
            compare(background.item.objectName, data.tag, "Background should be %1".arg(data.style));
        }
    }
}
