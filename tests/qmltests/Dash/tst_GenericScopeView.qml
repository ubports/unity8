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

    // BEGIN To reduce warnings
    // TODO I think it we should pass down these variables
    // as needed instead of hoping they will be globally around
    property var greeter: null
    property var panel: null
    // BEGIN To reduce warnings

    Scopes {
        id: scopes
    }

    property Item applicationManager: Item {
        signal sideStageFocusedApplicationChanged()
        signal mainStageFocusedApplicationChanged()
    }


    GenericScopeView {
        id: genericScopeView
        anchors.fill: parent
        previewListView: previewListView

        UT.UnityTestCase {
            name: "GenericScopeView"
            when: scopes.loaded && windowShown

            function init() {
                genericScopeView.scope = scopes.getScope(2)
                shell.width = units.gu(120)
                genericScopeView.categoryView.positionAtBeginning();
                tryCompare(genericScopeView.categoryView, "contentY", 0)
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
                scopes.getScope(2).showDash();
                tryCompare(previewListView, "open", false);
            }

            function test_hideDash() {
                previewListView.open = true;
                scopes.getScope(2).hideDash();
                tryCompare(previewListView, "open", false);
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
                genericScopeView.scope = scopes.getScope(1)
                genericScopeView.scope = scopes.getScope(2)
                tryCompare(genericScopeView.scope, "searchQuery", "test")
            }

            function test_filter_expand_collapse() {
                // wait for the item to be there
                waitForRendering(genericScopeView);
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
                tryCompareFunction(function() { return category.height > middleHeight; }, true);

                mouseClick(header, header.width / 2, header.height / 2);
                verify(category.expandable);
                tryCompare(category, "filtered", true);
            }

            function test_filter_expand_expand_collapse() {
                // wait for the item to be there
                tryCompareFunction(function() { return findChild(genericScopeView, "dashSectionHeader2") != null; }, true);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.contentY = categoryListView.height;

                var header2 = findChild(genericScopeView, "dashSectionHeader2")
                var category2 = findChild(genericScopeView, "dashCategory2")
                var category2FilterGrid = category2.children[1].children[2];
                verify(UT.Util.isInstanceOf(category2FilterGrid, "CardFilterGrid"));

                waitForRendering(header2);
                verify(category2.expandable);
                verify(category2.filtered);

                mouseClick(header2, header2.width / 2, header2.height / 2);
                tryCompare(category2, "filtered", false);
                tryCompare(category2FilterGrid, "filtered", false);

                categoryListView.positionAtBeginning();

                var header0 = findChild(genericScopeView, "dashSectionHeader0")
                var category0 = findChild(genericScopeView, "dashCategory0")
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category0, "filtered", false);
                tryCompare(category2, "filtered", true);
                tryCompare(category2FilterGrid, "filtered", true);
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category0, "filtered", true);
                tryCompare(category2, "filtered", true);
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
                tryCompareFunction(function() { return category.item.height == genericScopeView.height - category.item.displayMarginBeginning - category.item.displayMarginEnd; }, true);
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category, "filtered", true);
            }

            function test_haeder_logo() {
                genericScopeView.scope = scopes.getScope(3);

                var image = findChild(genericScopeView, "titleImage");
                verify(image, "Could not find the title image");
                compare(image.source, Qt.resolvedUrl("../Components/tst_PageHeader/logo-ubuntu-orange.svg"), "Title image has the wrong source");
            }
        }
    }

    PreviewListView {
        id: previewListView
        anchors.fill: parent
        visible: false
        scope: genericScopeView.scope
    }
}
