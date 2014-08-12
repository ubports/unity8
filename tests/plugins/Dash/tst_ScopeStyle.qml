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

    ScopeStyle {
        id: tool
    }

    TestCase {
        id: testCase
        name: "ScopeStyle"
        when: windowShown

        property color color
        property var styles: [
            {},
            { "foreground-color": "red", "background-color": "black", "page-header": { "logo": "/foo/bar" } },
            { "foreground-color": "green", "background-color": "white", "page-header": { "foreground-color": "black" } },
            { "foreground-color": "blue", "background-color": "darkgrey", "page-header": { "background": "gradient:///white/blue" } },
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
                { tag: "red", luminance: 0.2126 },
                { tag: "green", luminance: 0.3590 },
                { tag: "blue", luminance: 0.0722 },
            ];
        }

        function test_luminance(data) {
            testCase.color = data.tag;
            compare(tool.luminance(testCase.color).toFixed(4), data.luminance.toFixed(4));
        }

        function test_foreground_data() {
            return [
                { tag: "default", index: 0, foreground: "grey", luminance: 0.5020 },
                { tag: "red on black", index: 1, foreground: "red", luminance: 0.2126 },
                { tag: "green on white", index: 2, foreground: "green", luminance: 0.3590 },
                { tag: "blue on darkgrey", index: 3, foreground: "blue", luminance: 0.0722 },
            ];
        }

        function test_foreground(data) {
            tool.style = testCase.styles[data.index];
            verify(Qt.colorEqual(tool.foreground, data.foreground),
                   "Foreground color not equal: %1 != %2".arg(tool.foreground).arg(data.foreground));
            compare(tool.foregroundLuminance.toFixed(4), data.luminance.toFixed(4));
        }

        function test_background_data() {
            return [
                { tag: "default", index: 0, background: "transparent" },
                { tag: "red on black", index: 1, background: "black", luminance: 0 },
                { tag: "green on white", index: 2, background: "white", luminance: 1 },
                { tag: "blue on darkgrey", index: 3, background: "darkgrey", luminance: 0.6627 },
            ];
        }

        function test_background(data) {
            tool.style = testCase.styles[data.index];
            verify(Qt.colorEqual(tool.background, data.background),
                   "Background color not equal: %1 != %2".arg(tool.background).arg(data.background));
            if (data.hasOwnProperty("luminance")) {
                compare(tool.backgroundLuminance.toFixed(4), data.luminance.toFixed(4));
            }
        }

        function test_threshold_data() {
            return [
                { tag: "default", index: 0, threshold: 0.7510 },
                { tag: "red on black", index: 1, threshold: 0.1063 },
                { tag: "green on white", index: 2, threshold: 0.6795 },
                { tag: "blue on darkgrey", index: 3, threshold: 0.3675 },
            ];
        }

        function test_threshold(data) {
            tool.style = testCase.styles[data.index];
            compare(tool.threshold.toFixed(4), data.threshold.toFixed(4), "Luminance threshold was incorrect.");
        }

        function test_light_data() {
            return [
                { tag: "default", index: 0, light: "white" },
                { tag: "red on black", index: 1, light: "red" },
                { tag: "green on white", index: 2, light: "white" },
                { tag: "blue on darkgrey", index: 3, light: "darkgrey" },
            ];
        }

        function test_light(data) {
            tool.style = testCase.styles[data.index];
            verify(Qt.colorEqual(tool.light, data.light),
                   "Light color not equal: %1 != %2".arg(tool.light).arg(data.light));
        }

        function test_dark_data() {
            return [
                { tag: "default", index: 0, dark: "grey" },
                { tag: "red on black", index: 1, dark: "black" },
                { tag: "green on white", index: 2, dark: "green" },
                { tag: "blue on darkgrey", index: 3, dark: "blue" },
            ];
        }

        function test_dark(data) {
            tool.style = testCase.styles[data.index];
            verify(Qt.colorEqual(tool.dark, data.dark),
                   "Dark color not equal: %1 != %2".arg(tool.dark).arg(data.dark));
        }

        function test_headerLogo_data() {
            return [
                { tag: "default", index: 0, headerLogo: "" },
                { tag: "with logo", index: 1, headerLogo: "file:///foo/bar" },
            ];
        }

        function test_headerLogo(data) {
            tool.style = testCase.styles[data.index];
            compare(tool.headerLogo, data.headerLogo, "Header logo was incorrect.");
        }

        function test_headerForeground_data() {
            return [
                { tag: "default", index: 0, headerForeground: "grey" },
                { tag: "black", index: 2, headerForeground: "black" },
            ];
        }

        function test_headerForeground(data) {
            tool.style = testCase.styles[data.index];
            verify(Qt.colorEqual(tool.headerForeground, data.headerForeground),
                   "Header foreground not equal: %1 != %2".arg(tool.headerForeground).arg(data.headerForeground));
        }

        function test_headerBackground_data() {
            return [
                { tag: "default", index: 0, headerBackground: "" },
                { tag: "black", index: 3, headerBackground: "gradient:///white/blue" },
            ];
        }

        function test_headerBackground(data) {
            tool.style = testCase.styles[data.index];
            compare(tool.headerBackground, data.headerBackground, "Header background was incorrect.");
        }
    }
}
