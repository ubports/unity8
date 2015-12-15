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
import Utils 0.1

TestCase {
    id: testCase
    name: "UtilsStyle"

    property color color

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
        compare(Style.luminance(testCase.color).toFixed(4), data.luminance.toFixed(4));
    }
}
