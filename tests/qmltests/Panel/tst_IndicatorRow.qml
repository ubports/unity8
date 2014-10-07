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
import "../../../qml/Panel"
import Unity.Indicators 0.1 as Indicators

/*
  This tests the IndicatorRow component by using a fake model to stage data in the indicators
  A view will show with indicators at the top, as does in the shell.
*/
Item {
    id: rootItem
    width: units.gu(40)
    height: units.gu(60)

    PanelBackground {
        anchors.fill: indicatorRow
    }

    IndicatorRow {
        id: indicatorRow
        anchors {
            left: parent.left
            right: parent.right
        }

        indicatorsModel: indicatorModel

        Component.onCompleted: indicatorModel.load("test1")
    }

    Indicators.IndicatorsModel {
        id: indicatorModel
    }

    UT.UnityTestCase {
        name: "IndicatorRow"
        when: windowShown

        function init() {
            indicatorModel.load("test1");

            indicatorRow.state = "initial";
            indicatorRow.setCurrentItemIndex(-1);
            indicatorRow.unitProgress = 0.0;
        }

        function get_indicator_item(index) {
            return findChild(indicatorRow.row, "item" + index);
        }

        function test_set_current_item() {
            indicatorRow.setCurrentItemIndex(0);
            compare(indicatorRow.indicatorsModel.data(indicatorRow.currentItemIndex, Indicators.IndicatorsModelRole.Identifier),
                    "fake-indicator-1",
                    "Incorrect item at position 0");

            indicatorRow.setCurrentItemIndex(1);
            compare(indicatorRow.indicatorsModel.data(indicatorRow.currentItemIndex, Indicators.IndicatorsModelRole.Identifier),
                    "fake-indicator-2",
                    "Incorrect item at position 1");

            indicatorRow.setCurrentItemIndex(2);
            compare(indicatorRow.indicatorsModel.data(indicatorRow.currentItemIndex, Indicators.IndicatorsModelRole.Identifier),
                    "fake-indicator-3",
                    "Incorrect item at position 2");
        }

        function test_highlight_data() {
            return [
                { index: 0, progress: 0.0, current: false, other: false },
                { index: 0, progress: 0.1, current: true, other: false },
                { index: 0, progress: 0.5, current: true, other: false },
                { index: 0, progress: 1.0, current: true, other: false },
                { index: 2, progress: 0.0, current: false, other: false },
                { index: 2, progress: 0.1, current: true, other: false },
                { index: 2, progress: 0.5, current: true, other: false },
                { index: 2, progress: 1.0, current: true, other: false }
            ];
        }

        function test_highlight(data) {
            indicatorRow.unitProgress = data.progress;
            indicatorRow.setCurrentItemIndex(data.index);

            compare(indicatorRow.currentItem.highlighted, data.current, "Indicator hightlight did not match for current item");

            for (var i = 0; i < indicatorRow.row.count; i++) {
                compare(get_indicator_item(i).highlighted, i === data.index ? data.current: data.other, "Indicator hightlight did not match for item iter");
            }
        }

        function test_opacity_data() {
            return [
                { index: 0, progress: 0.0, current: 1.0, other: 1.0 },
                { index: 0, progress: 0.1, current: 1.0, other: 0.9 },
                { index: 0, progress: 0.5, current: 1.0, other: 0.5 },
                { index: 0, progress: 1.0, current: 1.0, other: 0.0 },
                { index: 2, progress: 0.0, current: 1.0, other: 1.0 },
                { index: 2, progress: 0.1, current: 1.0, other: 0.9 },
                { index: 2, progress: 0.5, current: 1.0, other: 0.5 },
                { index: 2, progress: 1.0, current: 1.0, other: 0.0 }
            ];
        }

        function test_opacity(data) {
            indicatorRow.unitProgress = data.progress;
            indicatorRow.setCurrentItemIndex(data.index);

            tryCompare(indicatorRow.currentItem, "opacity", data.current);

            for (var i = 0; i < indicatorRow.row.count; i++) {
                tryCompare(get_indicator_item(i), "opacity", i === data.index ? data.current: data.other);
            }
        }

        function test_dimmed_data() {
            return [
                { index: 0, progress: 0.0, current: false, other: false },
                { index: 0, progress: 0.1, current: false, other: true },
                { index: 0, progress: 0.5, current: false, other: true },
                { index: 0, progress: 1.0, current: false, other: true },
                { index: 2, progress: 0.0, current: false, other: false },
                { index: 2, progress: 0.1, current: false, other: true },
                { index: 2, progress: 0.5, current: false, other: true },
                { index: 2, progress: 1.0, current: false, other: true }
            ];
        }

        function test_dimmed(data) {
            indicatorRow.unitProgress = data.progress;
            indicatorRow.setCurrentItemIndex(data.index);

            compare(indicatorRow.currentItem.dimmed, data.current, "Indicator dim did not match for current item");

            for (var i = 0; i < indicatorRow.row.count; i++) {
                compare(get_indicator_item(i).dimmed, i === data.index ? data.current: data.other, "Indicator dim did not match for item iter");
            }
        }
    }
}
