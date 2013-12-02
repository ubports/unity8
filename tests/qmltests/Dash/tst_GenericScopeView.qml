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
import "../../../Dash"
import "../../../Components"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: shell
    width: units.gu(120)
    height: units.gu(80)

    Scopes {
        id: scopes

        onLoadedChanged: {
            genericScopeView.scope = scopes.get(0)
        }
    }

    property Item applicationManager: Item {
        signal sideStageFocusedApplicationChanged()
        signal mainStageFocusedApplicationChanged()
    }

    PreviewListView {
        id: previewListView
        anchors.fill: parent
        openEffect: openEffect
        categoryView: genericScopeView.categoryView
        scope: genericScopeView.scope
    }

    DashContentOpenEffect {
        id: openEffect
        previewListView: previewListView
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

             function test_isCurrent() {
                genericScopeView.isCurrent = true
                pageHeader.searchQuery = "test"
                previewListView.open = true
                genericScopeView.isCurrent = false
                tryCompare(pageHeader, "searchQuery", "")
                tryCompare(previewListView, "open", false);
            }

            function test_showDash() {
                previewListView.open = true;
                tryCompare(openEffect, "live", true);
                scopes.get(0).showDash();
                tryCompare(previewListView, "open", false);
                tryCompare(openEffect, "live", true);
            }

            function test_hideDash() {
                previewListView.open = true;
                scopes.get(0).hideDash();
                tryCompare(previewListView, "open", false);
            }

            function openPreview() {
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.positionAtBeginning();

                tryCompareFunction(function() {
                                       var tile = findChild(genericScopeView, "delegate0");
                                       return tile != undefined;
                                   },
                                   true);
                var tile = findChild(genericScopeView, "delegate0");
                mouseClick(tile, tile.width / 2, tile.height / 2);
                tryCompare(previewListView, "open", true);
                tryCompare(openEffect, "gap", 1);
            }

            function checkArrowPosition(index) {
                tryCompareFunction(function() {
                                       var tile = findChild(genericScopeView, "delegate" + index);
                                       return tile != undefined;
                                   },
                                   true);
                var tile = findChild(genericScopeView, "delegate" + index);
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

                var tile = findChild(genericScopeView, "delegate0");
                mouseClick(tile, tile.width / 2, tile.height - 1);
                tryCompare(openEffect, "gap", 1);

                verify(openEffect.positionPx >= pageHeader.height + categoryListView.stickyHeaderHeight);
            }

            function test_previewCycle() {
                tryCompare(previewListView, "open", false);

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
                openPreview();
                var previewLoader = findChild(previewListView, "previewLoader0");

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
                genericScopeView.scope = scopes.get(0)
                tryCompare(genericScopeView.scope, "searchQuery", "")
            }
        }
    }
}
