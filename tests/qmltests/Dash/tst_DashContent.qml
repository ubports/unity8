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

    property var scope_status: {
        'MockScope1': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'MockScope2': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'MockScope3': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'MockScope4': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'MockScope5': { 'movementStarted': 0, 'positionedAtBeginning': 0 }
    }

    Scopes {
        id: scopesModel
    }

    DashContent {
        id: dash_content
        anchors.fill: parent

        model: scopesModel
        scopes : scopesModel

        scopeDelegateMapping: { "MockScope3" : "../tests/qmltests/Dash/qml/fake_scopeView3.qml",
                               "MockScope2" : "../tests/qmltests/Dash/qml/fake_scopeView2.qml",
                               "MockScope1" : "../tests/qmltests/Dash/qml/fake_scopeView1.qml",
                               "MockScope4" : "../tests/qmltests/Dash/qml/fake_scopeView4.qml"
                             }

        genericScope: "../tests/qmltests/Dash/qml/fake_generic_scopeView.qml"
    }

    function clear_scope_status() {
        scope_status["MockScope1"].movementStarted = 0;
        scope_status["MockScope1"].positionedAtBeginning = 0;

        scope_status["MockScope2"].movementStarted = 0;
        scope_status["MockScope2"].positionedAtBeginning = 0;

        scope_status["MockScope3"].movementStarted = 0;
        scope_status["MockScope3"].positionedAtBeginning = 0;

        scope_status["MockScope4"].movementStarted = 0;
        scope_status["MockScope4"].positionedAtBeginning = 0;

        scope_status["MockScope5"].movementStarted = 0;
        scope_status["MockScope5"].positionedAtBeginning = 0;
    }

    SignalSpy {
        id: scopeLoaded_spy
        target: dash_content
        signalName: "scopeLoaded"
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
            scopeLoaded_spy.clear();
            movementStarted_spy.clear();
            contentEndReached_spy.clear()
            clear_scope_status();

            // clear, wait for dahs to empty and load scopes.
            var dashContentList = findChild(dash_content, "dashContentList");
            verify(dashContentList != undefined)
            scopesModel.clear();
            tryCompare(dashContentList, "count", 0);
            scopesModel.load();
        }

        function test_movement_started_signal() {
            dash_content.setCurrentScopeAtIndex(3, true, false);

            var dashContentList = findChild(dash_content, "dashContentList");
            verify(dashContentList != undefined)
            tryCompare(scopeLoaded_spy, "count", 5);

            dashContentList.movementStarted();
            compare(movementStarted_spy.count, 1, "DashContent should have emitted movementStarted signal when content list did.");
            compare(scope_status["MockScope1"].movementStarted, 1, "MockScope1 should have emitted movementStarted signal when content list did.");
            compare(scope_status["MockScope2"].movementStarted, 1, "MockScope2 should have emitted movementStarted signal when content list did.");
            compare(scope_status["MockScope3"].movementStarted, 1, "MockScope3 should have emitted movementStarted signal when content list did.");
            compare(scope_status["MockScope4"].movementStarted, 1, "MockScope4 should have emitted movementStarted signal when content list did.");
            compare(scope_status["MockScope5"].movementStarted, 1, "MockScope5 should have emitted movementStarted signal when content list did.");
        }

        function test_positioned_at_beginning_signal() {
            dash_content.setCurrentScopeAtIndex(3, true, false);

            tryCompare(scopeLoaded_spy, "count", 5);

            dash_content.positionedAtBeginning();
            compare(scope_status["MockScope1"].positionedAtBeginning, 1, "MockScope1 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scope_status["MockScope2"].positionedAtBeginning, 1, "MockScope2 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scope_status["MockScope3"].positionedAtBeginning, 1, "MockScope3 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scope_status["MockScope4"].positionedAtBeginning, 1, "MockScope4 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scope_status["MockScope5"].positionedAtBeginning, 1, "MockScope5 should have emitted positionedAtBeginning signal when DashContent did.");
        }

        function test_scope_loaded() {
            tryCompare(scopeLoaded_spy, "count", 5);
        }

        function test_content_end_reached() {
            var dashContentList = findChild(dash_content, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(scopeLoaded_spy, "count", 5);

            dash_content.setCurrentScopeAtIndex(0, true, false);
            dashContentList.currentItem.item.endReached();

            compare(contentEndReached_spy.count, 1);
        }

        // This tests that setting the current scope index will end up at the correct index even if
        // the scopes are loaded asynchrounsly.
        function test_set_current_scope_index_async() {
            verify(scopesModel.loaded == false);

            // next index is 1 if current is -1, otherwise it's current + 1
            var next_index = ((dash_content.currentIndex == -1 ? 0 : dash_content.currentIndex) + 1) % 5

            dash_content.setCurrentScopeAtIndex(next_index, true, false);
            tryCompare(dash_content, "currentIndex", next_index);
            verify(scopesModel.loaded == true);

            // test greater than scope count.
            dash_content.setCurrentScopeAtIndex(scopesModel.count, true, false);
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

        function test_scope_mapping_data() {
            return [
                {tag: "index0", index: 0, objectName: "fake_scopeView1"},
                {tag: "index1", index: 1, objectName: "fake_scopeView2"},
                {tag: "index2", index: 2, objectName: "fake_scopeView3"},
                {tag: "index3", index: 3, objectName: "fake_scopeView4"},
                {tag: "index4", index: 4, objectName: "fake_generic_scopeView"}
            ]
        }

        function test_scope_mapping(data) {
            dash_content.setCurrentScopeAtIndex(data.index, true, false);
            tryCompareFunction(get_current_item_object_name, data.objectName)
        }

    }
}
