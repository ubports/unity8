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
import "../../../Components"

/*
  This tests the Indicators component by using a fake model to stage data in the indicators
  A view will show with indicators at the top, as does in the shell. There is a clickable area
  marked "Click Me" which can be used to expose the indicators.
*/
Item {
    id: shell
    width: units.gu(40)
    height: units.gu(80)

    PanelBackground {
        anchors.fill: indicators
    }

    Indicators {
        id: indicators
        anchors {
            right: parent.right
        }
        width: (shell.width > units.gu(60)) ? units.gu(40) : shell.width
        y: 0
        hintValue: indicatorRevealer.hintDisplacement
        shown: false
        revealer: indicatorRevealer

        openedHeight: parent.height - click_me.height

        showAnimation: NumberAnimation { property: "progress"; duration: 350; to: indicatorRevealer.openedValue; easing.type: Easing.OutCubic }
        hideAnimation: NumberAnimation { property: "progress"; duration: 350; to: indicatorRevealer.closedValue; easing.type: Easing.OutCubic }
    }

    Revealer {
        anchors.fill: indicators
        id: indicatorRevealer
        hintDisplacement: indicators.panelHeight * 3

        openedValue: indicators.openedHeight - indicators.panelHeight
        closedValue: indicators.panelHeight
    }

    // Just a rect for clicking to open the indicators.
    Rectangle {
        id: click_me
        color: "red"
        anchors {
            bottom: shell.bottom
            left: parent.left
            right: parent.right
        }
        height: 50

        Text {
            text: "Click Me"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (!indicators.shown) {
                        indicators.openOverview();
                        indicators.show();
                    }
                    else {
                        indicators.hide();
                    }
                }
            }
        }
    }

    UT.UnityTestCase {
        name: "Indicators"
        when: windowShown

        function init() {
            indicators.hide();
            tryCompare(indicators.hideAnimation, "running", false);
            tryCompare(indicators, "state", "initial");
        }

        // Showing the indicators should fully open the indicator panel with the overview menu visible.
        function test_show() {
            indicators.show()
            tryCompare(indicators, "fullyOpened", true);

            // A show must open the indicators.
            compare(findChild(indicators, "indicatorRow").overviewActive, true, "Overview indicator should be active when opened overview.")
        }

        // Opening the overview menu will activate the overview panel.
        function test_open_overview() {
            indicators.openOverview();
            compare(findChild(indicators, "indicatorRow").overviewActive, true, "Overview should be active when opened overview.")
        }

        // Showing the indicators, then changing the progress (simulating drag) should keep the overview panel open until
        // the reveal state is reached.
        function test_slow_close_open_overview() {

            var indicator_row = findChild(indicators, "indicatorRow");
            verify(indicator_row != undefined);

            indicators.show()
            // wait for animation to end. (progress needs to be updated)
            tryCompare(indicators.showAnimation, "running", false);
            compare(indicator_row.overviewActive, true, "Overview should be active when opened overview.")

            // iteratively decrease the progress and ensure that it keeps the correct behaviour
            var current_progress = indicators.progress - shell.height/20;
            while (current_progress > 0) {
                indicators.progress = current_progress;

                if (indicators.state == "commit" || indicators.state == "locked") {
                    compare(indicator_row.overviewActive, true, "Overview should be active when in locked or commit state after show.")
                }
                else if (indicators.state == "reveal" || indicators.state == "hint") {
                    compare(indicator_row.overviewActive, false, "Overview should be not active when not in commit or locked state.")
                }

                current_progress = current_progress - shell.height/20;
            }
        }

        // Test the change in the revealer lateral position changes the current panel menu to fit the position
        // of the indicator in the row.
        function test_change_revealer_lateral_position()
        {
            // tests changing the lateral position of the revealer activates the correct indicator items.

            // This "should" put the indicators in "hint" state
            indicators.progress = indicators.hintValue;

            var indicator_row = findChild(indicators, "indicatorRow")
            var row_repeater = findChild(indicators, "rowRepeater")

            for (var i = 0; i < row_repeater.count; i++) {
                var indicator_item = row_repeater.itemAt(i);

                var indicator_position = indicator_row.row.x + indicator_item.x + indicator_item.width/2;

                indicatorRevealer.lateralPosition = indicator_position;

                compare(indicator_row.currentItem, indicator_item, "Incorrect item activated at position " + i);
            }
        }

        // PROGRESS TESTS

        // values for specific state changes are subject to internal decisions, so we can't determine the true progress value
        // which would cause the state to change without making too many assuptyions
        // However, we can assume that a partially opened panel will not be initial, and fully opened panel will be locked.

        function test_progress_changes_state_to_not_initial() {
            indicators.progress = indicatorRevealer.closedValue +  (indicatorRevealer.openedValue - indicatorRevealer.closedValue)/2;
            compare(indicators.state!="initial", true, "Indicators should not be in initial state when partially opened.");
        }

        function test_progress_changes_state_to_locked() {
            indicators.progress = indicators.openedHeight;
            compare(indicators.state, "locked", "Indicators should be locked when fully opened.");
        }

        function test_partially_open() {
            indicators.progress = indicatorRevealer.closedValue +  (indicatorRevealer.openedValue - indicatorRevealer.closedValue)/2;
            compare(indicators.partiallyOpened, true, "Indicator should show as partially opened when in between revealer closedValue & openedValue height");
            compare(indicators.fullyOpened, false, "Indicator should not show as fully opened when in between revealer closedValue & openedValue height");
        }

        function test_fully_open() {
            indicators.progress = indicatorRevealer.openedValue
            compare(indicators.partiallyOpened, false, "Indicator should show as fully opened when in between revealer closedValue & openedValue height");
            compare(indicators.fullyOpened, true, "Indicator should not show as fully opened when at revealer openedValue height");
        }

        // The indicator menu content should be shown if the indicators are show through an animation before they
        // enter a furthur state through a progress change (eg press indicator row, drag down a less then hint
        // threshold and release to show
        function test_menu_open_on_hint_drag() {
            indicators.handlePress();
            indicators.show()

            var menuContent = findChild(indicators, "menuContent")
            compare(menuContent.__shown, true, "Indicator menu content should be shown after a indicator show.");
        }
    }
}
