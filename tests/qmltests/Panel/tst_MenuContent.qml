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
import ".."
import "../../../Panel"
import Ubuntu.ChewieUI 0.1 as ChewieUI

Item {
    id: shell
    width: units.gu(40)
    height: units.gu(70)

    property var indicator_status: {
        'menu_plugin1': { 'started': false, 'reset': 0 },
        'menu_plugin2': { 'started': false, 'reset': 0 },
        'menu_plugin3': { 'started': false, 'reset': 0 },
        'menu_plugin4': { 'started': false, 'reset': 0 },
        'menu_plugin5': { 'started': false, 'reset': 0 }
    }

    // Dummy objects
    Item { id: greeter }
    Item { id: handle }


    ChewieUI.PluginModel {
        id: indicatorsModel
    }

    MenuContent {
        id: menuContent
        indicatorsModel: indicatorsModel
        contentReleaseInterval: 50

        height: parent.height - 50
    }

    Item {
        id: click_me

        height: 50
        anchors {
            top: menuContent.bottom
            left: parent.left
            right: parent.right
        }

        Rectangle {
            color: "#999999"

            anchors {
                top: parent.top
                left: parent.left
                right: parent.horizontalCenter
                bottom: parent.bottom
            }

            Text {
                text: "Devices"
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: menuContent.showOverview()
            }
        }

        Rectangle {
            color: "#bbbbbb"

            anchors {
                top: parent.top
                left: parent.horizontalCenter
                right: parent.right
                bottom: parent.bottom
            }

            Text {
                text: "Next Indicator"
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: activate_next_content()
            }
        }
    }

    function activate_next_content()
    {
        if (menuContent.currentIndex == -1)
            activate_content(0);
        else
            activate_content((menuContent.currentIndex + 1) % indicatorsModel.count)
    }

    function activate_content(index)
    {
        menuContent.currentIndex = index
        menuContent.showMenu();
    }

    function get_test_menu_objecName(index) {
        return "menu_plugin"+(index+1);
    }

    property string test_menu_objectName : ""
    function current_menu_equals_test_menu() {
        var current_loader = menu_content_test.findChild(menuContent, "menus").currentItem
        if (current_loader == undefined) {
            console.log("current_loader undefined");
            return false;
        }

        var menu = menu_content_test.findChild(menuContent, test_menu_objectName);
        if (menu == undefined) {
            console.log("test_menu undefined");
            return false;
        }

        // The parent of the menu will be the loader
        return menu.parent == current_loader;
    }

    UT.UnityTestCase {
        id: menu_content_test
        name: "MenuContentTest"
        when: windowShown

        function init() {
            menuContent.hideAll();
            if (menuContent.__contentActive)
                menuContent.releaseContent();
            tryCompare(menuContent, "__contentActive", false);
        }

        // Check that the correct menus are displayed for the requested item.
        function test_show_menu() {
            var menu_count = indicatorsModel.count;
            verify(menu_count > 0, "Menu count should be greater than zero");

            var menus = menu_content_test.findChild(menuContent, "menus")

            // Loop over twice to test jump between last and first.
            for (var i = 0; i < menu_count*2; i++) {

                var menu_index = i%menu_count;

                activate_content(menu_index);
                test_menu_objectName = get_test_menu_objecName(menu_index);
                compare(menus.currentIndex, menu_index, "Current menu index does not match selected menu index");
                tryCompareFunction(current_menu_equals_test_menu, true);
            }
            // overview should not be visible.
            tryCompare(findChild(menuContent, "overview"), "visible", false);
        }

        function test_show_overview() {
            menuContent.showOverview();

            var overview = findChild(menuContent, "overview");
            tryCompare(overview, "visible", true);
            tryCompare(overview, "enabled", true);
            tryCompare(overview, "opacity", 1.0);

            // menus should not be enabled.
            tryCompare(findChild(menuContent, "menus"), "opacity", 0);
            tryCompare(findChild(menuContent, "menus"), "enabled", false);
        }

        function test_overview_menuSelected_signal() {
            menuContent.showOverview();

            var overview = findChild(menuContent, "overview");
            var menus = menu_content_test.findChild(menuContent, "menus")

            var menu_count = indicatorsModel.count;
            verify(menu_count > 0, "Menu count should be greater than zero");
            for (var i = 0; i < menu_count; i++) {
                // manually emit signal from overview.
                // we dont want to go with mouse events here, otherwise we're testing the overview and not the signal.
                overview.menuSelected(i);

                test_menu_objectName = get_test_menu_objecName(i);
                compare(menus.currentIndex, i, "Current menu index does not match selected menu index");
                tryCompareFunction(current_menu_equals_test_menu, true);
            }
        }

        // Calling activateContent should call start on all menus
        function test_activate_content() {
            var menu_count = indicatorsModel.count;
            verify(menu_count > 0, "Menu count should be greater than zero");

            // Ensure all the menus are stopped first
            menuContent.__contentActive = false;
            for (var i = 0; i < menu_count; i++) {
                tryCompare(indicator_status[get_test_menu_objecName(i)], "started", false);
            }

            // activate content the content to call stop.
            menuContent.activateContent();
            for (var i = 0; i < menu_count; i++) {
                tryCompare(indicator_status[get_test_menu_objecName(i)], "started", true);
            }
        }

        // Calling activateContent should call stop on all menus.
        function test_release_content() {
            var menu_count = indicatorsModel.count;
            verify(menu_count > 0, "Menu count should be greater than zero");

            // Ensure all the menus are started first
            menuContent.__contentActive = true;
            for (var i = 0; i < menu_count; i++) {
                tryCompare(indicator_status[get_test_menu_objecName(i)], "started", true);
            }
            // release the content to call stop.
            menuContent.releaseContent();
            for (var i = 0; i < menu_count; i++) {
                tryCompare(indicator_status[get_test_menu_objecName(i)], "started", false);
            }
        }

        // Header title should be the same as the item
        function test_menu_header() {
            var menu_count = indicatorsModel.count;
            verify(menu_count > 0, "Menu count should be greater than zero");

            var header = findChild(menuContent, "header")

            for (var i = 0; i < menu_count; i++) {
                activate_content(i);

                var menu_title = indicatorsModel.get(i).title;
                compare(header.title, menu_title, "Header doesnt match menu title for menu " + i);
            }
        }

        // Tests QTBUG-30632 - asynchronous loader crashes when changing index quickly.
        function test_multi_activate() {
            var menu_count = indicatorsModel.count;
            verify(menu_count > 0, "Menu count should be greater than zero");

            for (var i = 0; i < 100; i++) {
                activate_content(i % menu_count);
                compare(menuContent.currentIndex, i%menu_count);
            }
            wait(100);
        }
    }
}
