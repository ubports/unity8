/*
 * Copyright (C) 2013,2015,2016 Canonical Ltd.
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
import ".."
import "../../../qml/Dash"
import "../../../qml/Components/SearchHistoryModel"
import Ubuntu.Components 1.3
import Unity 0.2
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(110)
    height: units.gu(50)

    SignalSpy {
        id: escapeSpy
        target: pageHeader
        signalName: "clearSearch"
    }

    UT.UnityTestCase {
        name: "PageHeaderLabelTest"
        when: windowShown

        property alias searchEnabled : pageHeader.searchEntryEnabled
        property alias searchQuery : pageHeader.searchQuery
        property var headerContainer: findChild(pageHeader, "headerContainer")

        function doTypeString(text) {
            tryCompare(headerContainer, "clip", false);
            compare(headerContainer.state, "search");
            typeString(text);
        }

        function doResetSearch() {
            pageHeader.resetSearch();
            tryCompare(headerContainer, "clip", false);
            verify(headerContainer.state !== "search");
        }

        function init() {
            searchEnabled = true;

            // Reset to initial state
            pageHeader.searchQuery = "";
            pageHeader.closePopup();
            pageHeader.searchHistory.clear();

            // Check initial state
            tryCompare(pageHeader.extraPanel, "visible", false);
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
            escapeSpy.clear();
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
            tryCompare(pageHeader.extraPanel, "visible", true);

            pageHeader.searchQuery = data.searchText;

            if (data.searchText == "") {
                // When the text is empty the user can also close the
                // popup by clicking outside the header instead of by starting a search
                mouseClick(root, root.width / 2, root.height - 1);
            }

            tryCompare(headerContainer, "showSearch", !data.hideSearch);
            tryCompare(pageHeader.extraPanel, "visible", false);

            doResetSearch();
        }

        function test_popup_closing_with_escape() {
            searchEnabled = true;
            pageHeader.searchHistory.clear();

            pageHeader.searchHistory.addQuery("Search1");
            pageHeader.searchHistory.addQuery("Search2");

            pageHeader.triggerSearch();

            var headerContainer = findChild(pageHeader, "headerContainer");
            tryCompare(pageHeader.extraPanel, "visible", true);

            pageHeader.searchQuery = "foobar";

            // press Esc once, the search should be cleared
            keyClick(Qt.Key_Escape);
            pageHeader.searchQuery = ""; // simulate clearing the text field, the clear button doesn't do anything on its own
            compare(escapeSpy.count, 1);
            compare(escapeSpy.signalArguments[0][0], true);

            escapeSpy.clear();

            // press Escape a second time, the whole search should be hidden
            keyClick(Qt.Key_Escape);
            tryCompare(headerContainer, "showSearch", false);
            compare(escapeSpy.count, 1);
            compare(escapeSpy.signalArguments[0][0], false);
            tryCompare(pageHeader.extraPanel, "visible", false);

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

        DashPageHeader {
            id: pageHeader
            anchors {
                left: parent.left
                right: parent.right
            }

            searchHistory: SearchHistoryModel
            searchEntryEnabled: true
            title: "%^$%^%^&%^&%^$%GHR%"
            extraPanel: peExtraPanel
            scopeStyle: QtObject {
                readonly property color foreground: theme.palette.normal.baseText
                readonly property url headerLogo: showImageCheckBox.checked ? pageHeader.titleImageSource : ""
            }
            showBackButton: showBackButtonCheckBox.checked

            property string titleImageSource: Qt.resolvedUrl("tst_PageHeader/logo-ubuntu-orange.svg")
            property date lastBackClicked
            onBackClicked: lastBackClicked = new Date()
        }

        PageHeaderExtraPanel {
            id: peExtraPanel
            width: parent.width
            z: 1
            visible: false
            searchHistory: SearchHistoryModel
            onHistoryItemClicked: {
                SearchHistoryModel.addQuery(text);
                pageHeader.searchQuery = text;
            }
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
