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

    GenericScopeView {
        id: genericScopeView
        anchors.fill: parent

        UT.UnityTestCase {
            name: "GenericScopeView"
            when: scopes.loaded

            function test_isCurrent() {
                var pageHeader = findChild(genericScopeView, "pageHeader");
                var previewListView = findChild(genericScopeView, "previewListView");
                genericScopeView.isCurrent = true
                pageHeader.searchQuery = "test"
                previewListView.open = true
                genericScopeView.isCurrent = false
                tryCompare(pageHeader, "searchQuery", "")
                tryCompare(genericScopeView, "previewShown", false);
            }

            function test_showDash() {
                var previewListView = findChild(genericScopeView, "previewListView");
                previewListView.open = true;
                scopes.get(0).showDash();
                tryCompare(genericScopeView, "previewShown", false);
            }

            function test_hideDash() {
                var previewListView = findChild(genericScopeView, "previewListView");
                previewListView.open = true;
                scopes.get(0).hideDash();
                tryCompare(genericScopeView, "previewShown", false);
            }

            function openPreview() {
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.positionAtBeginning();

                var tile = findChild(genericScopeView, "delegate0");
                mouseClick(tile, tile.width / 2, tile.height / 2);
                var openEffect = findChild(genericScopeView, "openEffect");
                tryCompare(openEffect, "gap", 1);
            }

            function checkArrowPosition(index) {
                var tile = findChild(genericScopeView, "delegate" + index);
                var tileCenter = tile.x + tile.width/2;
                var pointerArrow = findChild(genericScopeView, "pointerArrow");
                var pointerArrowCenter = pointerArrow.x + pointerArrow.width/2;
                compare(pointerArrowCenter, tileCenter, "Pointer did not move to tile");
            }

            function closePreview() {
                var closePreviewMouseArea = findChild(genericScopeView, "closePreviewMouseArea");
                mouseClick(closePreviewMouseArea, closePreviewMouseArea.width / 2, closePreviewMouseArea.height / 2);

                var previewListView = findChild(genericScopeView, "previewListView");
                tryCompare(previewListView, "open", false);
                var openEffect = findChild(genericScopeView, "openEffect");
                tryCompare(openEffect, "gap", 0);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.flick(0, units.gu(200));
                tryCompare(categoryListView, "flicking", false);
            }

            function test_previewOpenClose() {
                var previewListView = findChild(genericScopeView, "previewListView");
                tryCompare(previewListView, "open", false);

                openPreview();

                // check for it opening successfully
                var currentPreviewItem = findChild(genericScopeView, "previewLoader0");
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

            function test_previewCycleOne() {
                var previewListView = findChild(genericScopeView, "previewListView");
                tryCompare(previewListView, "open", false);

                openPreview();

                // wait for it to be loaded
                var currentPreviewItem = findChild(genericScopeView, "previewLoader0");
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
                    var nextPreviewItem = findChild(genericScopeView, "previewLoader" + i);
                    tryCompareFunction(function() {
                                           var parts = nextPreviewItem.source.toString().split("/");
                                           var name = parts[parts.length - 1];
                                           return name == "GenericPreview.qml";
                                       },
                                       true);
                    tryCompare(nextPreviewItem, "progress", 1);
                    waitForRendering(nextPreviewItem);

                    checkArrowPosition(i);
                }

                closePreview();
            }

            function test_show_spinner() {
                openPreview();
                var previewListView = findChild(genericScopeView, "previewListView");
                var previewLoader = findChild(genericScopeView, "previewLoader0");

                previewLoader.item.showProcessingAction = true;
                var waitingForAction = findChild(genericScopeView, "waitingForActionMouseArea");
                tryCompare(waitingForAction, "enabled", true);
                previewLoader.closePreviewSpinner();
                tryCompare(waitingForAction, "enabled", false);

                closePreview();
            }
        }
    }
}
