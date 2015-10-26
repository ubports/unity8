/*
 * Copyright 2013-2014 Canonical Ltd.
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
import Utils 0.1
import Unity.Test 0.1 as UT

Item {
    width: units.gu(80) + controls.width
    height: units.gu(80)

    Column {
        id: controls
        width: units.gu(40)
        height: parent.height
        anchors.top: parent.top
        anchors.right: parent.right
        ListItem.ValueSelector {
            id: cardSizeSelector
            text: "card-size"
            // small, medium, large card sizes
            values: [units.gu(12), units.gu(18.5), units.gu(38)]
            selectedIndex: 0
        }
        ListItem.ValueSelector {
            id: minColumnSpacingSelector
            text: "minColumnSpacing"
            values: [0, units.gu(2), units.gu(8), units.gu(25)]
            selectedIndex: 0
        }
        ListItem.ValueSelector {
            id: rowSpacingSelector
            text: "rowSpacing"
            values: [units.gu(1), units.gu(2), units.gu(4), units.gu(8)]
            selectedIndex: 1
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

    UnitySortFilterProxyModel {
        id: wrappedFakeModel
        model: fakeModel
    }

    Rectangle {
        id: journalRect
        height: parent.height
        color: "grey"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: controls.left

        ResponsiveVerticalJournal {
            id: journal
            anchors.fill: parent
            model: wrappedFakeModel
            minimumColumnSpacing: minColumnSpacingSelector.values[minColumnSpacingSelector.selectedIndex]
            rowSpacing: rowSpacingSelector.values[rowSpacingSelector.selectedIndex]
            columnWidth: cardSizeSelector.values[cardSizeSelector.selectedIndex]

            delegate: Rectangle {
                id: delegateItem
                // So that it can be identified by test code
                property bool isJournalDelegate: true
                objectName: "delegate" + index
                color: "grey"
                border.color: "red"
                border.width: 1

                // width derived from Card's template['card-size']
                width: cardSizeSelector.values[cardSizeSelector.selectedIndex]
                height: Math.max(units.gu(8), Math.floor(Math.random() * 300))

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
        name: "ResponsiveVerticalJournal"
        when: windowShown

        function test_minimumColumnSpacing_data() {
            return [{minColumnSpacingIndex: 0, expectedColumns: 2},
                    {minColumnSpacingIndex: 1, expectedColumns: 2},
                    {minColumnSpacingIndex: 2, expectedColumns: 1}]
        }

        // Test how minimumColumnSpacing affects column count.
        function test_minimumColumnSpacing(data) {
            cardSizeSelector.selectedIndex = 2 // large card

            minColumnSpacingSelector.selectedIndex = data.minColumnSpacingIndex

            tryCompareFunction(countJournalDelegatesOnFirstRow, data.expectedColumns)
        }

        function test_maximumNumberOfColumns_data() {
            return [{cardSizeIndex: 0, expectedColumns: 6},
                    {cardSizeIndex: 1, expectedColumns: 4},
                    {cardSizeIndex: 2, expectedColumns: 2}]
        }

        // Test how maximumNumberOfColumns and columnWidth affect column count.
        function test_maximumNumberOfColumns(data) {
            minColumnSpacingSelector.selectedIndex = 0 // no spacing

            cardSizeSelector.selectedIndex = data.cardSizeIndex // columnWidth

            tryCompareFunction(countJournalDelegatesOnFirstRow, data.expectedColumns)
        }

        function countJournalDelegatesOnFirstRow() {
            return __countJournalDelegatesOnFirstRow(journal.visibleChildren, 0)
        }

        function __countJournalDelegatesOnFirstRow(objList, total) {
            for (var i = 0; i < objList.length; ++i) {
                var child = objList[i];
                if (child.isJournalDelegate !== undefined && child.y === 0) {
                    ++total;
                } else {
                    total = __countJournalDelegatesOnFirstRow(
                            child.visibleChildren, total)
                }
            }
            return total
        }
    }
}
