/*
 * Copyright (C) 2015 Canonical, Ltd.
 * Copyright (C) 2021 UBports Foundation
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


Image {
    id: root
    width: 70
    height: 70

    source: wallpaperResolver.background

    readonly property url blue: Qt.resolvedUrl("../../data/unity/backgrounds/blue.png")
    readonly property url red: Qt.resolvedUrl("../../data/unity/backgrounds/red.png")
    readonly property url big: Qt.resolvedUrl("../../graphics/applicationIcons/dash.png")

    WallpaperResolver {
        id: wallpaperResolver

        property var pastBackgrounds: []

        onBackgroundChanged: pastBackgrounds.push(background)
    }

    SignalSpy {
        id: spy
        signalName: "backgroundChanged"
        target: wallpaperResolver
    }

    UnityTestCase {
        id: testCase
        name: "WallpaperResolver"
        when: windowShown

        function test_background_data() {
            return [
                {tag: "empty-candidates",
                 list: [],
                 output: ""},

                {tag: "blank-candidate",
                 list: [""],
                 output: ""},

                {tag: "blank-urls",
                 list: [Qt.resolvedUrl(""), Qt.resolvedUrl(""), root.blue],
                 output: root.blue},

                {tag: "invalid-urls",
                 list: [Qt.resolvedUrl("/first"), Qt.resolvedUrl("/middle"), root.blue],
                 output: root.blue},

                {tag: "valid-after-blanks",
                 list: ["", "", root.red],
                 output: root.red},

                // Ensure that the WallpaperResolver doesn't get stuck if it
                // sees the same invalid wallpaper multiple times in a row
                {tag: "valid-after-the-same-invalid",
                 list: ["/first", "/first", "/first", root.red],
                 output: root.red},

                {tag: "naughty",
                 list: [null, undefined, "", NaN, 1.0, 1, root.red, null],
                 output: root.red},

                {tag: "none-valid",
                 list: ["/first", "/middle", "/last"],
                 output: Qt.resolvedUrl("/last")},

                {tag: "first-valid",
                 list: [root.blue, "/middle", "/last"],
                 output: root.blue},

                {tag: "middle-valid",
                 list: ["/first", root.red, "/last"],
                 output: root.red},

                {tag: "last-valid",
                 list: ["/first", "/middle", root.red],
                 output: root.red},

                {tag: "multiple-valid",
                 list: [root.blue, root.red],
                 output: root.blue},

                {tag: "multiple-valid-after-multiple-invalid",
                 list: ["/first", "/middle", "/last", root.blue, root.red],
                 output: root.blue},

            ]
        }

        function init() {
            // Make sure we don't have our next test compare() to the results
            // of the last test by exercising the resolver
            wallpaperResolver.cache = true;
            wallpaperResolver.candidates = [];
            tryCompare(wallpaperResolver, "background", "");
            wallpaperResolver.pastBackgrounds = [];
            wallpaperResolver.candidates = [root.blue, root.blue];
            tryCompare(wallpaperResolver, "background", root.blue);
            wallpaperResolver.candidates = [];
            tryCompare(wallpaperResolver, "background", "");
            tryCompare(wallpaperResolver, "pastBackgrounds", [root.blue, Qt.resolvedUrl("")])
            wallpaperResolver.pastBackgrounds = [];
        }

        function test_background(data) {
            wallpaperResolver.candidates = data.list;
            tryCompare(wallpaperResolver, "background", data.output);
        }

        function test_reload_with_blanks() {
            wallpaperResolver.candidates = ["", "", root.red];
            tryCompare(wallpaperResolver, "background", root.red);
            wallpaperResolver.candidates = ["", "", root.blue];
            tryCompare(wallpaperResolver, "background", root.blue);
        }

        // WallpaperResolver loads images asynchronously. It's important to make
        // sure that it never returns the wrong image just because they loaded
        // in the wrong order. So we set its images 100 times.
        function test_images_changing() {
            wallpaperResolver.cache = false;
            for (var i = 0; i < 50; i++) {
                // We don't spy on the first one because the wallpaper doesn't
                // transition from a set url to "" the first time.
                wallpaperResolver.candidates = [root.red, root.big, root.blue];
                tryCompare(wallpaperResolver, "background", root.red);

                spy.clear();
                wallpaperResolver.pastBackgrounds = [];
                wallpaperResolver.candidates = [root.big, root.blue, root.red];
                tryCompare(wallpaperResolver, "background", root.big);
                compare(wallpaperResolver.pastBackgrounds, ["", root.big])
                compare(spy.count, 4);
            }
        }
    }
}
