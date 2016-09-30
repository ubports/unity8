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
    width:  units.gu(100)
    height:  units.gu(50)

    Component.onCompleted: {
        QuickUtils.keyboardAttached = true;
        theme.name = "Ubuntu.Components.Themes.SuruDark"
    }

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    DesktopMenuData { id: desktopMenuData }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: units.gu(1)
        }
        height: units.gu(3)
        color: "grey"

        MenuBarLoader {
            id: menuBar
            anchors.fill: parent

            unityMenuModel: UnityMenuModel {
                id: menuBackend
                modelData: desktopMenuData.testData
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
            menuBar.closePopup();
            menuBackend.modelData = desktopMenuData.generateTestData(3, 2, 0);
            activatedSpy.clear();
        }

        function test_mnemonics_data() {
            return [
                { tag: "a" },
                { tag: "b" },
            ]
        }

        function test_mnemonics(data) {
            menuBackend.modelData = desktopMenuData.generateTestData(3, 2, 0);

            keyPress(data.tag, Qt.AltModifier, 100);
            tryCompareFunction(function() { return menuBar.openItem !== undefined; }, true);
        }

        function test_navigateRight(data) {
            var menuItem0 = findChild(menuBar, "menuBar-menu0"); verify(menuItem0);
            var menuItem1 = findChild(menuBar, "menuBar-menu1"); verify(menuItem1);
            var menuItem2 = findChild(menuBar, "menuBar-menu2"); verify(menuItem2);

            menuBar.open(menuItem0, true);
            compare(menuBar.openItem, menuItem0);

            keyClick(Qt.Key_Right, Qt.NoModifier);
            compare(menuBar.openItem, menuItem1);

            keyClick(Qt.Key_Right, Qt.NoModifier);
            compare(menuBar.openItem, menuItem2);

            keyClick(Qt.Key_Right, Qt.NoModifier);
            compare(menuBar.openItem, menuItem0);
        }

        function test_navigateLeft(data) {
            var menuItem0 = findChild(menuBar, "menuBar-menu0"); verify(menuItem0);
            var menuItem1 = findChild(menuBar, "menuBar-menu1"); verify(menuItem1);
            var menuItem2 = findChild(menuBar, "menuBar-menu2"); verify(menuItem2);

            menuBar.open(menuItem0, true);
            compare(menuBar.openItem, menuItem0);

            keyClick(Qt.Key_Left, Qt.NoModifier);
            compare(menuBar.openItem, menuItem2);

            keyClick(Qt.Key_Left, Qt.NoModifier);
            compare(menuBar.openItem, menuItem1);

            keyClick(Qt.Key_Left, Qt.NoModifier);
            compare(menuBar.openItem, menuItem0);
        }
    }
}
