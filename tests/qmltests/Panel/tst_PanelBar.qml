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
import QtQuick.Layouts 1.1
import QtTest 1.0
import "../../../qml/Panel"
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT
import Unity.Indicators 0.1 as Indicators
import "../../../qml/Panel/Indicators"

PanelTest {
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

            PanelBar {
                id: indicatorsBar
                height: expanded ? units.gu(7) : units.gu(3)
                width: units.gu(widthSlider.value)
                anchors.centerIn: parent
                model: root.indicatorsModel
                interactive: expanded && height === units.gu(7)

                rowItemDelegate: Item {
                    property int ownIndex: index
                    objectName: model.identifier + "-panelItem"

                    implicitWidth: indicatorsBar.expanded ? units.gu(5) : units.gu(3)
                    height: parent.height

                    Rectangle {
                        anchors {
                            fill: parent
                            margins: 2
                        }
                        color: "red"
                        Label { anchors.centerIn: parent; text: ownIndex }
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        id: heightAnimation
                        duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing
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

            Slider {
                id: widthSlider
                Layout.fillWidth: true
                minimumValue: 10
                maximumValue: 60
                value: 30
            }

            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
            }

            Repeater {
                model: root.originalModelData
                RowLayout {
                    CheckBox {
                        checked: true
                        onCheckedChanged: checked ? insertIndicator(index) : removeIndicator(index);
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData["identifier"]
                    }

                    CheckBox {
                        checked: true
                        onCheckedChanged: setIndicatorVisible(index, checked);
                    }
                    Label {
                        text: "visible"
                    }
                }
            }
        }
    }

    UT.UnityTestCase {
        name: "IndicatorsBar"
        when: windowShown

        function init() {
            widthSlider.value = 30;
            indicatorsBar.expanded = false;
            wait_for_expansion_to_settle();
        }

        function test_expandSelectedItem_data() {
            return [
                { index: 0 },
                { index: 2 },
                { index: 4 }
            ];
        }

        function wait_for_expansion_to_settle() {
            waitUntilTransitionsEnd(indicatorsBar);
            tryCompare(heightAnimation, "running", false);
            wait(UbuntuAnimation.SnapDuration); // put a little extra wait in for things to settle
        }

        // Rough check that expanding a selected item keeps it within the area of the original item.
        function test_expandSelectedItem(data) {
            var dataItem = findChild(indicatorsBar, root.originalModelData[data.index]["identifier"] + "-panelItem");
            verify(dataItem !== null);

            waitForRendering(dataItem);
            var mappedPosition = indicatorsBar.mapFromItem(dataItem, dataItem.width/2, dataItem.height/2);
            indicatorsBar.selectItemAt(mappedPosition.x);
            indicatorsBar.expanded = true;
            wait_for_expansion_to_settle();

            // mappedPosition contained within mappedRect
            tryCompareFunction(function() {
                var mappedRect = indicatorsBar.mapFromItem(dataItem, 0, 0, dataItem.width, dataItem.height);
                return mappedRect.x <= mappedPosition.x; },
            true);
            tryCompareFunction(function() {
                var mappedRect = indicatorsBar.mapFromItem(dataItem, 0, 0, dataItem.width, dataItem.height);
                return mappedRect.x + mappedRect.width >= mappedPosition.x;
            }, true);
        }

        function test_scrollOffset() {
            indicatorsBar.expanded = true;
            wait_for_expansion_to_settle();

            var lastItemIndex = root.originalModelData.length-1;
            var dataItem = findChild(indicatorsBar, root.originalModelData[lastItemIndex]["identifier"] + "-panelItem");
            verify(dataItem !== null);

            var row = findChild(indicatorsBar, "panelItemRow");
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
            wait_for_expansion_to_settle();

            var dataItem = findChild(indicatorsBar, root.originalModelData[data.index]["identifier"] + "-panelItem");
            if (indicatorsBar.mapFromItem(dataItem, dataItem.width/2, dataItem.height/2).x < 0) {
                skip("Out of bounds");
            }
            mouseClick(dataItem);

            var row = findChild(indicatorsBar, "panelItemRow");
            compare(dataItem, row.currentItem, "Item should be selected");
        }

        // Rough test that resizing the IndicatorsBar has the items reposition correctly
        function test_widthChangeRepositionsItems() {
            var lastItemIndex = root.originalModelData.length-1;
            var dataItem = findChild(indicatorsBar, root.originalModelData[lastItemIndex]["identifier"] + "-panelItem");
            verify(dataItem !== null);

            var mappedPosition = indicatorsBar.mapFromItem(dataItem, dataItem.width/2, dataItem.height/2);
            var oldDistanceFromRightEdge = indicatorsBar.width - mappedPosition.x;

            widthSlider.value = 50;
            mappedPosition = indicatorsBar.mapFromItem(dataItem, dataItem.width/2, dataItem.height/2);
            var newDistanceFromRightEdge = indicatorsBar.width - mappedPosition.x;

            compare(newDistanceFromRightEdge, oldDistanceFromRightEdge);
        }
    }
}
