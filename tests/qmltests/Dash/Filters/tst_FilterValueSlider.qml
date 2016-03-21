/*
 * Copyright 2015 Canonical Ltd.
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
import "../../../../qml/Dash/Filters"
import Unity.Test 0.1 as UT
import Unity 0.2

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)
    color: theme.palette.selected.background

    QtObject {
        id: widgetData1

        property string title
        property int value: 30
        property int minValue: 10
        property int maxValue: 150

        property ListModel values: ListModel {
            ListElement {
                value: 10
                label: "10"
            }
            ListElement {
                value: 30
                label: "30"
            }
            ListElement {
                value: 100
                label: "100"
            }
            ListElement {
                value: 150
                label: "150"
            }
        }
    }

    FilterWidgetFactory {
        id: factory
        widgetId: "testRangeValueSlider"
        widgetType: Filters.ValueSliderFilter
        widgetData: widgetData1;
        y: 100
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    UT.UnityTestCase {
        name: "FilterValueSlider"
        when: windowShown

        function test_valueChanges() {
            var slider = findChild(factory, "slider");
            compare(slider.value, 30);

            slider.value = 50
            compare(widgetData1.value, 50);
        }

        function test_labelPositions() {
            var slider = findChild(factory, "slider");
            var repeater = findChild(factory, "repeater");

            // It's very hard to check the position of the
            // labels is right, but at least we can check
            // they all have different X positions and the
            // same Y one
            compare(repeater.count, 4);
            for (var i = 0; i < repeater.count; ++i) {
                var itemI = repeater.itemAt(i);
                for (var j = i + 1; j < repeater.count; ++j) {
                    var itemJ = repeater.itemAt(j);
                    verify(itemI.x != itemJ.x);
                    verify(itemI.y == itemJ.y);
                }
            }
        }
    }
}
