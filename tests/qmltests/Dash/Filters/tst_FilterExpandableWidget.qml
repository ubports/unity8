/*
 * Copyright 2016 Canonical Ltd.
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

        property string title: "Expand me!"
        property ListModel filters: ListModel {
            dynamicRoles: true
        }
    }

    QtObject {
        id: sliderObject

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

    Component.onCompleted: {
        widgetData1.filters.append({"type": Filters.ValueSliderFilter, "filter": sliderObject, id: "trololo"});
    }

    FilterWidgetFactory {
        id: factory
        widgetId: "testExpandableWidget"
        widgetType: Filters.ExpandableFilterWidget
        widgetData: widgetData1
        anchors {
            left: parent.left
            right: parent.right
        }
        height: implicitHeight
        clip: true
    }

    UT.UnityTestCase {
        name: "FilterExpandableWidget"
        when: windowShown

        function test_expandedChanges() {
            var expandingItem = findChild(factory, "expandingItem");
            verify(!expandingItem.expanded)
            compare(expandingItem.height, expandingItem.collapsedHeight)
            mouseClick(expandingItem);
            verify(expandingItem.expanded)
            tryCompare(expandingItem, "height", expandingItem.expandedHeight)
            verify(expandingItem.collapsedHeight < expandingItem.expandedHeight / 2);
        }

    }
}
