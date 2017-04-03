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
    width:  units.gu(120)
    height:  units.gu(70)

    Component.onCompleted: {
        QuickUtils.keyboardAttached = true;
        theme.name = "Ubuntu.Components.Themes.SuruDark"
    }

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    SurfaceManager { id: sMgr }
    ApplicationMenuDataLoader {
        id: appMenuData
        surfaceManager: sMgr
    }

    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            margins: units.gu(1)
        }
        height: units.gu(3)
        width: parent.width * 2/3
        color: theme.palette.normal.background

        MenuBar {
            id: menuBar
            anchors.fill: parent
            enableKeyFilter: true

            unityMenuModel: UnityMenuModel {
                id: menuBackend
                modelData: appMenuData.generateTestData(10,5,2,3)
            }
        }
    }

    SignalSpy {
        id: activatedSpy
        target: menuBackend
        signalName: "activated"
    }

    SignalSpy {
        id: aboutToShowCalledSpy
        target: menuBackend
        signalName: "aboutToShowCalled"
    }

    UnityTestCase {
        id: testCase
        name: "MenuBar"
        when: windowShown

        function init() {
            menuBar.dismiss();
            menuBackend.modelData = appMenuData.generateTestData(5,5,2,3, "menu")
            activatedSpy.clear();
            waitForRendering(menuBar);
        }

        function test_mouseNavigation() {
            menuBackend.modelData = appMenuData.generateTestData(3,3,0,0, "menu");
            wait(50) // wait for row to build
            var priv = findInvisibleChild(menuBar, "d");

            var menuItem0 = findChild(menuBar, "menuBar-item0"); verify(menuItem0);
            var menuItem1 = findChild(menuBar, "menuBar-item1"); verify(menuItem1);
            var menuItem2 = findChild(menuBar, "menuBar-item2"); verify(menuItem2);

            menuItem0.show();
            mouseMove(menuItem0, menuItem0.width/2, menuItem0.height/2);
            compare(priv.currentItem, menuItem0, "CurrentItem should be set to item 0");
            compare(priv.currentItem.popupVisible, true, "Popup should be visible");

            mouseMove(menuItem1, menuItem1.width/2, menuItem1.height/2);
            tryCompare(priv, "currentItem", menuItem1, undefined, "CurrentItem should have moved to item 1");
            compare(menuItem1.popupVisible, true, "Popup should be visible");

            mouseMove(menuItem2, menuItem2.width/2, menuItem2.height/2);
            tryCompare(priv, "currentItem", menuItem2, undefined, "CurrentItem should have moved to item 2");
            compare(menuItem2.popupVisible, true, "Popup should be visible");

            mouseMove(menuItem0, menuItem0.width/2, menuItem0.height/2);
            tryCompare(priv, "currentItem", menuItem0, undefined, "CurrentItem should have moved to item 0");
            compare(menuItem0.popupVisible, true, "Popup should be visible");
        }

        function test_aboutToShow() {
            menuBackend.modelData = appMenuData.generateTestData(3,3,0,0, "menu");
            wait(50) // wait for row to build
            var priv = findInvisibleChild(menuBar, "d");

            var menuItem0 = findChild(menuBar, "menuBar-item0");
            var menuItem1 = findChild(menuBar, "menuBar-item1");

            aboutToShowCalledSpy.clear();
            menuItem0.show();
            compare(aboutToShowCalledSpy.count, 1);

            menuItem0.show();
            // It's already shown so nothing happens
            compare(aboutToShowCalledSpy.count, 1);

            menuItem0.hide();
            menuItem0.show();
            compare(aboutToShowCalledSpy.count, 2);

            menuItem0.dismiss();
            menuItem0.show();
            compare(aboutToShowCalledSpy.count, 3);

            menuItem1.show();
            compare(aboutToShowCalledSpy.count, 4);

            menuItem0.show();
            compare(aboutToShowCalledSpy.count, 5);

            compare(aboutToShowCalledSpy.signalArguments[0][0], 0);
            compare(aboutToShowCalledSpy.signalArguments[1][0], 0);
            compare(aboutToShowCalledSpy.signalArguments[2][0], 0);
            compare(aboutToShowCalledSpy.signalArguments[3][0], 1);
            compare(aboutToShowCalledSpy.signalArguments[4][0], 0);
        }

        function test_keyboardNavigation_RightKeySelectsNextMenuItem(data) {
            menuBackend.modelData = appMenuData.generateTestData(3,3,0,0, "menu");
            var priv = findInvisibleChild(menuBar, "d");

            var menuItem0 = findChild(menuBar, "menuBar-item0"); verify(menuItem0);
            var menuItem1 = findChild(menuBar, "menuBar-item1"); verify(menuItem1);
            var menuItem2 = findChild(menuBar, "menuBar-item2"); verify(menuItem2);

            menuItem0.show();
            compare(priv.currentItem, menuItem0, "CurrentItem should be set to item 0");
            compare(priv.currentItem.popupVisible, true, "Popup should be visible");

            keyClick(Qt.Key_Right, Qt.NoModifier);
            compare(priv.currentItem, menuItem1, "CurrentItem should have moved to item 1");
            compare(menuItem1.popupVisible, true, "Popup should be visible");

            keyClick(Qt.Key_Right, Qt.NoModifier);
            compare(priv.currentItem, menuItem2, "CurrentItem should have moved to item 2");
            compare(menuItem2.popupVisible, true, "Popup should be visible");

            keyClick(Qt.Key_Right, Qt.NoModifier);
            compare(priv.currentItem, menuItem0, "CurrentItem should have moved back to item 0");
            compare(menuItem0.popupVisible, true, "Popup should be visible");
        }

        function test_keyboardNavigation_LeftKeySelectsPreviousMenuItem(data) {
            menuBackend.modelData = appMenuData.generateTestData(3,3,0,0, "menu");
            var priv = findInvisibleChild(menuBar, "d");

            var menuItem0 = findChild(menuBar, "menuBar-item0"); verify(menuItem0);
            var menuItem1 = findChild(menuBar, "menuBar-item1"); verify(menuItem1);
            var menuItem2 = findChild(menuBar, "menuBar-item2"); verify(menuItem2);

            menuItem0.show();
            compare(priv.currentItem, menuItem0, "CurrentItem should be set to item 0");
            compare(priv.currentItem.popupVisible, true, "Popup should be visible");

            keyClick(Qt.Key_Left, Qt.NoModifier);
            compare(priv.currentItem, menuItem2, "CurrentItem should have moved to item 2");
            compare(menuItem2.popupVisible, true, "Popup should be visible");

            keyClick(Qt.Key_Left, Qt.NoModifier);
            compare(priv.currentItem, menuItem1, "CurrentItem should have moved to item 1");
            compare(menuItem1.popupVisible, true, "Popup should be visible");

            keyClick(Qt.Key_Left, Qt.NoModifier);
            compare(priv.currentItem, menuItem0, "CurrentItem should have moved back to item 0");
            compare(menuItem0.popupVisible, true, "Popup should be visible");
        }

        function test_mnemonics_data() {
            return [
                { tag: "a", expectedItem: "menuBar-item0" },
                { tag: "c", expectedItem: "menuBar-item2" },
            ]
        }

        function test_mnemonics(data) {
            menuBackend.modelData = appMenuData.generateTestData(3,3,0,0,"menu");
            var priv = findInvisibleChild(menuBar, "d");

            var menuItem = findChild(menuBar, data.expectedItem); verify(menuItem);

            keyPress(data.tag, Qt.AltModifier, 100);
            tryCompare(priv, "currentItem", menuItem);
            keyRelease(data.tag, Qt.AltModifier, 100);
        }

        function test_disabledTopLevel() {
            var modelData = appMenuData.generateTestData(3,3,0,0,"menu");
            modelData[1].rowData.sensitive = false;
            menuBackend.modelData = modelData;

            var priv = findInvisibleChild(menuBar, "d");

            var menuItem0 = findChild(menuBar, "menuBar-item0"); verify(menuItem0);
            var menuItem2 = findChild(menuBar, "menuBar-item2"); verify(menuItem2);

            menuItem0.show();
            compare(menuItem0.popupVisible, true, "Popup should be visible");

            keyClick(Qt.Key_Right);
            compare(priv.currentItem, menuItem2);
            compare(menuItem2.popupVisible, true);
            compare(menuItem0.popupVisible, false);

            keyClick(Qt.Key_Left);
            compare(priv.currentItem, menuItem0);
            compare(menuItem2.popupVisible, false);
            compare(menuItem0.popupVisible, true);
        }

        function test_menuActivateClosesMenu() {
            menuBackend.modelData = appMenuData.generateTestData(3,3,0,0,"menu");
            var priv = findInvisibleChild(menuBar, "d");

            var menuItem = findChild(menuBar, "menuBar-item0");
            menuItem.show();
            compare(priv.currentItem, menuItem, "CurrentItem should be set to item 0");
            compare(priv.currentItem.popupVisible, true, "Popup should be visible");

            var actionItem = findChild(menuBar, "menuBar-item0-menu-item0-actionItem");
            mouseClick(actionItem);
            compare(priv.currentItem, null, "CurrentItem should be null");
        }

        function test_subMenuActivateClosesMenu() {
            menuBackend.modelData = appMenuData.generateTestData(3,4,1,0,"menu");
            var priv = findInvisibleChild(menuBar, "d");

            var menuItem = findChild(menuBar, "menuBar-item0");
            menuItem.show();
            compare(priv.currentItem, menuItem, "CurrentItem should be set to item 0");
            compare(priv.currentItem.popupVisible, true, "Popup should be visible");

            var actionItem = findChild(menuBar, "menuBar-item0-menu-item0-actionItem");
            mouseClick(actionItem);

            actionItem = findChild(menuBar, "menuBar-item0-menu-item0-menu-item0-actionItem");
            mouseClick(actionItem);

            actionItem = findChild(menuBar, "menuBar-item0-menu-item0-menu-item0-menu-item0-actionItem");
            mouseClick(actionItem);

            compare(priv.currentItem, null, "CurrentItem should be null");
        }

        function test_openAppMenuShortcut() {
            var priv = findInvisibleChild(menuBar, "d");

            var menuItem0 = findChild(menuBar, "menuBar-item0"); verify(menuItem0);
            menuItem0.enabled = false;

            var menuItem1 = findChild(menuBar, "menuBar-item1"); verify(menuItem1);
            verify(priv.currentItem === null);

            keyClick(Qt.Key_F10, Qt.AltModifier);
            compare(priv.currentItem, menuItem1, "First enabled item should be opened");
        }

        function test_clickOpenMenuClosesMenu() {
            menuBackend.modelData = appMenuData.generateTestData(3,3,0,0,"menu");
            var priv = findInvisibleChild(menuBar, "d");

            var menuItem = findChild(menuBar, "menuBar-item0");
            waitForRendering(menuItem);
            mouseClick(menuItem);
            compare(priv.currentItem, menuItem, "CurrentItem should be set to item 0");
            compare(priv.currentItem.popupVisible, true, "Popup should be visible");

            waitForRendering(menuItem);
            mouseClick(menuItem);
            compare(priv.currentItem, null, "CurrentItem should be null");
        }

        function test_overfow() {
            menuBackend.modelData = appMenuData.generateTestData(5,2,0,0,"menu");

            var overflow = findChild(menuBar, "overflow");
            compare(overflow.visible, false, "Overflow should not be visible");

            var menu = { "rowData": { "label": "Short" } };
            tryCompareFunction(function() {
                menuBackend.insertRow(0, menu);
                wait(1);
                if (overflow.visible) {
                    return true;
                }
                return false;
            }, true);

            mouseClick(overflow);
            verify(overflow.__popup);
            var menuItem = findChild(menuBar, "overflow-menu-item0-actionItem");
            waitForRendering(menuItem);
            mouseClick(menuItem);

            verify(findChild(menuBar, "overflow-menu-item0-menu-item0-actionItem"));

            tryCompareFunction(function() {
                menuBackend.removeRow(0);
                wait(1);
                if (!overflow.visible) {
                    return true;
                }
                return false;
            }, true);
        }

        function test_stray_submenus() {
            menuBackend.modelData = appMenuData.generateTestData(3,4,1,0,"menu");
            var priv = findInvisibleChild(menuBar, "d");

            var menuItem = findChild(menuBar, "menuBar-item0");
            menuItem.show();
            compare(priv.currentItem, menuItem, "CurrentItem should be set to item 0");
            compare(priv.currentItem.popupVisible, true, "Popup should be visible");

            var actionItem = findChild(menuBar, "menuBar-item0-menu-item0-actionItem");
            mouseClick(actionItem);

            actionItem = findChild(menuBar, "menuBar-item0-menu-item0-menu-item0-actionItem");
            mouseClick(actionItem);

            actionItem = findChild(menuBar, "menuBar-item0-menu-item0-menu-item0-menu-item0-actionItem");

            // There's one popup
            tryCompareFunction(function() { return findChildsByType(root, "MenuPopup").length; }, 3);

            menuBackend.modelData = null;

            tryCompareFunction(function() { return findChildsByType(root, "MenuPopup").length; }, 0);
        }

        function test_firstDisabled() {
            var data = appMenuData.generateTestData(10,5,2,3);
            data[0].submenu[1].submenu[0].rowData.sensitive = false;
            menuBackend.modelData = data;

            var menuItem = findChild(menuBar, "menuBar-item0");
            menuItem.show();

            // waits for item to be created so the keyclick actually works
            findChild(menuBar, "menuBar-item0-menu-item1-actionItem");

            keyClick(Qt.Key_Down);
            keyClick(Qt.Key_Down);
            keyClick(Qt.Key_Right);

            var submenu = findChild(menuBar, "menuBar-item0-menu-item1-menu");
            var priv = findInvisibleChild(submenu, "d");
            var subActionItem1 = findChild(submenu, "menuBar-item0-menu-item1-menu-item1-actionItem");
            compare(priv.currentItem.item, subActionItem1);

            keyClick(Qt.Key_Down);
            var subActionItem3 = findChild(submenu, "menuBar-item0-menu-item1-menu-item3-actionItem");
            compare(priv.currentItem.item, subActionItem3);

            // now move mouse over to a different item and back to exercise a different codepath
            var actionItem0 = findChild(menuBar, "menuBar-item0-menu-item0-actionItem");
            mouseMove(actionItem0, actionItem0.width/2, actionItem0.height/2);

            var actionItem1 = findChild(menuBar, "menuBar-item0-menu-item1-actionItem");
            mouseMove(actionItem1, actionItem1.width/2, actionItem1.height/2);

            tryCompareFunction(function() { return priv.currentItem.item == subActionItem1; }, true);
        }
    }
}
