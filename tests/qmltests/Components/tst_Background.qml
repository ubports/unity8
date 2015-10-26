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

import QtQuick 2.4
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

        SignalSpy {
            id: loadedSpy
            target: background
            signalName: "loaded"
        }

        function cleanup() {
            background.style = "";
            loadedSpy.clear();
        }

        function test_style_data() {
            return [
                { tag: "empty", style: "", luminance: 0.5 },
                { tag: "solid", style: "color:///black", luminance: 0 },
                { tag: "gradient", style: "gradient:///black/red", luminance: 0.1063 },
                { tag: "image", style: "/some/path", luminance: 0.5 },
            ];
        }

        function test_style(data) {
            background.style = data.style;
            expectFail("empty", "Empty style should not create a background.");
            loadedSpy.wait();
            compare(background.item.objectName, data.tag, "Background should be %1".arg(data.style));
            compare(background.luminance, data.luminance);
        }

        function test_solid() {
            background.style = "color:///black";
            loadedSpy.wait();

            verify(Qt.colorEqual(background.item.color, "black"),
                   "Solid color not equal: %1 != black".arg(background.item.color));
        }

        function test_gradient() {
            background.style = "gradient:///black/red";
            loadedSpy.wait();

            var stops = background.item.gradient.stops;

            verify(Qt.colorEqual(stops[0].color, "black"),
                   "Top gradient color not equal: %1 != black".arg(stops[0].color));
            verify(Qt.colorEqual(stops[1].color, "red"),
                   "Bottom gradient color not equal: %1 != black".arg(stops[1].color));
        }

        function test_image() {
            background.style = "/some/path";
            loadedSpy.wait();

            compare(background.item.source, Qt.resolvedUrl("/some/path"), "Image path is incorrect.");
        }
    }
}
