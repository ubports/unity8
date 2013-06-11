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
import "../../../Dash"
import Ubuntu.Components 0.1
import Unity 0.1
import Unity.Test 0.1 as UT

Item {
    id: shell
    width: units.gu(40)
    height: units.gu(80)

    property ListModel searchHistory: ListModel {}

    property var lens_status: {
        'MockLens1': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'MockLens2': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'MockLens3': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'MockLens4': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'MockLens5': { 'movementStarted': 0, 'positionedAtBeginning': 0 }
    }

    Lenses {
        id: lensesModel
    }

    DashContent {
        id: dash_content
        anchors.fill: parent

        model: lensesModel
        scopes : lensesModel

        lensDelegateMapping: { "MockLens3" : "../tests/qmltests/Dash/qml/fake_lensView3.qml",
                               "MockLens2" : "../tests/qmltests/Dash/qml/fake_lensView2.qml",
                               "MockLens1" : "../tests/qmltests/Dash/qml/fake_lensView1.qml",
                               "MockLens4" : "../tests/qmltests/Dash/qml/fake_lensView4.qml"
                             }

        genericLens: "../tests/qmltests/Dash/qml/fake_generic_lensView.qml"
    }

    function clear_lens_status() {
        lens_status["MockLens1"].movementStarted = 0;
        lens_status["MockLens1"].positionedAtBeginning = 0;

        lens_status["MockLens2"].movementStarted = 0;
        lens_status["MockLens2"].positionedAtBeginning = 0;

        lens_status["MockLens3"].movementStarted = 0;
        lens_status["MockLens3"].positionedAtBeginning = 0;

        lens_status["MockLens4"].movementStarted = 0;
        lens_status["MockLens4"].positionedAtBeginning = 0;

        lens_status["MockLens5"].movementStarted = 0;
        lens_status["MockLens5"].positionedAtBeginning = 0;
    }

    SignalSpy {
        id: lensLoaded_spy
        target: dash_content
        signalName: "lensLoaded"
    }

    SignalSpy {
        id: movementStarted_spy
        target: dash_content
        signalName: "movementStarted"
    }

    SignalSpy {
        id: contentEndReached_spy
        target: dash_content
        signalName: "contentEndReached"
    }

    UT.UnityTestCase {
        name: "DashContent"
        when: windowShown

        function init() {
            lensLoaded_spy.clear();
            movementStarted_spy.clear();
            contentEndReached_spy.clear()
            clear_lens_status();

            // clear, wait for dahs to empty and load lenses.
            var dashContentList = findChild(dash_content, "dashContentList");
            verify(dashContentList != undefined)
            lensesModel.clear();
            tryCompare(dashContentList, "count", 0);
            lensesModel.load();
        }

        function test_movement_started_signal() {
            dash_content.setCurrentLensAtIndex(3, true, false);

            var dashContentList = findChild(dash_content, "dashContentList");
            verify(dashContentList != undefined)
            tryCompare(lensLoaded_spy, "count", 5);

            dashContentList.movementStarted();
            compare(movementStarted_spy.count, 1, "DashContent should have emitted movementStarted signal when content list did.");
            compare(lens_status["MockLens1"].movementStarted, 1, "MockLens1 should have emitted movementStarted signal when content list did.");
            compare(lens_status["MockLens2"].movementStarted, 1, "MockLens2 should have emitted movementStarted signal when content list did.");
            compare(lens_status["MockLens3"].movementStarted, 1, "MockLens3 should have emitted movementStarted signal when content list did.");
            compare(lens_status["MockLens4"].movementStarted, 1, "MockLens4 should have emitted movementStarted signal when content list did.");
            compare(lens_status["MockLens5"].movementStarted, 1, "MockLens5 should have emitted movementStarted signal when content list did.");
        }

        function test_positioned_at_beginning_signal() {
            dash_content.setCurrentLensAtIndex(3, true, false);

            tryCompare(lensLoaded_spy, "count", 5);

            dash_content.positionedAtBeginning();
            compare(lens_status["MockLens1"].positionedAtBeginning, 1, "MockLens1 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(lens_status["MockLens2"].positionedAtBeginning, 1, "MockLens2 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(lens_status["MockLens3"].positionedAtBeginning, 1, "MockLens3 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(lens_status["MockLens4"].positionedAtBeginning, 1, "MockLens4 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(lens_status["MockLens5"].positionedAtBeginning, 1, "MockLens5 should have emitted positionedAtBeginning signal when DashContent did.");
        }

        function test_lens_loaded() {
            tryCompare(lensLoaded_spy, "count", 5);
        }

        function test_content_end_reached() {
            var dashContentList = findChild(dash_content, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(lensLoaded_spy, "count", 5);

            dash_content.setCurrentLensAtIndex(0, true, false);
            dashContentList.currentItem.item.endReached();

            compare(contentEndReached_spy.count, 1);
        }

        // This tests that setting the current lens index will end up at the correct index even if
        // the lenses are loaded asynchrounsly.
        function test_set_current_lens_index_async() {
            verify(lensesModel.loaded == false);

            // next index is 1 if current is -1, otherwise it's current + 1
            var next_index = ((dash_content.currentIndex == -1 ? 0 : dash_content.currentIndex) + 1) % 5

            dash_content.setCurrentLensAtIndex(next_index, true, false);
            tryCompare(dash_content, "currentIndex", next_index);
            verify(lensesModel.loaded == true);

            // test greater than lens count.
            dash_content.setCurrentLensAtIndex(lensesModel.count, true, false);
            compare(dash_content.currentIndex, 4);
        }

        function get_current_item_object_name() {
            var dashContentList = findChild(dash_content, "dashContentList");
            verify(dashContentList != undefined);

            if (dashContentList.currentItem != undefined) {
                if (dashContentList.currentItem.item != undefined)
                    return dashContentList.currentItem.item.objectName;
            }

            return "";
        }

        function test_lens_mapping_data() {
            return [
                {tag: "index0", index: 0, objectName: "fake_lensView1"},
                {tag: "index1", index: 1, objectName: "fake_lensView2"},
                {tag: "index2", index: 2, objectName: "fake_lensView3"},
                {tag: "index3", index: 3, objectName: "fake_lensView4"},
                {tag: "index4", index: 4, objectName: "fake_generic_lensView"}
            ]
        }

        function test_lens_mapping(data) {
            dash_content.setCurrentLensAtIndex(data.index, true, false);
            tryCompareFunction(get_current_item_object_name, data.objectName)
        }

    }
}
