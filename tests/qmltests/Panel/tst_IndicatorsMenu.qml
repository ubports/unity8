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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtTest 1.0
import "../../../qml/Panel"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT
import Unity.Indicators 0.1 as Indicators

IndicatorTest {
    id: root
    width: units.gu(80)
    height: units.gu(71)
    color: "white"

    property string indicatorProfile: "phone"

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            id: itemArea
            color: "blue"

            IndicatorsMenu {
                id: indicatorsMenu
                width: units.gu(40)
                anchors {
                    top: parent.top
                    right: parent.right
                }
                minimizedPanelHeight: units.gu(3)
                expandedPanelHeight: units.gu(7)
                openedHeight: parent.height
                indicatorsModel: root.indicatorsModel
                shown: false
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: false

            Button {
                Layout.fillWidth: true
                text: indicatorsMenu.shown ? "Hide" : "Show"
                onClicked: {
                    if (indicatorsMenu.shown) {
                        indicatorsMenu.hide();
                    } else {
                        indicatorsMenu.show();
                    }
                }
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
        id: testCase
        name: "IndicatorsMenu"
        when: windowShown

        function init() {
            indicatorsMenu.hide();
            tryCompare(indicatorsMenu.hideAnimation, "running", false);
            compare(indicatorsMenu.state, "initial");
        }

        function get_indicator_item(index) {
            var indicatorItem = findChild(indicatorsMenu, indicatorsModel.originalModelData[index]["identifier"] + "-panelItem");
            verify(indicatorItem !== null);

            return indicatorItem;
        }

        // Showing the indicators should fully open the indicator panel.
        function test_showAndHide() {
            indicatorsMenu.show();
            tryCompare(indicatorsMenu, "fullyOpened", true);

            indicatorsMenu.hide();
            tryCompare(indicatorsMenu, "fullyClosed", true);
        }

        function test_progress_changes_state_to_reveal() {
            indicatorsMenu.height = indicatorsMenu.openedHeight / 2;
            compare(indicatorsMenu.state, "reveal", "Indicators should be locked when fully opened.");
        }

        function test_progress_changes_state_to_locked() {
            indicatorsMenu.height = indicatorsMenu.openedHeight;
            compare(indicatorsMenu.state, "locked", "Indicators should be locked when fully opened.");
        }

        function test_open_state() {
            compare(indicatorsMenu.fullyClosed, true, "Indicator should show as fully closed.");
            compare(indicatorsMenu.partiallyOpened, false, "Indicator should not show as partially opened");
            compare(indicatorsMenu.fullyOpened, false, "Indicator should not show as fully opened");

            indicatorsMenu.height = indicatorsMenu.openedHeight / 2
            compare(indicatorsMenu.fullyClosed, false, "Indicator should not show as fully closed.");
            compare(indicatorsMenu.partiallyOpened, true, "Indicator should show as partially opened");
            compare(indicatorsMenu.fullyOpened, false, "Indicator should not show as fully opened");

            indicatorsMenu.height = indicatorsMenu.openedHeight;
            compare(indicatorsMenu.fullyClosed, false, "Indicator should not show as fully closed.");
            compare(indicatorsMenu.partiallyOpened, false, "Indicator should show as partially opened");
            compare(indicatorsMenu.fullyOpened, true, "Indicator should not show as fully opened");
        }

        // Pressing on the indicator panel should activate the indicator hints
        // and expose the header
        function test_hint() {
            var indicatorItem = get_indicator_item(0);
            var mappedPosition = root.mapFromItem(indicatorItem, indicatorItem.width/2, indicatorItem.height/2);

            touchPress(indicatorsMenu, mappedPosition.x, indicatorsMenu.minimizedPanelHeight / 2);

            // hint animation should be run, meaning that indicators will move downwards
            // by hintValue pixels without any drag taking place
            tryCompareFunction(function() { return indicatorsMenu.height }, indicatorsMenu.expandedPanelHeight + units.gu(2));
            tryCompare(indicatorsMenu, "partiallyOpened", true);

            touchRelease(indicatorsMenu, mappedPosition.x, indicatorsMenu.minimizedPanelHeight / 2);
        }

        // tests swiping on an indicator item activates the correct item.
        function test_swipeForCurrentItem()
        {
            var indicatorItemRow = findChild(indicatorsMenu, "indicatorItemRow");
            verify(indicatorItemRow !== null);

            for (var i = 0; i < indicatorsModel.originalModelData.length; i++) {
                var indicatorItem = get_indicator_item(i);

                var mappedPosition = root.mapFromItem(indicatorItem, indicatorItem.width/2, indicatorItem.height/2);

                touchFlick(indicatorsMenu,
                           mappedPosition.x, mappedPosition.y,
                           mappedPosition.x, indicatorsMenu.openedHeight / 2,
                           true /* beginTouch */, false /* endTouch */);

                compare(indicatorItemRow.currentItem, indicatorItem,
                        "Incorrect item activated at position " + i);

                touchFlick(indicatorItemRow,
                           mappedPosition.x, indicatorsMenu.openedHeight / 2,
                           mappedPosition.x, mappedPosition.y,
                           false /* beginTouch */, true /* endTouch */);

                // wait until fully closed
                tryCompare(indicatorsMenu, "fullyClosed", true);
            }
        }

        // Test the vertical velocity check when flicking the indicators open at an angle.
        // If the vertical velocity is above a specific point, we shouldnt change active indicators
        // if the x position changes
        function test_verticalVelocityDetector() {
            verify(indicatorsModel.originalModelData.length >= 2);

            var indicatorItemRow = findChild(indicatorsMenu, "indicatorItemRow");
            verify(indicatorItemRow !== null);

            // Get the first indicator
            var firstItem = get_indicator_item(0);
            var firstItemMappedPosition = root.mapFromItem(firstItem, firstItem.width/2, firstItem.height/2);

            // 1) Drag the mouse down to hint a bit
            touchFlick(indicatorsMenu,
                       firstItemMappedPosition.x, indicatorsMenu.minimizedPanelHeight / 2,
                       firstItemMappedPosition.x, indicatorsMenu.minimizedPanelHeight * 2,
                       true /* beginTouch */, false /* endTouch */);

            tryCompare(indicatorItemRow, "currentItem", firstItem)

            // next time position will have moved.
            var nextItem = get_indicator_item(1);
            var nextItemMappedPosition = root.mapFromItem(nextItem, nextItem.width/2, nextItem.height/2);

            // 1) Flick mouse down to bottom
            touchFlick(indicatorsMenu,
                       firstItemMappedPosition.x, indicatorsMenu.minimizedPanelHeight * 2,
                       nextItemMappedPosition.x, indicatorsMenu.openedHeight / 3,
                       false /* beginTouch */, true /* endTouch */,
                       units.gu(5) /* speed */, 10 /* iterations */); // more samples needed for accurate velocity

            compare(indicatorItemRow.currentItem, firstItem, "First indicator should still be the current item");
        }
    }
}
