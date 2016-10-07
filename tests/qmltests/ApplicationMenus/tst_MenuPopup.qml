/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import Ubuntu.Components.ListItems 1.3
import Unity.Application 0.1
import QMenuModel 0.1
import Unity.Test 0.1
import Utils 0.1

import "../../../qml/ApplicationMenus"
import ".."

Item {
    id: root
    width:  Math.max(units.gu(100), page.width + units.gu(6))
    height:  Math.max(units.gu(50), page.height + units.gu(6))

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    ApplicationMenuDataLoader { id: appMenuData }

    MenuPopup {
        id: page
        focus: true

        anchors {
            left: parent.left
            top: parent.top
            leftMargin: units.gu(3)
            topMargin: units.gu(3)
        }

        unityMenuModel: UnityMenuModel {
            id: menuBackend
            modelData: appMenuData.generateTestData(7,5,2,3,"menu")
        }
    }

    SignalSpy {
        id: activatedSpy
        target: menuBackend
        signalName: "activated"
    }

    UnityTestCase {
        id: testCase
        name: "MenuPage"
        when: windowShown

        function init() {
            page.dismiss();
            wait(100); // let the page dismiss
            activatedSpy.clear();
        }

        // visit and verify that all the backend menus have been created
        function recurseMenuConstruction(rows, menuPage) {
            for (var i = 0; i < rows.length; ++i) {
                var rowData = rows[i]["rowData"];

                var menuItemName = menuPage.objectName +"-item"+i

                var menuItem = findChild(menuPage, menuItemName); verify(menuItem);

                var menuPriv = findInvisibleChild(menuPage, "d");

                // recurse into submenu
                var submenu = rows[i]["submenu"];
                if (submenu) {
                    mouseClick(menuItem, menuItem.width/2, menuItem.height/2);
                    tryCompare(menuPriv, "currentItem", menuItem);

                    tryCompareFunction(function() { return menuItem.popup !== null && menuItem.visible }, true);

                    var submenuPage = findChild(menuPage, menuItemName + "-menu"); verify(submenuPage);

                    recurseMenuConstruction(submenu, submenuPage);
                } else {
                    mouseMove(menuItem, menuItem.width/2, menuItem.height/2);
                    tryCompare(menuPriv, "currentItem", menuItem);
                }
            }
        }

        function test_clickNavigation_data() {
            return [
                { tag: "long", testData: appMenuData.generateTestData(4, 2, 1, 0, "menu", false) },
                { tag: "deep", testData: appMenuData.generateTestData(2, 4, 1, 0, "menu", false) }
            ]
        }

        function test_clickNavigation(data) {
            menuBackend.modelData = data.testData;

            recurseMenuConstruction(data.testData, page);
        }

        function test_checkableMenuTogglesOnClick() {
            menuBackend.modelData = appMenuData.singleCheckable;

            var menuItem = findChild(page, "menu-item0-actionItem");
            verify(menuItem);
            compare(menuItem.action.checkable, true, "Menu item should be checkable");
            compare(menuItem.action.checked, false, "Menu item should not be checked");

            mouseClick(menuItem, menuItem.width/2, menuItem.height/2);

            compare(menuItem.action.checked, true, "Checkable menu item should have toggled");
        }

        function test_keyboardNavigation_DownKeySelectsAndOpensNextMenuItemAndRotates() {
            menuBackend.modelData = appMenuData.generateTestData(3,3,0,0,"menu",false);

            var item0 = findChild(page, "menu-item0"); verify(item0);
            var item1 = findChild(page, "menu-item1"); verify(item1);
            var item2 = findChild(page, "menu-item2"); verify(item2);

            var priv = findInvisibleChild(page, "d");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item0, "CurrentItem should have moved to item 0");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item1, "CurrentItem should have moved to item 1");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item2, "CurrentItem should have moved to item 2");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item0, "CurrentItem should have moved to item 0");
        }

        function test_keyboardNavigation_UpKeySelectsAndOpensPreviousMenuItemAndRotates() {
            menuBackend.modelData = appMenuData.generateTestData(3,3,0,0,"menu",false);

            var item0 = findChild(page, "menu-item0"); verify(item0);
            var item1 = findChild(page, "menu-item1"); verify(item1);
            var item2 = findChild(page, "menu-item2"); verify(item2);

            var priv = findInvisibleChild(page, "d");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item0, "CurrentItem should have moved to item 2");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item1, "CurrentItem should have moved to item 1");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item2, "CurrentItem should have moved to item 0");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item0, "CurrentItem should have moved to item 2");
        }

        function test_keyboardNavigation_RightKeyEntersSubMenu() {
            menuBackend.modelData = appMenuData.generateTestData(3,3,1,0,"menu",false);

            var menuItem = findChild(page, "menu-item0");

            var priv = findInvisibleChild(page, "d");
            priv.currentItem = menuItem;

            keyClick(Qt.Key_Right, Qt.NoModifier);
            tryCompareFunction(function() { return menuItem.popup !== null && menuItem.popup.visible }, true);

            var submenu0 = findChild(page, "menu-item0-menu"); verify(submenu0);
            var submenu0item0 = findChild(submenu0, "menu-item0-menu-item0"); verify(submenu0item0);

            var submenu0Priv = findInvisibleChild(submenu0, "d"); verify(submenu0Priv);
            compare(submenu0Priv.currentItem, submenu0item0, "First item of submenu should be selected");
        }

        function test_keyboardNavigation_LeftKeyClosesSubMenu() {
            menuBackend.modelData = appMenuData.generateTestData(3,3,1,0,"menu",false);

            var menuItem = findChild(page, "menu-item0"); verify(menuItem);
            mouseClick(menuItem, menuItem.width/2, menuItem.height/2);
            tryCompareFunction(function() { return menuItem.popup !== null && menuItem.popup.visible }, true);

            keyClick(Qt.Key_Left, Qt.NoModifier);
            tryCompareFunction(function() { return menuItem.popup !== null && menuItem.popup.visible }, false);
        }
    }
}
