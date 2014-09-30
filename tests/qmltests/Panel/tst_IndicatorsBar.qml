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


    RowLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)

        Rectangle {
            id: itemArea
            color: "blue"
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                color: "black"
                anchors.fill: indicatorsBar
            }

            IndicatorsBar {
                id: indicatorsBar
                height: expanded ? units.gu(7) : units.gu(3)
                width: units.gu(30)
                anchors.centerIn: parent
                indicatorsModel: root.indicatorsModel

                Behavior on height {
                    NumberAnimation {
                        id: heightAnimation
                        duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !indicatorsBar.expanded
                    onPressed: {
                        indicatorsBar.selectItemAt(mouse.x);
                        indicatorsBar.expanded = true
                    }
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: false

            Button {
                Layout.fillWidth: true
                text: indicatorsBar.expanded ? "Collapse" : "Expand"
                onClicked: indicatorsBar.expanded = !indicatorsBar.expanded
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
        name: "IndicatorsBar"
        when: windowShown

        function init() {
            indicatorsBar.expanded = false;
            tryCompare(heightAnimation, "running", false);
        }

        function test_expandSelectedItem_data() {
            return [
                { index: 0 },
                { index: 2 },
                { index: 4 }
            ];
        }

        // Rough check that expanding a selected item keeps it within the area of the original item.
        function test_expandSelectedItem(data) {
            var dataItem = findChild(indicatorsBar, indicatorsModel.originalModelData[data.index]["identifier"]+"-panelItem");
            verify(dataItem !== null);

            var mappedPosition = indicatorsBar.mapFromItem(dataItem, dataItem.width/2, dataItem.height/2);

            indicatorsBar.selectItemAt(mappedPosition.x);
            indicatorsBar.expanded = true;

            // wait for animations to finish
            tryCompare(heightAnimation, "running", false);

            var mappedRect = indicatorsBar.mapFromItem(dataItem, 0, 0, dataItem.width, dataItem.height);

            // mappedPosition contained within mappedRect
            verify(mappedRect.x <= mappedPosition.x)
            verify(mappedRect.x + mappedRect.width >= mappedPosition.x)
        }

        function test_scrollOffset() {
            indicatorsBar.expanded = true;
            tryCompare(heightAnimation, "running", false);

            var dataItem = findChild(indicatorsBar, indicatorsModel.originalModelData[indicatorsModel.originalModelData.length-1]["identifier"]+"-panelItem");
            verify(dataItem !== null);

            var row = findChild(indicatorsBar, "indicatorItemRow");
            // test will not work without these conditions
            verify(row.width >= indicatorsBar.width + dataItem.width);

            var mappedPosition = indicatorsBar.mapFromItem(dataItem, dataItem.width/2, dataItem.height/2);
            indicatorsBar.addScrollOffset(-dataItem.width);
            var newMappedPosition = indicatorsBar.mapFromItem(dataItem, dataItem.width/2, dataItem.height/2);

            compare(mappedPosition.x, newMappedPosition.x - dataItem.width);
        }

        function test_selectItemWhenExpanded_data() {
            return [
                { index: 3 },
                { index: 4 }
            ];
        }

        function test_selectItemWhenExpanded(data) {
            indicatorsBar.expanded = true;
            tryCompare(heightAnimation, "running", false);

            var dataItem = findChild(indicatorsBar, indicatorsModel.originalModelData[data.index]["identifier"]+"-panelItem");
            if (indicatorsBar.mapFromItem(dataItem, dataItem.width/2, dataItem.height/2).x < 0) {
                skip("Out of bounds");
            }
            mouseClick(dataItem, dataItem.width/2, dataItem.height/2);
            verify(dataItem.selected === true);
        }
    }
}
