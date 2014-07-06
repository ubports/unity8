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
import Dash 0.1
import Ubuntu.Components 1.1

Rectangle {
    width: units.gu(40)
    height: units.gu(71)

    StyleTool {
        id: tool
    }

    TestCase {
        id: testCase
        name: "StyleTool"
        when: windowShown

        property color color
        property var styles: [
            {},
            { "foreground-color": "red", "background-color": "black" },
            { "foreground-color": "green", "background-color": "white" },
            { "foreground-color": "blue", "background-color": "darkgrey" },
        ]

        function cleanup() {
            testCase.color = "transparent";
        }

        function test_luminance_data() {
            return [
                { tag: "#F00", luminance: 0.2126 },
                { tag: "#0F0", luminance: 0.7152 },
                { tag: "#00F", luminance: 0.0722 },
                { tag: "white", luminance: 1.0 },
                { tag: "black", luminance: 0.0 },
                { tag: "lightgrey", luminance: 0.8275 },
                { tag: "grey", luminance: 0.5020 },
                { tag: "darkgrey", luminance: 0.6627 },
            ];
        }

        function test_luminance(data) {
            testCase.color = data.tag;
            compare(tool.luminance(testCase.color).toFixed(4), data.luminance.toFixed(4));
        }

        function test_foreground_data() {
            return [
                { tag: "default", index: 0, foreground: "grey" },
                { tag: "red on black", index: 1, foreground: "red" },
                { tag: "green on white", index: 2, foreground: "green" },
                { tag: "blue on darkgrey", index: 3, foreground: "blue" },
            ];
        }

        function test_foreground(data) {
            tool.style = testCase.styles[data.index];
            verify(Qt.colorEqual(tool.foreground, data.foreground),
                   "Foreground color not equal: %1 != %2".arg(tool.foreground).arg(data.foreground));
        }

        function test_background_data() {
            return [
                { tag: "default", index: 0, background: "transparent" },
                { tag: "red on black", index: 1, background: "black" },
                { tag: "green on white", index: 2, background: "white" },
                { tag: "blue on darkgrey", index: 3, background: "darkgrey" },
            ];
        }

        function test_background(data) {
            tool.style = testCase.styles[data.index];
            verify(Qt.colorEqual(tool.background, data.background),
                   "Background color not equal: %1 != %2".arg(tool.background).arg(data.background));
        }

        function test_threshold_data() {
            return [
                { tag: "default", index: 0, threshold: 0.5020 },
                { tag: "red on black", index: 1, threshold: 0.1063 },
                { tag: "green on white", index: 2, threshold: 0.6795 },
                { tag: "blue on darkgrey", index: 3, threshold: 0.3675 },
            ];
        }

        function test_threshold(data) {
            tool.style = testCase.styles[data.index];
            compare(tool.threshold.toFixed(4), data.threshold.toFixed(4), "Luminance threshold was incorrect.")
        }
    }
}
