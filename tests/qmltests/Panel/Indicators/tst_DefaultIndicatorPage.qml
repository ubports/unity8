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
import Unity.Test 0.1 as UT
import QMenuModel 0.1
import Ubuntu.Settings.Menus 0.1 as Menus
import "../../../../qml/Panel/Indicators"

Item {
    id: testView
    width: units.gu(40)
    height: units.gu(70)

   DefaultIndicatorPage {
        id: page

        anchors.fill: parent

        menuModel: UnityMenuModel {}
        busName: "test"
        actionsObjectPath: "test"
        menuObjectPath: "test"

        identifier: "test-indicator"
        rootMenuType: "com.canonical.indicator.root"

        factory {
            _map: {
                "default": {
                    "com.canonical.indicator.test" : testMenu
                }
            }
        }
    }

   Component {
       id: testMenu
       Menus.StandardMenu {
           signal menuSelected
           signal menuDeselected
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
        name: "DefaultIndicatorPage"

        function init() {
            var mainMenu = findChild(page, "mainMenu");
            page.menuModel.modelData = [];
            verify(mainMenu.model !== null);
        }

        function test_reloadData() {
            var mainMenu = findChild(page, "mainMenu");

            page.menuModel.modelData = [];
            tryCompare(mainMenu, "count", 0);

            page.menuModel.modelData = fullMenuData;
            tryCompare(mainMenu, "count", 3);

            page.menuModel.modelData = [];
            tryCompare(mainMenu, "count", 0);

            page.menuModel.modelData = fullMenuData;
            tryCompare(mainMenu, "count", 3);
        }

        function test_traverse_rootMenuType_data() {
            return [
                { tag: "Incorrect", rootMenuType: "com.canonical.indicator", expectedCount: 0},
                { tag: "Correct", rootMenuType: "com.canonical.indicator.root", expectedCount: 3},
            ]
        }

        function test_traverse_rootMenuType(data) {
            page.rootMenuType = data.rootMenuType;
            page.menuModel.modelData = fullMenuData;

            var mainMenu = findChild(page, "mainMenu");
            tryCompare(mainMenu, "count", data.expectedCount);
        }

        function test_remove_selected_item_data() {
            return [
                { remove: 0 },
                { remove: 2 },
            ]
        }

        function test_remove_selected_item(data) {
            var mainMenu = findChild(page, "mainMenu");
            page.menuModel.modelData = fullMenuData;

            tryCompare(mainMenu, "count", 3);

            var menuId = "menu"+data.remove

            tryCompareFunction(function() { return findChild(page, menuId) !== null;}, true);
            var menu = findChild(page, menuId);

            menu.menuSelected();
            compare(mainMenu.currentIndex, data.remove, "Incorrect index selected");
            mainMenu.model.removeRow(data.remove);

            compare(mainMenu.currentIndex, -1, "Current index should be reset after current item removal");

            // now make sure selecting a new menu works.
            var menu1 = findChild(page, "menu1");
            menu1.menuSelected();
            compare(menu1.selected, true, "Item not selected");
        }
    }
}
