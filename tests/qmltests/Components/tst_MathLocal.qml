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
import "../../../Components/Math.js" as MathLocal

TestCase {
    name: "MathLocal"

    property int minValue
    property int maxValue
    property int clampValue
    property int clamped

    function test_clamp_positive_lower() {
        minValue = 9
        maxValue = 42
        clampValue = -7

        clamped = MathLocal.clamp(clampValue, minValue, maxValue)
        compare(clamped, minValue, "clamped value not within range")
    }

    function test_clamp_positive_greater() {
        minValue = 9
        maxValue = 42
        clampValue = 111

        clamped = MathLocal.clamp(clampValue, minValue, maxValue)
        compare(clamped, maxValue, "clamped value not within range")
    }

    function test_clamp_positive_within() {
        minValue = 9
        maxValue = 53
        clampValue = 42

        clamped = MathLocal.clamp(clampValue, minValue, maxValue)
        compare(clamped, clampValue, "clamped value changed even though it shouldn't have")
    }

    function test_clamp_positive_on_border() {
        minValue = 9
        maxValue = 42
        clampValue = 9

        clamped = MathLocal.clamp(clampValue, minValue, maxValue)
        compare(clamped, clampValue, "clamped value changed even though it shouldn't have")
    }

    function test_clamp_negative_lower() {
        minValue = -42
        maxValue = -9
        clampValue = -50

        clamped = MathLocal.clamp(clampValue, minValue, maxValue)
        compare(clamped, minValue, "clamped value not within range")
    }

    function test_clamp_negative_greater() {
        minValue = -42
        maxValue = -9
        clampValue = 50

        clamped = MathLocal.clamp(clampValue, minValue, maxValue)
        compare(clamped, maxValue, "clamped value not within range")
    }

    function test_clamp_postive_and_negative_greater() {
        minValue = -42
        maxValue = 9
        clampValue = 50

        clamped = MathLocal.clamp(clampValue, minValue, maxValue)
        compare(clamped, maxValue, "clamped value not within range")
    }
}
