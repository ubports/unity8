/*
 * Copyright 2013-2015 Canonical Ltd.
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
import Unity.Test 0.1
import Ubuntu.Components 1.3
import Unity.Application 0.1
import Unity.Indicators 0.1 as Indicators
import Ubuntu.Telephony 0.1 as Telephony
import "../../../qml/Panel"

IndicatorTest {
    id: root
    width: units.gu(100)
    height: units.gu(71)
    color: "white"

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)
        clip: true

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            id: itemArea
            color: backgroundMouseArea.pressed ? "red" : "blue"

            MouseArea {
                id: backgroundMouseArea
                anchors.fill: parent
            }

            Panel {
                id: panel
                anchors.fill: parent
                indicators {
                    width: parent.width > units.gu(60) ? units.gu(40) : parent.width
                    indicatorsModel: root.indicatorsModel
                }

                property real panelAndSeparatorHeight: panel.indicators.minimizedPanelHeight + units.dp(2)
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: false

            Button {
                Layout.fillWidth: true
                text: panel.indicators.shown ? "Hide" : "Show"
                onClicked: {
                    if (panel.indicators.shown) {
                        panel.indicators.hide();
                    } else {
                        panel.indicators.show();
                    }
                }
            }

            Button {
                text: panel.fullscreenMode ? "Maximize" : "FullScreen"
                Layout.fillWidth: true
                onClicked: panel.fullscreenMode = !panel.fullscreenMode
            }

            Button {
                Layout.fillWidth: true
                text: callManager.hasCalls ? "Called" : "No Calls"
                onClicked: {
                    if (callManager.foregroundCall) {
                        callManager.foregroundCall = null;
                    } else {
                        callManager.foregroundCall = phoneCall;
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

            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
            }

            MouseTouchEmulationCheckbox {}
        }
    }

    Telephony.CallEntry {
        id: phoneCall
        phoneNumber: "+447812221111"
    }

    UnityTestCase {
        name: "Panel"
        when: windowShown

        SignalSpy {
            id: backgroundPressedSpy
            target: backgroundMouseArea
            signalName: "pressedChanged"
        }

        function init() {
            panel.fullscreenMode = false;
            callManager.foregroundCall = null;

            panel.indicators.hide();
            // Wait for animation to complete
            tryCompare(panel.indicators.hideAnimation, "running", false);

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            var indicatorArea = findChild(panel, "indicatorArea");
            tryCompare(indicatorArea, "y", 0);

            backgroundPressedSpy.clear();
            compare(backgroundPressedSpy.valid, true);
        }

        function get_indicator_item(index) {
            var indicatorItem = findChild(panel, root.originalModelData[index]["identifier"]+"-panelItem");
            verify(indicatorItem !== null);

            return indicatorItem;
        }

        function pullDownIndicatorsMenu() {
            var showDragHandle = findChild(panel, "showDragHandle");
            touchFlick(showDragHandle,
                       showDragHandle.width / 2,
                       showDragHandle.height / 2,
                       showDragHandle.width / 2,
                       showDragHandle.height / 2 + (showDragHandle.autoCompleteDragThreshold * 1.1));
            tryCompare(panel.indicators, "fullyOpened", true);
        }

        function test_drag_show_data() {
            return [
                { tag: "pinned", fullscreen: false, call: null,
                            indicatorY: 0 },
                { tag: "fullscreen", fullscreen: true, call: null,
                            indicatorY: -panel.panelAndSeparatorHeight },
                { tag: "pinned-callActive", fullscreen: false, call: phoneCall,
                            indicatorY: 0},
                { tag: "fullscreen-callActive", fullscreen: true, call: phoneCall,
                            indicatorY: -panel.panelAndSeparatorHeight }
            ];
        }

        // Dragging from a indicator item in the panel will gradually expose the
        // indicators, first by running the hint animation, then after dragging down will
        // expose more of the panel, binding it to the selected indicator and opening it's menu.
        // Tested from first Y pixel to check for swipe from offscreen.
        function test_drag_show(data) {
            panel.fullscreenMode = data.fullscreen;
            callManager.foregroundCall = data.call;

            var indicatorRow = findChild(panel.indicators, "indicatorItemRow");
            verify(indicatorRow !== null);

            var menuContent = findChild(panel.indicators, "menuContent");
            verify(menuContent !== null);

            var indicatorArea = findChild(panel, "indicatorArea");
            verify(indicatorArea !== null);

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            tryCompareFunction(function() { return indicatorArea.y }, data.indicatorY);

            for (var i = 0; i < root.originalModelData.length; i++) {
                var indicatorItem = get_indicator_item(i);

                var startXPosition = panel.mapFromItem(indicatorItem, indicatorItem.width / 2, 0).x;

                touchFlick(panel,
                           startXPosition, 0,
                           startXPosition, panel.height,
                           true /* beginTouch */, false /* endTouch */, units.gu(5), 15);

                // Indicators height should follow the drag, and therefore increase accordingly.
                // They should be at least half-way through the screen
                tryCompareFunction(
                    function() {return panel.indicators.height >= panel.height * 0.5},
                    true);

                touchRelease(panel, startXPosition, panel.height);

                compare(indicatorRow.currentItemIndex, i,  "Indicator item should be activated at position " + i);
                compare(menuContent.currentMenuIndex, i, "Menu conetent should be activated for item at position " + i);

                // init for next indicatorItem
                panel.indicators.hide();
                tryCompare(panel.indicators.hideAnimation, "running", false);
                tryCompare(panel.indicators, "state", "initial");
            }
        }

        function test_drag_hide_data() {
            return [
                { tag: "pinned", fullscreen: false, call: null,
                            indicatorY: 0 },
                { tag: "fullscreen", fullscreen: true, call: null,
                            indicatorY: -panel.panelAndSeparatorHeight },
                { tag: "pinned-callActive", fullscreen: false, call: phoneCall,
                            indicatorY: 0},
                { tag: "fullscreen-callActive", fullscreen: true, call: phoneCall,
                            indicatorY: -panel.panelAndSeparatorHeight }
            ];
        }

        // Dragging the shown indicators up from bottom of panel will hide the indicators
        // Tested from last Y pixel to check for swipe from offscreen.
        function test_drag_hide(data) {
            panel.fullscreenMode = data.fullscreen;
            callManager.foregroundCall = data.call;

            var indicatorRow = findChild(panel.indicators, "indicatorItemRow");
            verify(indicatorRow !== null);

            var menuContent = findChild(panel.indicators, "menuContent");
            verify(menuContent !== null);

            var indicatorArea = findChild(panel, "indicatorArea");
            verify(indicatorArea !== null);

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            tryCompareFunction(function() { return indicatorArea.y }, data.indicatorY);

            panel.indicators.show();
            tryCompare(panel.indicators.showAnimation, "running", false);
            tryCompare(panel.indicators, "unitProgress", 1);

            touchFlick(panel.indicators,
                       panel.indicators.width / 2, panel.height,
                       panel.indicators.width / 2, 0,
                       true /* beginTouch */, false /* endTouch */, units.gu(5), 15);

            // Indicators height should follow the drag, and therefore increase accordingly.
            // They should be at least half-way through the screen
            tryCompareFunction(
                function() {return panel.indicators.height <= panel.height * 0.5},
                true);

            touchRelease(panel.indicators, panel.indicators.width / 2, 0);

            tryCompare(panel.indicators.hideAnimation, "running", true);
            tryCompare(panel.indicators.hideAnimation, "running", false);
            tryCompare(panel.indicators, "state", "initial");
        }

        function test_hint_data() {
            return [
                { tag: "normal", fullscreen: false, call: null, hintExpected: true},
                { tag: "fullscreen", fullscreen: true, call: null, hintExpected: false},
                { tag: "call hint", fullscreen: false, call: phoneCall, hintExpected: false},
            ];
        }

        function test_hint(data) {
            panel.fullscreenMode = data.fullscreen;
            callManager.foregroundCall = data.call;

            if (data.fullscreen) {
                // Wait for the indicators to get into position.
                // (switches between normal and fullscreen modes are animated)
                var indicatorArea = findChild(panel, "indicatorArea");
                tryCompare(indicatorArea, "y", -panel.panelHeight);
            }

            var indicatorItem = get_indicator_item(0);
            var mappedPosition = root.mapFromItem(indicatorItem, indicatorItem.width / 2, indicatorItem.height / 2);

            touchPress(panel, mappedPosition.x, panel.indicators.minimizedPanelHeight / 2);

            // Give some time for a hint animation to change things, if any
            wait(500);

            // no hint animation when fullscreen
            compare(panel.indicators.fullyClosed, !data.hintExpected, "Indicator should be fully closed");
            compare(panel.indicators.partiallyOpened, data.hintExpected, "Indicator should be partialy opened");
            compare(panel.indicators.fullyOpened, false, "Indicator should not be fully opened");

            touchRelease(panel, mappedPosition.x, panel.minimizedPanelHeight / 2);
        }

        /* Checks that no input reaches items behind the indicator bar.
           Ie., the indicator bar should eat all input events that hit it.
         */
        function test_indicatorBarEatsAllEvents() {
            // Perform several taps throughout the length of the indicator bar to ensure
            // that it doesn't have a "weak spot" from where taps pass through.
            var numTaps = 5;
            var stepLength = (panel.width / (numTaps + 1));
            var tapY = panel.indicators.minimizedPanelHeight / 2;
            for (var i = 1; i <= numTaps; ++i) {
                tap(panel, stepLength * i, tapY);
                tryCompare(panel.indicators, "fullyClosed", true);
            }

            compare(backgroundPressedSpy.count, 0);
        }

        function test_darkenedAreaEatsAllEvents() {

            // The center of the area not covered by the indicators menu
            // Ie, the visible darkened area behind the menu
            var touchPosX = (panel.width - panel.indicators.width) / 2
            var touchPosY = panel.indicators.minimizedPanelHeight +
                    ((panel.height - panel.indicators.minimizedPanelHeight) / 2)

            // input goes through while the indicators menu is closed
            tryCompare(panel.indicators, "fullyClosed", true);
            compare(backgroundPressedSpy.count, 0);
            tap(panel, touchPosX, touchPosY);
            compare(backgroundPressedSpy.count, 2);

            pullDownIndicatorsMenu();

            // Darkened area eats input when the indicators menu is fully opened
            tap(panel, touchPosX, touchPosY);
            compare(backgroundPressedSpy.count, 2);
            backgroundPressedSpy.clear();

            // And should continue to eat inpunt until the indicators menu is fully closed
            wait(10);
            while (!panel.indicators.fullyClosed) {
                tap(panel, touchPosX, touchPosY);

                // it could have got fully closed during the tap
                // so we have to double check here
                if (!panel.indicators.fullyClosed) {
                    compare(backgroundPressedSpy.count, 0);
                }

                // let the animation go a bit further
                wait(50);
            }

            // Now that's fully closed, input should go through again
            backgroundPressedSpy.clear();
            tap(panel, touchPosX, touchPosY);
            compare(backgroundPressedSpy.count, 2);
        }

        /*
          Regression test for https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1439318
          When the panel is in fullscreen mode and the user taps near the top edge,
          the panel should take no action and the tap should reach the item behind the
          panel.
         */
        function test_tapNearTopEdgeWithPanelInFullscreenMode() {
            var indicatorArea = findChild(panel, "indicatorArea");
            verify(indicatorArea);
            var panelPriv = findInvisibleChild(panel, "panelPriv");
            verify(panelPriv);

            panel.fullscreenMode = true;
            // wait until if finishes hiding itself
            tryCompare(indicatorArea, "y", -panelPriv.indicatorHeight);

            compare(panel.indicators.shown, false);
            verify(panel.indicators.fullyClosed);

            // tap near the very top of the screen
            tap(itemArea, itemArea.width / 2, 2);

            // the tap should have reached the item behind the panel
            compare(backgroundPressedSpy.count, 2);

            // give it a couple of event loop iterations for any animations etc to kick in
            wait(50);

            compare(panel.indicators.shown, false);
            verify(panel.indicators.fullyClosed);
        }

        function test_tapToReturnCallDoesntExpandIndicators() {
            compare(panel.indicators.shown, false);
            verify(panel.indicators.fullyClosed);

            callManager.foregroundCall = phoneCall;

            ApplicationManager.focusApplication("unity8-dash");
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");

            mouseClick(panel.indicators,
                       panel.indicators.width / 2,
                       panel.indicators.minimizedPanelHeight / 2);

            compare(panel.indicators.shown, false);
            verify(panel.indicators.fullyClosed);
        }

        function test_openAndClosePanelWithMouseClicks() {
            compare(panel.indicators.shown, false);
            verify(panel.indicators.fullyClosed);

            mouseClick(panel.indicators,
                    panel.indicators.width / 2,
                    panel.indicators.minimizedPanelHeight / 2);

            compare(panel.indicators.shown, true);
            tryCompare(panel.indicators, "fullyOpened", true);

            var handle = findChild(panel.indicators, "handle");
            verify(handle);

            mouseClick(handle);

            compare(panel.indicators.shown, false);
            tryCompare(panel.indicators, "fullyClosed", true);
        }
    }
}
