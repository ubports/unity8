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
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

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


    Dash {
        id: dash
        anchors.fill: parent
    }

    UT.UnityTestCase {
        name: "Dash"
        when: windowShown

        readonly property Item dashContent: findChild(dash, "dashContent");
        readonly property var scopes: dashContent.scopes

        function init() {
            // clear and reload the scopes.
            scopes.clear();
            var dashContentList = findChild(dash, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(dashContentList, "count", 0);
            scopes.load();
            tryCompare(dashContentList, "currentIndex", 0);
            tryCompare(dashContentList, "count", 6);
            tryCompare(scopes, "loaded", true);
            tryCompareFunction(function() {
                var mockScope1Loader = findChild(dash, "scopeLoader0");
                return mockScope1Loader && mockScope1Loader.item != null; },
                true, 15000);
            tryCompareFunction(function() {
                var mockScope1Loader = findChild(dash, "scopeLoader0");
                return mockScope1Loader && mockScope1Loader.status === Loader.Ready; },
                true, 15000);
            waitForRendering(findChild(dash, "scopeLoader0").item);
        }

        function get_scope_data() {
            return [
                        { tag: "MockScope1", visualIndex: 0 },
                        { tag: "MockScope2", visualIndex: -1 },
                        { tag: "clickscope", visualIndex: 1 },
                        { tag: "MockScope5", visualIndex: 2 },
            ]
        }

        function test_show_scope_on_load_data() {
            return get_scope_data()
        }

        function test_dash_overview_show_select_same_favorite() {
            // Show the overview
            touchFlick(dash, dash.width / 2, dash.height - 1, dash.width / 2, dash.height - units.gu(18));
            var overviewController = findInvisibleChild(dash, "overviewController");
            tryCompare(overviewController, "progress", 1);

            // Make sure tab is where it should
            var scopesOverview = findChild(dash, "scopesOverview");
            compare(scopesOverview.currentTab, 0);

            // Make sure stuff is loaded
            var scopesOverviewFavoritesRepeater = findChild(dash, "scopesOverviewFavoritesRepeater");
            tryCompare(scopesOverviewFavoritesRepeater, "count", 6);
            tryCompareFunction(function() { return scopesOverviewFavoritesRepeater.itemAt(0).item != null; }, true);
            waitForRendering(scopesOverviewFavoritesRepeater.itemAt(0).item);

            // Click in first item
            mouseClick(scopesOverviewFavoritesRepeater.itemAt(0).item, 0, 0);

            // Make sure animation went back
            tryCompare(overviewController, "progress", 0);

            var dashContentList = findChild(dash, "dashContentList");
            compare(dashContentList.currentIndex, 0);
        }

        function test_dash_overview_show_select_different_favorite() {
            // Show the overview
            touchFlick(dash, dash.width / 2, dash.height - 1, dash.width / 2, dash.height - units.gu(18));
            var overviewController = findInvisibleChild(dash, "overviewController");
            tryCompare(overviewController, "progress", 1);

            // Make sure tab is where it should
            var scopesOverview = findChild(dash, "scopesOverview");
            compare(scopesOverview.currentTab, 0);

            // Make sure stuff is loaded
            var scopesOverviewFavoritesRepeater = findChild(dash, "scopesOverviewFavoritesRepeater");
            tryCompare(scopesOverviewFavoritesRepeater, "count", 6);
            tryCompareFunction(function() { return scopesOverviewFavoritesRepeater.itemAt(0).item != null; }, true);
            waitForRendering(scopesOverviewFavoritesRepeater.itemAt(1).item);

            // Click in first item
            mouseClick(scopesOverviewFavoritesRepeater.itemAt(1).item, 0, 0);

            // Make sure animation went back
            tryCompare(overviewController, "progress", 0);
            var dashContentList = findChild(dash, "dashContentList");
            compare(dashContentList.currentIndex, 1);
        }

        function test_dash_overview_all_temp_scope_done_from_all() {
            // Show the overview
            touchFlick(dash, dash.width / 2, dash.height - 1, dash.width / 2, dash.height - units.gu(18));
            var overviewController = findInvisibleChild(dash, "overviewController");
            tryCompare(overviewController, "progress", 1);

            // Make sure tab is where it should
            var scopesOverview = findChild(dash, "scopesOverview");
            compare(scopesOverview.currentTab, 0);

            // Make sure stuff is loaded
            var scopesOverviewFavoritesRepeater = findChild(dash, "scopesOverviewFavoritesRepeater");
            tryCompare(scopesOverviewFavoritesRepeater, "count", 6);
            tryCompareFunction(function() { return scopesOverviewFavoritesRepeater.itemAt(0).item != null; }, true);
            waitForRendering(scopesOverviewFavoritesRepeater.itemAt(1).item);

            // Click on the all tab
            var scopesOverviewAllTabButton = findChild(dash, "scopesOverviewAllTabButton");
            mouseClick(scopesOverviewAllTabButton, 0, 0);

            // Wait for all tab to be enabled (animation finish)
            var scopesOverviewAllView = findChild(dash, "scopesOverviewRepeaterChild1");
            tryCompare(scopesOverviewAllView, "enabled", true);

            // Click in the middle of the black bar (nothing happens)
            var bottomBar = findChild(scopesOverview, "bottomBar");
            mouseClick(bottomBar, bottomBar.width / 2, bottomBar.height / 2);
            // Check temp scope is not there
            var scopesOverviewTempScopeItem = findChild(dash, "scopesOverviewTempScopeItem");
            expectFailContinue("", "Clicking in the middle of bottom bar should not open a temp scope");
            tryCompareFunction( function() { return scopesOverviewTempScopeItem.scope != null; }, true);

            // Click on a temp scope
            var tempScopeCard = findChild(scopesOverviewAllView, "delegate1");
            mouseClick(tempScopeCard, 0, 0);

            // Check the bottom edge (overview) is disabled from temp scope
            var overviewDragHandle = findChild(dash, "overviewDragHandle");
            compare(overviewDragHandle.enabled, false);

            // Check temp scope is there
            tryCompareFunction( function() { return scopesOverviewTempScopeItem.scope != null; }, true);
            tryCompare(scopesOverviewTempScopeItem, "enabled", true);

            // Go back
            var scopesOverviewTempScopeItemHeader = findChild(scopesOverviewTempScopeItem, "scopePageHeader");
            var backButton = findChild(findChild(scopesOverviewTempScopeItemHeader, "innerPageHeader"), "backButton");
            mouseClick(backButton, 0, 0);

            // Check temp scope is gone
            var scopesOverviewTempScopeItem = findChild(dash, "scopesOverviewTempScopeItem");
            tryCompareFunction( function() { return scopesOverviewTempScopeItem.scope == null; }, true);
            tryCompare(scopesOverviewTempScopeItem, "enabled", false);

            // Press on done
            var scopesOverviewDoneButton = findChild(scopesOverview, "scopesOverviewDoneButton");
            mouseClick(scopesOverviewDoneButton, 0, 0);

            // Check the dash overview is gone
            tryCompare(overviewController, "progress", 0);

            // Original list is still on 0
            var dashContentList = findChild(dash, "dashContentList");
            compare(dashContentList.currentIndex, 0);
        }

        function test_temp_scope_dash_overview_all_search_temp_scope_favorite_from_all() {
            // Swipe right to Apps scope
            var dashContentList = findChild(dash, "dashContentList");
            touchFlick(dash, dash.width - 1, units.gu(1), dash.width - units.gu(10), units.gu(1));
            tryCompare(dashContentList, "contentX", dashContentList.width);
            tryCompare(dashContentList, "currentIndex", 1);

            // Click on card that opens temp scope
            var categoryListView = findChild(dashContentList.currentItem, "categoryListView");
            var dashCategory2 = findChild(categoryListView, "dashCategory2");
            tryCompareFunction(function() {
                    if (dashCategory2.y < 200) return true;
                    categoryListView.contentY += 100;
                    return false;
                }, true);
            var card2 = findChild(dashCategory2, "delegate2");
            waitForRendering(card2);
            mouseClick(card2, card2.width / 2, card2.height / 2);

            // Wait for temp scope to be there
            var dashTempScopeItem = findChild(dash, "dashTempScopeItem");
            tryCompare(dashTempScopeItem, "x", 0);

            // Show the overview
            touchFlick(dash, dash.width / 2, dash.height - 1, dash.width / 2, dash.height - units.gu(18));
            var overviewController = findInvisibleChild(dash, "overviewController");
            tryCompare(overviewController, "progress", 1);

            // Make sure tab is where it should
            var scopesOverview = findChild(dash, "scopesOverview");
            compare(scopesOverview.currentTab, 1);

            // Do a search
            var scopesOverviewPageHeader = findChild(scopesOverview, "scopesOverviewPageHeader");
            var searchButton = findChild(scopesOverviewPageHeader, "search_header_button");
            mouseClick(searchButton, 0, 0);

            // Type something
            keyClick(Qt.Key_H);

            // Check results grid is there and the other lists are not
            var searchResultsViewer = findChild(scopesOverview, "searchResultsViewer");
            var scopesOverviewRepeater = findChild(dash, "scopesOverviewRepeater");
            tryCompare(searchResultsViewer, "opacity", 1);
            tryCompare(scopesOverviewRepeater, "count", 0);

            // Click on a temp scope in the search
            tryCompareFunction( function() {
                return findChild(findChild(searchResultsViewer, "dashCategorysearchA"), "delegate2") != null;
            }, true);
            var cardTempScope = findChild(findChild(searchResultsViewer, "dashCategorysearchA"), "delegate2");
            verify(cardTempScope, "Could not find delegate2");

            waitForRendering(cardTempScope);
            mouseClick(cardTempScope, cardTempScope.width / 2, cardTempScope.height / 2);

            // Check the bottom edge (overview) is disabled from temp scope
            var overviewDragHandle = findChild(dash, "overviewDragHandle");
            compare(overviewDragHandle.enabled, false);

            // Check temp scope is there
            var scopesOverviewTempScopeItem = findChild(dash, "scopesOverviewTempScopeItem");
            tryCompareFunction( function() { return scopesOverviewTempScopeItem.scope != null; }, true);
            tryCompare(scopesOverviewTempScopeItem, "enabled", true);

            // Go back
            var scopesOverviewTempScopeItemHeader = findChild(scopesOverviewTempScopeItem, "scopePageHeader");
            var backButton = findChild(findChild(scopesOverviewTempScopeItemHeader, "innerPageHeader"), "backButton");
            mouseClick(backButton, 0, 0);

            // Check temp scope is gone
            var scopesOverviewTempScopeItem = findChild(dash, "scopesOverviewTempScopeItem");
            tryCompareFunction( function() { return scopesOverviewTempScopeItem.scope == null; }, true);
            tryCompare(scopesOverviewTempScopeItem, "enabled", false);

            // Press on a favorite
            var dashCategorysearchB = findChild(searchResultsViewer, "dashCategorysearchB");
            var cardFavSearch = findChild(dashCategorysearchB, "delegate3");
            mouseClick(cardFavSearch, 0, 0);

            // Check the dash overview is gone
            tryCompare(overviewController, "progress", 0);

            // Original list went to the favorite
            compare(dashContentList.currentIndex, 0);
        }

        function test_setCurrentScope() {
            var dashContentList = findChild(dash, "dashContentList");
            var startX = dash.width - units.gu(1);
            var startY = dash.height / 2;
            var stopX = units.gu(1)
            var stopY = startY;
            waitForRendering(dashContentList)
            mouseFlick(dash, startX, startY, stopX, stopY);
            mouseFlick(dash, startX, startY, stopX, stopY);
            compare(dashContentList.currentIndex, 2, "Could not flick to scope id 2");
            var dashCommunicatorService = findInvisibleChild(dash, "dashCommunicatorService");
            dashCommunicatorService.mockSetCurrentScope(0, true, false);
            tryCompare(dashContentList, "currentIndex", 0)
            dashCommunicatorService.mockSetCurrentScope(1, true, false);
            tryCompare(dashContentList, "currentIndex", 1)
        }

        function test_processing_indicator() {
            var processingIndicator = findChild(dash, "processingIndicator");
            verify(processingIndicator, "Can't find the processing indicator.");

            verify(!processingIndicator.visible, "Processing indicator should be visible.");

            tryCompareFunction(function() {
                return scopes.getScope(dashContent.currentIndex) != null;
            }, true);
            var currentScope = scopes.getScope(dashContent.currentIndex);
            verify(currentScope, "Can't find the current scope.");

            currentScope.setSearchInProgress(true);
            tryCompare(processingIndicator, "visible", true);

            currentScope.setSearchInProgress(false);
            tryCompare(processingIndicator, "visible", false);
        }
    }
}
