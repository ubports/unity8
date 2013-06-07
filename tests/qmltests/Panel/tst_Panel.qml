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

        function test_hint_data() { return get_window_data() }

        // Pressing on the indicator panel should activate the indicator hints
        // and expose a portion of the conent.
        function test_hint(data) {
            panel.fullscreenMode = data.fullscreenFlag;

            var indicator_item_coord = get_indicator_item_position(0);
            var indicator_revealer = findChild(panel, "indicatorRevealer");
            verify(indicator_revealer != undefined)

            mousePress(panel,
                       indicator_item_coord.x, panel.panelHeight/2,
                       Qt.LeftButton, Qt.NoModifier , 0);

            if (!panel.fullscreenMode)
            {
                compare(indicator_revealer.hintingAnimation.running, true, "Indicator revealer hint animation should be running after mouse press on indicator panel in pinned mode");
                tryCompare(indicator_revealer.hintingAnimation, "running", false);
                tryCompare(panel.indicators, "partiallyOpened", true);
            }
            else
            {
                // nothing should happen
                compare(indicator_revealer.hintingAnimation.running, false, "Indicator revealer hint animation should not be running after mouse press on indicator panel in fullscreen mode");
                compare(panel.indicators.partiallyOpened, false, "Indicator should not be partially opened when panel is pressed in fullscreenmode");
                compare(panel.indicators.fullyOpened, false, "Indicator should not be partially opened when panel is pressed in fullscreenmode");
            }

            mouseRelease(panel,
                         indicator_item_coord.x, panel.panelHeight/2,
                         Qt.LeftButton, Qt.NoModifier , 0);
        }

        function test_show_click_data() { return get_window_data() }

        // Clicking the indicator panel should fully open the inidicators
        function test_show_click(data) {
            panel.fullscreenMode = data.fullscreenFlag;

            var indicator_item_coord = get_indicator_item_position(0);

            mouseClick(panel,
                       indicator_item_coord.x, panel.panelHeight/2,
                       Qt.LeftButton, Qt.NoModifier , 0);

            if (!panel.fullscreenMode)
            {
                compare(panel.indicators.showAnimation.running, true, "Show animation should run after panel is clicked in pinned mode.");
                tryCompare(panel.indicators, "fullyOpened", true);

                // click will activate device overview.
                compare(findChild(panel.indicators, "indicatorRow").overviewActive, true, "Overview indicator should be avtive when indicators clicked.")
            }
            else
            {
                compare(panel.indicators.showAnimation.running, false, "Indicators should not open when panel is clicked in pinned mode.");
            }
        }

        function test_show_press_release_data() { return get_window_data() }

        // Pressing and releasing on the indicator panel will fully open the indicators
        function test_show_press_release(data) {
            panel.fullscreenMode = data.fullscreenFlag;

            var indicator_item_coord = get_indicator_item_position(0);

            mousePress(panel,
                       indicator_item_coord.x, panel.panelHeight/2,
                       Qt.LeftButton, Qt.NoModifier , 0);

            mouseRelease(panel,
                         indicator_item_coord.x, panel.panelHeight/2,
                         Qt.LeftButton, Qt.NoModifier , 0);

            if (!panel.fullscreenMode)
            {
                compare(panel.indicators.showAnimation.running, true, "Show animation should run after panel is clicked in pinned mode.");
                tryCompare(panel.indicators, "fullyOpened", true);
            }
            else
            {
                // nothing should happen.
                compare(panel.indicators.showAnimation.running, false, "Indicators should not open when panel is clicked in pinned mode.");
            }
        }

        function test_drag_show_data() { return get_window_data() }

        // Dragging from a indicator item in the panel will gradually expose the
        // indicators, first by running the hint animation, then after dragging down will
        // expose more of the panel, binding it to the selected indicator and opening it's menu.
        function test_drag_show(data) {
            panel.fullscreenMode = data.fullscreenFlag;

            var indicator_revealer = findChild(panel, "indicatorRevealer");
            verify(indicator_revealer != undefined)

            var indicator_row = findChild(panel.indicators, "indicatorRow");
            verify(indicator_row != undefined)

            var row_repeater = findChild(panel.indicators, "rowRepeater");
            verify(indicator_row != undefined)

            var menu_content = findChild(panel.indicators, "menuContent");
            verify(indicator_row != undefined)

            // do this for each indicator item
            for (var i = 0; i < row_repeater.count; i++) {

                var indicator_item = get_indicator_item(i);
                verify(indicator_item != undefined)

                var indicator_item_coord = get_indicator_item_position(i);

                // 1) Press on the panel
                mousePress(panel,
                           indicator_item_coord.x, panel.panelHeight/2,
                           Qt.LeftButton, Qt.NoModifier , 0);

                if (!panel.fullscreenMode)
                {
                    // hint animation should be run, and panel will end in partiallyOpened state.
                    compare(indicator_revealer.hintingAnimation.running, true, "Indicator revealer hint animation should be running after mouse press on indicator panel");
                    tryCompare(indicator_revealer.hintingAnimation, "running", false);
                    tryCompare(panel.indicators, "partiallyOpened", true);
                }

                // 2) Drag the mouse down
                var old_progress = panel.indicators.progress
                mouseMove(panel,
                          indicator_item_coord.x, old_progress + (panel.height - old_progress)/2,
                          0, Qt.LeftButton);

                // progress should increase.
                var progress_increases = panel.indicators.progress > old_progress;
                compare(progress_increases, true, "Progress has not increased on dragging indicator.");

                mouseMove(panel,
                          indicator_item_coord.x, shell.y + shell.height,
                          0, Qt.LeftButton);

                tryCompare(panel.indicators, "fullyOpened", true);

                mouseRelease(panel,
                             indicator_item_coord.x, indicator_item_coord.y + panel.height/2,
                             Qt.LeftButton, Qt.NoModifier , 0);

                compare(indicator_row.currentItem, indicator_item, "Incorrect item activated at position " + i);
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

            mouseClick(search_indicator,
                       1, 1,
                       Qt.LeftButton, Qt.NoModifier , 0);

            compare(search_clicked, true, "Clicking search indicator while it was enabled did not emit searchClicked signal")
        }

        function test_search_click_when_not_visible() {
            panel.fullscreenMode = false;
            panel.searchVisible = false

            var search_indicator = findChild(panel, "search");
            verify(search_indicator != undefined);

            mouseClick(search_indicator,
                       1, 1,
                       Qt.LeftButton, Qt.NoModifier , 0);

            compare(search_clicked, false, "Clicking search indicator while it was not visible emitted searchClicked signal")
        }
    }
}
