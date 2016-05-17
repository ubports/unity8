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

import QtQuick 2.4
import QtTest 1.0
import "../../../qml/Dash"
import "../../../qml/Components"
import Ubuntu.Components 1.3
import Unity 0.2
import Unity.Test 0.1 as UT
import Utils 0.1

Item {
    id: shell
    width: units.gu(40)
    height: units.gu(80)

    // BEGIN To reduce warnings
    // TODO I think it we should pass down these variables
    // as needed instead of hoping they will be globally around
    property var greeter: null
    property var panel: null
    // BEGIN To reduce warnings

    Scopes {
        id: scopesModel
    }

    DashContent {
        id: dashContent
        anchors.fill: parent

        scopes : scopesModel
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
        id: loadedSpy
        signalName: "loaded"
    }

    UT.UnityTestCase {
        name: "DashContent"
        when: scopesModel.loaded && windowShown

        function loadScopes() {
            scopeLoadedSpy.clear();
            scopesModel.load();
            tryCompare(scopeLoadedSpy, "count", 6, 15000);
            tryCompare(scopesModel, "loaded", true);
            tryCompareFunction(function() {
                var mockScope1Loader = findChild(shell, "scopeLoader0");
                return mockScope1Loader && mockScope1Loader.item != null; },
                true, 15000);
            tryCompareFunction(function() {
                var mockScope1Loader = findChild(shell, "scopeLoader0");
                return mockScope1Loader && mockScope1Loader.status === Loader.Ready; },
                true, 15000);
            waitForRendering(findChild(shell, "scopeLoader0").item);
        }

        function init() {
            scopesModel.clear();
            loadScopes();
        }

        function cleanup() {
            movementStartedSpy.clear();
            loadedSpy.clear();
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

            loadScopes();

            verify(dashContentList.currentIndex >= 0);
        }

        function test_current_index_after_reset() {
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList != undefined)

            scopesModel.clear();
            compare(dashContentList.count, 0, "DashContent should have 0 items after clearing");
            // pretend we're running after a model reset
            dashContentList.currentIndex = 27;

            loadScopes();

            compare(dashContentList.count, 6);
            verify(dashContentList.currentIndex >= 0 && dashContentList.currentIndex < dashContentList.count);
        }

        function test_show_header_on_list_movement() {
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList !== null);
            var scope = findChild(dashContent, "scopeLoader0");
            waitForRendering(scope);

            var categoryListView = findChild(scope, "categoryListView");
            waitForRendering(categoryListView);

            categoryListView.contentY = units.gu(15);
            tryCompare(categoryListView, "contentY", units.gu(15));

            var startX = dashContentList.width/2;
            var startY = dashContentList.height/2;
            touchFlick(dashContentList, startX - units.gu(4), startY, startX, startY);
            tryCompare(categoryListView, "contentY", units.gu(15) - categoryListView.pageHeader.height);
        }

        function test_set_current_scope_reset() {
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList, "Couldn't find dashContentList");
            var scope = findChild(dashContent, "scopeLoader0");

            tryCompare(scope, "status", Loader.Ready);

            var categoryListView = findChild(scope, "categoryListView");
            categoryListView.contentY = units.gu(10);

            compare(dashContentList.currentItem.item.objectName,  "MockScope1")
            compare(categoryListView.contentY, units.gu(10));

            dashContent.setCurrentScopeAtIndex(0, false, true);

            compare(dashContentList.currentItem.item.objectName,  "MockScope1")
            compare(categoryListView.contentY,  0);
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
            dashContent.setCurrentScopeAtIndex(18, true, false);
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
                {tag: "index0", index: 0, objectName: "MockScope1"},
                {tag: "index1", index: 1, objectName: "clickscope"},
                {tag: "index2", index: 2, objectName: "MockScope5"},
                {tag: "index3", index: 3, objectName: "SingleCategoryScope"}
            ]
        }

        function test_scope_mapping(data) {
            dashContent.setCurrentScopeAtIndex(data.index, true, false);
            tryCompareFunction(get_current_item_object_name, data.objectName)
            var scopeView = findChild(dashContent, data.objectName);
            verify(scopeView, "Could not find the scope view.");
            var pageHeader = findChild(scopeView, "scopePageHeader");
            verify(pageHeader, "Could not find the scope page header.");
            var innerHeader = findChild(pageHeader, "innerPageHeader");
            verify(innerHeader, "Could not find the scope page header.");
            compare(innerHeader.title, scopesModel.getScope(data.index).name);
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

            tryCompare(scopesModel.getScope(0), "isActive", data.active0);
            tryCompare(scopesModel.getScope(1), "isActive", data.active1);
            tryCompare(scopesModel.getScope(2), "isActive", data.active2);
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

        function test_carouselAspectRatio() {
            tryCompareFunction(function() {
                                    var scope = findChild(dashContent, "scopeLoader0");
                                    if (scope != null) {
                                        var dashCategory1 = findChild(scope, "dashCategory1");
                                        if (dashCategory1 != null) {
                                            var tile = findChild(dashCategory1, "carouselDelegate1");
                                            return tile != null;
                                        }
                                    }
                                    return false;
                                },
                                true);

            var scope = findChild(dashContent, "scopeLoader0");
            var dashCategory1 = findChild(scope, "dashCategory1");
            var cardTool = findChild(dashCategory1, "cardTool");
            var carouselLV = findChild(dashCategory1, "listView");
            verify(carouselLV.tileWidth / carouselLV.tileHeight == cardTool.components["art"]["aspect-ratio"]);
        }

        function test_mainNavigation() {
            var dashContentList = findChild(dashContent, "dashContentList");
            tryCompareFunction(function() { return findChild(dashContentList.currentItem, "dashNavigation") != null; }, true);
            var dashNavigation = findChild(dashContentList.currentItem, "dashNavigation");
            var peExtraPanel = findChild(dashContentList.currentItem, "peExtraPanel");
            var searchButton = findChild(dashContentList.currentItem, "search_button");
            var searchTextField = findChild(dashContentList.currentItem, "searchTextField");
            compare(peExtraPanel.visible, false);
            mouseClick(searchButton);
            tryCompare(peExtraPanel, "visible", true);
            peExtraPanel.searchHistory.clear();

            var navigationListView = findChild(dashNavigation, "navigationListView");
            tryCompareFunction(function() {
                return navigationListView.currentItem &&
                       navigationListView.currentItem.navigation &&
                       navigationListView.currentItem.navigation.loaded; }, true);

            waitForRendering(navigationListView);
            waitForRendering(navigationListView.currentItem);

            var navigation = findChild(dashNavigation, "navigation0child3");
            mouseClick(navigation);
            compare(peExtraPanel.visible, false);
            tryCompare(dashNavigation.currentNavigation, "navigationId", "middle3");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "root");

            mouseClick(searchTextField);
            tryCompare(peExtraPanel, "visible", true);
            waitForRendering(navigationListView);
            waitForRendering(navigationListView.currentItem);

            var header0 = findChild(dashNavigation, "dashNavigationHeader0");
            compare(header0.backVisible, false);
            mouseClick(header0);
            compare(peExtraPanel.visible, false);
            tryCompare(dashNavigation.currentNavigation, "navigationId", "root");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "root");

            var headerContainer = findChild(dashContentList.currentItem, "headerContainer");
            tryCompare(headerContainer, "contentY", headerContainer.height);
            mouseClick(searchButton);
            tryCompare(peExtraPanel, "visible", true);
            waitForRendering(navigationListView);
            waitForRendering(navigationListView.currentItem);

            navigation = findChild(dashNavigation, "navigation0child2");
            mouseClick(navigation);
            compare(peExtraPanel.visible, true);
            tryCompare(dashNavigation.currentNavigation, "navigationId", "middle2");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "middle2");

            var navigationList1 = findChild(dashNavigation, "navigation1");
            var header1 = findChild(dashNavigation, "dashNavigationHeader1");
            compare(header0.height, 0);
            compare(header1.backVisible, true);

            tryCompare(navigationListView, "contentX", navigationList1.x);
            waitForRendering(navigationListView);
            mouseClick(header1);
            compare(peExtraPanel.visible, false);
            tryCompare(dashNavigation.currentNavigation, "navigationId", "middle2");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "middle2");

            mouseClick(searchTextField);
            tryCompare(peExtraPanel, "visible", true);
            waitForRendering(navigationListView);
            waitForRendering(navigationListView.currentItem);
            compare(header0.height, 0);
            compare(header1.backVisible, true);

            tryCompare(navigationList1.navigation, "loaded", true);
            tryCompare(navigationList1, "implicitHeight", navigationList1.itemHeight * 8);
            tryCompare(navigationList1, "height", navigationList1.implicitHeight);
            navigation = findChild(dashNavigation, "navigation1child2");
            mouseClick(navigation);
            compare(peExtraPanel.visible, false);
            tryCompare(dashNavigation.currentNavigation, "navigationId", "childmiddle22");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "middle2");

            mouseClick(searchTextField);
            tryCompare(peExtraPanel, "visible", true);
            waitForRendering(navigationListView);
            waitForRendering(navigationListView.currentItem);

            tryCompare(navigationList1.navigation, "loaded", true);
            navigation = findChild(dashNavigation, "navigation1child3");
            mouseClick(navigation);
            compare(peExtraPanel.visible, false);
            tryCompare(dashNavigation.currentNavigation, "navigationId", "childmiddle23");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "middle2");

            mouseClick(searchTextField);
            tryCompare(peExtraPanel, "visible", true);
            waitForRendering(navigationListView);
            waitForRendering(navigationListView.currentItem);
            mouseClick(findChild(header1, "backButton"));

            tryCompare(dashNavigation.currentNavigation, "navigationId", "root");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "root");
            compare(peExtraPanel.visible, true);
            mouseClick(header0);
            compare(peExtraPanel.visible, false);

            tryCompare(headerContainer, "contentY", headerContainer.height);
            mouseClick(searchButton);
            tryCompare(peExtraPanel, "visible", true);
            tryCompare(navigationListView.currentItem.navigation, "loaded", true);
            var navigationList0 = findChild(dashNavigation, "navigation0");
            tryCompare(navigationList0, "implicitHeight", navigationList0.itemHeight * 8);
            tryCompare(navigationList0, "height", navigationList0.implicitHeight);
            navigation = findChild(dashNavigation, "navigation0child2");
            mouseClick(navigation);
            compare(peExtraPanel.visible, true);
            navigationList1 = findChild(dashNavigation, "navigation1");
            compare(navigationList1.navigation.loaded, false);
            tryCompare(dashNavigation.currentNavigation, "navigationId", "middle2");
            mouseClick(header0);
            tryCompare(dashNavigation.currentNavigation, "navigationId", "middle2");
        }

        function goToSecondLevel() {
            var dashContentList = findChild(dashContent, "dashContentList");
            tryCompareFunction(function() { return findChild(dashContentList.currentItem, "dashNavigation") != null; }, true);
            var dashNavigation = findChild(dashContentList.currentItem, "dashNavigation");
            var peExtraPanel = findChild(dashContentList.currentItem, "peExtraPanel");
            var searchButton = findChild(dashContentList.currentItem, "search_button");
            var searchTextField = findChild(dashContentList.currentItem, "searchTextField");
            compare(peExtraPanel.visible, false);
            mouseClick(searchButton);
            tryCompare(peExtraPanel, "visible", true);

            var navigationListView = findChild(dashNavigation, "navigationListView");
            tryCompareFunction(function() {
                return navigationListView.currentItem &&
                       navigationListView.currentItem.navigation &&
                       navigationListView.currentItem.navigation.loaded; }, true);
            waitForRendering(navigationListView);
            waitForRendering(navigationListView.currentItem);

            var navigation4 = findChild(dashNavigation, "navigation0child4");
            mouseClick(navigation4);
            tryCompare(dashNavigation.currentNavigation, "navigationId", "middle4");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "middle4");
            tryCompare(dashNavigation.currentNavigation, "loaded", true);

            waitForRendering(navigationListView);
            waitForRendering(navigationListView.currentItem);

            var navigation44 = findChild(dashNavigation, "navigation1child4");
            mouseClick(navigation44);
            tryCompare(dashNavigation.currentNavigation, "navigationId", "childmiddle44");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "childmiddle44");
            tryCompare(dashNavigation.currentNavigation, "loaded", true);

            waitForRendering(navigationListView);
            waitForRendering(navigationListView.currentItem);

            // header 0 is hidden
            var header0 = findChild(dashNavigation, "dashNavigationHeader0");
            compare(header0.height, 0);
        }

        function test_navigationSecondLevelToRoot() {
            goToSecondLevel();

            var dashContentList = findChild(dashContent, "dashContentList");
            var dashNavigation = findChild(dashContentList.currentItem, "dashNavigation");
            var navigationListView = findChild(dashNavigation, "navigationListView");
            var peExtraPanel = findChild(dashContentList.currentItem, "peExtraPanel");

            // Go directly to the root pressing the back button of header1
            var header1 = findChild(dashNavigation, "dashNavigationHeader1");
            compare(header1.backVisible, true);
            mouseClick(findChild(header1, "backButton"));

            tryCompare(dashNavigation.currentNavigation, "navigationId", "root");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "root");
            compare(peExtraPanel.visible, true);
        }

        function test_navigationSecondLevelToFirstName() {
            goToSecondLevel();

            var dashContentList = findChild(dashContent, "dashContentList");
            var dashNavigation = findChild(dashContentList.currentItem, "dashNavigation");
            var navigationListView = findChild(dashNavigation, "navigationListView");
            var peExtraPanel = findChild(dashContentList.currentItem, "peExtraPanel");

            // Go directly to the first pressing the header1
            var header1 = findChild(dashNavigation, "dashNavigationHeader1");
            mouseClick(header1);

            tryCompare(dashNavigation.currentNavigation, "navigationId", "middle4");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "middle4");
            compare(peExtraPanel.visible, false);
        }

        function test_navigationSecondLevelToFirstBack() {
            goToSecondLevel();

            var dashContentList = findChild(dashContent, "dashContentList");
            var dashNavigation = findChild(dashContentList.currentItem, "dashNavigation");
            var navigationListView = findChild(dashNavigation, "navigationListView");
            var peExtraPanel = findChild(dashContentList.currentItem, "peExtraPanel");

            // Go back to the first level pressing the back button of header2
            var header2 = findChild(dashNavigation, "dashNavigationHeader2");
            compare(header2.backVisible, true);
            mouseClick(findChild(header2, "backButton"));

            tryCompare(dashNavigation.currentNavigation, "navigationId", "middle4");
            tryCompare(navigationListView.currentItem.navigation, "navigationId", "middle4");
            compare(peExtraPanel.visible, true);
        }

        function test_clearSearchWithNavigationClosed() {
            var dashContentList = findChild(dashContent, "dashContentList");
            var searchButton = findChild(dashContentList.currentItem, "search_button");
            var peExtraPanel = findChild(dashContentList.currentItem, "peExtraPanel");
            var searchTextField = findChild(dashContentList.currentItem, "searchTextField");

            compare(peExtraPanel.visible, false);
            mouseClick(searchButton);
            tryCompare(peExtraPanel, "visible", true);

            typeString("A");
            compare(peExtraPanel.visible, false);

            var clearIcon = findChild(searchTextField, "clearIcon");
            mouseClick(clearIcon);
            tryCompare(peExtraPanel, "visible", true);
        }

        function test_navigationShowFilterPopup() {
            var dashContentList = findChild(dashContent, "dashContentList");
            var pageHeader = findChild(dashContentList.currentItem, "scopePageHeader")
            var settingsButton = findChild(dashContentList.currentItem, "settingsButton");
            var searchButton = findChild(dashContentList.currentItem, "search_button");
            var cancelButton = findChild(dashContentList.currentItem, "cancelButton");
            var searchTextField = findChild(pageHeader, "searchTextField");
            var peExtraPanel = findChild(dashContentList.currentItem, "peExtraPanel");
            var headerContainer = findChild(pageHeader, "headerContainer");

            // test that closing the filters popover without a search unfocuses and removes the navigation
            mouseClick(searchButton);
            tryCompare(peExtraPanel, "visible", true);

            var filtersPopover = findChild(shell, "filtersPopover")
            verify(!filtersPopover);

            mouseClick(settingsButton);

            filtersPopover = findChild(shell, "filtersPopover")
            verify(filtersPopover);

            mouseClick(shell, shell.width - 1, shell.height - 1);

            tryCompare(pageHeader.extraPanel, "visible", false);
            tryCompare(headerContainer, "showSearch", true);
            tryCompare(searchTextField, "focus", false);

            mouseClick(cancelButton);
            tryCompare(headerContainer, "showSearch", false);
            tryCompare(headerContainer, "contentY", headerContainer.height);

            // test within a navigation
            goToSecondLevel();

            filtersPopover = findChild(shell, "filtersPopover")
            verify(!filtersPopover);

            mouseClick(settingsButton);

            filtersPopover = findChild(shell, "filtersPopover")
            verify(filtersPopover);

            mouseClick(shell, shell.width - 1, shell.height - 1);

            tryCompare(pageHeader.extraPanel, "visible", false);
            tryCompare(headerContainer, "showSearch", true);
        }

        function test_primaryFilter() {
            var dashContentList = findChild(dashContent, "dashContentList");
            tryCompareFunction(function() { return findChild(dashContentList.currentItem, "dashNavigation") != null; }, true);
            dashContentList.currentItem.item.scope.setHasNavigation(false);
            var peExtraPanel = findChild(dashContentList.currentItem, "peExtraPanel");
            var searchButton = findChild(dashContentList.currentItem, "search_button");

            compare(peExtraPanel.visible, false);
            mouseClick(searchButton);
            tryCompare(peExtraPanel, "visible", true);

            tryCompareFunction(function() { return findChild(peExtraPanel, "OSF3") != null; }, true);
        }

        function test_searchHint() {
            var dashContentList = findChild(dashContent, "dashContentList");
            verify(dashContentList !== null);
            var scope = findChild(dashContent, "scopeLoader0");
            waitForRendering(scope);

            var categoryListView = findChild(scope, "categoryListView");
            waitForRendering(categoryListView);

            compare(categoryListView.pageHeader.searchHint, "Search People");
        }

        function compareArrays(a, b) {
            if (a.length != b.length) return false;
            for (var i in a) {
                if (a[i] != b[i]) return false;
            }
            return true;
        }

        function getSettledButtons() {
            var buttons = findChildsByType(dashContent, "UCAbstractButton");
            wait(2500);
            var aux = findChildsByType(dashContent, "UCAbstractButton");
            while (!compareArrays(aux, buttons)) {
                buttons = aux;
                wait(2500);
                aux = findChildsByType(dashContent, "UCAbstractButton");
            }
            return buttons;
        }

        function test_noDelegateCreationDestructionOnMove() {
            // Our cards are of type AbstractButton as defined in CardCreator.js
            // This gives also other things that are not cards but for our purpose it
            // does not matter

            // Wait for the buttons to settle
            var buttons = getSettledButtons();

            // Move the scopes so that the item on the right is the current one
            // without releasing the button
            mouseFlick(dashContent, dashContent.width - units.gu(1), units.gu(1), units.gu(1), units.gu(1), true, false);

            // Make sure we have changed to a new scope
            compare(dashContent.currentIndex, 1);

            // Wait for the buttons to settle
            var buttons2 = getSettledButtons();

            // Verify we have exactly the same buttons as before starting to move
            verify(compareArrays(buttons2, buttons));

            // Release the mouse
            mouseRelease(dashContent, units.gu(1), units.gu(1));

            // Wait for the scopes list to stop moving
            var dashContentList = findChild(dashContent, "dashContentList");
            tryCompare(dashContentList, "moving", false);
            compare(dashContent.currentIndex, 1);

            // Wait for the buttons to settle
            var buttons3 = getSettledButtons();

            // Verify we have a different set of buttons now
            expectFail("", "There has to be new cards after releasing the list is not moving anymore");
            verify(compareArrays(buttons3, buttons));
        }

        function test_unfavoriteScope()
        {
            var dashContentList = findChild(dashContent, "dashContentList");
            var header = findChild(dashContentList.currentItem, "scopePageHeader")
            var favoriteAction = findChild(header, "favorite_button");
            compare(dashContentList.currentIndex, 0);
            compare(dashContentList.indexAt(dashContentList.width * 1.5, 0), 1);
            var nextScopeId = dashContentList.itemAt(dashContentList.width * 1.5, 0).item.scope.id;
            mouseClick(favoriteAction);
            tryCompareFunction(function() { return dashContentList.currentItem.item.scope.id == nextScopeId; }, true);
            compare(dashContentList.currentIndex, 0);
        }

        function test_extraPanel() {
            var dashContentList = findChild(dashContent, "dashContentList");
            var pageHeader = findChild(dashContentList.currentItem, "scopePageHeader")
            pageHeader.searchEntryEnabled = true;
            pageHeader.searchHistory.clear();

            pageHeader.searchHistory.addQuery("Search1");
            pageHeader.searchHistory.addQuery("Search2");

            pageHeader.triggerSearch();
            tryCompare(pageHeader.extraPanel, "visible", true);

            var searchTextField = findChild(pageHeader, "searchTextField");
            compare(searchTextField.focus, true);

            var recentSearches = findChild(pageHeader.extraPanel, "recentSearchesRepeater");
            verify(recentSearches, "Could not find recent searches");

            waitForRendering(recentSearches);

            mouseClick(recentSearches.itemAt(0));
            compare(pageHeader.searchQuery, "Search2");
            tryCompare(pageHeader.extraPanel, "visible", false);
            compare(searchTextField.focus, false);
        }
    }
}
