/*
 * Copyright 2013-2014 Canonical Ltd.
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
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT
import QMenuModel 0.1
import Ubuntu.Settings.Menus 0.1 as Menus
import "../../../qml/Panel"
import "../../../qml/Panel/Indicators"

Item {
    id: testView
    width: units.gu(40)
    height: units.gu(70)

    UnityMenuModel {
        id: unityMenuModel
        modelData: fullMenuData
    }

    PanelMenuPage {
        id: page
        anchors.fill: parent

        menuModel: unityMenuModel
        submenuIndex: 0

        factory: Object {
            function load(model) {
               return standardMenuComponent;
            }

            Component {
                id: standardMenuComponent

                Menus.StandardMenu {
                    signal menuSelected
                    signal menuDeselected
                }
            }
        }
    }

    property var fullMenuData: [{
            "rowData": {                // 1
                "label": "root",
                "sensitive": true,
                "isSeparator": false,
                "icon": "",
                "type": "com.canonical.indicator.root",
                "ext": {},
                "action": "",
                "actionState": {},
                "isCheck": false,
                "isRadio": false,
                "isToggled": false,
            },
            "submenu": [{
                "rowData": {                // 1.1
                    "label": "menu0",
                    "sensitive": true,
                    "isSeparator": false,
                    "icon": "",
                    "type": "com.canonical.indicator.test",
                    "ext": {},
                    "action": "menu0",
                    "actionState": {},
                    "isCheck": false,
                    "isRadio": false,
                    "isToggled": false,
                }}, {
               "rowData": {                // 1.2
                   "label": "menu1",
                   "sensitive": true,
                   "isSeparator": false,
                   "icon": "",
                   "type": "com.canonical.indicator.test",
                   "ext": {},
                   "action": "menu1",
                   "actionState": {},
                   "isCheck": false,
                   "isRadio": false,
                   "isToggled": false,
               }}, {
               "rowData": {                // row 1.2
                   "label": "menu2",
                   "sensitive": true,
                   "isSeparator": false,
                   "icon": "",
                   "type": "com.canonical.indicator.test",
                   "ext": {},
                   "action": "menu2",
                   "actionState": {},
                   "isCheck": false,
                   "isRadio": false,
                   "isToggled": false,
               }}
            ]
        }]; // end row 1

    property var emptySubMenuData: [{
            "rowData": {                // 1
                "label": "root",
                "sensitive": true,
                "isSeparator": false,
                "icon": "",
                "type": "com.canonical.indicator.root",
                "ext": {},
                "action": "",
                "actionState": {},
                "isCheck": false,
                "isRadio": false,
                "isToggled": false,
            },
            "submenu": []
        }]; // end row 1

    UT.UnityTestCase {
        name: "IndicatorPage"

        function init() {
            page.submenuIndex = 0;
            unityMenuModel.modelData = [];
            tryCompareFunction(function() { return page.currentPage == null }, true);
        }

        function test_loadData() {
            unityMenuModel.modelData = fullMenuData;

            tryCompareFunction(function() { return page.currentPage != null }, true);
            var listView = findChild(page.currentPage, "listView", 50);
            verify(listView);
            tryCompare(listView, "count", 3);

            unityMenuModel.modelData = [];
            tryCompareFunction(function() { return page.currentPage == null }, true);
        }

        function test_traverse_submenuIndex_data() {
            return [,
                { tag: "Correct", submenuIndex: 0, expectedCount: 3},
                { tag: "Incorrect", submenuIndex: 1, expectedCount: 0}
            ]
        }

        function test_traverse_submenuIndex(data) {
            page.submenuIndex = data.submenuIndex;
            unityMenuModel.modelData = fullMenuData;

            tryCompareFunction(function() { return page.currentPage != null }, data.expectedCount > 0);
            if (data.expectedCount > 0) {
                var listView = findChild(page.currentPage, "listView", 50);
                tryCompare(listView, "count", data.expectedCount);
            }
        }

        function test_remove_selected_item_data() {
            return [
                { remove: 0 },
                { remove: 2 },
            ]
        }

        function test_remove_selected_item(data) {
            unityMenuModel.modelData = fullMenuData;
            var listView = findChild(page.currentPage, "listView", 50);

            var menuId = "menu"+data.remove
            var menu = findChild(listView, menuId);
            verify(menu);

            menu.menuSelected();
            compare(listView.currentIndex, data.remove, "Incorrect index selected");
            listView.model.removeRow(data.remove);

            compare(listView.currentIndex, -1, "Current index should be reset after current item removal");

            // now make sure selecting a new menu works.
            var menu1 = findChild(page, "menu1");
            verify(menu1);
            menu1.menuSelected();
            compare(menu1.selected, true, "Item not selected");
        }
    }
}
