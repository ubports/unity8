/*
 * Copyright 2013-2016 Canonical Ltd.
 * Copyright 2019 UBports Foundation
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

PanelTest {
    id: root
    width: units.gu(80)
    height: units.gu(71)

    SignalSpy {
        id: clickThroughSpy
        target: clickThroughTester
    }

    SignalSpy {
        id: showTappedSpy
        target: indicatorsMenu
        signalName: "showTapped"
    }

    MouseArea {
        id: clickThroughTester
        anchors.fill: root
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            id: itemArea
            color: "blue"

            PanelMenu {
                id: indicatorsMenu
                width: units.gu(40)
                anchors {
                    top: parent.top
                    right: parent.right
                }
                minimizedPanelHeight: units.gu(3)
                expandedPanelHeight: units.gu(7)
                openedHeight: parent.height
                model: root.indicatorsModel
                shown: false

                rowItemDelegate: Item {
                    property int ownIndex: index
                    objectName: model.identifier + "-panelItem"

                    implicitWidth: indicatorsMenu.expanded ? units.gu(5) : units.gu(3)
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
        id: testCase
        name: "PanelMenu"
        when: windowShown

        function init() {
            indicatorsMenu.verticalVelocityThreshold = 0.5
            tryCompare(indicatorsMenu.hideAnimation, "running", false);
            tryCompare(indicatorsMenu, "state", "initial");
            wait(100);
        }

        function cleanup() {
            touchRelease(root);
            clickThroughSpy.clear();
            showTappedSpy.clear();
            indicatorsMenu.hideAnimation.complete();
            indicatorsMenu.hideNow();
        }

        function get_indicator_item(index) {
            var indicatorItem = findChild(indicatorsMenu, root.originalModelData[index]["identifier"] + "-panelItem");
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

        // Test that closing the indicators ends up in the correct position.
        function test_hideEndsInCorrectPosition() {
            var indicatorsBar = findChild(indicatorsMenu, "indicatorsBar");
            var flickable = findChild(indicatorsBar, "flickable");

            var originalContentX = flickable.contentX;

            indicatorsMenu.show();
            indicatorsBar.setCurrentItemIndex(0);
            tryCompare(indicatorsMenu, "fullyOpened", true);

            indicatorsMenu.hide();
            tryCompare(flickable, "contentX", originalContentX);
        }

        function test_progress_changes_state_to_reveal() {
            var firstItem = get_indicator_item(0);
            var firstItemMappedPosition = indicatorsMenu.mapFromItem(firstItem, firstItem.width/2, firstItem.height/2);
            touchPress(indicatorsMenu, firstItemMappedPosition.x, indicatorsMenu.minimizedPanelHeight / 2);

            indicatorsMenu.height = indicatorsMenu.openedHeight / 2;
            tryCompare(indicatorsMenu, "state", "reveal", 5000, "Indicators should be revealing when partially opened.");

            indicatorsMenu.height = indicatorsMenu.openedHeight;
            compare(indicatorsMenu.state, "reveal", "Indicators should still be revealing when fully opened.");

            touchRelease(indicatorsMenu, firstItemMappedPosition.x, indicatorsMenu.minimizedPanelHeight / 2);
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
            var mappedPosition = indicatorsMenu.mapFromItem(indicatorItem, indicatorItem.width/2, indicatorItem.height/2);

            touchPress(indicatorsMenu, mappedPosition.x, indicatorsMenu.minimizedPanelHeight / 2);

            // hint animation should be run, meaning that indicators will move downwards
            // by hintValue pixels without any drag taking place
            tryCompareFunction(function() { return indicatorsMenu.height }, indicatorsMenu.expandedPanelHeight + units.gu(2));
            tryCompare(indicatorsMenu, "partiallyOpened", true);

            touchRelease(indicatorsMenu, mappedPosition.x, indicatorsMenu.minimizedPanelHeight / 2);
        }

        function test_swipeForCurrentItem_data() {
            return [
                {item: 0},
                {item: 1},
                {item: 2},
                {item: 3},
                {item: 4},
                {item: 5},
                {item: 6},
                {item: 7},
                {item: 8},
            ]
        }

        // tests swiping on an indicator item activates the correct item.
        function test_swipeForCurrentItem(data)
        {
            var panelItemRow = findChild(indicatorsMenu, "panelItemRow");
            verify(panelItemRow !== null);

            var indicatorItem = get_indicator_item(data.item);

            var mappedPosition = indicatorsMenu.mapFromItem(indicatorItem, indicatorItem.width/2, indicatorItem.height/2);

            touchFlick(indicatorsMenu,
                        mappedPosition.x, mappedPosition.y,
                        mappedPosition.x, indicatorsMenu.openedHeight / 2,
                        true /* beginTouch */, false /* endTouch */);

            tryCompare(panelItemRow, "currentItem", indicatorItem, undefined /*timeout, default */,
                        "Incorrect item activated at position " + data.item);

            touchFlick(panelItemRow,
                        mappedPosition.x, indicatorsMenu.openedHeight / 2,
                        mappedPosition.x, mappedPosition.y,
                        false /* beginTouch */, true /* endTouch */);

            // wait until fully closed
            tryCompare(indicatorsMenu, "fullyClosed", true);
        }

        // Test the vertical velocity check when flicking the indicators open at an angle.
        // If the vertical velocity is above a specific point, we shouldnt change active indicators
        // if the x position changes
        function test_verticalVelocityDetector() {
            indicatorsMenu.verticalVelocityThreshold = 0;
            verify(root.originalModelData.length >= 2);

            var panelItemRow = findChild(indicatorsMenu, "panelItemRow");
            verify(panelItemRow !== null);

            // Get the first indicator
            var firstItem = get_indicator_item(0);
            var firstItemMappedPosition = indicatorsMenu.mapFromItem(firstItem, firstItem.width/2, firstItem.height/2);

            // 1) Drag the mouse down to hint a bit
            touchFlick(indicatorsMenu,
                       firstItemMappedPosition.x, indicatorsMenu.minimizedPanelHeight / 2,
                       firstItemMappedPosition.x, indicatorsMenu.minimizedPanelHeight * 2,
                       true /* beginTouch */, false /* endTouch */);

            tryCompare(panelItemRow, "currentItem", firstItem)

            // next time position will have moved.
            var nextItem = get_indicator_item(1);
            var nextItemMappedPositionX = firstItemMappedPosition.x + firstItem.width;

            firstItemMappedPosition = indicatorsMenu.mapFromItem(firstItem, firstItem.width/2, firstItem.height/2);

            // 1) Flick mouse down to bottom
            touchFlick(indicatorsMenu,
                       firstItemMappedPosition.x, indicatorsMenu.minimizedPanelHeight * 2,
                       nextItemMappedPositionX, indicatorsMenu.openedHeight / 3,
                       false /* beginTouch */, false /* endTouch */,
                       units.gu(50) /* speed */, 5 /* iterations */); // more samples needed for accurate velocity

            tryCompare(panelItemRow, "currentItem", firstItem, undefined /* timeout, default */,
                       "First indicator should still be the current item");
            // after waiting in the same spot with touch down, it should update to the next item.
            tryCompare(panelItemRow, "currentItem", nextItem);

            touchRelease(indicatorsMenu, nextItemMappedPositionX, indicatorsMenu.openedHeight / 3);
        }

        function test_preventMouseEventsThru() {
            indicatorsMenu.show();
            tryCompare(indicatorsMenu, "fullyOpened", true);

            clickThroughSpy.signalName = "wheel";
            mouseWheel(indicatorsMenu, indicatorsMenu.width/2, indicatorsMenu.height/2, 10, 10);
            tryCompare(clickThroughSpy, "count", 0);

            clickThroughSpy.clear();
            clickThroughSpy.signalName = "clicked";
            mouseClick(indicatorsMenu, indicatorsMenu.width/2, indicatorsMenu.height/2, Qt.RightButton);
            tryCompare(clickThroughSpy, "count", 0);
        }

        function test_enableMenuSetting_data() {
            return [
                {tag: "menu enabled", enabled: true},
                {tag: "menu disabled", enabled: false}
            ]
        }

        function test_enableMenuSetting(data) {
            indicatorsMenu.available = data.enabled;

            indicatorsMenu.show();
            tryCompare(indicatorsMenu, data.enabled ? "fullyOpened" : "fullyClosed", true);

            indicatorsMenu.available = true;
            indicatorsMenu.hide();
        }

        // Ensure that showTapped is only signaled when the user hasn't moved
        // thir tap point
        // Prior to this, the user could press and drag down very fast but
        // still call showTapped
        function test_showTapped() {
            // Get the first indicator
            var firstItem = get_indicator_item(0);
            var firstItemMappedPosition = indicatorsMenu.mapFromItem(firstItem, firstItem.width/2, firstItem.height/2);

            touchFlick(indicatorsMenu,
                       firstItemMappedPosition.x, indicatorsMenu.minimizedPanelHeight / 2,
                       firstItemMappedPosition.x, indicatorsMenu.minimizedPanelHeight * 7,
                       true /* beginTouch */, true /* endTouch */, 100, 2);

            verify(showTappedSpy.count === 0);
        }
    }
}
