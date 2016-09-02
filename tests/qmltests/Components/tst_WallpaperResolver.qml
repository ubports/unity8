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
import QtTest 1.0
import Ubuntu.Components 1.3
import Unity.Test 0.1

import "../../../qml/Components"


Image {
    width: units.gu(70)
    height: units.gu(70)

    source: wallpaperResolver.background

    WallpaperResolver {
        id: wallpaperResolver
    }

    UnityTestCase {
        id: testCase
        name: "WallpaperResolver"
        when: windowShown

        function test_background_data() {
            return [
                {tag: "none-valid",
                 list: ["/first", "/middle", "/last"],
                 output: "file:///last"},

                {tag: "first-valid",
                 list: [Qt.resolvedUrl("../../data/unity/backgrounds/blue.png"),
                        "/middle", "/last"],
                 output: Qt.resolvedUrl("../../data/unity/backgrounds/blue.png")},

                {tag: "middle-valid",
                 list: ["/first",
                        Qt.resolvedUrl("../../data/unity/backgrounds/red.png"),
                        "/last"],
                 output: Qt.resolvedUrl("../../data/unity/backgrounds/red.png")},

                {tag: "last-valid",
                 list: ["/first",
                        "/middle",
                        Qt.resolvedUrl("../../data/unity/backgrounds/red.png")],
                 output: Qt.resolvedUrl("../../data/unity/backgrounds/red.png")},

                {tag: "multiple-valid",
                 list: [Qt.resolvedUrl("../../data/unity/backgrounds/blue.png"),
                        Qt.resolvedUrl("../../data/unity/backgrounds/red.png")],
                 output: Qt.resolvedUrl("../../data/unity/backgrounds/blue.png")},
            ]
        }

        function test_background(data) {
            wallpaperResolver.candidates = data.list;
            tryCompare(wallpaperResolver, "background", data.output);
        }
    }
}
