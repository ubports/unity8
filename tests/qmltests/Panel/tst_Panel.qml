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
import ".."
import "../../../Panel"

/*
  This tests the Panel component using a fake model to stage data in the indicators
  A view will show with indicators at the top, as does in the shell. This can be controlled
  as in the shell.
*/
Item {
    id: shell
    width: units.gu(40)
    height: units.gu(80)

    property bool search_clicked: false

    Connections {
        target: panel
        onSearchClicked: search_clicked = true
    }

    Panel {
        id: panel
        anchors.fill: parent
    }

    UT.UnityTestCase {
        name: "Panel"
        when: windowShown

        function get_window_data() {
            return [
            {tag: "pinned", fullscreenFlag: false },
            {tag: "fullscreen", fullscreenFlag: true }
        ]}


        function init() {
            search_clicked = false;
            panel.indicators.hide();
            tryCompare(panel.indicators.hideAnimation, "running", false);
            tryCompare(panel.indicators, "state", "initial");
        }

        function get_indicator_item(index) {
            var row_repeater = findChild(panel.indicators, "rowRepeater");
            verify(row_repeater != undefined)
            return row_repeater.itemAt(index);
        }

        function get_indicator_item_position(index) {

            var indicator_row = findChild(panel.indicators, "indicatorRow");
            verify(indicator_row != undefined)

            var indicator_item = get_indicator_item(index);
            verify(indicator_item != undefined);

            return panel.mapFromItem(indicator_item, indicator_item.width/2, indicator_item.height/2);
        }

        // Pressing on the indicator panel should activate the indicator hints
        // and expose a portion of the conent.
        function test_hint() {
            panel.fullscreenMode = false;
            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            tryCompare(panel.indicators, "y", 0)

            var indicator_item_coord = get_indicator_item_position(0);

            touchPress(panel, indicator_item_coord.x, panel.panelHeight / 2)

            // hint animation should be run, meaning that indicators will move downwards
            // by hintValue pixels without any drag taking place
            tryCompare(panel.indicators, "height",
                       panel.indicators.panelHeight + panel.indicators.hintValue);
            tryCompare(panel.indicators, "partiallyOpened", true);
            tryCompare(panel.indicators, "fullyOpened", false);

            touchRelease(panel, indicator_item_coord.x, panel.panelHeight/2)
        }

        // Pressing on the top edge of the screen should have no effect if the panel
        // is hidden (!pinned), which is the case when a fullscreen app is being shown
        function test_noHintOnFullscreenMode() {
            panel.fullscreenMode = true;
            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            tryCompare(panel.indicators, "y", -panel.panelHeight)

            var indicator_item_coord = get_indicator_item_position(0);

            touchPress(panel, indicator_item_coord.x, panel.panelHeight / 2)

            // Give some time for a hint animation to change things, if any
            wait(500)

            // no hint animation when fullscreen
            compare(panel.indicators.y, -panel.panelHeight)
            var indicatorRow = findChild(panel.indicators, "indicatorRow");
            verify(indicatorRow != undefined)
            compare(indicatorRow.y, 0)
            compare(panel.indicators.height, panel.indicators.panelHeight)
            compare(panel.indicators.partiallyOpened, false,
                    "Indicator should not be partially opened when panel is pressed in" +
                    " fullscreenmode")
            compare(panel.indicators.fullyOpened, false, "Indicator should not be partially" +
                   " opened when panel is pressed in fullscreenmode")

            touchRelease(panel, indicator_item_coord.x, panel.panelHeight/2)
        }

        function test_drag_show_data() { return get_window_data() }

        // Dragging from a indicator item in the panel will gradually expose the
        // indicators, first by running the hint animation, then after dragging down will
        // expose more of the panel, binding it to the selected indicator and opening it's menu.
        function test_drag_show(data) {
            panel.fullscreenMode = data.fullscreenFlag;

            var indicator_row = findChild(panel.indicators, "indicatorRow");
            verify(indicator_row != undefined)

            var row_repeater = findChild(panel.indicators, "rowRepeater");
            verify(indicator_row != undefined)

            var menu_content = findChild(panel.indicators, "menuContent");
            verify(indicator_row != undefined)

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            if (data.fullscreenFlag) {
                tryCompare(panel.indicators, "y", -panel.panelHeight)
            } else {
                tryCompare(panel.indicators, "y", 0)
            }

            // do this for each indicator item
            for (var i = 0; i < row_repeater.count; i++) {

                var indicator_item = get_indicator_item(i);
                verify(indicator_item != undefined)

                var indicator_item_coord = get_indicator_item_position(i);

                touchPress(panel,
                           indicator_item_coord.x, panel.panelHeight / 2)

                // 1) Drag the mouse down
                touchFlick(panel,
                           indicator_item_coord.x, panel.panelHeight / 2,
                           indicator_item_coord.x, panel.height * 0.8,
                           false /* beginTouch */, false /* endTouch */)

                // Indicators height should follow the drag, and therefore increase accordingly.
                // They should be at least half-way through the screen
                tryCompareFunction(
                    function() {return panel.indicators.height >= panel.height * 0.5},
                    true)

                touchRelease(panel, indicator_item_coord.x, panel.height * 0.8)

                compare(indicator_row.currentItem, indicator_item,
                        "Incorrect item activated at position " + i)
                compare(menu_content.__shown, true, "Menu conetent should be enabled for item at position " + i);

                // init for next indicator_item
                init();
            }
        }

        function test_search_click_when_visible() {
            panel.fullscreenMode = false;
            panel.searchVisible = true;

            var search_indicator = findChild(panel, "search");
            verify(search_indicator != undefined);

            tap(search_indicator, 1, 1)

            compare(search_clicked, true,
                    "Tapping search indicator while it was enabled did not emit searchClicked signal")
        }

        function test_search_click_when_not_visible() {
            panel.fullscreenMode = false;
            panel.searchVisible = false

            var search_indicator = findChild(panel, "search");
            verify(search_indicator != undefined);

            tap(search_indicator, 1, 1)

            compare(search_clicked, false,
                    "Tapping search indicator while it was not visible emitted searchClicked signal")
        }
    }
}
