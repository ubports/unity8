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
import ".."
import "../../../qml/Components"
import Ubuntu.Components 0.1
import Unity 0.2
import Unity.Test 0.1 as UT

Item {
    width: units.gu(110)
    height: units.gu(30)

    Scope {
        id: scopeMock
    }

    UT.UnityTestCase {
        name: "PageHeaderLabelTest"
        when: windowShown

        property alias searchEnabled : pageHeader.searchEntryEnabled
        property alias searchQuery : pageHeader.searchQuery

        function init() {
            searchEnabled = true;
        }

        function test_search_disabled() {
            searchEnabled = false
            pageHeader.resetSearch()

            pageHeader.triggerSearch()
            keyClick(Qt.Key_S)

            compare(searchQuery, "", "Search entry not disabled properly (could still type in textfield).")
        }

        function test_search_enable() {
            searchEnabled = true
            pageHeader.resetSearch()

            pageHeader.triggerSearch()
            typeString("test")

            compare(searchQuery, "test", "Typing in the search field did not change searchQuery")
        }

        function test_search_hard_coded() {
            searchEnabled = true
            pageHeader.triggerSearch()
            searchQuery = "test1"
            typeString("test2")
            compare(searchQuery, "test1test2", "Setting searchQuery text does not update the TextField")
        }

        function test_reset_search() {
            searchEnabled = true
            pageHeader.resetSearch()

            pageHeader.triggerSearch()
            keyClick(Qt.Key_S)

            compare(searchQuery, "s", "Could not type in TextField.")

            pageHeader.resetSearch()
            compare(searchQuery, "", "Reset search did not reset searchQuery correctly.")
        }

        function test_move_search_by_width()
        {
            searchEnabled = true
            pageHeader.resetSearch()

            var searchContainer = findChild(pageHeader, "searchContainer")

            parent.width = units.gu(40)

            verify(searchContainer !== undefined)
            verify(searchContainer.y <= 0)

            pageHeader.triggerSearch()
            verify(searchContainer.y >= 0)

            pageHeader.resetSearch()
            verify(searchContainer.y <= 0)

            parent.width = units.gu(110)
            verify(searchContainer.y >= 0)

            pageHeader.triggerSearch()
            tryCompare(searchContainer, "narrowMode", false)
            tryCompare(searchContainer, "state", "active")
            tryCompare(searchContainer, "width", units.gu(40))
        }

        function test_history() {
            pageHeader.searchHistory.clear()
            compare(pageHeader.searchHistory.count, 0)

            pageHeader.triggerSearch()
            typeString("humppa1")
            pageHeader.resetSearch()

            compare(pageHeader.searchHistory.count, 1)
            compare(pageHeader.searchHistory.get(0).query, "humppa1")

            pageHeader.triggerSearch()
            typeString("humppa2")
            pageHeader.resetSearch()

            compare(pageHeader.searchHistory.count, 2)
            compare(pageHeader.searchHistory.get(0).query, "humppa2")

            pageHeader.triggerSearch()
            typeString("humppa3")
            pageHeader.resetSearch()

            compare(pageHeader.searchHistory.count, 3)
            compare(pageHeader.searchHistory.get(0).query, "humppa3")

            pageHeader.triggerSearch()
            typeString("humppa4")
            pageHeader.resetSearch()

            compare(pageHeader.searchHistory.count, 3)
            compare(pageHeader.searchHistory.get(0).query, "humppa4")
        }

        function test_search_indicator() {
            var searchIndicator = findChild(pageHeader, "searchIndicator")
            var primaryImage = findChild(pageHeader, "primaryImage")

            pageHeader.triggerSearch()

            scopeMock.setSearchInProgress(false);
            compare(searchIndicator.running, false, "Search indicator is running.")
            tryCompare(primaryImage, "visible", true)

            scopeMock.setSearchInProgress(true);
            compare(searchIndicator.running, true, "Search indicator isn't running.")
            tryCompare(primaryImage, "visible", false)
        }

        function cleanup() {
            scopeMock.setSearchInProgress(false);
            pageHeader.resetSearch();
        }

        function test_popover() {
            searchEnabled = true;
            pageHeader.searchHistory.clear();

            pageHeader.searchHistory.addQuery("Search1");
            pageHeader.searchHistory.addQuery("Search2");

            pageHeader.triggerSearch();

            var searchContainer = findChild(pageHeader, "searchContainer");
            verify(searchContainer !== undefined, "searchContainer != undefined");
            tryCompareFunction(function() { return searchContainer.popover !== null; }, true);

            tryCompare(searchContainer.popover, "visible", true);
        }

        function test_resetSearch_onPopupClose() {
            searchEnabled = true;
            pageHeader.searchHistory.clear();

            pageHeader.searchHistory.addQuery("Search1");
            pageHeader.searchHistory.addQuery("Search2");

            pageHeader.triggerSearch();

            var searchContainer = findChild(pageHeader, "searchContainer");
            verify(searchContainer !== undefined, "searchContainer != undefined");
            tryCompareFunction(function() { return searchContainer.popover !== null; }, true);
            compare(searchContainer.popover.visible, true);

            pageHeader.searchQuery = "test";
            tryCompareFunction( function() { return (searchContainer.popover===null || !searchContainer.popover.visible) }, true);

            pageHeader.resetSearch();
            compare((searchContainer.popover===null || !searchContainer.popover.visible), true);
        }
    }

    Column {
        anchors.fill: parent
        spacing: units.gu(1)

        PageHeaderLabel {
            id: pageHeader
            anchors {
                left: parent.left
                right: parent.right
            }

            scope: scopeMock

            searchEntryEnabled: true
            searchHistory: SearchHistoryModel {}
            text: "%^$%^%^&%^&%^$%GHR%"
        }

        Row {
            spacing: units.gu(1)
            anchors {
                left: parent.left
                right: parent.right
            }
            Button {
                text: "Set search query programmatically"
                onClicked: pageHeader.searchQuery = "testsearch"
                width: units.gu(40)
            }
            Label {
                text: "searchQuery: \"" + pageHeader.searchQuery + "\""
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            spacing: units.gu(1)
            anchors {
                left: parent.left
                right: parent.right
            }
            Button {
                text: "Clear history model"
                onClicked: pageHeader.searchHistory.clear()
                width: units.gu(40)
            }
            Label {
                text: "History count: " + pageHeader.searchHistory.count
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
