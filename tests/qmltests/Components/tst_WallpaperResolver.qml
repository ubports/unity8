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
import AccountsService 0.1
import GSettings 1.0

import "../../../qml/Components"


Image {
    width: units.gu(70)
    height: units.gu(70)

    source: wallpaperResolver.background

    WallpaperResolver {
        id: wallpaperResolver
        width: units.gu(70)
    }

    UnityTestCase {
        id: testCase
        name: "WallpaperResolver"
        when: windowShown

        function test_background_data() {
            return [
                {tag: "color",
                 accounts: Qt.resolvedUrl("data:image/svg+xml,<svg><rect width='100%' height='100%' fill='#dd4814'/></svg>"),
                 gsettings: "",
                 output: Qt.resolvedUrl("data:image/svg+xml,<svg><rect width='100%' height='100%' fill='#dd4814'/></svg>")},

                {tag: "empty", accounts: "", gsettings: "", output: "defaultBackground"},

                {tag: "as-specified",
                 accounts: Qt.resolvedUrl("../../data/unity/backgrounds/blue.png"),
                 gsettings: "",
                 output: Qt.resolvedUrl("../../data/unity/backgrounds/blue.png")},

                {tag: "gs-specified",
                 accounts: "",
                 gsettings: Qt.resolvedUrl("../../data/unity/backgrounds/red.png"),
                 output: Qt.resolvedUrl("../../data/unity/backgrounds/red.png")},

                {tag: "both-specified",
                 accounts: Qt.resolvedUrl("../../data/unity/backgrounds/blue.png"),
                 gsettings: Qt.resolvedUrl("../../data/unity/backgrounds/red.png"),
                 output: Qt.resolvedUrl("../../data/unity/backgrounds/blue.png")},

                {tag: "invalid-as",
                 accounts: Qt.resolvedUrl("../../data/unity/backgrounds/nope.png"),
                 gsettings: Qt.resolvedUrl("../../data/unity/backgrounds/red.png"),
                 output: Qt.resolvedUrl("../../data/unity/backgrounds/red.png")},

                {tag: "invalid-both",
                 accounts: Qt.resolvedUrl("../../data/unity/backgrounds/nope.png"),
                 gsettings: Qt.resolvedUrl("../../data/unity/backgrounds/stillnope.png"),
                 output: "defaultBackground"},
            ]
        }
        function test_background(data) {
            AccountsService.backgroundFile = data.accounts;
            GSettingsController.setPictureUri(data.gsettings);

            if (data.output === "defaultBackground") {
                tryCompare(wallpaperResolver, "background", wallpaperResolver.defaultBackground);
            } else {
                tryCompare(wallpaperResolver, "background", data.output);
            }
        }
    }
}
