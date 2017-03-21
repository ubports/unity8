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
    width:  Math.max(units.gu(100), loader.width + units.gu(6))
    height:  Math.max(units.gu(50), loader.height + units.gu(6))

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    ApplicationMenuDataLoader { id: appMenuData }

    Loader {
        id: loader
        sourceComponent: MenuPopup {
            anchors {
                left: parent ? parent.left : undefined
                top: parent ? parent.top : undefined
                leftMargin: units.gu(3)
                topMargin: units.gu(3)
            }

            unityMenuModel: UnityMenuModel {
                modelData: [{
                        "rowData": {
                            "label": "Short",
                        }}, {
                       "rowData": {
                           "label": "This is a long menu item which tests width",
                       }}
                    ]
            }
        }
    }

    SignalSpy {
        id: aboutToShowCalledSpy
        target: loader.item ? loader.item.unityMenuModel : undefined
        signalName: "aboutToShowCalled"
    }

    UnityTestCase {
        id: testCase
        name: "MenuPopup"
        when: windowShown

        property var menu: loader.status === Loader.Ready ? loader.item : null

        function init() {
            loader.active = true;
            menu.show();
        }

        function cleanup() {
            menu.reset();
            wait(100); // let the page dismiss

            loader.active = false;
            tryCompare(loader, "item", null);
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
                    waitForRendering(menuItem);
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

        function test_mouseNavigation_data() {
            return [
                { tag: "long", testData: appMenuData.generateTestData(4, 2, 1, 0, "menu", false) },
                { tag: "deep", testData: appMenuData.generateTestData(2, 4, 1, 0, "menu", false) }
            ]
        }

        function test_mouseNavigation(data) {
            menu.unityMenuModel.modelData = data.testData;

            recurseMenuConstruction(data.testData, menu);
        }

        function test_checkableMenuTogglesOnClick() {
            menu.unityMenuModel.modelData = appMenuData.singleCheckable;

            var menuItem = findChild(menu, "menu-item0-actionItem");
            verify(menuItem);
            compare(menuItem.action.checkable, true, "Menu item should be checkable");
            compare(menuItem.action.checked, false, "Menu item should not be checked");

            mouseClick(menuItem, menuItem.width/2, menuItem.height/2);

            compare(menuItem.action.checked, true, "Checkable menu item should have toggled");
        }

        function test_keyboardNavigation_DownKeySelectsAndOpensNextMenuItemAndRotates() {
            menu.unityMenuModel.modelData = appMenuData.generateTestData(3,3,0,0,"menu",false);

            var item0 = findChild(menu, "menu-item0"); verify(item0);
            var item1 = findChild(menu, "menu-item1"); verify(item1);
            var item2 = findChild(menu, "menu-item2"); verify(item2);

            var priv = findInvisibleChild(menu, "d");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item1, "CurrentItem should have moved to item 1");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item2, "CurrentItem should have moved to item 2");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item0, "CurrentItem should have moved to item 0");

            keyClick(Qt.Key_Down, Qt.NoModifier);
            compare(priv.currentItem, item1, "CurrentItem should have moved to item 1");
        }

        function test_keyboardNavigation_UpKeySelectsAndOpensPreviousMenuItemAndRotates() {
            menu.unityMenuModel.modelData = appMenuData.generateTestData(3,3,0,0,"menu",false);

            var item0 = findChild(menu, "menu-item0"); verify(item0);
            var item1 = findChild(menu, "menu-item1"); verify(item1);
            var item2 = findChild(menu, "menu-item2"); verify(item2);

            var priv = findInvisibleChild(menu, "d");

            keyClick(Qt.Key_Up, Qt.NoModifier);
            compare(priv.currentItem, item2, "CurrentItem should have moved to item 2");

            keyClick(Qt.Key_Up, Qt.NoModifier);
            compare(priv.currentItem, item1, "CurrentItem should have moved to item 1");

            keyClick(Qt.Key_Up, Qt.NoModifier);
            compare(priv.currentItem, item0, "CurrentItem should have moved to item 0");

            keyClick(Qt.Key_Up, Qt.NoModifier);
            compare(priv.currentItem, item2, "CurrentItem should have moved to item 2");
        }

        function test_aboutToShow() {
            menu.unityMenuModel.modelData = appMenuData.generateTestData(3,3,1,0,"menu",false);

            var item0 = findChild(menu, "menu-item0");
            var item1 = findChild(menu, "menu-item1");
            var item2 = findChild(menu, "menu-item2");

            aboutToShowCalledSpy.clear();

            mouseMove(item0, item0.width/2, item0.height/2);
            tryCompare(aboutToShowCalledSpy, "count", 1);

            mouseMove(item1, item0.width/2, item0.height/2);
            tryCompare(aboutToShowCalledSpy, "count", 2);

            mouseMove(item2, item0.width/2, item0.height/2);
            tryCompare(aboutToShowCalledSpy, "count", 3);

            mouseMove(item0, item0.width/2, item0.height/2);
            tryCompare(aboutToShowCalledSpy, "count", 4);

            item0.item.trigger();
            // it's already visible
            tryCompare(aboutToShowCalledSpy, "count", 4);

            compare(aboutToShowCalledSpy.signalArguments[0][0], 0);
            compare(aboutToShowCalledSpy.signalArguments[1][0], 1);
            compare(aboutToShowCalledSpy.signalArguments[2][0], 2);
            compare(aboutToShowCalledSpy.signalArguments[3][0], 0);
        }

        function test_keyboardNavigation_RightKeyEntersSubMenu() {
            menu.unityMenuModel.modelData = appMenuData.generateTestData(3,3,1,0,"menu",false);

            var menuItem = findChild(menu, "menu-item0");

            var priv = findInvisibleChild(menu, "d");
            priv.currentItem = menuItem;

            keyClick(Qt.Key_Right, Qt.NoModifier);
            tryCompareFunction(function() { return menuItem.popup !== null && menuItem.popup.visible }, true);

            var submenu0 = findChild(menu, "menu-item0-menu"); verify(submenu0);
            var submenu0item0 = findChild(submenu0, "menu-item0-menu-item0"); verify(submenu0item0);

            var submenu0Priv = findInvisibleChild(submenu0, "d"); verify(submenu0Priv);
            compare(submenu0Priv.currentItem, submenu0item0, "First item of submenu should be selected");
        }

        function test_keyboardNavigation_LeftKeyClosesSubMenu() {
            menu.unityMenuModel.modelData = appMenuData.generateTestData(3,3,1,0,"menu",false);

            var menuItem = findChild(menu, "menu-item0"); verify(menuItem);
            mouseClick(menuItem, menuItem.width/2, menuItem.height/2);
            tryCompareFunction(function() { return menuItem.popup !== null && findInvisibleChild(menuItem.popup, "d").currentItem !== null }, true);

            keyClick(Qt.Key_Left, Qt.NoModifier);
            tryCompareFunction(function() { return menuItem.popup !== null && menuItem.popup.visible }, false);
        }

        function test_mouseHoverOpensSubMenu() {
            menu.unityMenuModel.modelData = appMenuData.generateTestData(3,3,1,0,"menu",false);

            var menuItem = findChild(menu, "menu-item0");

            var priv = findInvisibleChild(menu, "d");
            priv.currentItem = menuItem;

            mouseMove(menuItem, menuItem.width/2, menuItem.height/2);
            verify(!menuItem.popup);

            tryCompareFunction(function() { return menuItem.popup != null; }, true);
        }

        function test_differentSizes() {
            var differentSizesMenu = [{
                "rowData": { "label": "Short" }}, {
                "rowData": { "label": "This is a long menu item which tests width" }
            }];

            menu.unityMenuModel.modelData = differentSizesMenu;

            // Wait for the two items to be there
            tryCompareFunction(function() { return findChild(menu, "menu-item1") !== null; }, true);
            var longWidth = menu.width;

            // Now pop one item and make sure it's smaller
            differentSizesMenu.pop();
            menu.unityMenuModel.modelData = differentSizesMenu;

            tryCompareFunction(function() { return findChild(menu, "menu-item0") !== null; }, true);
            tryCompareFunction(function() { return menu.width < longWidth; }, true);
        }

        function test_minimumWidth() {
            var shortMenu = [{
                "rowData": { "label": "Short" }
            }];
            menu.unityMenuModel.modelData = shortMenu;

            var priv = findInvisibleChild(menu, "d");
            priv.__minimumWidth = 0;
            priv.__maximumWidth = 1000;
            tryCompareFunction(function() { return menu.width > priv.__minimumWidth; }, true);

            priv.__minimumWidth = 300;
            tryCompare(menu, "width", priv.__minimumWidth);
        }

        function test_maximumWidth() {
            var longMenu = [{
                "rowData": { "label": "This is a long menu item which tests width" }
            }];

            var priv = findInvisibleChild(menu, "d");
            priv.__minimumWidth = 0;
            priv.__maximumWidth = 100;

            menu.unityMenuModel.modelData = longMenu;
            tryCompare(menu, "width", priv.__maximumWidth);

            priv.__maximumWidth = 200;
            tryCompare(menu, "width", priv.__maximumWidth);

            priv.__maximumWidth = 1200;
            tryCompareFunction(function() { return menu.width < priv.__maximumWidth; }, true);
        }

        function test_minimumHeight() {
            var shortMenu = [{
                "rowData": { "label": "menu1" }
            }];
            menu.unityMenuModel.modelData = shortMenu;

            var priv = findInvisibleChild(menu, "d");
            priv.__minimumHeight = 0;
            priv.__maximumHeight = 1000;
            tryCompareFunction(function() { return menu.height > priv.__minimumHeight; }, true);

            priv.__minimumHeight = 300;
            tryCompare(menu, "height", priv.__minimumHeight);
        }

        function test_maximumHeight() {
            var shortMenu = [{
                "rowData": { "label": "menu1" }}, {
                "rowData": { "label": "menu2" }}, {
                "rowData": { "label": "menu3" }}, {
                "rowData": { "label": "menu4" }}, {
                "rowData": { "label": "menu5" }}, {
                "rowData": { "label": "menu6" }}, {
                "rowData": { "label": "menu7" }}, {
                "rowData": { "label": "menu8" }}, {
                "rowData": { "label": "menu9" }
            }];
            menu.unityMenuModel.modelData = shortMenu;

            var priv = findInvisibleChild(menu, "d");
            priv.__minimumHeight = 0;
            priv.__maximumHeight = 100;
            tryCompare(menu, "height", priv.__maximumHeight);

            priv.__maximumHeight = 200;
            tryCompare(menu, "height", priv.__maximumHeight);

            priv.__maximumHeight = 1200;
            tryCompareFunction(function() { return menu.height < priv.__maximumHeight; }, true);
        }
    }
}
