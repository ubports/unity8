/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Components.Themes.Ambiance 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0
import "../Components"
import "../Components/SearchHistoryModel"

Item {
    id: root
    objectName: "pageHeader"
    implicitHeight: headerContainer.height + bottomContainer.height + (showSignatureLine ? units.gu(2) : 0);

    property bool showBackButton: false
    property string title

    property bool searchEntryEnabled: false
    property ListModel searchHistory: SearchHistoryModel
    property alias searchQuery: searchTextField.text
    property alias searchHint: searchTextField.placeholderText
    property bool showSignatureLine: true

    property alias bottomItem: bottomContainer.children
    property int paginationCount: 0
    property int paginationIndex: -1

    // TODO We should use foreground for the icons
    // of the toolbar but unfortunately Action does not have
    // the keyColor property as Icon does :-/
    property var scopeStyle: null

    signal backClicked()

    onScopeStyleChanged: refreshLogo()
    onSearchQueryChanged: {
        // Make sure we are at the search page if the search query changes behind our feet
        if (searchQuery) {
            headerContainer.showSearch = true;
        }
    }

    function triggerSearch() {
        if (searchEntryEnabled) {
            headerContainer.showSearch = true;
            searchTextField.forceActiveFocus();
        }
    }

    function closePopup() {
        if (headerContainer.popover != null) {
            PopupUtils.close(headerContainer.popover);
        }
    }

    function resetSearch(keepFocus) {
        if (searchHistory) {
            searchHistory.addQuery(searchTextField.text);
        }
        if (!keepFocus) {
            unfocus();
        }
        searchTextField.text = "";
        closePopup();
    }

    function unfocus() {
        searchTextField.focus = false;
        if (!searchTextField.text) {
            headerContainer.showSearch = false;
        }
    }

    function openSearchHistory() {
        if (openSearchAnimation.running) {
            openSearchAnimation.openSearchHistory = true;
        } else if (root.searchHistory.count > 0 && headerContainer.popover == null) {
            headerContainer.popover = PopupUtils.open(popoverComponent, searchTextField,
                                                      {
                                                          "contentWidth": searchTextField.width,
                                                          "edgeMargins": units.gu(1)
                                                      }
                                                     );
        }
    }

    function refreshLogo() {
        if (scopeStyle ? scopeStyle.headerLogo != "" : false) {
            header.contents = imageComponent.createObject();
        } else if (header.contents) {
            header.contents.destroy();
            header.contents = null;
        }
    }

    Connections {
        target: root.scopeStyle
        onHeaderLogoChanged: root.refreshLogo()
    }

    InverseMouseArea {
        anchors { fill: parent; margins: units.gu(1); bottomMargin: units.gu(3) + bottomContainer.height }
        visible: headerContainer.showSearch
        onPressed: {
            closePopup();
            if (!searchTextField.text) {
                headerContainer.showSearch = false;
            }
            searchTextField.focus = false;
            mouse.accepted = false;
        }
    }

    Flickable {
        id: headerContainer
        objectName: "headerContainer"
        clip: contentY < height
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: units.gu(6.5)
        contentHeight: headersColumn.height
        interactive: false
        contentY: showSearch ? 0 : height

        property bool showSearch: false
        property var popover: null

        Background {
            objectName: "headerBackground"
            style: scopeStyle.headerBackground
        }

        Behavior on contentY {
            UbuntuNumberAnimation {
                id: openSearchAnimation
                property bool openSearchHistory: false

                onRunningChanged: {
                    if (!running && openSearchAnimation.openSearchHistory) {
                        openSearchAnimation.openSearchHistory = false;
                        root.openSearchHistory();
                    }
                }
            }
        }

        Column {
            id: headersColumn
            anchors { left: parent.left; right: parent.right }

            PageHeadStyle {
                id: searchHeader
                anchors { left: parent.left; right: parent.right }
                height: headerContainer.height
                contentHeight: height
                opacity: headerContainer.clip || headerContainer.showSearch ? 1 : 0 // setting visible false cause column to relayout
                separatorSource: ""
                // Required to keep PageHeadStyle noise down as it expects the Page's properties around.
                property var styledItem: searchHeader
                property string title
                property var config: PageHeadConfiguration {
                    foregroundColor: root.scopeStyle ? root.scopeStyle.headerForeground : Theme.palette.normal.baseText
                    backAction: Action {
                        iconName: "back"
                        onTriggered: {
                            root.resetSearch();
                            headerContainer.showSearch = false;
                        }
                    }
                }
                property var contents: TextField {
                    id: searchTextField
                    objectName: "searchTextField"
                    inputMethodHints: Qt.ImhNoPredictiveText
                    hasClearButton: false
                    anchors {
                        fill: parent
                        leftMargin: units.gu(1)
                        topMargin: units.gu(1)
                        bottomMargin: units.gu(1)
                        rightMargin: root.width > units.gu(60) ? root.width - units.gu(40) : units.gu(1)
                    }

                    secondaryItem: AbstractButton {
                        height: searchTextField.height
                        width: height
                        enabled: searchTextField.text.length > 0

                        Image {
                            objectName: "clearIcon"
                            anchors.fill: parent
                            anchors.margins: units.gu(.75)
                            source: "image://theme/clear"
                            opacity: searchTextField.text.length > 0
                            visible: opacity > 0
                            Behavior on opacity {
                                UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration }
                            }
                        }

                        onClicked: {
                            root.resetSearch(true);
                            root.openSearchHistory();
                        }
                    }

                    onActiveFocusChanged: {
                        if (activeFocus) {
                            root.openSearchHistory();
                        }
                    }

                    onTextChanged: {
                        if (text != "") {
                            closePopup();
                        }
                    }
                }
            }

            PageHeadStyle {
                id: header
                objectName: "innerPageHeader"
                anchors { left: parent.left; right: parent.right }
                height: headerContainer.height
                contentHeight: height
                opacity: headerContainer.clip || !headerContainer.showSearch ? 1 : 0 // setting visible false cause column to relayout
                separatorSource: ""
                property var styledItem: header
                property string title: root.title
                property var config: PageHeadConfiguration {
                    foregroundColor: root.scopeStyle ? root.scopeStyle.headerForeground : Theme.palette.normal.baseText
                    backAction: Action {
                        iconName: "back"
                        visible: root.showBackButton
                        onTriggered: {
                            root.backClicked();
                        }
                    }

                    actions: [
                        Action {
                            objectName: "search"
                            iconName: "search"
                            visible: root.searchEntryEnabled
                            onTriggered: {
                                headerContainer.showSearch = true;
                                searchTextField.forceActiveFocus();
                            }
                        }
                    ]
                }

                property var contents: null
                Component.onCompleted: root.refreshLogo()

                Component {
                    id: imageComponent

                    Item {
                        anchors { fill: parent; topMargin: units.gu(1); bottomMargin: units.gu(1) }
                        clip: true
                        Image {
                            objectName: "titleImage"
                            anchors.fill: parent
                            source: root.scopeStyle ? root.scopeStyle.headerLogo : ""
                            fillMode: Image.PreserveAspectFit
                            horizontalAlignment: Image.AlignLeft
                            sourceSize.height: height
                        }
                    }
                }
            }
        }
    }

    Row {
        spacing: units.gu(.5)
        Repeater {
            objectName: "paginationRepeater"
            model: root.paginationCount
            Image {
                objectName: "paginationDots_" + index
                height: units.gu(1)
                width: height
                source: (index == root.paginationIndex) ? "graphics/pagination_dot_on.png" : "graphics/pagination_dot_off.png"
            }
        }
        anchors {
            top: headerContainer.bottom
            horizontalCenter: headerContainer.horizontalCenter
            topMargin: units.gu(.5)
        }
    }

    Component {
        id: popoverComponent
        Popover {
            id: popover
            autoClose: false

            Component.onDestruction: {
                headerContainer.popover = null;
            }

            Column {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                Repeater {
                    id: recentSearches
                    objectName: "recentSearches"
                    model: searchHistory

                    delegate: Standard {
                        showDivider: index < recentSearches.count - 1
                        text: query
                        onClicked: {
                            searchHistory.addQuery(text);
                            searchTextField.text = text;
                            closePopup();
                            unfocus();
                        }
                    }
                }
            }
        }
    }

    BorderImage {
        id: bottomBorder
        visible: showSignatureLine
        anchors {
            top: headerContainer.bottom
            left: parent.left
            right: parent.right
            bottom: bottomContainer.top
        }

        source: "graphics/PageHeaderBaseDivider.sci"
    }

    Item {
        id: bottomContainer

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: childrenRect.height
    }
}
