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

import QtQuick 2.4
import QtTest 1.0
import Dash 0.1

Item {
    width: units.gu(40)
    height: units.gu(4.5)

    property var testData: [
        [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"}],
        [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"},{"value":"text3"}],
        [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"},{"value":"text3"},{"value":"text4"}],
        [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"},{"value":"text3","style":"highlighted"},{"value":"text4","icon":"image://theme/close","style":"highlighted"},{"value":"text5"}],
        [{"value":"text1","icon":"image://theme/ok"},{},{},{},{"value":"text5", "icon": "image://theme/search"}],
    ]

    CardAttributes {
        id: cardAttributes
        model: testData[3]
        clip: true
    }

    TestCase {
        name: "CardAttributesTest"
        when: windowShown

        function init() {
        }

        function test_columns_data() {
            return testData;
        }

        function test_columns(data) {
            cardAttributes.model = data;
            compare(cardAttributes.columns, 2 + data.length % 2);
            var rows = Math.ceil(data.length / 3);
            tryCompare(cardAttributes, "height", rows * units.gu(2) + (rows - 1) * cardAttributes.rowSpacing);
        }
    }
}
