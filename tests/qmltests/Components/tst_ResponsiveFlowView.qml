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
import "../../../qml/Components"
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    width: flowRect.width + controls.width
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
        id: flowRect
        width: units.gu(80)
        height: parent.height
        color: "grey"
        anchors.top: parent.top
        anchors.left: parent.left

        ResponsiveFlowView {
            id: flow
            anchors.fill: parent
            model: fakeModel
            minimumHorizontalSpacing:
                minHSpacingSelector.values[minHSpacingSelector.selectedIndex]
            verticalSpacing: units.gu(2)
            maximumNumberOfColumns:
                maxColumnsSelector.values[maxColumnsSelector.selectedIndex]
            referenceDelegateWidth: units.gu(6)

            delegate: Rectangle {
                // So that it can be identified by test code
                property bool isFlowDelegate: true
                color: "grey"
                border.color: "red"
                border.width: 1

                // IMPORTANT: always use flow's cellWidth and cellHeight here to get
                // ResponsiveFlowView's intended result
                width: flow.cellWidth
                height: flow.cellHeight

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
        name: "ResponsiveFlowView"
        when: windowShown

        function test_maximumNumberOfColumns_data() {
            var data = new Array()

            data.push({selectedIndex: 0, maxColumnCount:2, columnCount: 2})
            data.push({selectedIndex: 1, maxColumnCount:4, columnCount: 4})
            data.push({selectedIndex: 2, maxColumnCount:8, columnCount: 8})
            data.push({selectedIndex: 4, maxColumnCount:1000, columnCount: 13})

            return data
        }

        /* Change ResponsiveFlowView's maximumNumberOfColumns property and check
           that the resulting number of columns matches expectations */
        function test_maximumNumberOfColumns(data) {
            minHSpacingSelector.selectedIndex = 0

            // sanity checks
            compare(maxColumnsSelector.values[data.selectedIndex], data.maxColumnCount)
            compare(minHSpacingSelector.values[0], 0)

            maxColumnsSelector.selectedIndex = data.selectedIndex
            tryCompareFunction(countFlowDelegatesOnFirstRow, data.columnCount);
            compare(flow.columns, data.columnCount)
        }

        function test_minimumHorizontalSpacing_data() {
            var data = new Array()

            data.push({selectedIndex: 0, minHSpacing:0, columnCount: 13})
            data.push({selectedIndex: 1, minHSpacing:units.gu(2), columnCount: 9})
            data.push({selectedIndex: 2, minHSpacing:units.gu(8), columnCount: 5})
            data.push({selectedIndex: 3, minHSpacing:units.gu(25), columnCount: 2})

            return data
        }

        /* Change ResponsiveFlowView's minimumHorizontalSpacing property and check
           that the resulting number of columns matches expectations */
        function test_minimumHorizontalSpacing(data) {
            maxColumnsSelector.selectedIndex = 4

            // sanity checks
            compare(maxColumnsSelector.values[4], 1000)
            compare(minHSpacingSelector.values[data.selectedIndex], data.minHSpacing)

            minHSpacingSelector.selectedIndex = data.selectedIndex
            tryCompareFunction(countFlowDelegatesOnFirstRow, data.columnCount);
            compare(flow.columns, data.columnCount)
        }

        function countFlowDelegatesOnFirstRow() {
            return __countFlowDelegatesOnFirstRow(flow.visibleChildren, 0)
        }

        function __countFlowDelegatesOnFirstRow(objList, total) {
            for (var i = 0; i < objList.length; ++i) {
                var child = objList[i];
                if (child.isFlowDelegate !== undefined && child.y === 0) {
                    ++total;
                } else {
                    total = __countFlowDelegatesOnFirstRow(child.visibleChildren, total)
                }
            }
            return total
        }
    }
}
