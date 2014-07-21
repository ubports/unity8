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
import Dash 0.1

Item {
    width: units.gu(40)
    height: units.gu(30)

    property var testData: [
        [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"}],
        [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"},{"value":"text3"}]
    ]

    CardAttributesGrid {
        id: cardAttributesGrid
        model: testData[0]
    }

    TestCase {
        name: "CardAttributesGridTest"
        when: windowShown

        function init() {
        }

        function test_columns_data() {
            return testData;
        }

        function test_columns(data) {
            cardAttributesGrid.model = data;
            compare(cardAttributesGrid.columns, data.length);
        }
    }
}
