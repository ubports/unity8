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
import "SearchHistoryModel"

Item {
    id: root
    implicitHeight: headerContainer.height + units.gu(2) + bottomContainer.height

    property bool showBackButton: false
    property string title
    property string imageSource

    property bool searchEntryEnabled: false
    property ListModel searchHistory: SearchHistoryModel
    property alias searchQuery: searchTextField.text
    property bool searchInProgress: false

    property alias bottomItem: bottomContainer.children

    signal backClicked()

    function triggerSearch() {
        if (searchEntryEnabled) searchTextField.forceActiveFocus()
    }

    function resetSearch(keepFocus) {
        if (searchHistory) {
            searchHistory.addQuery(searchTextField.text);
        }
        if (!keepFocus) {
            unfocus();
        }
        searchTextField.text = "";
        if (headerContainer.popover != null) {
            PopupUtils.close(headerContainer.popover);
        }
    }

    function unfocus() {
        searchTextField.focus = false;
    }

    function openSearchHistory() {
        if (openSearchAnimation.running) {
            openSearchAnimation.openSearchHistory = true
        } else if (root.searchHistory.count > 0 && headerContainer.popover == null) {
            headerContainer.popover = PopupUtils.open(popoverComponent, searchTextField,
                                                      {
                                                          "contentWidth": searchTextField.width,
                                                          "edgeMargins": units.gu(1)
                                                      }
                                                     )
        }
    }

    onImageSourceChanged: {
        if (imageSource) {
            header.contents = imageComponent.createObject();
        } else {
            header.contents.destroy();
            header.contents = null
        }
    }

    Flickable {
        id: headerContainer
        objectName: "headerContainer"
        clip: true
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: units.gu(6.5)
        contentHeight: headersColumn.height
        interactive: false
        contentY: showSearch ? 0 : height

        property bool showSearch: false
        property var popover: null

        Behavior on contentY {
            UbuntuNumberAnimation {
                id: openSearchAnimation
                property bool openSearchHistory: false

                onRunningChanged: {
                    if (!running && openSearchAnimation.openSearchHistory) {
                        openSearchAnimation.openSearchHistory = false;
                        root.openSearchHistory()
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
                separatorSource: ""
                // Required to keep PageHeadStyle noise down as it expects the Page's properties around.
                property var styledItem: searchHeader
                property string title
                property var config: PageHeadConfiguration {
                    backAction: Action {
                        iconName: "back"
                        onTriggered: {
                            root.resetSearch()
                            headerContainer.showSearch = false
                        }
                    }
                }
                property var contents: TextField {
                    id: searchTextField
                    hasClearButton: false
                    anchors {
                        fill: parent;
                        leftMargin: units.gu(1)
                        topMargin: units.gu(1)
                        bottomMargin: units.gu(1)
                        rightMargin: root.width > units.gu(60) ? root.width - units.gu(40) : units.gu(1)
                    }

                    secondaryItem: AbstractButton {
                        height: searchTextField.height
                        width: height

                        Image {
                            objectName: "clearIcon"
                            anchors.fill: parent
                            anchors.margins: units.gu(.75)
                            source: "image://theme/clear"
                            opacity: searchTextField.text.length > 0 && !searchActivityIndicator.running
                            visible: opacity > 0
                        }

                        ActivityIndicator {
                            id: searchActivityIndicator
                            objectName: "searchIndicator"
                            anchors.fill: parent
                            anchors.margins: units.gu(.75)
                            running: root.searchInProgress
                            opacity: running ? 1 : 0
                            Behavior on opacity {
                                UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration }
                            }
                        }

                        onClicked: {
                            root.resetSearch(true)
                            root.openSearchHistory()
                        }
                    }

                    onActiveFocusChanged: {
                        if (activeFocus) {
                            root.openSearchHistory()
                        }
                    }
                }
            }

            PageHeadStyle {
                id: header
                anchors { left: parent.left; right: parent.right }
                height: headerContainer.height
                contentHeight: height
                separatorSource: ""
                textColor: "grey"
                property var styledItem: header
                property string title: root.title
                property var config: PageHeadConfiguration {
                    backAction: Action {
                        iconName: "back"
                        visible: root.showBackButton
                        onTriggered: {
                            root.backClicked()
                        }
                    }

                    actions: [
                        Action {
                            iconName: "search"
                            visible: root.searchEntryEnabled
                            onTriggered: {
                                headerContainer.showSearch = true
                                searchTextField.forceActiveFocus()
                            }
                        }
                    ]
                }

                property var contents: null
                Component.onCompleted: {
                    if (root.imageSource.length > 0) {
                        header.contents = imageComponent.createObject();
                    }
                }
                Component {
                    id: imageComponent

                    Item {
                        anchors { fill: parent; topMargin: units.gu(1); bottomMargin: units.gu(1) }
                        clip: true
                        Image {
                            objectName: "titleImage"
                            anchors.fill: parent
                            source: root.imageSource
                            fillMode: Image.PreserveAspectFit
                            horizontalAlignment: Image.AlignLeft
                        }
                    }
                }
            }
        }
    }

    Component {
        id: popoverComponent
        Popover {
            id: popover

            Component.onDestruction: {
                headerContainer.popover = null
            }

            Column {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                Standard { enabled: false; text: i18n.tr("Recent searches") }

                Repeater {
                    id: recentSearches
                    model: searchHistory

                    delegate: Standard {
                        showDivider: index < recentSearches.count - 1
                        text: query
                        onClicked: {
                            searchHistory.addQuery(text)
                            searchTextField.text = text
                            PopupUtils.close(popover)
                        }
                    }
                }
            }
        }
    }

    BorderImage {
        id: bottomBorder
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
