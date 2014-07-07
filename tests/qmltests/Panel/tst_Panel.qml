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
import Unity.Test 0.1 as UT
import Ubuntu.Components 0.1 as UC
import Ubuntu.Telephony 0.1 as Telephony
import ".."
import "../../../qml/Panel"

/*
  This tests the Panel component using a fake model to stage data in the indicators
  A view will show with indicators at the top, as does in the shell. This can be controlled
  as in the shell.
*/
Item {
    id: shell
    width: units.gu(40)
    height: units.gu(80)

    property bool searchClicked: false

    Connections {
        target: panel
        onSearchClicked: searchClicked = true
    }

    Panel {
        id: panel
        anchors {
            left: parent.left
            right: parent.right
        }
        height: parent.height - row.height
        fullscreenMode: false

        indicators {
            profile: "test1"
            panelHeight: units.gu(5)
        }
        callHint {
            height: units.gu(4)
        }

        property real panelAndSeparatorHeight: panel.indicators.panelHeight + units.dp(2)
    }


    Row {
        id: row
        anchors {
            bottom: shell.bottom
            left: parent.left
            right: parent.right
        }
        height: 50

        UC.Button {
            text: panel.indicators.shown ? "Hide" : "Show"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width/3

            onClicked: {
                if (panel.indicators.shown) {
                    panel.indicators.hide();
                } else {
                    panel.indicators.show();
                }
            }
        }

        UC.Button {
            text: panel.fullscreenMode ? "Maximize" : "FullScreen"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width/3

            onClicked: panel.fullscreenMode = !panel.fullscreenMode
        }

        UC.Button {
            text: callManager.hasCalls ? "Called" : "No Calls"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width/3

            onClicked: {
                if (callManager.foregroundCall) {
                    callManager.foregroundCall = null;
                } else {
                    callManager.foregroundCall = phoneCall;
                }
            }
        }
    }

    Telephony.CallEntry {
        id: phoneCall
        phoneNumber: "+447812221111"
    }

    UT.UnityTestCase {
        name: "Panel"
        when: windowShown

        function init() {
            panel.indicators.initialise();
            panel.fullscreenMode = false;

            searchClicked = false;
            panel.indicators.hide();
            // Wait for animation to complete
            tryCompare(panel.indicators.hideAnimation, "running", false);
            callManager.foregroundCall = null;

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            var indicatorArea = findChild(panel, "indicatorArea");
            tryCompare(indicatorArea, "y", 0);
        }

        function get_indicator_item(index) {
            var indicatorRow = findChild(panel.indicators, "indicatorRow");
            verify(indicatorRow !== null);

            return findChild(indicatorRow.row, "item" + index);
        }

        function get_indicator_item_position(index) {
            var indicatorRow = findChild(panel.indicators, "indicatorRow");
            verify(indicatorRow !== null);

            var indicatorItem = get_indicator_item(index);
            verify(indicatorItem !== null);

            return panel.mapFromItem(indicatorItem, indicatorItem.width/2, indicatorItem.height/2);
        }

        // Pressing on the indicator panel should activate the indicator hints
        // and expose a portion of the conent.
        function test_hint() {
            var indicatorItemCoord = get_indicator_item_position(0);

            touchPress(panel, indicatorItemCoord.x, panel.indicators.panelHeight / 2);

            // hint animation should be run, meaning that indicators will move downwards
            // by hintValue pixels without any drag taking place
            tryCompareFunction(function() { return panel.indicators.height },
                                panel.indicators.panelHeight + panel.indicators.hintValue);
            tryCompare(panel.indicators, "partiallyOpened", true);
            tryCompare(panel.indicators, "fullyOpened", false);

            touchRelease(panel, indicatorItemCoord.x, panel.indicators.panelHeight/2);
        }

        // Pressing on the top edge of the screen should have no effect if the panel
        // is hidden (fullscreen), which is the case when a fullscreen app is being shown
        function test_noHintOnFullscreenMode() {
            panel.fullscreenMode = true;
            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            var indicatorArea = findChild(panel, "indicatorArea");
            tryCompare(indicatorArea, "y", -panel.panelHeight);

            var indicatorItemCoord = get_indicator_item_position(0);

            touchPress(panel, indicatorItemCoord.x, panel.indicators.panelHeight / 2);

            // Give some time for a hint animation to change things, if any
            wait(500);

            // no hint animation when fullscreen
            compare(panel.indicators.partiallyOpened, false,
                    "Indicator should not be partially opened when panel is pressed in" +
                    " fullscreenmode");
            compare(panel.indicators.fullyOpened, false, "Indicator should not be partially" +
                   " opened when panel is pressed in fullscreenmode");

            touchRelease(panel, indicatorItemCoord.x, panel.panelHeight/2);
        }

        // Pressing on the top edge of the indicator should have no effect if the panel
        // has an active call
        function test_noHintOnActiveCall() {
            callManager.foregroundCall = phoneCall;

            var indicatorItemCoord = get_indicator_item_position(0);

            touchPress(panel, indicatorItemCoord.x, panel.callHint.height + panel.indicators.panelHeight / 2);

            // Give some time for a hint animation to change things, if any
            wait(500);

            // no hint animation when fullscreen
            compare(panel.indicators.partiallyOpened, false,
                    "Indicator should not be partially opened when panel is pressed in" +
                    " fullscreenmode");
            compare(panel.indicators.fullyOpened, false, "Indicator should not be partially" +
                   " opened when panel is pressed in fullscreenmode");

            touchRelease(panel, indicatorItemCoord.x, panel.panelHeight/2);
        }

        function test_drag_show_data() {
            return [
                { tag: "pinned", fullscreenFlag: false, alreadyOpen: false, call: null,
                            indicatorY: 0 },
                { tag: "fullscreen", fullscreenFlag: true, alreadyOpen: false, call: null,
                            indicatorY: -panel.panelAndSeparatorHeight },
                { tag: "pinned-alreadyOpen", fullscreenFlag: false, alreadyOpen: true, call: null,
                            indicatorY: 0 },
                { tag: "fullscreen-alreadyOpen", fullscreenFlag: true, alreadyOpen: true, call: null,
                            indicatorY: 0 },
                { tag: "pinned-callActive", fullscreenFlag: false, alreadyOpen: false, call: phoneCall,
                            indicatorY: 0},
                { tag: "fullscreen-callActive", fullscreenFlag: true, alreadyOpen: false, call: phoneCall,
                            indicatorY: -panel.panelAndSeparatorHeight }
            ];
        }

        // Dragging from a indicator item in the panel will gradually expose the
        // indicators, first by running the hint animation, then after dragging down will
        // expose more of the panel, binding it to the selected indicator and opening it's menu.
        function test_drag_show(data) {
            panel.fullscreenMode = data.fullscreenFlag;
            callManager.foregroundCall = data.call;

            if (data.alreadyOpen) {
                panel.indicators.show();
                tryCompare(panel.indicators, "fullyOpened", true);
            }

            var indicatorRow = findChild(panel.indicators, "indicatorRow");
            verify(indicatorRow !== null);

            var menuContent = findChild(panel.indicators, "menuContent");
            verify(menuContent !== null);

            var indicatorArea = findChild(panel, "indicatorArea");
            verify(indicatorArea !== null);

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            tryCompareFunction(function() { return indicatorArea.y }, data.indicatorY);

            // do this for each indicator item
            for (var i = 0; i < indicatorRow.row.count; i++) {

                var indicatorItem = get_indicator_item(i);
                verify(indicatorItem !== null);

                if (!indicatorItem.visible)
                    continue;

                var indicatorItemCoord = get_indicator_item_position(i);

                touchPress(panel,
                           indicatorItemCoord.x, panel.indicators.panelHeight / 2);

                // 1) Drag the mouse down
                touchFlick(panel,
                           indicatorItemCoord.x, panel.indicators.panelHeight / 2,
                           indicatorItemCoord.x, panel.height,
                           false /* beginTouch */, false /* endTouch */);

                // Indicators height should follow the drag, and therefore increase accordingly.
                // They should be at least half-way through the screen
                tryCompareFunction(
                    function() {return panel.indicators.height >= panel.height * 0.5},
                    true);

                touchRelease(panel, indicatorItemCoord.x, panel.height);

                compare(indicatorRow.currentItem, indicatorItem,
                        "Incorrect item activated at position " + i);
                compare(menuContent.currentMenuIndex, i, "Menu conetent should be enabled for item at position " + i);

                // init for next indicatorItem
                if (!data.alreadyOpen) {
                    panel.indicators.hide();
                    tryCompare(panel.indicators.hideAnimation, "running", false);
                    tryCompare(panel.indicators, "state", "initial");
                }
            }
        }

        function test_search_click_when_visible() {
            panel.fullscreenMode = false;
            panel.searchVisible = true;

            var searchIndicator = findChild(panel, "search");
            verify(searchIndicator !== null);

            tryCompare(searchIndicator, "enabled", true);

            tap(searchIndicator, 1, 1);

            compare(searchClicked, true,
                    "Tapping search indicator while it was enabled did not emit searchClicked signal");
        }

        function test_search_click_when_not_visible() {
            panel.fullscreenMode = false;
            panel.searchVisible = false;

            var searchIndicator = findChild(panel, "search");
            verify(searchIndicator !== null);

            tap(searchIndicator, 1, 1);

            compare(searchClicked, false,
                    "Tapping search indicator while it was not visible emitted searchClicked signal");
        }

        // Test the vertical velocity check when flicking the indicators open at an angle.
        // If the vertical velocity is above a specific point, we shouldnt change active indicators
        // if the x position changes
        function test_vertical_velocity_detector() {
            panel.fullscreenMode = false;
            panel.searchVisible = false;

            var indicatorRow = findChild(panel.indicators, "indicatorRow");
            verify(indicatorRow !== null);

            // Get the first indicator
            var indicatorItemFirst = get_indicator_item(0);
            verify(indicatorItemFirst !== null);

            var indicatorItemCoordFirst = get_indicator_item_position(0);
            var indicatorItemCoordNext = get_indicator_item_position(indicatorRow.row.count - 1);

            touchPress(panel,
                       indicatorItemCoordFirst.x, panel.indicators.panelHeight / 2);

            // 1) Drag the mouse down to hint a bit
            touchFlick(panel,
                       indicatorItemCoordFirst.x, panel.indicators.panelHeight / 2,
                       indicatorItemCoordFirst.x, panel.indicators.panelHeight * 2,
                       false /* beginTouch */, false /* endTouch */);

            tryCompare(indicatorRow, "currentItem", indicatorItemFirst)

            // 1) Flick mouse down to bottom
            touchFlick(panel,
                       indicatorItemCoordFirst.x, panel.indicators.panelHeight * 2,
                       indicatorItemCoordNext.x, panel.height,
                       false /* beginTouch */, true /* endTouch */,
                       units.gu(10) /* speed */, 30 /* iterations */); // more samples needed for accurate velocity

            compare(indicatorRow.currentItem, indicatorItemFirst, "First indicator should still be the current item");
        }

        function test_hideIndicatorMenu_data() {
            return [ {tag: "no-delay", delay: undefined },
                     {tag: "delayed", delay: 200 }
            ];
        }

        function test_hideIndicatorMenu(data) {
            panel.indicators.show();
            compare(panel.indicators.shown, true);

            panel.hideIndicatorMenu(data.delay);
            tryCompare(panel.indicators, "shown", false);
        }
    }
}
