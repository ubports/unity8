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
import "../../../Components"
import Ubuntu.Components 0.1
import Unity 0.1
import Unity.Test 0.1 as UT

Item {
    width: units.gu(110)
    height: units.gu(30)

    Scope {
        id: scopeMock
    }

    UT.UnityTestCase {
        name: "PageHeaderTest"
        when: windowShown

        property alias searchEnabled : pageHeader.searchEntryEnabled
        property alias searchQuery : pageHeader.searchQuery

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
            pageHeader.triggerSearch()
            typeString("test")
            tryCompare(pageHeader, "searchInProgress", true)
            pageHeader.resetSearch()
        }
    }

    Column {
        anchors.fill: parent
        spacing: units.gu(1)

        PageHeader {
            id: pageHeader
            anchors {
                left: parent.left
                right: parent.right
            }

            scope: scopeMock

            searchEntryEnabled: true
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
