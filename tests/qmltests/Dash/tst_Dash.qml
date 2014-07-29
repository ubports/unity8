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
        showScopeOnLoaded: "MockScope2"
    }

    UT.UnityTestCase {
        name: "Dash"
        when: windowShown

        property var scopes

        Component.onCompleted: {
            var dashContent = findChild(dash, "dashContent");
            scopes = dashContent.scopes;
        }

        function init() {
            // clear and reload the scopes.
            scopes.clear();
            var dashContentList = findChild(dash, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(dashContentList, "count", 0);
            scopes.load();
        }

        function get_scope_data() {
            return [
                        { tag: "MockScope1", visualIndex: 0, shouldBeVisible: true },
                        { tag: "MockScope2", visualIndex: -1, shouldBeVisible: false },
                        { tag: "clickscope", visualIndex: 1, shouldBeVisible: true },
                        { tag: "MockScope5", visualIndex: 2, shouldBeVisible: true },
            ]
        }

        function test_show_scope_on_load_data() {
            return get_scope_data()
        }

        function test_show_scope_on_load(data) {
            if (data.shouldBeVisible == false) {
                console.log("Not testing " + data.tag + ": not visible");
                return;
            }
            var dashContentList = findChild(dash, "dashContentList");

            dash.showScopeOnLoaded = data.tag
            scopes.clear();
            tryCompare(dashContentList, "count", 0);
            scopes.load();
            tryCompare(scopes, "loaded", true);
            tryCompare(dashContentList, "count", 6);

            verify(dashContentList != undefined);
            tryCompare(dashContentList, "currentIndex", data.visualIndex);
        }

        function test_dash_overview_show_select_same_favorite() {
            // Wait for stuff to be loaded
            tryCompare(scopes, "loaded", true);
            var dashContentList = findChild(dash, "dashContentList");
            tryCompare(dashContentList, "count", 6);
            var mockScope1Loader = findChild(dash, "MockScope1 loader");
            tryCompareFunction(function() { return mockScope1Loader.item != null; }, true);

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
            compare(dashContentList.currentIndex, 0);
        }

        function test_dash_overview_show_select_different_favorite() {
            // Wait for stuff to be loaded
            tryCompare(scopes, "loaded", true);
            var dashContentList = findChild(dash, "dashContentList");
            tryCompare(dashContentList, "count", 6);
            var mockScope1Loader = findChild(dash, "MockScope1 loader");
            tryCompareFunction(function() { return mockScope1Loader.item != null; }, true);

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
            compare(dashContentList.currentIndex, 1);
        }

        function test_dash_overview_all_temp_scope_done_from_all() {
            // Wait for stuff to be loaded
            tryCompare(scopes, "loaded", true);
            var dashContentList = findChild(dash, "dashContentList");
            tryCompare(dashContentList, "count", 6);
            var mockScope1Loader = findChild(dash, "MockScope1 loader");
            tryCompareFunction(function() { return mockScope1Loader.item != null; }, true);

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

            // Click on a temp scope
            var tempScopeCard = findChild(scopesOverviewAllView, "delegate1");
            mouseClick(tempScopeCard, 0, 0);

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

            // Press on done
            var scopesOverviewDoneButton = findChild(scopesOverview, "scopesOverviewDoneButton");
            mouseClick(scopesOverviewDoneButton, 0, 0);

            // Check the dash overview is gone
            tryCompare(overviewController, "progress", 0);

            // Original list is still on 0
            compare(dashContentList.currentIndex, 0);
        }

        function test_temp_scope_dash_overview_all_search_temp_scope_favorite_from_all() {
            // Wait for stuff to be loaded
            tryCompare(scopes, "loaded", true);
            var dashContentList = findChild(dash, "dashContentList");
            tryCompare(dashContentList, "count", 6);
            var mockScope1Loader = findChild(dash, "MockScope1 loader");
            tryCompareFunction(function() { return mockScope1Loader.item != null; }, true);

            // Swipe right to Apps scope
            touchFlick(dash, dash.width - 1, units.gu(1), dash.width - units.gu(10), units.gu(1));
            tryCompare(dashContentList, "contentX", dashContentList.width);
            tryCompare(dashContentList, "currentIndex", 1);

            // Click on card that opens temp scope
            var dashCategory2 = findChild(dashContentList.currentItem, "dashCategory2");
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
            var dashCategorysearchA = findChild(searchResultsViewer, "dashCategorysearchA");
            var cardTempScope = findChild(dashCategorysearchA, "delegate2");
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
    }
}
