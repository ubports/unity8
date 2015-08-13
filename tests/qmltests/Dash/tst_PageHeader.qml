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
import "../../../qml/Dash"
import Ubuntu.Components 0.1
import Unity 0.2
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(110)
    height: units.gu(30)

    UT.UnityTestCase {
        name: "PageHeaderLabelTest"
        when: windowShown

        property alias searchEnabled : pageHeader.searchEntryEnabled
        property alias searchQuery : pageHeader.searchQuery
        property var headerContainer: findChild(pageHeader, "headerContainer")

        function doTypeString(text) {
            tryCompare(headerContainer, "contentY", 0);
            typeString(text);
        }

        function doResetSearch() {
            pageHeader.resetSearch();
            tryCompare(headerContainer, "contentY", headerContainer.height);
        }

        function init() {
            searchEnabled = true;

            // Reset to initial state
            pageHeader.searchQuery = "";
            pageHeader.closePopup();
            pageHeader.searchHistory.clear();

            // Check initial state
            tryCompareFunction(function() { return headerContainer.popover === null; }, true);
            compare(pageHeader.searchHistory.count, 0);
        }

        function test_search_disabled() {
            searchEnabled = false
            doResetSearch();

            pageHeader.triggerSearch()
            keyClick(Qt.Key_S)

            compare(searchQuery, "", "Search entry not disabled properly (could still type in textfield).")
        }

        function test_search_enable() {
            searchEnabled = true
            doResetSearch();

            pageHeader.triggerSearch()
            doTypeString("test")

            compare(searchQuery, "test", "Typing in the search field did not change searchQuery")
        }

        function test_search_hard_coded() {
            searchEnabled = true
            pageHeader.triggerSearch()
            searchQuery = "test1"
            doTypeString("test2")
            compare(searchQuery, "test1test2", "Setting searchQuery text does not update the TextField")
        }

        function test_reset_search() {
            searchEnabled = true
            doResetSearch();

            pageHeader.triggerSearch()
            keyClick(Qt.Key_S)

            compare(searchQuery, "s", "Could not type in TextField.")

            doResetSearch();
            compare(searchQuery, "", "Reset search did not reset searchQuery correctly.")
        }

        function test_history() {
            pageHeader.triggerSearch()
            doTypeString("humppa1")
            doResetSearch();

            tryCompare(pageHeader.searchHistory, "count", 1)
            compare(pageHeader.searchHistory.get(0).query, "humppa1")

            pageHeader.triggerSearch()
            doTypeString("humppa2")
            doResetSearch();

            compare(pageHeader.searchHistory.count, 2)
            compare(pageHeader.searchHistory.get(0).query, "humppa2")

            pageHeader.triggerSearch()
            doTypeString("humppa3")
            doResetSearch();

            compare(pageHeader.searchHistory.count, 3)
            compare(pageHeader.searchHistory.get(0).query, "humppa3")

            pageHeader.triggerSearch()
            doTypeString("humppa4")
            doResetSearch();

            compare(pageHeader.searchHistory.count, 3)
            compare(pageHeader.searchHistory.get(0).query, "humppa4")
        }

        function test_titleImage() {

            var titleImage = findChild(pageHeader, "titleImage");
            verify(titleImage == null);

            showImageCheckBox.checked = true;

            titleImage = findChild(pageHeader, "titleImage");
            verify(titleImage !== null);
            compare(titleImage.source, pageHeader.titleImageSource);

        }

        function cleanup() {
            doResetSearch();
        }

        function test_popover() {
            searchEnabled = true;
            pageHeader.searchHistory.clear();

            pageHeader.searchHistory.addQuery("Search1");
            pageHeader.searchHistory.addQuery("Search2");

            pageHeader.triggerSearch();

            var headerContainer = findChild(pageHeader, "headerContainer");
            verify(headerContainer !== null, "headerContainer != null");
            tryCompareFunction(function() { return headerContainer.popover !== null; }, true);

            tryCompare(headerContainer.popover, "visible", true);

            var searchTextField = findChild(pageHeader, "searchTextField");
            compare(searchTextField.focus, true);

            var recentSearches = findChild(headerContainer.popover, "recentSearches");
            verify(recentSearches, "Could not find recent searches in the popover");
            waitForRendering(recentSearches);
            mouseClick(recentSearches.itemAt(0));

            compare(pageHeader.searchQuery, "Search2");
            tryCompareFunction(function() { return headerContainer.popover === null; }, true);
            compare(searchTextField.focus, false);
        }

        function test_popup_closing_data() {
            return [
                        { tag: "with search text", searchText: "foobar", hideSearch: false },
                        { tag: "without search text", searchText: "", hideSearch: true }
                    ];
        }

        function test_pagination() {
            var paginationRepeater = findChild(pageHeader, "paginationRepeater");
            tryCompare(paginationRepeater, "count", 0);
            pageHeader.paginationCount = 5;
            tryCompare(paginationRepeater, "count", 5);
            for (var i=0; i<pageHeader.paginationCount; i++) {
                pageHeader.paginationIndex = i;
                for (var j=0; j<paginationRepeater.count; j++) {
                    var paginationDot = findChild(pageHeader, "paginationDots_"+j);
                    if (i==j) {
                        compare(paginationDot.source.toString().indexOf("pagination_dot_on") > -1, true);
                    } else {
                        compare(paginationDot.source.toString().indexOf("pagination_dot_off") > -1, true);
                    }
                }
            }
            pageHeader.paginationIndex = -1;
            pageHeader.paginationCount = 0;
            tryCompare(paginationRepeater, "count", 0);
        }

        function test_popup_closing(data) {
            searchEnabled = true;
            pageHeader.searchHistory.clear();

            pageHeader.searchHistory.addQuery("Search1");
            pageHeader.searchHistory.addQuery("Search2");

            pageHeader.triggerSearch();

            var headerContainer = findChild(pageHeader, "headerContainer");
            verify(headerContainer !== null, "headerContainer != null");
            tryCompareFunction(function() { return headerContainer.popover !== null; }, true);
            compare(headerContainer.popover.visible, true);

            pageHeader.searchQuery = data.searchText;

            if (data.searchText == "") {
                // When the text is empty the user can also close the
                // popup by clicking outside the header instead of by starting a search
                mouseClick(root, root.width / 2, root.height - 1);
            }

            tryCompare(headerContainer, "showSearch", !data.hideSearch);
            tryCompareFunction(function() { return headerContainer.popover === null; }, true);

            doResetSearch();
        }

        function test_search_change_shows_search() {
            var headerContainer = findChild(pageHeader, "headerContainer");
            compare(headerContainer.showSearch, false);
            compare(searchQuery, "");

            searchQuery = "H";
            compare(headerContainer.showSearch, true);
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

            searchEntryEnabled: true
            title: "%^$%^%^&%^&%^$%GHR%"
            scopeStyle: QtObject {
                readonly property color foreground: Theme.palette.normal.baseText
                readonly property url headerLogo: showImageCheckBox.checked ? pageHeader.titleImageSource : ""
            }
            showBackButton: showBackButtonCheckBox.checked

            property string titleImageSource: Qt.resolvedUrl("tst_PageHeader/logo-ubuntu-orange.svg")
            property date lastBackClicked
            onBackClicked: lastBackClicked = new Date()
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

        Row {
            spacing: units.gu(1)
            anchors {
                left: parent.left
                right: parent.right
            }
            CheckBox {
                id: showBackButtonCheckBox
            }
            Label {
                text: "Back button enabled (Last clicked: " + Qt.formatTime(pageHeader.lastBackClicked, "hh:mm:ss") + ")"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            spacing: units.gu(1)
            anchors {
                left: parent.left
                right: parent.right
            }
            CheckBox {
                id: showImageCheckBox
            }
            Label {
                text: "Show image instead of title"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
