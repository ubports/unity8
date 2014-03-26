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
import "../../../qml/Panel"
import Unity.Indicators 0.1 as Indicators

Item {
    id: shell
    width: units.gu(40)
    height: units.gu(70)

    property var indicator_status: {
        'indicator-fake1-page': { 'started': false, 'reset': 0 },
        'indicator-fake2-page': { 'started': false, 'reset': 0 },
        'indicator-fake3-page': { 'started': false, 'reset': 0 },
        'indicator-fake4-page': { 'started': false, 'reset': 0 },
        'indicator-fake5-page': { 'started': false, 'reset': 0 }
    }

    // Dummy objects
    Item { id: greeter }
    Item { id: handle }


    Indicators.IndicatorsModel {
        id: indicatorsModel
        Component.onCompleted: load("test1")
    }

    MenuContent {
        id: menuContent
        indicatorsModel: indicatorsModel
        contentReleaseInterval: 50
        height: parent.height - 50
    }

    Rectangle {
        color: "#bbbbbb"

        height: 50
        anchors {
            top: menuContent.bottom
            left: parent.left
            right: parent.right
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

    function activate_next_content()
    {
        if (menuContent.currentMenuIndex == -1)
            activate_content(0);
        else
            activate_content((menuContent.currentMenuIndex + 1) % indicatorsModel.count)
    }

    function activate_content(index)
    {
        menuContent.setCurrentMenuIndex(index)
    }

    function get_test_menu_objecName(index) {
        return "indicator-fake" + (index + 1) + "-page";
    }

    property string testTabObjectName : ""

    function selected_tab_equals_test_tab() {
        var currentTab = menu_content_test.findChild(menuContent, "tabs").selectedTab
        if (currentTab === null) {
            console.log("selected tab undefined");
            return false;
        }

        var testTab = menu_content_test.findChild(menuContent, testTabObjectName);
        if (testTab === null) {
            console.log("test_tab " + testTabObjectName + " undefined");
            return false;
        }

        return testTab == currentTab;
    }

    UT.UnityTestCase {
        id: menu_content_test
        name: "MenuContentTest"
        when: windowShown

        function init() {
            if (menuContent.__contentActive)
                menuContent.releaseContent();
            tryCompare(menuContent, "__contentActive", false);
        }

        // Check that the correct menus are displayed for the requested item.
        function test_show_menu() {
            var menuCount = indicatorsModel.count;
            verify(menuCount > 0, "Menu count should be greater than zero");

            var tabs = menu_content_test.findChild(menuContent, "tabs")

            // Loop over twice to test jump between last and first.
            for (var i = 0; i < menuCount*2; i++) {

                var menuIndex = i%menuCount;

                activate_content(menuIndex);
                testTabObjectName = indicatorsModel.data(menuIndex, Indicators.IndicatorsModelRole.Identifier);
                compare(tabs.selectedTabIndex, menuIndex, "Current tab index does not match selected tab index");
                tryCompareFunction(selected_tab_equals_test_tab, true);
            }
        }

        // Calling activateContent should call start on all menus
        function test_activate_content() {
            var menuCount = indicatorsModel.count;
            verify(menuCount > 0, "Menu count should be greater than zero");

            // Ensure all the menus are stopped first
            menuContent.__contentActive = false;
            for (var i = 0; i < menuCount; i++) {
                tryCompare(indicator_status[get_test_menu_objecName(i)], "started", false);
            }

            // activate content the content to call stop.
            menuContent.activateContent();
            for (var i = 0; i < menuCount; i++) {
                tryCompare(indicator_status[get_test_menu_objecName(i)], "started", true);
            }
        }

        // Calling activateContent should call stop on all menus.
        function test_release_content() {
            var menuCount = indicatorsModel.count;
            verify(menuCount > 0, "Menu count should be greater than zero");

            // Ensure all the menus are started first
            menuContent.__contentActive = true;
            for (var i = 0; i < menuCount; i++) {
                tryCompare(indicator_status[get_test_menu_objecName(i)], "started", true);
            }
            // release the content to call stop.
            menuContent.releaseContent();
            for (var i = 0; i < menuCount; i++) {
                tryCompare(indicator_status[get_test_menu_objecName(i)], "started", false);
            }
        }

        // Tests QTBUG-30632 - asynchronous loader crashes when changing index quickly.
        function test_multi_activate() {
            var menuCount = indicatorsModel.count;
            verify(menuCount > 0, "Menu count should be greater than zero");

            for (var i = 0; i < 100; i++) {
                activate_content(i % menuCount);
                compare(menuContent.currentMenuIndex, i%menuCount);
            }
            wait(100);
        }
    }
}
