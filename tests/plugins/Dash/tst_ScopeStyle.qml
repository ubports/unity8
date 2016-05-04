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
import Dash 0.1
import Ubuntu.Components 1.3
import Utils 0.1

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
            { "foreground-color": "red", "background-color": "black", "page-header": { "logo": "/foo/bar" },
              "preview-button-color": "red"},
            { "foreground-color": "green", "background-color": "white",
              "page-header": { "foreground-color": "black",
                               "divider-color": "blue" } },
            { "foreground-color": "blue", "background-color": "darkgrey",
              "page-header": { "background": "gradient:///white/blue",
                               "navigation-background": "gradient:///white/blue" } },
        ]

        function cleanup() {
            testCase.color = "transparent";
        }

        function test_foreground_data() {
            return [
                { tag: "default", index: 0, foreground: UbuntuColors.darkGrey, luminance: 0.3647 },
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
                { tag: "default", index: 0, background: "#00f5f5f5", luminance: 0.9608 },
                { tag: "red on black", index: 1, background: "black", luminance: 0 },
                { tag: "green on white", index: 2, background: "white", luminance: 1 },
                { tag: "blue on darkgrey", index: 3, background: "darkgrey", luminance: 0.6627 },
            ];
        }

        function test_background(data) {
            tool.style = testCase.styles[data.index];
            verify(Qt.colorEqual(tool.background, data.background),
                   "Background color not equal: %1 != %2".arg(tool.background).arg(data.background));
            compare(tool.backgroundLuminance.toFixed(4), data.luminance.toFixed(4));
        }

        function test_getTextColor_data() {
            return [
                { tag: "default on black", background: "black", index: 0, textColor: "white" },
                { tag: "default on lightgrey", background: "lightgrey", index: 0, textColor: UbuntuColors.darkGrey },
                { tag: "default on white", background: "white", index: 0, textColor: UbuntuColors.darkGrey },
                { tag: "default on yellow", background: "yellow", index: 0, textColor: UbuntuColors.darkGrey },
                { tag: "red/black on black", background: "black", index: 1, textColor: "red" },
                { tag: "red/black on lightgrey", background: "lightgrey", index: 1, textColor: "black" },
                { tag: "red/black on white", background: "white", index: 1, textColor: "black" },
                { tag: "red/black on yellow", background: "yellow", index: 1, textColor: "black" },
                { tag: "green/white on black", background: "black", index: 2, textColor: "white" },
                { tag: "green/white on lightgrey", background: "lightgrey", index: 2, textColor: "green" },
                { tag: "green/white on white", background: "white", index: 2, textColor: "green" },
                { tag: "green/white on yellow", background: "yellow", index: 2, textColor: "green" },
                { tag: "blue/darkgrey on black", background: "black", index: 3, textColor: "darkgrey" },
                { tag: "blue/darkgrey on lightgrey", background: "lightgrey", index: 3, textColor: "blue" },
                { tag: "blue/darkgrey on white", background: "white", index: 3, textColor: "blue" },
                { tag: "blue/darkgrey on yellow", background: "yellow", index: 3, textColor: "blue" },
            ];
        }

        function test_getTextColor(data) {
            tool.style = testCase.styles[data.index];
            var textColor = tool.getTextColor(Style.luminance(data.background));
            verify(Qt.colorEqual(textColor, data.textColor),
                   "TextColor not equal: %1 != %2".arg(textColor).arg(data.textColor));
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
                { tag: "default", index: 0, headerForeground: UbuntuColors.darkGrey },
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
                { tag: "default", index: 0, headerBackground: "color:///#ffffff" },
                { tag: "black", index: 3, headerBackground: "gradient:///white/blue" },
            ];
        }

        function test_headerBackground(data) {
            tool.style = testCase.styles[data.index];
            compare(tool.headerBackground, data.headerBackground, "Header background was incorrect.");
        }

        function test_headerDividerColor_data() {
            return [
                { tag: "default", index: 0, headerDividerColor: "#e0e0e0" },
                { tag: "blue", index: 2, headerDividerColor: "blue" },
            ];
        }

        function test_headerDividerColor(data) {
            tool.style = testCase.styles[data.index];
            verify(Qt.colorEqual(tool.headerDividerColor, data.headerDividerColor),
                   "Header divider color not equal: %1 != %2".arg(tool.headerDividerColor).arg(data.headerDividerColor));
        }

        function test_navigationBackground_data() {
            return [
                { tag: "default", index: 0, navigationBackground: "color:///#f5f5f5" },
                { tag: "black", index: 3, navigationBackground: "gradient:///white/blue" },
            ];
        }

        function test_navigationBackground(data) {
            tool.style = testCase.styles[data.index];
            compare(tool.navigationBackground, data.navigationBackground, "Navigation background was incorrect.");
        }

        function test_previewButtonColor_data() {
            return [
                { tag: "default", index: 0, previewButtonColor: UbuntuColors.orange },
                { tag: "red", index: 1, previewButtonColor: "red" },
            ];
        }

        function test_previewButtonColor(data) {
            tool.style = testCase.styles[data.index];
            verify(Qt.colorEqual(tool.previewButtonColor, data.previewButtonColor),
                   "Preview button color not equal: %1 != %2".arg(tool.previewButtonColor).arg(data.previewButtonColor));
        }
    }
}
