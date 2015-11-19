/*
 * Copyright 2013,2015 Canonical Ltd.
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
import "../../../qml/Components"
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(10)
    color: theme.palette.selected.background

    Rating {
        id: rating
        anchors.centerIn: parent
        maximumValue: 5
        size: 5
        value: 3
    }

    UT.UnityTestCase {
        name: "RatingTest"
        when: windowShown

        function init() {
            rating.maximumValue = 5;
            rating.size = 5
            rating.value = 3;
        }

        function test_interactive_rating_data() {
            return [
                {tag: "1st icon without interactive", interactive: false, size: 5, maximumValue: 5, index: 0, value: 3},
                {tag: "1st icon", interactive: true, size: 5, maximumValue: 5, index: 0, value: 1},
                {tag: "1st icon size 10", interactive: true, size: 10, maximumValue: 10, index: 0, value: 1},
                {tag: "3rd icon size 10 small maximumValue", interactive: true, size: 10, maximumValue: 5, index: 2, value: 1.5},
                {tag: "2nd icon with big maximumValue", interactive: true, size: 5, maximumValue: 100, index: 1, value: 40},
                {tag: "last icon", interactive: true, size: 5, maximumValue: 5, index: 4, value: 5},
            ];
        }

        function test_interactive_rating(data) {
            rating.interactive = data.interactive;
            rating.maximumValue = data.maximumValue;
            rating.size = data.size;

            var averageIconWidth = rating.width / rating.size;
            mouseClick(rating, averageIconWidth * data.index + averageIconWidth / 2, rating.height / 2);
            compare(rating.value, data.value);

            rating.interactive = false;
        }

        function test_effectiveValue_data() {
            return [
                {tag: "negative", value: -3, expectedValue: 0},
                {tag: "ranged value", value: 2, expectedValue: 2},
                {tag: "big", value: 200, expectedValue: rating.maximumValue},
                {tag: "min", value: 0, expectedValue: 0},
                {tag: "max", value: rating.maximumValue, expectedValue: rating.maximumValue},
                {tag: "half", value: 2.5, expectedValue: 2.5}
            ];
        }

        function test_effectiveValue(data) {
            rating.value = data.value;
            compare(rating.effectiveValue, data.expectedValue, "effectiveValue not calculated correctly")
        }
    }
}
