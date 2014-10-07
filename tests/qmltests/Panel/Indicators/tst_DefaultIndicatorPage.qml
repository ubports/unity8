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
import Unity.Indicators 0.1 as Indicators
import "../../../../qml/Panel/Indicators"

Item {
    id: testView
    width: units.gu(40)
    height: units.gu(70)

   DefaultIndicatorPage {
        id: page
        anchors.fill: parent

        identifier: "test-indicator"
        busName: "com.caninical.indicator.test"
        actionsObjectPath: "/com/canonical/indicator/test"
        menuObjectPath: "/com/canonical/indicator/test"
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
                   "label": "menu1",
                   "sensitive": true,
                   "isSeparator": false,
                   "icon": "",
                   "type": "",
                   "ext": {},
                   "action": "",
                   "actionState": {},
                   "isCheck": false,
                   "isRadio": false,
                   "isToggled": false,
               }}, {
              "rowData": {                // 1.2
                  "label": "menu2",
                  "sensitive": true,
                  "isSeparator": false,
                  "icon": "",
                  "type": "",
                  "ext": {},
                  "action": "",
                  "actionState": {},
                  "isCheck": false,
                  "isRadio": false,
                  "isToggled": false,
              }}, {
              "rowData": {                // row 1.2
                  "label": "menu3",
                  "sensitive": true,
                  "isSeparator": false,
                  "icon": "",
                  "type": "",
                  "ext": {},
                  "action": "",
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

   function initializeMenuData(data) {
       Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicator.test",
                                                         "/com/canonical/indicator/test",
                                                         "/com/canonical/indicator/test",
                                                         data);
   }

    UT.UnityTestCase {
        name: "DefaultIndicatorPage"

        function init() {
            initializeMenuData([]);
        }

        function test_reloadData() {
            var mainMenu = findChild(page, "mainMenu");

            tryCompare(mainMenu, "count", 0);

            initializeMenuData(fullMenuData);
            tryCompare(mainMenu, "count", 3);

            initializeMenuData([]);
            tryCompare(mainMenu, "count", 0);
        }

        function test_traverse_rootMenuType_data() {
            return [
                { tag: "Incorrect", rootMenuType: "com.canonical.indicator", expectedCount: 0},
                { tag: "Correct", rootMenuType: "com.canonical.indicator.root", expectedCount: 3},
            ]
        }

        function test_traverse_rootMenuType(data) {
            page.rootMenuType = data.rootMenuType;
            initializeMenuData(fullMenuData);

            var mainMenu = findChild(page, "mainMenu");
            tryCompare(mainMenu, "count", data.expectedCount);
        }
    }
}
