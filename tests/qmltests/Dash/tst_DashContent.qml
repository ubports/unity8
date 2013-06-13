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

    property var lensStatus: {
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
        id: dashContent
        anchors.fill: parent

        model: lensesModel
        lenses : lensesModel

        lensMapper : lensDelegateMapper
    }

    LensDelegateMapper {
        id: lensDelegateMapper
        lensDelegateMapping: {
            "MockLens1": "../tests/qmltests/Dash/qml/fake_lensView1.qml",
            "MockLens2": "../tests/qmltests/Dash/qml/fake_lensView2.qml",
            "MockLens3": "../tests/qmltests/Dash/qml/fake_lensView3.qml",
            "MockLens4": "../tests/qmltests/Dash/qml/fake_lensView4.qml"
        }
        genericLens: "../tests/qmltests/Dash/qml/fake_generic_lensView.qml"
    }

    function clear_lens_status() {
        lensStatus["MockLens1"].movementStarted = 0;
        lensStatus["MockLens1"].positionedAtBeginning = 0;

        lensStatus["MockLens2"].movementStarted = 0;
        lensStatus["MockLens2"].positionedAtBeginning = 0;

        lensStatus["MockLens3"].movementStarted = 0;
        lensStatus["MockLens3"].positionedAtBeginning = 0;

        lensStatus["MockLens4"].movementStarted = 0;
        lensStatus["MockLens4"].positionedAtBeginning = 0;

        lensStatus["MockLens5"].movementStarted = 0;
        lensStatus["MockLens5"].positionedAtBeginning = 0;
    }

    SignalSpy {
        id: lensLoadedSpy
        target: dashContent
        signalName: "lensLoaded"
    }

    SignalSpy {
        id: movementStartedSpy
        target: dashContent
        signalName: "movementStarted"
    }

    SignalSpy {
        id: contentEndReachedSpy
        target: dashContent
        signalName: "contentEndReached"
    }

    UT.UnityTestCase {
        name: "DashContent"
        when: windowShown

        function init() {
            lensLoadedSpy.clear();
            movementStartedSpy.clear();
            contentEndReachedSpy.clear()
            clear_lens_status();

            // clear, wait for dahs to empty and load lenses.
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined)
            lensesModel.clear();
            tryCompare(dashContentList, "count", 0);
            lensesModel.load();
        }

        function test_movement_started_signal() {
            dashContent.setCurrentLensAtIndex(3, true, false);

            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined)
            tryCompare(lensLoadedSpy, "count", 5);

            dashContentList.movementStarted();
            compare(movementStartedSpy.count, 1, "DashContent should have emitted movementStarted signal when content list did.");
            compare(lensStatus["MockLens1"].movementStarted, 1, "MockLens1 should have emitted movementStarted signal when content list did.");
            compare(lensStatus["MockLens2"].movementStarted, 1, "MockLens2 should have emitted movementStarted signal when content list did.");
            compare(lensStatus["MockLens3"].movementStarted, 1, "MockLens3 should have emitted movementStarted signal when content list did.");
            compare(lensStatus["MockLens4"].movementStarted, 1, "MockLens4 should have emitted movementStarted signal when content list did.");
            compare(lensStatus["MockLens5"].movementStarted, 1, "MockLens5 should have emitted movementStarted signal when content list did.");
        }

        function test_positioned_at_beginning_signal() {
            dashContent.setCurrentLensAtIndex(3, true, false);

            tryCompare(lensLoadedSpy, "count", 5);

            dashContent.positionedAtBeginning();
            compare(lensStatus["MockLens1"].positionedAtBeginning, 1, "MockLens1 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(lensStatus["MockLens2"].positionedAtBeginning, 1, "MockLens2 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(lensStatus["MockLens3"].positionedAtBeginning, 1, "MockLens3 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(lensStatus["MockLens4"].positionedAtBeginning, 1, "MockLens4 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(lensStatus["MockLens5"].positionedAtBeginning, 1, "MockLens5 should have emitted positionedAtBeginning signal when DashContent did.");
        }

        function test_lens_loaded() {
            tryCompare(lensLoadedSpy, "count", 5);
        }

        function test_content_end_reached() {
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(lensLoadedSpy, "count", 5);

            dashContent.setCurrentLensAtIndex(0, true, false);
            dashContentList.currentItem.item.endReached();

            compare(contentEndReachedSpy.count, 1);
        }

        // This tests that setting the current lens index will end up at the correct index even if
        // the lenses are loaded asynchrounsly.
        function test_set_current_lens_index_async() {
            verify(lensesModel.loaded == false);

            // next index is 1 if current is -1, otherwise it's current + 1
            var next_index = ((dashContent.currentIndex == -1 ? 0 : dashContent.currentIndex) + 1) % 5

            dashContent.setCurrentLensAtIndex(next_index, true, false);
            tryCompare(dashContent, "currentIndex", next_index);
            verify(lensesModel.loaded == true);

            // test greater than lens count.
            dashContent.setCurrentLensAtIndex(lensesModel.count, true, false);
            compare(dashContent.currentIndex, 4);
        }

        function get_current_item_object_name() {
            var dashContentList = findChild(dashContent, "dashContentList");
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
            dashContent.setCurrentLensAtIndex(data.index, true, false);
            tryCompareFunction(get_current_item_object_name, data.objectName)
        }

    }
}
