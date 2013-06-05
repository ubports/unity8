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
import ".."
import "../../../Panel"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Rectangle {
    width: units.gu(10)
    height: units.gu(5)
    color: "black"

    IndicatorItem {
        id: indicatorItem
        anchors.fill: parent
        iconSource: "../../../Panel/graphics/Clock.png"
        label: "Clock"
    }

    UT.UnityTestCase {
        name: "IndicatorItem"

        function init_test() {
            indicatorItem.iconSource = "../../../Panel/graphics/Clock.png"
            indicatorItem.label = "Clock"
        }

        function test_dimmed() {
            init_test()

            var itemRow = findChild(indicatorItem, "itemRow")
            indicatorItem.dimmed = true
            compare(itemRow.opacity > 0, true, "IndicatorItem opacity should not be 0")
            compare(itemRow.opacity < 1, true, "IndicatorItem opacity should not be 1")
        }

        function test_empty() {
            init_test()

            indicatorItem.iconSource = ""
            indicatorItem.label = ""
            compare(indicatorItem.visible, false, "IndicatorItem should not be visible")
        }

        function test_noLabel() {
            init_test()

            var itemImage = findChild(indicatorItem, "itemImage")
            var itemLabel = findChild(indicatorItem, "itemLabel")
            indicatorItem.label = ""
            compare(itemImage.visible, true, "The image should be visible")
            compare(itemImage.width > 0, true, "The image should have a positive width")
            compare(itemLabel.width > 0, false, "The label should not have a positive width")
        }

        function test_noImage() {
            init_test()

            var itemImage = findChild(indicatorItem, "itemImage")
            var itemLabel = findChild(indicatorItem, "itemLabel")
            indicatorItem.iconSource = ""
            compare(itemImage.visible, false, "The image should not be visible")
            compare(itemLabel.width > 0, true, "The label should have a positive width")
        }
    }
}
