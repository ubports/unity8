/*
 * Copyright 2014 Canonical Ltd.
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
import Unity 0.2
import ".."
import "../../../qml/Dash"
import "../../../qml/Components"
import Ubuntu.Components 1.3
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
        // for tryGenericScopeView
        onLoadedChanged: if (loaded) genericScopeView.scope = scopes.getScope(2);
    }

    MockScope {
        id: mockScope
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
        visibleToParent: true

        UT.UnityTestCase {
            id: testCase
            name: "GenericScopeView"
            when: scopes.loaded && windowShown

            property Item subPageLoader: findChild(genericScopeView, "subPageLoader")
            property Item header: findChild(genericScopeView, "scopePageHeader")

            function init() {
                // Start from a clean scopes situation every test
                scopes.clear();
                scopes.load();
                tryCompare(scopes, "loaded", true);

                genericScopeView.scope = scopes.getScope(2);
                genericScopeView.isCurrent = true;
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

            function scrollToCategory(categoryName) {
                var categoryListView = findChild(genericScopeView, "categoryListView");
                tryCompareFunction(function() {
                    var category = findChild(genericScopeView, categoryName);
                    if (category && category.y > 0 && category.y < genericScopeView.height) return true;
                    touchFlick(genericScopeView, genericScopeView.width/2, units.gu(20),
                               genericScopeView.width/2, genericScopeView.y)
                    tryCompare(categoryListView, "moving", false);
                    return false;
                }, true);

                tryCompareFunction(function() { return findChild(genericScopeView, "delegate0") !== null; }, true);
                return findChild(genericScopeView, categoryName);
            }

            function scrollToEnd()
            {
                var categoryListView = findChild(genericScopeView, "categoryListView");
                waitForRendering(categoryListView);
                tryCompareFunction(function() {
                        mouseFlick(genericScopeView, genericScopeView.width/2, genericScopeView.height - units.gu(8),
                                   genericScopeView.width/2, genericScopeView.y)
                        tryCompare(categoryListView, "moving", false);
                        return categoryListView.atYEnd;
                    }, true);
            }

            function test_isActive() {
                genericScopeView.isCurrent = false
                tryCompare(genericScopeView.scope, "isActive", false)
                genericScopeView.isCurrent = true
                tryCompare(genericScopeView.scope, "isActive", true)
                testCase.subPageLoader.open = true
                tryCompare(genericScopeView.scope, "isActive", false)
                testCase.subPageLoader.open = false
                tryCompare(genericScopeView.scope, "isActive", true)
                genericScopeView.isCurrent = false
                tryCompare(genericScopeView.scope, "isActive", false)
            }

            function test_showDash() {
                testCase.subPageLoader.open = true;
                genericScopeView.scope.showDash();
                tryCompare(testCase.subPageLoader, "open", false);
            }

            function test_hideDash() {
                testCase.subPageLoader.open = true;
                genericScopeView.scope.hideDash();
                tryCompare(testCase.subPageLoader, "open", false);
            }

            function test_searchQuery() {
                genericScopeView.isCurrent = false
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
                genericScopeView.isCurrent = false;
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
                mouseClick(seeAll);
                verify(category.expanded);
                tryCompare(category, "height", category.item.expandedHeight + seeAll.height);

                waitForRendering(seeAll);
                mouseClick(seeAll);
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

                mouseClick(seeAll2);
                tryCompare(category2, "expanded", true);

                categoryListView.positionAtBeginning();

                var category0 = findChild(genericScopeView, "dashCategory0")
                var seeAll0 = findChild(category0, "seeAll")
                mouseClick(seeAll0);
                tryCompare(category0, "expanded", true);
                tryCompare(category2, "expanded", false);
                mouseClick(seeAll0);
                tryCompare(category0, "expanded", false);
                tryCompare(category2, "expanded", false);
            }

            function test_headerLink() {
                tryCompareFunction(function() { return findChild(genericScopeView, "dashSectionHeader1") != null; }, true);
                var header = findChild(genericScopeView, "dashSectionHeader1");

                spy.target = genericScopeView.scope;
                spy.signalName = "queryPerformed";

                mouseClick(header);

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
            }

            function test_narrow_delegate_ranges_expand() {
                tryCompareFunction(function() { return findChild(genericScopeView, "dashCategory0") !== null; }, true);
                var category = findChild(genericScopeView, "dashCategory0")
                tryCompare(category, "expanded", false);

                shell.width = units.gu(20)
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.contentY = units.gu(20);
                var seeAll = findChild(category, "seeAll");
                var floatingSeeLess = findChild(genericScopeView, "floatingSeeLess");
                mouseClick(seeAll);
                tryCompare(category, "expanded", true);
                tryCompareFunction(function() {
                    return category.item.height + floatingSeeLess.height ==
                    genericScopeView.height - category.item.displayMarginBeginning - category.item.displayMarginEnd;
                    }, true);
                mouseClick(floatingSeeLess);
                tryCompare(category, "expanded", false);
            }

            function test_forced_category_expansion() {
                var category = scrollToCategory("dashCategory19");
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
                                        var cardGrid = findChild(genericScopeView, "dashCategory"+category);
                                        if (cardGrid != null) {
                                            var tile = findChild(cardGrid, "delegate"+delegate);
                                            return tile != null;
                                        }
                                        return false;
                                    },
                                    true);
                var tile = findChild(findChild(genericScopeView, "dashCategory"+category), "delegate"+delegate);
                waitForRendering(tile);
                mouseClick(tile);
                tryCompare(testCase.subPageLoader, "open", true);
                tryCompare(testCase.subPageLoader, "x", 0);
                tryCompare(findChild(genericScopeView, "categoryListView"), "visible", false);
            }

            function closePreview() {
                tryCompare(testCase.subPageLoader, "x", 0);
                var closePreviewMouseArea = findChild(subPageLoader.item, "pageHeader");
                mouseClick(closePreviewMouseArea, units.gu(2), units.gu(2));

                tryCompare(testCase.subPageLoader, "open", false);
                tryCompare(testCase.subPageLoader, "visible", false);
                var categoryListView = findChild(genericScopeView, "categoryListView");
                tryCompare(categoryListView, "visible", true);
                tryCompare(categoryListView, "x", 0);
            }

            function test_previewOpenClose() {
                tryCompare(testCase.subPageLoader, "open", false);
                tryCompare(testCase.subPageLoader, "visible", false);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.positionAtBeginning();

                openPreview();
                closePreview();
            }

            function test_tryOpenNullPreview() {
                genericScopeView.scope = scopes.getScope("NullPreviewScope");

                tryCompareFunction(function() {
                                        var cardGrid = findChild(genericScopeView, 0);
                                        if (cardGrid != null) {
                                            var tile = findChild(cardGrid, 0);
                                            return tile != null;
                                        }
                                        return false;
                                    },
                                    true);
                var tile = findChild(findChild(genericScopeView, 0), 0);

                tryCompare(testCase.subPageLoader, "open", false);
                tryCompare(testCase.subPageLoader, "visible", false);

                mouseClick(tile);

                tryCompare(testCase.subPageLoader, "open", false);
                tryCompare(testCase.subPageLoader, "visible", false);

                mousePress(tile);
                tryCompare(testCase.subPageLoader, "open", false);
                tryCompare(testCase.subPageLoader, "visible", false);
                mouseRelease(tile);
            }

            function test_showPreviewCarousel() {
                var category = scrollToCategory("dashCategory1");

                tryCompare(testCase.subPageLoader, "open", false);

                var tile = findChild(category, "carouselDelegate1");
                verify(tile, "Could not find delegate");

                mouseClick(tile);
                tryCompare(tile, "explicitlyScaled", true);
                mouseClick(tile);
                tryCompare(testCase.subPageLoader, "open", true);
                tryCompare(testCase.subPageLoader, "x", 0);

                closePreview();

                mousePress(tile);
                tryCompare(testCase.subPageLoader, "open", true);
                tryCompare(testCase.subPageLoader, "x", 0);
                mouseRelease(tile);

                closePreview();
            }

            function test_showPreviewHorizontalList() {
                var category = scrollToCategory("dashCategory18");

                tryCompare(testCase.subPageLoader, "open", false);

                tryCompareFunction(function() { return findChild(category, "delegate1") != null; }, true);
                var tile = findChild(category, "delegate1");

                mouseClick(tile);
                tryCompare(testCase.subPageLoader, "open", true);
                tryCompare(testCase.subPageLoader, "x", 0);

                closePreview();

                mousePress(tile);
                tryCompare(testCase.subPageLoader, "open", true);
                tryCompare(testCase.subPageLoader, "x", 0);
                mouseRelease(tile);

                closePreview();
            }

            function test_settingsOpenClose() {
                waitForRendering(genericScopeView);
                verify(header, "Could not find the header.");
                var innerHeader = findChild(header, "innerPageHeader");
                verify(innerHeader, "Could not find the inner header");

                // open
                tryCompare(testCase.subPageLoader, "open", false);
                tryCompare(testCase.subPageLoader, "visible", false);
                var settings = findChild(innerHeader, "settings_button");
                mouseClick(settings);
                tryCompare(testCase.subPageLoader, "open", true);
                tryCompareFunction(function() { return (String(subPageLoader.source)).indexOf("ScopeSettingsPage.qml") != -1; }, true);
                tryCompare(genericScopeView, "subPageShown", true);
                compare(testCase.subPageLoader.subPage, "settings");
                tryCompare(testCase.subPageLoader, "x", 0);

                // close
                var settingsHeader = findChild(testCase.subPageLoader.item, "pageHeader");
                mouseClick(settingsHeader, units.gu(2), units.gu(2));
                tryCompare(testCase.subPageLoader, "open", false);
                tryCompare(genericScopeView, "subPageShown", false);
                var categoryListView = findChild(genericScopeView, "categoryListView");
                tryCompare(categoryListView, "x", 0);
                tryCompare(testCase.subPageLoader, "visible", false);
                tryCompare(testCase.subPageLoader, "source", "");
            }

            function test_header_style_data() {
                return [
                    { tag: "Default", index: 0, foreground: UbuntuColors.darkGrey, background: "color:///#ffffff", logo: "" },
                    { tag: "Foreground", index: 1, foreground: "yellow", background: "color:///#ffffff", logo: "" },
                    { tag: "Logo+Background", index: 2, foreground: UbuntuColors.darkGrey, background: "gradient:///lightgrey/grey",
                      logo: Qt.resolvedUrl("../Dash/tst_PageHeader/logo-ubuntu-orange.svg") },
                ];
            }

            function test_header_style(data) {
                genericScopeView.scope = scopes.getScope(data.index);
                waitForRendering(genericScopeView);
                verify(header, "Could not find the header.");

                var innerHeader = findChild(header, "innerPageHeader");
                verify(innerHeader, "Could not find the inner header");
                verify(Qt.colorEqual(innerHeader.__styleInstance.foregroundColor, data.foreground),
                       "Foreground color not equal: %1 != %2".arg(innerHeader.__styleInstance.foregroundColor).arg(data.foreground));

                var background = findChild(header, "headerBackground");
                verify(background, "Could not find the background");
                compare(background.style, data.background);

                var image = findChild(genericScopeView, "titleImage");
                if (data.logo == "") expectFail(data.tag, "Title image should not exist.");
                verify(image, "Could not find the title image.");
                compare(image.source, data.logo, "Title image has the wrong source");
            }

            function test_seeAllTwoCategoriesScenario1() {
                mockScope.setId("mockScope");
                mockScope.setName("Mock Scope");
                mockScope.isActive = true;
                mockScope.categories.setCount(2);
                mockScope.categories.resultModel(0).setResultCount(50);
                mockScope.categories.resultModel(1).setResultCount(25);
                mockScope.categories.setLayout(0, "grid");
                mockScope.categories.setLayout(1, "grid");
                mockScope.categories.setHeaderLink(0, "");
                mockScope.categories.setHeaderLink(1, "");
                genericScopeView.scope = mockScope;
                waitForRendering(genericScopeView.categoryView);

                var category0 = findChild(genericScopeView, "dashCategory0")
                var seeAll0 = findChild(category0, "seeAll")

                waitForRendering(seeAll0);
                verify(category0.expandable);
                verify(!category0.expanded);

                mouseClick(seeAll0);
                verify(category0.expanded);
                tryCompare(category0, "height", category0.item.expandedHeight + seeAll0.height);
                tryCompare(genericScopeView.categoryView, "contentY", units.gu(8));

                scrollToEnd();

                tryCompareFunction(function() { return findChild(genericScopeView, "dashCategory1") !== null; }, true);
                var category1 = findChild(genericScopeView, "dashCategory1")
                var seeAll1 = findChild(category1, "seeAll")
                verify(category1.expandable);
                verify(!category1.expanded);

                mouseClick(seeAll1);
                verify(!category0.expanded);
                verify(category1.expanded);
                tryCompare(category1, "height", category1.item.expandedHeight + seeAll1.height);
                tryCompareFunction(function() {
                    return genericScopeView.categoryView.contentY + category1.y + category1.height
                           == genericScopeView.categoryView.contentHeight;}
                    , true);
            }

            function test_seeAllTwoCategoriesScenario2() {
                mockScope.setId("mockScope");
                mockScope.setName("Mock Scope");
                mockScope.isActive = true;
                mockScope.categories.setCount(2);
                mockScope.categories.resultModel(0).setResultCount(25);
                mockScope.categories.resultModel(1).setResultCount(50);
                mockScope.categories.setLayout(0, "grid");
                mockScope.categories.setLayout(1, "grid");
                mockScope.categories.setHeaderLink(0, "");
                mockScope.categories.setHeaderLink(1, "");
                genericScopeView.scope = mockScope;
                waitForRendering(genericScopeView.categoryView);

                var category0 = findChild(genericScopeView, "dashCategory0")
                var seeAll0 = findChild(category0, "seeAll")

                waitForRendering(seeAll0);
                verify(category0.expandable);
                verify(!category0.expanded);

                mouseClick(seeAll0);
                verify(category0.expanded);
                tryCompare(category0, "height", category0.item.expandedHeight + seeAll0.height);

                scrollToEnd();

                var category1 = findChild(genericScopeView, "dashCategory1")
                var seeAll1 = findChild(category1, "seeAll")
                verify(category1.expandable);
                verify(!category1.expanded);

                mouseClick(seeAll1);
                verify(!category0.expanded);
                verify(category1.expanded);
                tryCompare(category1, "height", category1.item.expandedHeight + seeAll1.height);
                tryCompare(category1, "y", units.gu(5));
            }

            function test_favorite_data() {
                return [
                    { tag: "People", id: "MockScope1", favorite: true },
                    { tag: "Music", id: "MockScope2", favorite: false },
                    { tag: "Apps", id: "clickscope", favorite: true },
                ];
            }

            function test_favorite(data) {
                genericScopeView.scope = scopes.getScopeFromAll(data.id);
                waitForRendering(genericScopeView);
                verify(header, "Could not find the header.");

                compare(genericScopeView.scope.favorite, data.favorite, "Unexpected initial favorite value");

                var innerHeader = findChild(header, "innerPageHeader");
                verify(innerHeader, "Could not find the inner header");

                expectFail("Apps", "Click scope should not have a favorite button");
                var favoriteAction = findChild(innerHeader, "favorite_button");
                verify(favoriteAction, "Could not find the favorite action.");
                mouseClick(favoriteAction);

                tryCompare(genericScopeView.scope, "favorite", !data.favorite);

                genericScopeView.scope = !genericScopeView.scope;
            }

            function test_pullToRefresh() {
                waitForRendering(genericScopeView)

                mouseFlick(genericScopeView,
                           genericScopeView.width/2, units.gu(10),
                           genericScopeView.width/2, units.gu(80),
                           true, false)

                var pullToRefresh = findChild(genericScopeView, "pullToRefresh")
                tryCompare(pullToRefresh, "releaseToRefresh", true)

                spy.target = genericScopeView.scope
                spy.signalName = "refreshed"

                mouseRelease(genericScopeView)
                tryCompare(pullToRefresh, "releaseToRefresh", false)

                spy.wait()
                compare(spy.count, 1)

                // test short swipe doesn't refresh on tall window
                mouseFlick(genericScopeView,
                           genericScopeView.width/2, units.gu(10),
                           genericScopeView.width/2, units.gu(20),
                           true, false)
                mouseRelease(genericScopeView)
                compare(spy.count, 1)

                // resize window, repeat the test
                var initialHeight = shell.height
                shell.height = units.gu(30)
                waitForRendering(shell)
                mouseFlick(genericScopeView,
                           genericScopeView.width/2, units.gu(10),
                           genericScopeView.width/2, units.gu(20),
                           true, false)

                tryCompare(pullToRefresh, "releaseToRefresh", true)

                mouseRelease(genericScopeView)
                tryCompare(pullToRefresh, "releaseToRefresh", false)

                spy.wait()
                compare(spy.count, 2)

                shell.height = initialHeight
                waitForRendering(shell)
            }

            function test_item_noninteractive() {
                waitForRendering(genericScopeView);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                waitForRendering(categoryListView);

                var category0 = findChild(categoryListView, "dashCategory0");
                waitForRendering(category0);

                var cardTool = findChild(category0, "cardTool");
                cardTool.template["non-interactive"] = true;
                cardTool.templateChanged();

                var category0 = findChild(categoryListView, "dashCategory0");
                waitForRendering(category0);

                tryCompareFunction(function() { return category0.item != null; }, true);
                var cardGrid = category0.item;
                compare(cardGrid.cardTool.template["non-interactive"], true);

                var item0 = findChild(cardGrid, "delegate0");
                waitForRendering(item0);
                compare(item0.enabled, false);
                var touchdown = findChild(item0, "touchdown");

                compare(touchdown.visible, false);
                mousePress(item0);
                compare(touchdown.visible, false);
                mouseRelease(item0);

                cardTool.template["non-interactive"] = false;
                cardTool.templateChanged();
                compare(cardGrid.cardTool.template["non-interactive"], false);

                waitForRendering(category0);
                item0 = findChild(cardGrid, "delegate0");
                compare(item0.enabled, true);
                var touchdown = findChild(item0, "touchdown");

                compare(touchdown.visible, false);
                mousePress(item0);
                compare(touchdown.visible, true);
                mouseRelease(item0);
                compare(touchdown.visible, false);
                closePreview();
            }

            function test_carousel_borderSource() {
                var category = scrollToCategory("dashCategory1");
                var tile = findChild(category, "carouselDelegate0");
                tryCompareFunction(function() { return findChild(tile, "artShapeLoader") !== null; }, true);
                var artShapeLoader = findChild(tile, "artShapeLoader");
                var shape = findChildsByType(artShapeLoader, "UCUbuntuShape");
                compare(shape.borderSource, undefined);
            }

            function test_clickScopeSizing() {
                genericScopeView.scope = scopes.getScopeFromAll("clickscope");
                waitForRendering(genericScopeView);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                waitForRendering(categoryListView);

                var categorypredefined = findChild(categoryListView, "dashCategorypredefined");
                waitForRendering(categorypredefined);

                var cardTool = findChild(categorypredefined, "cardTool");

                compare(cardTool.cardWidth, units.gu(11));
                shell.width = units.gu(46);
                waitForRendering(genericScopeView);
                compare(cardTool.cardWidth, units.gu(10));

                shell.width = units.gu(120)
            }
        }
    }
}
