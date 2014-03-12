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
import "../../../qml/Dash"
import "../../../qml/Components"
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
            "MockScope1": Qt.resolvedUrl("qml/fake_scopeView1.qml"),
            "MockScope2": Qt.resolvedUrl("qml/fake_scopeView2.qml"),
            "home.scope": Qt.resolvedUrl("qml/fake_scopeView3.qml"),
            "applications.scope": Qt.resolvedUrl("qml/fake_scopeView4.qml")
        }
        genericScope: Qt.resolvedUrl("qml/fake_generic_scopeView.qml")
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

    UT.UnityTestCase {
        name: "DashContent"
        when: scopesModel.loaded

        function init() {
            scopesModel.clear();
            scopeLoadedSpy.clear();
            scopesModel.load();
            tryCompare(scopeLoadedSpy, "count", 5);
        }

        function cleanup() {
            movementStartedSpy.clear();
            clear_scope_status();
            dashContent.visible = true;

            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined);
            scopesModel.clear();
            // wait for dash to empty scopes.
            tryCompare(dashContentList, "count", 0);
        }

        function test_current_index() {
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined)

            scopesModel.clear();
            compare(dashContentList.count, 0, "DashContent should have 0 items when it starts");
            tryCompare(dashContentList, "currentIndex", -1);

            scopeLoadedSpy.clear();
            scopesModel.load();
            tryCompare(scopeLoadedSpy, "count", 5);

            verify(dashContentList.currentIndex >= 0);
        }

        function test_current_index_after_reset() {
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined)

            scopesModel.clear();
            compare(dashContentList.count, 0, "DashContent should have 0 items after clearing");
            // pretend we're running after a model reset
            dashContentList.currentIndex = 27;

            scopeLoadedSpy.clear();
            scopesModel.load();
            tryCompare(scopeLoadedSpy, "count", 5);

            verify(dashContentList.currentIndex >= 0 && dashContentList.currentIndex < 5);
        }

        function test_movement_started_signal() {
            dashContent.setCurrentScopeAtIndex(3, true, false);

            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined)

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

            dashContent.positionedAtBeginning();
            compare(scopeStatus["MockScope1"].positionedAtBeginning, 1, "MockScope1 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scopeStatus["MockScope2"].positionedAtBeginning, 1, "MockScope2 should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scopeStatus["home.scope"].positionedAtBeginning, 1, "home.scope should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scopeStatus["applications.scope"].positionedAtBeginning, 1, "applications.scope should have emitted positionedAtBeginning signal when DashContent did.");
            compare(scopeStatus["MockScope5"].positionedAtBeginning, 1, "MockScope5 should have emitted positionedAtBeginning signal when DashContent did.");
        }

        // This tests that setting the current scope index will end up at the correct index even if
        // the scopes are loaded asynchrounsly.
        function test_set_current_scope_index_async() {
            scopesModel.clear();
            verify(scopesModel.loaded == false);

            tryCompare(dashContent, "currentIndex", -1);
            var next_index = 1

            dashContent.setCurrentScopeAtIndex(next_index, true, false);
            scopesModel.load();
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
            var pageHeader = findChild(dashContent, "pageHeader");
            compare(pageHeader.scope, scopesModel.get(data.index));
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

            dashContent.setCurrentScopeAtIndex(data.select, true, false);
            dashContent.visible = data.visible;

            tryCompare(scopesModel.get(0), "isActive", data.active0);
            tryCompare(scopesModel.get(1), "isActive", data.active1);
            tryCompare(scopesModel.get(2), "isActive", data.active2);
        }

        function doFindMusicButton(parent) {
            for (var i = 0; i < parent.children.length; i++) {
                var c = parent.children[i];
                if (UT.Util.isInstanceOf(c, "AbstractButton") && parent.x >= 0) {
                    for (var ii = 0; ii < c.children.length; ii++) {
                        var cc = c.children[ii];
                        if (UT.Util.isInstanceOf(cc, "Label") && cc.text == "Music") {
                            return c;
                        }
                    }
                }
                var r = doFindMusicButton(c);
                if (r !== undefined) {
                    return r;
                }
            }
            return undefined;
        }

        function findMusicButton() {
            // We need to find a AbstractButton that has a Label child
            // with text Music and it's parent x is >= 0
            var tabbar = findChild(dashContent, "tabbar");
            return doFindMusicButton(tabbar);
        }

        function test_tabBar_index_change() {
            tryCompare(scopesModel, "loaded", true);
            var tabbar = findChild(dashContent, "tabbar");

            compare(dashContent.currentIndex, 0);
            tryCompare(tabbar, "selectedIndex", 0);
            tryCompare(tabbar, "selectionMode", false);

            mouseClick(tabbar, units.gu(5), units.gu(5))

            tryCompare(tabbar, "selectionMode", true);
            tryCompare(tabbar, "selectedIndex", 0);
            tryCompare(dashContent, "currentIndex", 0);

            var button;
            tryCompareFunction(function() { button = findMusicButton(); return button != undefined; }, true);
            waitForRendering(button);

            mouseClick(button, button.width / 2, button.height / 2)

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
