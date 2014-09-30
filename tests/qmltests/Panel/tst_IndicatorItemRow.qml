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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtTest 1.0
import "../../../qml/Panel"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT
import Unity.Indicators 0.1 as Indicators

IndicatorTest {
    id: root
    width: units.gu(100)
    height: units.gu(40)
    color: "white"

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            id: itemArea
            color: "blue"

            Rectangle {
                color: "black"
                anchors.fill: indicatorsRow
            }

            IndicatorItemRow {
                id: indicatorsRow
                height: expanded ? units.gu(7) : units.gu(3)
                anchors.centerIn: parent
                indicatorsModel: root.indicatorsModel
                enableLateralChanges: ma.pressed

                Behavior on height {
                    NumberAnimation {
                        id: heightAnimation
                        duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing
                    }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    onPositionChanged: { indicatorsRow.lateralPosition = mouse.x }
                    onPressed: {
                        if (pressed) {
                            indicatorsRow.selectItemAt(mouse.x);
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: false

            Button {
                Layout.fillWidth: true
                text: indicatorsRow.expanded ? "Collapse" : "Expand"
                onClicked: indicatorsRow.expanded = !indicatorsRow.expanded
            }

            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
            }

            Repeater {
                model: indicatorsModel.originalModelData
                RowLayout {
                    CheckBox {
                        checked: true
                        onCheckedChanged: checked ? insertIndicator(index) : removeIndicator(index);
                    }
                    Label { text: modelData["identifier"] }
                }
            }
        }
    }

    UT.UnityTestCase {
        name: "IndicatorItemRow"
        when: windowShown

        function init() {
            root.resetData();

            indicatorsRow.resetCurrentItem();
            indicatorsRow.lateralPosition = -1;

            indicatorsRow.expanded = false;
            tryCompare(heightAnimation, "running", false);
            tryCompare(findChild(indicatorsRow, "highlight"), "highlightCenterOffset", 0);
            wait(1); // row seems to take a bit of time for item x values to update.
        }

        function test_indicatorRowChanges_data() {
            return [
                { remove: [0, 2] },
                { remove: [0, 1, 2, 3, 4] },
            ];
        }

        // test the changes in the available indicators updates the
        // indicators that are visible.
        function test_indicatorRowChanges(data) {
            var i;
            var item;
            var itemsToRemove = [0, 2];

            verify(indicatorsModel.originalModelData.length > 0);
            for (i = 0; i < indicatorsModel.originalModelData.length; i++) {
                item = findChild(indicatorsRow, indicatorsModel.originalModelData[i]["identifier"]+"-panelItem");
                verify(item);

                compare(item.ownIndex, i, "Item at incorrect index");
            }

            for (i = data.remove.length-1; i >= 0; i--) {
                removeIndicator(data.remove[i]);
            }

            // test removals
            for (i = 0; i < indicatorsModel.originalModelData.length; i++) {
                item = findChild(indicatorsRow, indicatorsModel.originalModelData[i]["identifier"]+"-panelItem");

                verify(data.remove.indexOf(i) !== -1 ? (item === null) : (item !== null));
            }

            // test insertion
            for (i = 0; i < data.remove.length; i++) {
                insertIndicator(data.remove[i]);
            }

            for (i = 0; i < indicatorsModel.originalModelData.length; i++) {
                item = findChild(indicatorsRow, indicatorsModel.originalModelData[i]["identifier"]+"-panelItem");
                verify(item);

                compare(item.ownIndex, i, "Item at incorrect index");
            }
        }

        function test_validCurrentItem_data() {
            return [
                { index: 0 },
                { index: 2 },
                { index: 4 }
            ];
        }

        // test selecting the item at it's position sets the current item of the row.
        function test_validCurrentItem(data) {
            var dataItem = findChild(indicatorsRow, indicatorsModel.originalModelData[data.index]["identifier"]+"-panelItem");
            verify(dataItem !== null);

            indicatorsRow.selectItemAt(dataItem.x + dataItem.width/2);
            compare(indicatorsRow.currentItem, dataItem);
        }

        // tests item default selection (no item at position X)
        function test_invalidCurrentItem() {
            indicatorsRow.selectItemAt(-100);
            var item = findChild(indicatorsRow, indicatorsModel.originalModelData[0]["identifier"]+"-panelItem");
            compare(indicatorsRow.currentItem, item);
        }

        // testing that changing the lateral position offset of the row changes the current item.
        function test_lateralPositionChangesCurrentItem_data() {
            return [
                { tag: "0 -> 4", from: 0, to: 4 },
                { tag: "3 -> 1", from: 3, to: 1 }
            ];
        }

        function test_lateralPositionChangesCurrentItem(data) {
            indicatorsRow.expanded = true;
            tryCompare(heightAnimation, "running", false);

            var fromItem = findChild(indicatorsRow, indicatorsModel.originalModelData[data.from]["identifier"]+"-panelItem");
            verify(fromItem !== null);

            var toItem = findChild(indicatorsRow, indicatorsModel.originalModelData[data.to]["identifier"]+"-panelItem");
            verify(toItem !== null);

            var fromPosition = indicatorsRow.mapFromItem(fromItem, fromItem.width/2, fromItem.height/2);
            var toPosition = indicatorsRow.mapFromItem(toItem, toItem.width/2, toItem.height/2);

            mousePress(indicatorsRow, fromPosition.x, fromPosition.y);
            compare(indicatorsRow.currentItem, fromItem, "Initial item not selected");

            // this uses the MouseArea above to change the indicatorRow lateralPosition
            mouseFlick(indicatorsRow, fromPosition.x, fromPosition.y, toPosition.x, toPosition.y, false, false, units.gu(5), 30);

            mouseRelease(indicatorsRow, fromPosition.x, fromPosition.y);
            compare(indicatorsRow.currentItem, toItem, "Current item did not change to expected item");
        }

        // testing that positive changes to the lateral position offset shifts the highlight offset to the right
        function test_positiveLateralPositionChangesHighlightOffset() {
            indicatorsRow.expanded = true;
            tryCompare(heightAnimation, "running", false);

            var highlight = findChild(indicatorsRow, "highlight");
            var item = findChild(indicatorsRow, indicatorsModel.originalModelData[2]["identifier"]+"-panelItem");
            verify(item !== null);
            var mappedPosition = indicatorsRow.mapFromItem(item, item.width/2, item.height/2);

            mousePress(indicatorsRow, mappedPosition.x, mappedPosition.y);
            var originalHightlightX = highlight.x
            var offset = 1;
            while((highlight.x - originalHightlightX) <= units.gu(0.5) && offset < units.gu(10)) {
                mouseMove(indicatorsRow, mappedPosition.x + offset, mappedPosition.y, 10);
                offset = offset + 2;
            }
            // verify that we hit the offset
            verify((highlight.x - originalHightlightX) >= units.gu(0.5));
            mouseRelease(indicatorsRow);

            // should go back to 0
            tryCompare(highlight, "highlightCenterOffset", 0);
        }

        // testing that negative changes to the lateral position offset shifts the highlight offset to the left
        function test_negativeLateralPositionChangesHighlightOffset() {
            indicatorsRow.expanded = true;
            tryCompare(heightAnimation, "running", false);

            var highlight = findChild(indicatorsRow, "highlight");
            var item = findChild(indicatorsRow, indicatorsModel.originalModelData[2]["identifier"]+"-panelItem");
            verify(item !== null);
            var mappedPosition = indicatorsRow.mapFromItem(item, item.width/2, item.height/2);

            mousePress(indicatorsRow, mappedPosition.x, mappedPosition.y);
            var originalHightlightX = highlight.x
            var offset = 1;
            while((highlight.x - originalHightlightX) >= -units.gu(0.5) && offset < units.gu(10)) {
                mouseMove(indicatorsRow, mappedPosition.x - offset, mappedPosition.y, 10);
                offset = offset + 2;
            }

            // verify that we hit the offset
            verify((highlight.x - originalHightlightX) <= -units.gu(0.5));
            mouseRelease(indicatorsRow);

            // should go back to 0
            tryCompare(findChild(indicatorsRow, "highlight"), "highlightCenterOffset", 0);
        }
    }
}
