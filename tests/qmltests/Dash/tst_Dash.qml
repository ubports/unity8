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

        function test_manage_dash_select_same_favorite() {
            // Show the manage dash
            touchFlick(dash, dash.width / 2, dash.height - 1, dash.width / 2, units.gu(2));
            var bottomEdgeController = findInvisibleChild(dash, "bottomEdgeController");
            tryCompare(bottomEdgeController, "progress", 1);

            // Make sure stuff is loaded
            var favScopesListCategory = findChild(dash, "scopesListCategoryfavorites");
            var favScopesListCategoryList = findChild(favScopesListCategory, "scopesListCategoryInnerList");
            tryCompare(favScopesListCategoryList, "currentIndex", 0);

            // Click in first item
            mouseClick(favScopesListCategoryList.currentItem, 0, 0);

            // Make sure animation went back
            tryCompare(bottomEdgeController, "progress", 0);

            var dashContentList = findChild(dash, "dashContentList");
            compare(dashContentList.currentIndex, 0);
        }

        function test_manage_dash_select_different_favorite() {
            // Show the manage dash
            touchFlick(dash, dash.width / 2, dash.height - 1, dash.width / 2, units.gu(2));
            var bottomEdgeController = findInvisibleChild(dash, "bottomEdgeController");
            tryCompare(bottomEdgeController, "progress", 1);

            // Make sure stuff is loaded
            var favScopesListCategory = findChild(dash, "scopesListCategoryfavorites");
            var favScopesListCategoryList = findChild(favScopesListCategory, "scopesListCategoryInnerList");
            tryCompare(favScopesListCategoryList, "currentIndex", 0);

            // Click in second item
            favScopesListCategoryList.currentIndex = 1;
            mouseClick(favScopesListCategoryList.currentItem, 0, 0);

            // Make sure animation went back
            tryCompare(bottomEdgeController, "progress", 0);
            var dashContentList = findChild(dash, "dashContentList");
            compare(dashContentList.currentIndex, 1);
        }

        function test_manage_dash_select_non_favorite() {
            // Show the manage dash
            touchFlick(dash, dash.width / 2, dash.height - 1, dash.width / 2, units.gu(2));
            var bottomEdgeController = findInvisibleChild(dash, "bottomEdgeController");
            tryCompare(bottomEdgeController, "progress", 1);

            // Make sure stuff is loaded
            var nonfavScopesListCategory = findChild(dash, "scopesListCategoryother");
            var nonfavScopesListCategoryList = findChild(nonfavScopesListCategory, "scopesListCategoryInnerList");
            tryCompare(nonfavScopesListCategoryList, "currentIndex", 0);

            // Click on a non favorite scope
            mouseClick(nonfavScopesListCategoryList.currentItem, 0, 0);

            // Check the bottom edge (manage dash) is disabled from temp scope
            var overviewDragHandle = findChild(dash, "overviewDragHandle");
            compare(overviewDragHandle.enabled, false);

            // Check temp scope is there
            var dashTempScopeItem = findChild(dash, "dashTempScopeItem");
            tryCompare(dashTempScopeItem, "x", 0);
            tryCompare(dashTempScopeItem, "visible", true);

            // Check the manage dash is gone
            tryCompare(bottomEdgeController, "progress", 0);

            // Go back
            var dashTempScopeItemHeader = findChild(dashTempScopeItem, "scopePageHeader");
            var backButton = findChild(findChild(dashTempScopeItemHeader, "innerPageHeader"), "backButton");
            mouseClick(backButton, 0, 0);

            // Check temp scope is gone
            tryCompare(dashTempScopeItem, "x", dash.width);
            tryCompare(dashTempScopeItem, "visible", false);

            // Original list is still on 0
            var dashContentList = findChild(dash, "dashContentList");
            compare(dashContentList.currentIndex, 0);
        }

        function test_manage_dash_search_temp_scope() {
            // Show the manage dash
            touchFlick(dash, dash.width / 2, dash.height - 1, dash.width / 2, units.gu(2));
            var bottomEdgeController = findInvisibleChild(dash, "bottomEdgeController");
            tryCompare(bottomEdgeController, "progress", 1);

            // Do a search
            var scopesList = findChild(dash, "scopesList");
            var scopesListPageHeader = findChild(scopesList, "pageHeader");
            var searchButton = findChild(scopesListPageHeader, "search_header_button");
            mouseClick(searchButton, 0, 0);

            // Type something
            keyClick(Qt.Key_H);

            // Click on a temp scope in the search
            tryCompareFunction( function() { return findChild(scopesList, "scopesListCategorysearchA") != null; }, true);
            var dashCategorysearchA = findChild(scopesList, "scopesListCategorysearchA");
            tryCompareFunction( function() { return findChild(dashCategorysearchA, "delegate2") != null; }, true);
            var cardTempScope = findChild(dashCategorysearchA, "delegate2");

            waitForRendering(cardTempScope);
            mouseClick(cardTempScope, cardTempScope.width / 2, cardTempScope.height / 2);

            // Check the bottom edge (overview) is disabled from temp scope
            var overviewDragHandle = findChild(dash, "overviewDragHandle");
            compare(overviewDragHandle.enabled, false);

            // Check temp scope is there
            var dashTempScopeItem = findChild(dash, "dashTempScopeItem");
            tryCompare(dashTempScopeItem, "x", 0);
            tryCompare(dashTempScopeItem, "visible", true);

            // Check the manage dash is gone
            tryCompare(bottomEdgeController, "progress", 0);

            // Go back
            var dashTempScopeItemHeader = findChild(dashTempScopeItem, "scopePageHeader");
            var backButton = findChild(findChild(dashTempScopeItemHeader, "innerPageHeader"), "backButton");
            mouseClick(backButton, 0, 0);

            // Check temp scope is gone
            tryCompare(dashTempScopeItem, "x", dash.width);
            tryCompare(dashTempScopeItem, "visible", false);

            // Original list is still on 0
            var dashContentList = findChild(dash, "dashContentList");
            compare(dashContentList.currentIndex, 0);
        }

        function test_manage_dash_open_no_favorites() {
            // Make it so there are no favorites
            scopes.clear();
            var dashContentList = findChild(dash, "dashContentList");
            tryCompare(dashContentList, "count", 0);

            // Show the manage dash
            touchFlick(dash, dash.width / 2, dash.height - 1, dash.width / 2, units.gu(2));
            var bottomEdgeController = findInvisibleChild(dash, "bottomEdgeController");
            tryCompare(bottomEdgeController, "progress", 1);

            // Go back
            var scopesList = findChild(dash, "scopesList");
            var scopesListPageHeader = findChild(scopesList, "pageHeader");
            var backButton = findChild(findChild(scopesListPageHeader, "innerPageHeader"), "backButton");
            mouseClick(backButton, 0, 0);
            tryCompare(bottomEdgeController, "progress", 0);
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

        function test_setCurrentScopeClosesPreview() {
            var dashContent = findChild(dash, "dashContent");
            waitForRendering(dash)

            var delegate0 = findChild(dash, "delegate0");
            mouseClick(delegate0, delegate0.width / 2, delegate0.height / 2);

            tryCompare(dashContent, "subPageShown", true)
            waitForRendering(dash);

            var dashCommunicatorService = findInvisibleChild(dash, "dashCommunicatorService");
            dashCommunicatorService.mockSetCurrentScope(0, true, false);

            tryCompare(dashContent, "subPageShown", false)
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
