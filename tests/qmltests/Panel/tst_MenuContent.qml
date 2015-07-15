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
import Unity.Test 0.1 as UT
import "../../../qml/Panel"
import Unity.Indicators 0.1 as Indicators

IndicatorTest {
    id: root
    width: units.gu(40)
    height: units.gu(70)

    // Dummy objects
    Item { id: greeter }
    Item { id: handle }

    MenuContent {
        id: menuContent
        indicatorsModel: root.indicatorsModel
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
            activate_content((menuContent.currentMenuIndex + 1) % root.originalModelData.length)
    }

    function activate_content(index)
    {
        menuContent.currentMenuIndex = index;
    }

    function get_test_menu_objecName(index) {
        return "indicator-fake" + (index + 1) + "-page";
    }

    property string testItemObjectName : ""

    function current_item_equals_test_item() {
        var currentItem = menu_content_test.findChild(menuContent, "indicatorsContentListView").currentItem
        if (currentItem === null) {
            console.log("current item undefined");
            return false;
        }

        var testItem = menu_content_test.findChild(menuContent, testItemObjectName);
        if (testItem === null) {
            console.log("testItem " + testItemObjectName + " undefined");
            return false;
        }

        return testItem === currentItem;
    }

    UT.UnityTestCase {
        id: menu_content_test
        name: "MenuContentTest"
        when: windowShown

        // Check that the correct menus are displayed for the requested item.
        function test_show_menu() {
            var menuCount = root.originalModelData.length;
            verify(menuCount > 0, "Menu count should be greater than zero");

            var listView = menu_content_test.findChild(menuContent, "indicatorsContentListView")
            verify(listView !== null)

            // Loop over twice to test jump between last and first.
            for (var i = 0; i < menuCount*2; i++) {
                var menuIndex = i%menuCount;

                activate_content(menuIndex);
                testItemObjectName = indicatorsModel.data(menuIndex, Indicators.IndicatorsModelRole.Identifier);
                compare(listView.currentIndex, menuIndex, "Current tab index does not match selected tab index");
                tryCompareFunction(current_item_equals_test_item, true);
            }
        }

        // Tests QTBUG-30632 - asynchronous loader crashes when changing index quickly.
        function test_multi_activate() {
            var menuCount = root.originalModelData.length;
            verify(menuCount > 0, "Menu count should be greater than zero");

            for (var i = 0; i < 100; i++) {
                activate_content(i % menuCount);
                compare(menuContent.currentMenuIndex, i%menuCount);
            }
        }
    }
}
