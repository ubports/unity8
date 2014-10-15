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
import "../../../qml/Panel"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Rectangle {
    width: units.gu(10)
    height: units.gu(5)
    color: "black"

    IndicatorItem {
        id: indicatorItem
        anchors.fill: parent
    }

    UT.UnityTestCase {
        name: "IndicatorItem"

        function test_dimmed() {
            indicatorItem.dimmed = false;
            tryCompareFunction(function(){return indicatorItem.opacity}, 1.0);
            indicatorItem.dimmed = true;
            tryCompareFunction(function(){return indicatorItem.opacity < 1.0}, true);
        }

        function test_empty() {
            compare(indicatorItem.indicatorVisible, false, "IndicatorItem should not be visible.");
            indicatorItem.widgetSource = "../../../qml/Panel/Indicators/DefaultIndicatorWidget.qml";
            tryCompare(indicatorItem, "indicatorVisible", true);
        }
    }
}
