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
import "../../../Components"
import Ubuntu.Components 0.1
import Unity 0.1
import Unity.Test 0.1 as UT
import Utils 0.1

Item {
    id: shell
    width: units.gu(40)
    height: units.gu(80)

    Item {
        // Fake. Make a few components less noisy
        id: greeter
        signal shownChanged
    }

    Item {
        // Fake. Make a few components less noisy
        id: panel
        signal searchClicked
    }

    property var scopeStatus: {
        'MockScope1': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'MockScope2': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'home.scope': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'applications.scope': { 'movementStarted': 0, 'positionedAtBeginning': 0 },
        'MockScope5': { 'movementStarted': 0, 'positionedAtBeginning': 0 }
    }

    Scopes {
        id: scopesModel
    }

    DashContent {
        id: dashContent
        anchors.fill: parent

        model: SortFilterProxyModel {
            model: scopesModel
        }
        scopes : scopesModel

        scopeMapper : scopeDelegateMapper
        searchHistory: SearchHistoryModel {}
    }

    ScopeDelegateMapper {
        id: scopeDelegateMapper
        scopeDelegateMapping: {
            "MockScope1": "../tests/qmltests/Dash/qml/fake_scopeView1.qml",
            "MockScope2": "../tests/qmltests/Dash/qml/fake_scopeView2.qml",
            "home.scope": "../tests/qmltests/Dash/qml/fake_scopeView3.qml",
            "applications.scope": "../tests/qmltests/Dash/qml/fake_scopeView4.qml"
        }
        genericScope: "../tests/qmltests/Dash/qml/fake_generic_scopeView.qml"
    }

    function clear_scope_status() {
        scopeStatus["MockScope1"].movementStarted = 0;
        scopeStatus["MockScope1"].positionedAtBeginning = 0;

        scopeStatus["MockScope2"].movementStarted = 0;
        scopeStatus["MockScope2"].positionedAtBeginning = 0;

        scopeStatus["home.scope"].movementStarted = 0;
        scopeStatus["home.scope"].positionedAtBeginning = 0;

        scopeStatus["applications.scope"].movementStarted = 0;
        scopeStatus["applications.scope"].positionedAtBeginning = 0;

        scopeStatus["MockScope5"].movementStarted = 0;
        scopeStatus["MockScope5"].positionedAtBeginning = 0;
    }

    SignalSpy {
        id: scopeLoadedSpy
        target: dashContent
        signalName: "scopeLoaded"
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
        when: scopesModel.loaded

        function init() {
            scopesModel.clear();
            scopesModel.load();
        }

        function cleanup() {
            scopeLoadedSpy.clear();
            movementStartedSpy.clear();
            contentEndReachedSpy.clear();
            clear_scope_status();
            dashContent.visible = true;

            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined);
            scopesModel.clear();
            // wait for dash to empty scopes.
            tryCompare(dashContentList, "count", 0);
            // this is the default state for empty model
            dashContentList.currentIndex = -1;
        }

        function test_current_index() {
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined)

            compare(dashContentList.count, 0, "DashContent should have 0 items when it starts");
            compare(dashContentList.currentIndex, -1, "DashContent's currentIndex should be -1 while there have been no items in the model");

            tryCompare(scopeLoadedSpy, "count", 5);

            verify(dashContentList.currentIndex >= 0);
        }

        function test_current_index_after_reset() {
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined)

            compare(dashContentList.count, 0, "DashContent should have 0 items when it starts");
            // pretend we're running after a model reset
            dashContentList.currentIndex = 27;

            tryCompare(scopeLoadedSpy, "count", 5);

            verify(dashContentList.currentIndex >= 0 && dashContentList.currentIndex < 5);
        }

        function test_movement_started_signal() {
            dashContent.setCurrentScopeAtIndex(3, true, false);

            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined)

            tryCompare(scopeLoadedSpy, "count", 5);

            dashContentList.movementStarted();

            compare(movementStartedSpy.count, 1, "DashContent should have emitted movementStarted signal when content list did.");
            compare(scopeStatus["MockScope1"].movementStarted, 1, "MockScope1 should have emitted movementStarted signal when content list did.");
            compare(scopeStatus["MockScope2"].movementStarted, 1, "MockScope2 should have emitted movementStarted signal when content list did.");
            compare(scopeStatus["home.scope"].movementStarted, 1, "home.scope should have emitted movementStarted signal when content list did.");
            compare(scopeStatus["applications.scope"].movementStarted, 1, "applications.scope should have emitted movementStarted signal when content list did.");
            compare(scopeStatus["MockScope5"].movementStarted, 1, "MockScope5 should have emitted movementStarted signal when content list did.");
        }

        function test_positioned_at_beginning_signal() {
            dashContent.setCurrentScopeAtIndex(3, true, false);

            tryCompare(scopeLoadedSpy, "count", 5);

            dashContent.positionedAtBeginning();
            compare(scopeStatus["MockScope1"].positionedAtBeginning, 1, "MockScope1 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scopeStatus["MockScope2"].positionedAtBeginning, 1, "MockScope2 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scopeStatus["home.scope"].positionedAtBeginning, 1, "home.scope should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scopeStatus["applications.scope"].positionedAtBeginning, 1, "applications.scope should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scopeStatus["MockScope5"].positionedAtBeginning, 1, "MockScope5 should have emitted positionedAtBeginning signal when DashContent did.");
        }

        function test_scope_loaded() {
            tryCompare(scopeLoadedSpy, "count", 5);
        }

        function test_content_end_reached() {
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined);

            tryCompare(scopeLoadedSpy, "count", 5);
            dashContent.setCurrentScopeAtIndex(0, true, false);
            dashContentList.currentItem.item.endReached();

            compare(contentEndReachedSpy.count, 1);
        }

        // This tests that setting the current scope index will end up at the correct index even if
        // the scopes are loaded asynchrounsly.
        function test_set_current_scope_index_async() {
            verify(scopesModel.loaded == false);

            // next index is 1 if current is -1, otherwise it's current + 1
            var next_index = ((dashContent.currentIndex == -1 ? 0 : dashContent.currentIndex) + 1) % 5

            dashContent.setCurrentScopeAtIndex(next_index, true, false);
            tryCompare(dashContent, "currentIndex", next_index);
            verify(scopesModel.loaded == true);

            // test greater than scope count.
            var currentScopeIndex = dashContent.currentIndex;
            dashContent.setCurrentScopeAtIndex(scopesModel.count, true, false);
            compare(dashContent.currentIndex, currentScopeIndex, "Scope should not change if changing to greater index than count");
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
            dashContent.setCurrentScopeAtIndex(data.index, true, false);
            tryCompareFunction(get_current_item_object_name, data.objectName)
        }

        function test_is_active_data() {
            return [
                {tag: "select 0", select: 0, visible: true, active0: true, active1: false, active2: false, active3: false},
                {tag: "select 2", select: 2, visible: true, active0: false, active1: false, active2: true, active3: false},
                {tag: "invisible", select: 0, visible: false, active0: false, active1: false, active2: false, active3: false},
            ]
        }

        function test_is_active(data) {
            var dashContentList = findChild(dashContent, "dashContentList");

            tryCompare(scopeLoadedSpy, "count", 5);

            dashContent.setCurrentScopeAtIndex(data.select, true, false);
            dashContent.visible = data.visible;

            tryCompare(scopesModel.get(0), "isActive", data.active0);
            tryCompare(scopesModel.get(1), "isActive", data.active1);
            tryCompare(scopesModel.get(2), "isActive", data.active2);
        }

        function test_tabBar_index_change() {
            tryCompare(scopesModel, "loaded", true);
            var tabbar = findChild(dashContent, "tabbar");

            compare(dashContent.currentIndex, 0);
            tryCompare(tabbar, "selectionMode", false);
            mouseClick(tabbar, units.gu(5), units.gu(5))
            tryCompare(tabbar, "selectionMode", true);
            var button0 = tabbar.children[0].children[0].children[0].children[2].children[1];
            waitForRendering(button0);
            tryCompare(button0.children[3], "text", "Music");
            mouseClick(button0, button0.width / 2, button0.height / 2)
            tryCompare(tabbar, "selectionMode", false);
            tryCompare(tabbar, "selectedIndex", 1);
            tryCompare(dashContent, "currentIndex", 1);
        }

        function test_tabBar_listens_to_index_change() {
            var tabbar = findChild(dashContent, "tabbar");
            tryCompare(dashContent, "currentIndex", 0);
            compare(tabbar.selectedIndex, 0);
            dashContent.currentIndex = 1;
            compare(tabbar.selectedIndex, 1);
        }

        function checkFlickMovingAndNotInteractive()
        {
            var dashContentList = findChild(dashContent, "dashContentList");

            if (dashContentList.currentItem.moving && !dashContentList.interactive)
                return true;

            var startX = dashContentList.width/2;
            var startY = dashContentList.height/2;
            touchFlick(dashContentList, startX, startY, startX, startY - units.gu(40));

            return dashContentList.currentItem.moving && !dashContentList.interactive;
        }

        function test_hswipe_disabled_vswipe() {
            var dashContentList = findChild(dashContent, "dashContentList");

            tryCompare(dashContentList, "interactive", true);

            tryCompareFunction(checkFlickMovingAndNotInteractive, true);
        }
    }
}
