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
import ".."
import "../../../qml/Components"
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT

Item {
    width: gridRect.width + controls.width
    height: units.gu(80)

    Column {
        id: controls
        width: units.gu(40)
        height: parent.height
        anchors.top: parent.top
        anchors.right: parent.right
        ListItem.ValueSelector {
            id: maxColumnsSelector
            text: "maximumNumberOfColumns"
            values: [2,4,8,13,1000]
            selectedIndex: 1
        }
        ListItem.ValueSelector {
            id: minHSpacingSelector
            text: "minHorizontalSpacing"
            values: [0,units.gu(2),units.gu(8),units.gu(25)]
            selectedIndex: 0
        }
    }

    ListModel {
        id: fakeModel
        ListElement { name: "A" }
        ListElement { name: "B" }
        ListElement { name: "C" }
        ListElement { name: "D" }
        ListElement { name: "E" }
        ListElement { name: "F" }
        ListElement { name: "G" }
        ListElement { name: "H" }
        ListElement { name: "I" }
        ListElement { name: "J" }
        ListElement { name: "K" }
        ListElement { name: "L" }
        ListElement { name: "M" }
        ListElement { name: "N" }
        ListElement { name: "O" }
        ListElement { name: "P" }
        ListElement { name: "Q" }
        ListElement { name: "R" }
        ListElement { name: "S" }
        ListElement { name: "T" }
        ListElement { name: "U" }
    }

    Rectangle {
        id: gridRect
        width: units.gu(80)
        height: parent.height
        color: "grey"
        anchors.top: parent.top
        anchors.left: parent.left

        ResponsiveGridView {
            id: grid
            anchors.fill: parent
            model: fakeModel
            minimumHorizontalSpacing:
                minHSpacingSelector.values[minHSpacingSelector.selectedIndex]
            verticalSpacing: units.gu(2)
            maximumNumberOfColumns:
                maxColumnsSelector.values[maxColumnsSelector.selectedIndex]
            delegateWidth: units.gu(6)
            delegateHeight: units.gu(6)

            delegate: Rectangle {
                // So that it can be identified by test code
                property bool isGridDelegate: true
                color: "grey"
                border.color: "red"
                border.width: 1

                // IMPORTANT: always use grid's cellWidth and cellHeight here to get
                // ResponsiveGridView's intended result
                width: grid.cellWidth
                height: grid.cellHeight

                Rectangle {
                    color: "green"
                    anchors.centerIn: parent
                    width: units.gu(6)
                    height: units.gu(6)
                    Text {
                        anchors.centerIn: parent
                        text: name
                    }
                }

                Text { x:0; y:0; text:"(" + parent.x + ", " + parent.y + ")"}
            }
        }
    }

    UT.UnityTestCase {
        name: "ResponsiveGridView"
        when: windowShown

        function test_maximumNumberOfColumns_data() {
            var data = new Array()

            data.push({selectedIndex: 0, maxColumnCount:2, columnCount: 2})
            data.push({selectedIndex: 1, maxColumnCount:4, columnCount: 4})
            data.push({selectedIndex: 2, maxColumnCount:8, columnCount: 8})
            data.push({selectedIndex: 4, maxColumnCount:1000, columnCount: 13})

            return data
        }

        /* Change ResponsiveGridView's maximumNumberOfColumns property and check
           that the resulting number of columns matches expectations */
        function test_maximumNumberOfColumns(data) {
            minHSpacingSelector.selectedIndex = 0

            // sanity checks
            compare(maxColumnsSelector.values[data.selectedIndex], data.maxColumnCount)
            compare(minHSpacingSelector.values[0], 0)

            maxColumnsSelector.selectedIndex = data.selectedIndex
            tryCompareFunction(countGridDelegatesOnFirstRow, data.columnCount);
            compare(grid.columns, data.columnCount)
        }

        function test_minimumHorizontalSpacing_data() {
            var data = new Array()

            data.push({selectedIndex: 0, minHSpacing:0, columnCount: 13})
            data.push({selectedIndex: 1, minHSpacing:units.gu(2), columnCount: 10})
            data.push({selectedIndex: 2, minHSpacing:units.gu(8), columnCount: 5})
            data.push({selectedIndex: 3, minHSpacing:units.gu(25), columnCount: 2})

            return data
        }

        /* Change ResponsiveGridView's minimumHorizontalSpacing property and check
           that the resulting number of columns matches expectations */
        function test_minimumHorizontalSpacing(data) {
            maxColumnsSelector.selectedIndex = 4

            // sanity checks
            compare(maxColumnsSelector.values[4], 1000)
            compare(minHSpacingSelector.values[data.selectedIndex], data.minHSpacing)

            minHSpacingSelector.selectedIndex = data.selectedIndex
            tryCompareFunction(countGridDelegatesOnFirstRow, data.columnCount);
            compare(grid.columns, data.columnCount)
        }


        function countGridDelegatesOnFirstRow() {
            return __countGridDelegatesOnFirstRow(grid.visibleChildren, 0)
        }

        function __countGridDelegatesOnFirstRow(objList, total) {
            for (var i = 0; i < objList.length; ++i) {
                var child = objList[i];
                if (child.isGridDelegate !== undefined && child.y === 0) {
                    ++total;
                } else {
                    total = __countGridDelegatesOnFirstRow(child.visibleChildren, total)
                }
            }
            return total
        }
    }
}
