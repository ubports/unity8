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
import Unity 0.2
import ".."
import "../../../qml/Dash"
import "../../../qml/Components"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: shell
    width: units.gu(120)
    height: units.gu(100)

    // TODO Add a test that checks we don't preview things whose uri starts with scope://

    // BEGIN To reduce warnings
    // TODO I think it we should pass down these variables
    // as needed instead of hoping they will be globally around
    property var greeter: null
    property var panel: null
    // BEGIN To reduce warnings

    Scopes {
        id: scopes
    }

    SignalSpy {
        id: spy
    }

    property Item applicationManager: Item {
        signal sideStageFocusedApplicationChanged()
        signal mainStageFocusedApplicationChanged()
    }

    GenericScopeView {
        id: genericScopeView
        anchors.fill: parent

        UT.UnityTestCase {
            id: testCase
            name: "GenericScopeView"
            when: scopes.loaded && windowShown

            property Item previewListView: findChild(genericScopeView, "previewListView")
            property Item header: findChild(genericScopeView, "scopePageHeader")

            function init() {
                genericScopeView.scope = scopes.getScope(2);
                shell.width = units.gu(120);
                genericScopeView.categoryView.positionAtBeginning();
                waitForRendering(genericScopeView.categoryView);
            }

            function cleanup() {
                genericScopeView.scope = null;
                spy.clear();
                spy.target = null;
                spy.signalName = "";
            }

            function test_isActive() {
                tryCompare(genericScopeView.scope, "isActive", false)
                genericScopeView.isCurrent = true
                tryCompare(genericScopeView.scope, "isActive", true)
                testCase.previewListView.open = true
                tryCompare(genericScopeView.scope, "isActive", false)
                testCase.previewListView.open = false
                tryCompare(genericScopeView.scope, "isActive", true)
                genericScopeView.isCurrent = false
                tryCompare(genericScopeView.scope, "isActive", false)
            }

            function test_showDash() {
                testCase.previewListView.open = true;
                genericScopeView.scope.showDash();
                tryCompare(testCase.previewListView, "open", false);
            }

            function test_hideDash() {
                testCase.previewListView.open = true;
                genericScopeView.scope.hideDash();
                tryCompare(testCase.previewListView, "open", false);
            }

            function test_searchQuery() {
                genericScopeView.scope = scopes.getScope(0);
                genericScopeView.scope.searchQuery = "test";
                genericScopeView.scope = scopes.getScope(1);
                genericScopeView.scope.searchQuery = "test2";
                genericScopeView.scope = scopes.getScope(0);
                tryCompare(genericScopeView.scope, "searchQuery", "test");
                genericScopeView.scope = scopes.getScope(1);
                tryCompare(genericScopeView.scope, "searchQuery", "test2");
            }

            function test_changeScope() {
                genericScopeView.scope.searchQuery = "test"
                var originalScopeId = genericScopeView.scope.id;
                genericScopeView.scope = scopes.getScope(originalScopeId + 1)
                genericScopeView.scope = scopes.getScope(originalScopeId)
                tryCompare(genericScopeView.scope, "searchQuery", "test")
            }

            function test_expand_collapse() {
                tryCompareFunction(function() { return findChild(genericScopeView, "dashSectionHeader0") != null; }, true);

                var category = findChild(genericScopeView, "dashCategory0")
                var seeAll = findChild(category, "seeAll")

                waitForRendering(seeAll);
                verify(category.expandable);
                verify(!category.expanded);

                var initialHeight = category.height;
                mouseClick(seeAll, seeAll.width / 2, seeAll.height / 2);
                verify(category.expanded);
                tryCompare(category, "height", category.item.expandedHeight + seeAll.height);

                waitForRendering(seeAll);
                mouseClick(seeAll, seeAll.width / 2, seeAll.height / 2);
                verify(!category.expanded);
            }

            function test_expand_expand_collapse() {
                // wait for the item to be there
                tryCompareFunction(function() { return findChild(genericScopeView, "dashSectionHeader2") != null; }, true);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.contentY = categoryListView.height;

                var category2 = findChild(genericScopeView, "dashCategory2")
                var seeAll2 = findChild(category2, "seeAll")

                waitForRendering(seeAll2);
                verify(category2.expandable);
                verify(!category2.expanded);

                mouseClick(seeAll2, seeAll2.width / 2, seeAll2.height / 2);
                tryCompare(category2, "expanded", true);

                categoryListView.positionAtBeginning();

                var category0 = findChild(genericScopeView, "dashCategory0")
                var seeAll0 = findChild(category0, "seeAll")
                mouseClick(seeAll0, seeAll0.width / 2, seeAll0.height / 2);
                tryCompare(category0, "expanded", true);
                tryCompare(category2, "expanded", false);
                mouseClick(seeAll0, seeAll0.width / 2, seeAll0.height / 2);
                tryCompare(category0, "expanded", false);
                tryCompare(category2, "expanded", false);
            }

            function test_headerLink() {
                tryCompareFunction(function() { return findChild(genericScopeView, "dashSectionHeader1") != null; }, true);
                var header = findChild(genericScopeView, "dashSectionHeader1");

                spy.target = genericScopeView.scope;
                spy.signalName = "performQuery";

                mouseClick(header, header.width / 2, header.height / 2);

                spy.wait();
                compare(spy.signalArguments[0][0], genericScopeView.scope.categories.data(1, Categories.RoleHeaderLink));
            }

            function test_headerLink_disable_expansion() {
                var categoryListView = findChild(genericScopeView, "categoryListView");
                waitForRendering(categoryListView);

                categoryListView.contentY = categoryListView.height * 2;

                // wait for the item to be there
                tryCompareFunction(function() { return findChild(genericScopeView, "dashSectionHeader4") != null; }, true);

                var categoryView = findChild(genericScopeView, "dashCategory4");
                verify(categoryView, "Can't find the category view.");

                var seeAll = findChild(categoryView, "seeAll");
                verify(seeAll, "Can't find the seeAll element");

                compare(seeAll.height, 0, "SeeAll should be 0-height.");

                openPreview(4, 0);

                compare(testCase.previewListView.count, 12, "There should only be 12 items in preview.");

                closePreview();
            }

            function test_narrow_delegate_ranges_expand() {
                tryCompareFunction(function() { return findChild(genericScopeView, "dashCategory0") !== null; }, true);
                var category = findChild(genericScopeView, "dashCategory0")
                tryCompare(category, "expanded", false);

                shell.width = units.gu(20)
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.contentY = units.gu(20);
                var seeAll = findChild(category, "seeAll")
                mouseClick(seeAll, seeAll.width / 2, seeAll.height / 2);
                tryCompare(category, "expanded", true);
                tryCompareFunction(function() { return category.item.height == genericScopeView.height - category.item.displayMarginBeginning - category.item.displayMarginEnd; }, true);
                mouseClick(seeAll, seeAll.width / 2, seeAll.height / 2);
                tryCompare(category, "expanded", false);
            }

            function test_forced_category_expansion() {
                tryCompareFunction(function() {
                    mouseFlick(genericScopeView, genericScopeView.width/2, genericScopeView.height,
                               genericScopeView.width/2, genericScopeView.y)
                    return findChild(genericScopeView, "dashCategory19") !== null;
                }, true);
                var category = findChild(genericScopeView, "dashCategory19")
                compare(category.expandable, false, "Category with collapsed-rows: 0 should not be expandable");

                var grid = findChild(category, "19");
                verify(grid, "Could not find the category renderer.");

                compare(grid.height, grid.expandedHeight, "Category with collapsed-rows: 0 should always be expanded.");
            }

            function test_single_category_expansion() {
                genericScopeView.scope = scopes.getScope(3);

                tryCompareFunction(function() { return findChild(genericScopeView, "dashCategory0") != undefined; }, true);
                var category = findChild(genericScopeView, "dashCategory0")
                compare(category.expandable, false, "Only category should not be expandable.");

                var grid = findChild(category, "0");
                verify(grid, "Could not find the category renderer.");

                compare(grid.height, grid.expandedHeight, "Only category should always be expanded");
            }

            function openPreview(category, delegate) {
                if (category === undefined) category = 0;
                if (delegate === undefined) delegate = 0;
                tryCompareFunction(function() {
                                        var cardGrid = findChild(genericScopeView, category);
                                        if (cardGrid != null) {
                                            var tile = findChild(cardGrid, "delegate"+delegate);
                                            return tile != null;
                                        }
                                        return false;
                                    },
                                    true);
                var tile = findChild(findChild(genericScopeView, category), "delegate"+delegate);
                mouseClick(tile, tile.width / 2, tile.height / 2);
                tryCompare(testCase.previewListView, "open", true);
                tryCompare(testCase.previewListView, "x", 0);
            }

            function closePreview() {
                var closePreviewMouseArea = findChild(genericScopeView, "innerPageHeader");
                mouseClick(closePreviewMouseArea, units.gu(2), units.gu(2));

                tryCompare(testCase.previewListView, "open", false);
            }

            function test_previewOpenClose() {
                tryCompare(testCase.previewListView, "open", false);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.positionAtBeginning();

                openPreview();
                closePreview();
            }

            function test_showPreviewCarousel() {
                tryCompareFunction(function() {
                                        var dashCategory1 = findChild(genericScopeView, "dashCategory1");
                                        if (dashCategory1 != null) {
                                            var tile = findChild(dashCategory1, "carouselDelegate1");
                                            return tile != null;
                                        }
                                        return false;
                                    },
                                    true);

                tryCompare(testCase.previewListView, "open", false);

                var dashCategory1 = findChild(genericScopeView, "dashCategory1");
                var tile = findChild(dashCategory1, "carouselDelegate1");
                mouseClick(tile, tile.width / 2, tile.height / 2);
                tryCompare(tile, "explicitlyScaled", true);
                mouseClick(tile, tile.width / 2, tile.height / 2);
                tryCompare(testCase.previewListView, "open", true);
                tryCompare(testCase.previewListView, "x", 0);

                closePreview();
            }

            function test_previewCycle() {
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.positionAtBeginning();

                tryCompare(testCase.previewListView, "open", false);
                var previewListViewList = findChild(previewListView, "listView");

                openPreview();

                // flick to the next previews
                tryCompare(testCase.previewListView, "count", 15);
                for (var i = 1; i < testCase.previewListView.count; ++i) {
                    mouseFlick(testCase.previewListView, testCase.previewListView.width - units.gu(1),
                                                testCase.previewListView.height / 2,
                                                units.gu(2),
                                                testCase.previewListView.height / 2);
                    tryCompare(previewListViewList, "moving", false);
                    tryCompare(testCase.previewListView.currentItem, "objectName", "preview" + i);

                }
                closePreview();
            }

            function test_header_style_data() {
                return [
                    { tag: "Default", index: 0, foreground: Theme.palette.normal.baseText, background: "color:///#f5f5f5", logo: "" },
                    { tag: "Foreground", index: 1, foreground: "yellow", background: "color:///#f5f5f5", logo: "" },
                    { tag: "Logo+Background", index: 2, foreground: Theme.palette.normal.baseText, background: "gradient:///lightgrey/grey",
                      logo: Qt.resolvedUrl("../Dash/tst_PageHeader/logo-ubuntu-orange.svg") },
                ];
            }

            function test_header_style(data) {
                genericScopeView.scope = scopes.getScope(data.index);
                waitForRendering(genericScopeView);
                verify(header, "Could not find the header.");

                var innerHeader = findChild(header, "innerPageHeader");
                verify(innerHeader, "Could not find the inner header");
                verify(Qt.colorEqual(innerHeader.textColor, data.foreground),
                       "Foreground color not equal: %1 != %2".arg(innerHeader.textColor).arg(data.foreground));

                var background = findChild(header, "headerBackground");
                verify(background, "Could not find the background");
                compare(background.style, data.background);

                var image = findChild(genericScopeView, "titleImage");
                if (data.logo == "") expectFail(data.tag, "Title image should not exist.");
                verify(image, "Could not find the title image.");
                compare(image.source, data.logo, "Title image has the wrong source");
            }
        }
    }
}
