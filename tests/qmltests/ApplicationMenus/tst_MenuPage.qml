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
import "../Stages"

Item {
    id: root
    width:  Math.max(units.gu(100), page.width + units.gu(6))
    height:  Math.max(units.gu(50), page.height + units.gu(6))

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    DesktopMenuData { id: desktopMenuData }

    Keys.onEscapePressed: {
        page.closePopup(true);
    }

    MenuPage {
        id: page
        focus: true

        anchors {
            left: parent.left
            top: parent.top
            leftMargin: units.gu(3)
            topMargin: units.gu(3)
        }

        delegateModel: rootDelegate.submenuItems
        MenuItemDelegateBase {
            id: rootDelegate
            menuModel: UnityMenuModel {
                id: menuBackend
                modelData: desktopMenuData.generateTestData(3, 3, 0);
            }
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

        property bool clickNavigate: true

        function init() {
            page.closePopup(true);
            menuBackend.modelData = desktopMenuData.generateTestData(3, 3, 0);
            activatedSpy.clear();
        }

        // visit and verify that all the backend menus have been created
        function recurseMenuConstruction(rows, menuPageName) {
            for (var i = 0; i < rows.length; ++i) {
                var rowData = rows[i]["rowData"];

                var menuPage = findChild(page, menuPageName);
                verify(menuPage);
                var menuItem = findChild(menuPage, menuPageName+"-menu"+i);
                verify(menuItem);

                // recurse into submenu
                var submenu = rows[i]["submenu"];
                if (submenu) {
                    if (clickNavigate) {
                        mouseClick(menuItem, menuItem.width/2, menuItem.height/2);
                    } else {
                        mouseMove(menuItem, menuItem.width/2, menuItem.height/2);
                    }
                    tryCompare(menuPage, "openItem", menuItem);
                    recurseMenuConstruction(submenu, menuPageName+"-subMenu"+i);
                }
            }
        }

        function test_hoverNavigation_data() {
            return [
                { tag: "long", testData: desktopMenuData.generateTestData(4, 2, 0) },
                { tag: "deep", testData: desktopMenuData.generateTestData(2, 4, 0) }
            ]
        }

        function test_hoverNavigation(data) {
            clickNavigate = false;
            menuBackend.modelData = data.testData;

            recurseMenuConstruction(data.testData, "menuPage");
        }

        function test_clickNavigation_data() {
            return [
                { tag: "long", testData: desktopMenuData.generateTestData(4, 2, 0) },
                { tag: "deep", testData: desktopMenuData.generateTestData(2, 4, 0) }
            ]
        }

        function test_clickNavigation(data) {
            clickNavigate = true;
            menuBackend.modelData = data.testData;

            recurseMenuConstruction(data.testData, "menuPage");
        }

        function test_checkableMenuTogglesOnClick() {
            menuBackend.modelData = desktopMenuData.singleCheckable;

            var menuItem = findChild(page, "menuPage-menu0");
            verify(menuItem);
            verify(menuItem.delegate.isCheck);
            verify(menuItem.delegate.isToggled === false);

            mouseClick(menuItem, menuItem.width/2, menuItem.height/2);

            compare(menuItem.delegate.isToggled, true, "Checkable menu should have toggled");
        }

        function test_keyboardNavigation_DownKeySelectsAndOpensNextMenuItemAndRotates() {
            menuBackend.modelData = desktopMenuData.generateTestData(4, 2, 3);
            var listView = findChild(page, "menuPage-ListView");
            verify(listView);

            var menuItem0 = findChild(page, "menuPage-menu0"); verify(menuItem0);
            var menuItem1 = findChild(page, "menuPage-menu1"); verify(menuItem1);
            var menuItem2 = findChild(page, "menuPage-menu2"); verify(menuItem2);
            verify(menuItem2.delegate.isSeparator);
            var menuItem3 = findChild(page, "menuPage-menu3"); verify(menuItem3);

            keyClick(Qt.Key_Down, Qt.NoModifier, 100);
            compare(listView.selectedItem, menuItem0);
            tryCompare(page, "openItem", menuItem0);

            keyClick(Qt.Key_Down, Qt.NoModifier, 100);
            compare(listView.selectedItem, menuItem1);
            tryCompare(page, "openItem", menuItem1);

            // Skip separator

            keyClick(Qt.Key_Down, Qt.NoModifier, 100);
            compare(listView.selectedItem, menuItem3);
            tryCompare(page, "openItem", menuItem3);

            keyClick(Qt.Key_Down, Qt.NoModifier, 100);
            compare(listView.selectedItem, menuItem0);
            tryCompare(page, "openItem", menuItem0);
        }

        function test_keyboardNavigation_UpKeySelectsAndOpensPreviousMenuItemAndRotates() {
            menuBackend.modelData = desktopMenuData.generateTestData(4, 2, 3);
            var listView = findChild(page, "menuPage-ListView");
            verify(listView);

            var menuItem0 = findChild(page, "menuPage-menu0"); verify(menuItem0);
            var menuItem1 = findChild(page, "menuPage-menu1"); verify(menuItem1);
            var menuItem2 = findChild(page, "menuPage-menu2"); verify(menuItem2);
            verify(menuItem2.delegate.isSeparator);
            var menuItem3 = findChild(page, "menuPage-menu3"); verify(menuItem3);

            keyClick(Qt.Key_Up, Qt.NoModifier, 100);
            compare(listView.selectedItem, menuItem3);
            tryCompare(page, "openItem", menuItem3);

            // Skip separator

            keyClick(Qt.Key_Up, Qt.NoModifier, 100);
            compare(listView.selectedItem, menuItem1);
            tryCompare(page, "openItem", menuItem1);

            keyClick(Qt.Key_Up, Qt.NoModifier, 100);
            compare(listView.selectedItem, menuItem0);
            tryCompare(page, "openItem", menuItem0);

            keyClick(Qt.Key_Up, Qt.NoModifier, 100);
            compare(listView.selectedItem, menuItem3);
            tryCompare(page, "openItem", menuItem3);
        }

        function test_keyboardNavigation_RightKeyEntersSubMenu() {
            menuBackend.modelData = desktopMenuData.generateTestData(2, 2, 0);

            var menuItem = findChild(page, "menuPage-menu0");
            verify(menuItem);
            page.open(menuItem, true);
            compare(page.openItem, menuItem);

            var submenu = findChild(page, "menuPage-subMenu0");
            verify(submenu);
            var listView = findChild(page, "menuPage-subMenu0-ListView");
            verify(listView);
            menuItem = findChild(page, "menuPage-subMenu0-menu0");
            verify(menuItem);

            keyClick(Qt.Key_Right, Qt.NoModifier);
            compare(listView.selectedItem, menuItem);
        }

        function test_keyboardNavigation_LeftKeyClosesSubMenu() {
            menuBackend.modelData = desktopMenuData.generateTestData(2, 2, 0);

            var menuItem = findChild(page, "menuPage-menu0");
            verify(menuItem);
            page.open(menuItem, true, 0); // quick open & select item 0

            compare(page.openItem, menuItem);
            keyClick(Qt.Key_Left, Qt.NoModifier);
            compare(page.openItem, undefined);
        }

        function test_mnemonics() {
            var menuItem0 = findChild(page, "menuPage-menu0"); verify(menuItem0);

            keyClick(Qt.Key_A, Qt.NoModifier);
            tryCompare(page, "openItem", menuItem0);

            var submenu0 = findChild(menuItem0, "menuPage-subMenu0"); verify(submenu0);
            var submenu0_menuItem1 = findChild(submenu0, "menuPage-subMenu0-menu1"); verify(submenu0_menuItem1);

            keyClick(Qt.Key_B, Qt.NoModifier);
            tryCompare(submenu0, "openItem", submenu0_menuItem1);

            keyClick(Qt.Key_B, Qt.NoModifier);
            compare(activatedSpy.signalArguments, [{ "0": "menuA.B.B" }], "Activate should have been emmited once");
        }
    }
}
