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
import Unity 0.1
import ".."
import "../../../qml/Dash"
import "../../../qml/Components"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: shell
    width: units.gu(120)
    height: units.gu(80)

    Scopes {
        id: scopes

        onLoadedChanged: {
            genericScopeView.scope = scopes.get(2)
        }
    }

    property Item applicationManager: Item {
        signal sideStageFocusedApplicationChanged()
        signal mainStageFocusedApplicationChanged()
    }

    DashContentOpenEffect {
        id: openEffect
        previewListView: previewListView
        sourceItem: genericScopeView
    }

    PageHeaderLabel {
        id: pageHeader
        searchHistory: SearchHistoryModel {}
    }

    GenericScopeView {
        id: genericScopeView
        anchors.fill: parent
        previewListView: previewListView
        openEffect: openEffect
        pageHeader: pageHeader
        tabBarHeight: pageHeader.implicitHeight

        UT.UnityTestCase {
            name: "GenericScopeView"
            when: scopes.loaded

            function init() {
                shell.width = units.gu(120)
                genericScopeView.categoryView.positionAtBeginning();
                tryCompare(genericScopeView.categoryView.contentY, 0)
            }

            function test_isCurrent() {
                genericScopeView.isCurrent = true
                pageHeader.searchQuery = "test"
                previewListView.open = true
                genericScopeView.isCurrent = false
                tryCompare(pageHeader, "searchQuery", "")
                tryCompare(previewListView, "open", false);
            }

            function test_isActive() {
                tryCompare(genericScopeView.scope, "isActive", false)
                genericScopeView.isCurrent = true
                tryCompare(genericScopeView.scope, "isActive", true)
                previewListView.open = true
                tryCompare(genericScopeView.scope, "isActive", false)
                previewListView.open = false
                tryCompare(genericScopeView.scope, "isActive", true)
                genericScopeView.isCurrent = false
                tryCompare(genericScopeView.scope, "isActive", false)
            }

            function test_showDash() {
                previewListView.open = true;
                tryCompare(openEffect, "live", true);
                scopes.get(2).showDash();
                tryCompare(previewListView, "open", false);
                tryCompare(openEffect, "live", true);
            }

            function test_hideDash() {
                previewListView.open = true;
                scopes.get(2).hideDash();
                tryCompare(previewListView, "open", false);
                tryCompare(openEffect, "gap", 0);
            }

            function openPreview(filterGridName, willOpen) {
                if (filterGridName === undefined)
                    filterGridName = "0";
                if (willOpen === undefined)
                    willOpen = true;
                tryCompareFunction(function() {
                                        var filterGrid = findChild(genericScopeView, filterGridName);
                                        if (filterGrid != null) {
                                            var tile = findChild(filterGrid, "delegate0");
                                            return tile != null;
                                        }
                                        return false;
                                   },
                                   true);
                var tile = findChild(findChild(genericScopeView, filterGridName), "delegate0");
                mouseClick(tile, tile.width / 2, tile.height / 2);
                tryCompare(previewListView, "open", willOpen);
                tryCompare(openEffect, "gap", willOpen ? 1 : 0);
            }

            function checkArrowPosition(index) {
                tryCompareFunction(function() {
                                       var tile = findChild(findChild(genericScopeView, "0"), "delegate" + index);
                                       return tile != null;
                                   },
                                   true);
                var tile = findChild(findChild(genericScopeView, "0"), "delegate" + index);
                var tileCenter = tile.x + tile.width/2;
                var pointerArrow = findChild(previewListView, "pointerArrow");
                var pointerArrowCenter = pointerArrow.x + pointerArrow.width/2;
                compare(pointerArrowCenter, tileCenter, "Pointer did not move to tile");
            }

            function closePreview() {
                var closePreviewMouseArea = findChild(genericScopeView, "closePreviewMouseArea");
                mouseClick(closePreviewMouseArea, closePreviewMouseArea.width / 2, closePreviewMouseArea.height / 2);

                tryCompare(previewListView, "open", false);
                tryCompare(openEffect, "gap", 0);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.flick(0, units.gu(200));
                tryCompare(categoryListView, "flicking", false);
            }

            function test_previewOpenClose() {
                tryCompare(previewListView, "open", false);
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.positionAtBeginning();

                openPreview();

                // check for it opening successfully
                var currentPreviewItem = findChild(previewListView, "previewLoader0");
                tryCompareFunction(function() {
                                       var parts = currentPreviewItem.source.toString().split("/");
                                       var name = parts[parts.length - 1];
                                       return name == "DashPreviewPlaceholder.qml";
                                   },
                                   true);
                tryCompareFunction(function() {
                                       var parts = currentPreviewItem.source.toString().split("/");
                                       var name = parts[parts.length - 1];
                                       return name == "GenericPreview.qml";
                                   },
                                   true);
                tryCompare(currentPreviewItem, "progress", 1);
                tryCompare(previewListView, "open", true);

                closePreview();
                tryCompare(previewListView, "open", false);
            }

            function test_hiddenPreviewOpen() {
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.positionAtBeginning();
                waitForRendering(categoryListView);
                categoryListView.flick(0, -units.gu(60));
                tryCompare(categoryListView.flicking, false);

                var tile = findChild(findChild(genericScopeView, "0"), "delegate0");
                mouseClick(tile, tile.width / 2, tile.height - 1);
                tryCompare(openEffect, "gap", 1);

                verify(openEffect.positionPx >= pageHeader.height + categoryListView.stickyHeaderHeight);
            }

            function test_previewCycle() {
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.positionAtBeginning();

                tryCompare(previewListView, "open", false);
                tryCompare(openEffect, "gap", 0);

                openPreview();

                // wait for it to be loaded
                var currentPreviewItem = findChild(previewListView, "previewLoader0");
                tryCompareFunction(function() {
                                       var parts = currentPreviewItem.source.toString().split("/");
                                       var name = parts[parts.length - 1];
                                       return name == "GenericPreview.qml";
                                   },
                                   true);
                tryCompare(currentPreviewItem, "progress", 1);
                waitForRendering(currentPreviewItem);

                checkArrowPosition(0);

                // flick to the next previews
                tryCompare(previewListView, "count", 15);
                for (var i = 1; i < previewListView.count; ++i) {

                    mouseFlick(previewListView, previewListView.width - units.gu(1),
                                                previewListView.height / 2,
                                                units.gu(2),
                                                previewListView.height / 2);

                    // wait for it to be loaded
                    var nextPreviewItem = findChild(previewListView, "previewLoader" + i);
                    tryCompareFunction(function() {
                                           var parts = nextPreviewItem.source.toString().split("/");
                                           var name = parts[parts.length - 1];
                                           return name == "GenericPreview.qml";
                                       },
                                       true);
                    tryCompare(nextPreviewItem, "progress", 1);
                    waitForRendering(nextPreviewItem);
                    tryCompareFunction(function() {return nextPreviewItem.item !== null}, true);

                    checkArrowPosition(i);

                    // Make sure only the new one has isCurrent set to true
                    compare(nextPreviewItem.item.isCurrent, true);

                    if (currentPreviewItem.item !== undefined && currentPreviewItem.item !== null) {
                        compare(currentPreviewItem.item.isCurrent, false);
                    }

                    currentPreviewItem = nextPreviewItem;
                }
                closePreview();
            }

            function test_show_spinner() {
                var categoryListView = findChild(genericScopeView, "categoryListView");
                waitForRendering(categoryListView);
                categoryListView.contentY = units.gu(13);
                openPreview();
                var previewLoader = findChild(previewListView, "previewLoader0");
                compare(previewLoader.source.toString().split("/").pop(), "DashPreviewPlaceholder.qml");
                compare(categoryListView.contentY, 0)
                tryCompare(previewLoader, "progress", 1.0);
                tryCompareFunction(function() { return previewLoader.item != undefined; }, true);

                previewLoader.item.showProcessingAction = true;
                var waitingForAction = findChild(previewListView, "waitingForActionMouseArea");
                tryCompare(waitingForAction, "enabled", true);
                previewLoader.closePreviewSpinner();
                tryCompare(waitingForAction, "enabled", false);

                closePreview();
            }

            function test_changeScope() {
                genericScopeView.scope.searchQuery = "test"
                genericScopeView.scope = scopes.get(1)
                genericScopeView.scope = scopes.get(2)
                tryCompare(genericScopeView.scope, "searchQuery", "")
            }

            function test_filter_expand_collapse() {
                // wait for the item to be there
                tryCompareFunction(function() { return findChild(genericScopeView, "dashSectionHeader0") != null; }, true);

                var header = findChild(genericScopeView, "dashSectionHeader0")
                var category = findChild(genericScopeView, "dashCategory0")

                waitForRendering(header);
                verify(category.expandable);
                verify(category.filtered);

                var initialHeight = category.height;
                var middleHeight;
                mouseClick(header, header.width / 2, header.height / 2);
                tryCompareFunction(function() { middleHeight = category.height; return category.height > initialHeight; }, true);
                tryCompare(category, "filtered", false);
                verify(category.height > middleHeight);

                mouseClick(header, header.width / 2, header.height / 2);
                verify(category.expandable);
                tryCompare(category, "filtered", true);
            }

            function test_getRendererCarouselGridFallback() {
                var rendererId = "carousel"
                var contentType = ""
                var rendererHint = ""
                var results = new Object()

                results.count = 7
                var renderer = genericScopeView.getRenderer(rendererId, contentType, rendererHint, results)
                compare(renderer, "Generic/GenericCarousel.qml")

                results.count = 6
                renderer = genericScopeView.getRenderer(rendererId, contentType, rendererHint, results)
                compare(renderer, "Generic/GenericFilterGrid.qml")
            }

            function test_showPreviewCarousel() {
                tryCompareFunction(function() { return findChild(genericScopeView, "carouselDelegate") != null; }, true);
                var tile = findChild(genericScopeView, "carouselDelegate");
                mouseClick(tile, tile.width / 2, tile.height / 2);
                tryCompare(openEffect, "gap", 1);

                // check for it opening successfully
                var currentPreviewItem = findChild(previewListView, "previewLoader0");
                tryCompareFunction(function() {
                                       var parts = currentPreviewItem.source.toString().split("/");
                                       var name = parts[parts.length - 1];
                                       return name == "DashPreviewPlaceholder.qml";
                                   },
                                   true);
                tryCompareFunction(function() {
                                       var parts = currentPreviewItem.source.toString().split("/");
                                       var name = parts[parts.length - 1];
                                       return name == "GenericPreview.qml";
                                   },
                                   true);
                tryCompare(currentPreviewItem, "progress", 1);
                tryCompare(previewListView, "open", true);

                closePreview();
                tryCompare(previewListView, "open", false);
            }

            function test_filter_expand_expand_collapse() {
                // wait for the item to be there
                tryCompareFunction(function() { return findChild(genericScopeView, "dashSectionHeaderapplications.scope") != null; }, true);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.contentY = categoryListView.height;

                var header2 = findChild(genericScopeView, "dashSectionHeaderapplications.scope")
                var category2 = findChild(genericScopeView, "dashCategoryapplications.scope")
                var category2FilterGrid = category2.children[0].children[0].children[0];
                verify(UT.Util.isInstanceOf(category2FilterGrid, "FilterGrid"));

                waitForRendering(header2);
                verify(category2.expandable);
                verify(category2.filtered);

                mouseClick(header2, header2.width / 2, header2.height / 2);
                tryCompare(category2, "filtered", false);
                tryCompare(category2FilterGrid, "filter", false);

                categoryListView.positionAtBeginning();

                // wait for the header0 to be on its position
                tryCompareFunction(
                    function() {
                        var header0 = findChild(genericScopeView, "dashSectionHeader0")
                        return header0.y == pageHeader.height;
                    },
                    true);

                var header0 = findChild(genericScopeView, "dashSectionHeader0")
                var category0 = findChild(genericScopeView, "dashCategory0")
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category0, "filtered", false);
                tryCompare(category2, "filtered", true);
                tryCompare(category2FilterGrid, "filter", true);
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category0, "filtered", true);
                tryCompare(category2, "filtered", true);
            }

            function test_bug1271676_no_move_y_no_preview() {
                waitForRendering(genericScopeView);
                var categoryListView = findChild(genericScopeView, "categoryListView");
                waitForRendering(categoryListView);
                tryCompareFunction(function() { return findChild(genericScopeView, "dashCategoryapplications.scope") != null; }, true);
                var category = findChild(genericScopeView, "dashCategoryapplications.scope")
                categoryListView.contentY = category.y;
                waitForRendering(categoryListView);
                var contentYBefore = categoryListView.contentY
                openPreview("applications.scope", false); // This actually doesn't open anything because we
                                                          // have code so that the item of installed
                                                          // does activate instead of preview and never shows a preview
                compare(categoryListView.contentY, contentYBefore);
            }

            function test_narrow_delegate_ranges_expand() {
                tryCompareFunction(function() { return findChild(genericScopeView, "dashCategory0") != undefined; }, true);
                var category = findChild(genericScopeView, "dashCategory0")
                tryCompare(category, "filtered", true);

                shell.width = units.gu(20)
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.contentY = units.gu(20);
                var header0 = findChild(genericScopeView, "dashSectionHeader0")
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category, "filtered", false);
                tryCompare(category.item, "delegateCreationEnd", category.item.delegateCreationBegin + genericScopeView.height);
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category, "filtered", true);
            }
        }
    }

    PreviewListView {
        id: previewListView
        anchors.fill: parent
        openEffect: openEffect
        categoryView: genericScopeView.categoryView
        scope: genericScopeView.scope
    }
}
