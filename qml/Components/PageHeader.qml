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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Unity 0.2

Item {
    id: root
    property bool searchEntryEnabled: false
    property alias searchQuery: searchField.text
    property ListModel searchHistory
    property Scope scope
    property alias childItem: itemContainer.children
    property alias showBackButton: backButton.visible

    signal backClicked

    height: units.gu(8.5)
    implicitHeight: units.gu(8.5)

    function triggerSearch() {
        if (searchEntryEnabled) searchField.forceActiveFocus()
    }

    function resetSearch() {
        if (!searchHistory) return;

        searchHistory.addQuery(searchField.text);
        unfocus();
        searchField.text = "";
    }

    function unfocus() {
        searchField.focus = false;
    }

    Connections {
        target: greeter
        onShownChanged: if (shown) resetSearch()
    }

    Flickable {
        id: header
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: units.gu(6.5)

        interactive: false
        contentHeight: headerContainer.height
        clip: true

        contentY: searchField.activeFocus || searchField.text != "" ? searchContainer.y : headerContainer.y

        Behavior on contentY { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        AbstractButton {
            id: backButton
            objectName: root.objectName + "_backButton"
            visible: false
            height: header.height
            y: header.contentY
            anchors {
                left: parent.left
                leftMargin: visible ? units.gu(2) : 0
            }
            width: visible ? image.width + units.gu(2) : 0
            onClicked: root.backClicked();
            Image {
                id: image
                anchors.centerIn: parent
                source: "graphics/headerback.png"
            }
        }

        // FIXME this could potentially be simplified to avoid all the containers
        Item {
            id: headerContainer

            anchors {
                left: backButton.right
                right: parent.right
            }
            height: childrenRect.height

            Item {
                id: itemContainer

                width: searchContainer.narrowMode ? header.width : header.width - searchContainer.width
                height: header.height
            }

            Item {
                id: searchContainer
                objectName: "searchContainer"

                visible: searchEntryEnabled
                property bool popoverShouldOpen: false
                property bool popoverShouldClose: false

                property bool narrowMode: parent.width < units.gu(80)

                property bool active: searchField.text != "" || searchField.activeFocus
                property var popover: null

                anchors.right: headerContainer.right
                height: header.height

                state:
                    if (active && narrowMode) "narrowActive"
                    else if (!active && narrowMode) "narrowInactive"
                    else if (active && !narrowMode) "active"
                    else if (!active && !narrowMode) "inactive"

                onStateChanged: {
                    if (state == "active" || state == "narrowActive") {
                        popoverShouldOpen = true;
                        popoverShouldClose = false;
                    } else {
                        popoverShouldOpen = false;
                        popoverShouldClose = true;
                    }
                }

                function openPopover() {
                    if (searchHistory.count > 0) {
                        searchContainer.popover = PopupUtils.open(popoverComponent, pointerPositioner,
                                                                  {
                                                                      "contentWidth": searchField.width,
                                                                      "edgeMargins": units.gu(1)
                                                                  }
                                                                 )
                    }
                    popoverShouldOpen = false;
                    popoverShouldClose = false;
                }

                function closePopover() {
                    if (searchContainer.popover) {
                        PopupUtils.close(searchContainer.popover);
                        searchContainer.popover = null;
                    }
                    popoverShouldOpen = false;
                    popoverShouldClose = false;
                }

                onActiveFocusChanged: if (!activeFocus) { searchHistory.addQuery(searchField.text) }

                TextField {
                    id: searchField

                    anchors.fill: parent
                    anchors.margins: units.gu(1)

                    inputMethodHints: Qt.ImhNoPredictiveText
                    hasClearButton: false

                    primaryItem: AbstractButton {
                        enabled: searchField.text != "" && !searchIndicator.running
                        onClicked: {
                            if (searchField.text != "") {
                                searchHistory.addQuery(searchField.text)
                                searchField.text = ""
                            }
                        }
                        height: parent.height
                        width: height

                        ActivityIndicator {
                            id: searchIndicator
                            objectName: "searchIndicator"

                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: units.gu(0.5)
                            }

                            running: opacity > 0
                        }

                        Image {
                            id: primaryImage
                            objectName: "primaryImage"
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: units.gu(0.5)
                            }
                            width: units.gu(3)
                            height: units.gu(3)
                            visible: opacity > 0
                        }

                        Item {
                            id: pointerPositioner
                            anchors.left: parent.right
                            anchors.leftMargin: units.gu(0.5)
                            anchors.top: parent.bottom
                        }
                    }

                    onTextChanged: {
                        if (text != "") searchContainer.closePopover()
                        else if (text == "" && activeFocus) searchContainer.openPopover()
                    }

                    onActiveFocusChanged: {
                        if (!activeFocus) searchContainer.closePopover()
                    }

                    states: [
                        State {
                            name: "searching"
                            when: scope && scope.searchInProgress
                            PropertyChanges { target: searchIndicator; running: true; opacity: 1 }
                            PropertyChanges { target: primaryImage; opacity: 0 }
                        },
                        State {
                            name: "idle"
                            when: !scope || !scope.searchInProgress
                            PropertyChanges { target: searchIndicator; opacity: 0 }
                            PropertyChanges { target: primaryImage; opacity: 1 }
                        }
                    ]

                    transitions: [
                        Transition {
                            to: "searching"
                            reversible: true
                            SequentialAnimation {
                                NumberAnimation { target: primaryImage; property: "opacity"; duration: UbuntuAnimation.FastDuration; easing.type: Easing.Linear }
                                NumberAnimation { target: searchIndicator; property: "opacity"; duration: UbuntuAnimation.FastDuration; easing.type: Easing.Linear }
                            }
                        }
                    ]
                }

                states: [
                    State {
                        name: "wide"
                        AnchorChanges { target: itemContainer; anchors.top: headerContainer.top }
                        AnchorChanges { target: searchContainer; anchors.left: undefined; anchors.top: itemContainer.top }
                    },
                    State {
                        name: "narrow"
                        PropertyChanges { target: searchField; highlighted: true }
                        AnchorChanges { target: itemContainer; anchors.top: searchContainer.bottom }
                        AnchorChanges { target: searchContainer; anchors.left: headerContainer.left; anchors.top: headerContainer.top }
                    },
                    State {
                        name: "active"
                        extend: "wide"
                        PropertyChanges { target: searchContainer; width: units.gu(40) }
                        PropertyChanges { target: primaryImage; source: searchField.text ? "../Dash/graphics/icon_clear.png" : "../Dash/graphics/icon_search_active.png" }
                        PropertyChanges { target: searchField; highlighted: true }
                    },
                    State {
                        name: "inactive"
                        extend: "wide"
                        PropertyChanges { target: searchContainer; width: units.gu(25) }
                        PropertyChanges { target: primaryImage; source: "../Dash/graphics/icon_search_inactive.png" }
                        PropertyChanges { target: searchField; highlighted: false }
                    },
                    State {
                        name: "narrowActive"
                        extend: "narrow"
                        PropertyChanges { target: header; contentY: 0 }
                        PropertyChanges { target: primaryImage; source: searchField.text ? "../Dash/graphics/icon_clear.png" : "../Dash/graphics/icon_search_active.png" }
                    },
                    State {
                        name: "narrowInactive"
                        extend: "narrow"
                        PropertyChanges { target: header; contentY: header.height }
                        PropertyChanges { target: primaryImage; source: searchField.text ? "../Dash/graphics/icon_clear.png" : "../Dash/graphics/icon_search_active.png" }
                    }
                ]

                transitions: [
                    Transition {
                        to: "active"
                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation { targets: [searchContainer, searchField]; property: "width"; duration: 200; easing.type: Easing.InOutQuad }
                                PropertyAction  { target: primaryImage; property: "source" }
                                AnchorAnimation { targets: [searchContainer, itemContainer]; duration: 200; easing.type: Easing.InOutQuad }
                            }
                            ScriptAction { script: if (searchContainer.popoverShouldOpen) { searchContainer.openPopover(); } }
                        }
                    },
                    Transition {
                        to: "inactive"
                        ScriptAction { script: if (searchContainer.popoverShouldClose) { searchContainer.closePopover(); } }
                        NumberAnimation { targets: [searchContainer, searchField] ; property: "width"; duration: 200; easing.type: Easing.InOutQuad }
                        AnchorAnimation { targets: [searchContainer, itemContainer]; duration: 200; easing.type: Easing.InOutQuad }
                    },
                    Transition {
                        to: "narrowActive"
                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation { targets: [searchContainer, searchField] ; property: "width"; duration: 200; easing.type: Easing.OutQuad }
                                AnchorAnimation { targets: [searchContainer, itemContainer]; duration: 200; easing.type: Easing.InOutQuad }
                            }
                            ScriptAction { script: if (searchContainer.popoverShouldOpen) { searchContainer.openPopover(); } }
                        }
                    },
                    Transition {
                        to: "narrowInactive"
                        ScriptAction { script: if (searchContainer.popoverShouldClose) { searchContainer.closePopover(); } }
                        NumberAnimation { targets: [searchContainer, searchField] ; property: "width"; duration: 200; easing.type: Easing.OutQuad }
                        AnchorAnimation { targets: [searchContainer, itemContainer]; duration: 200; easing.type: Easing.InOutQuad }
                    }
                ]

                Component {
                    id: popoverComponent
                    Popover {
                        id: popover

                        // FIXME: this should go into the first item below, but enable: false
                        // prevents mouse events propagation
                        AbstractButton {
                            anchors {
                                top: parent.top
                                right: parent.right
                            }
                            height: units.gu(6)
                            width: height

                            onClicked: searchContainer.closePopover()

                            Image {
                                anchors.centerIn: parent
                                width: units.gu(2)
                                height: units.gu(2)
                                source: "../Dash/graphics/icon_listview_clear.png"
                            }
                        }

                        Column {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            ListItem.Standard { enabled: false; text: i18n.tr("Recent searches") }

                            Repeater {
                                id: recentSearches
                                model: searchHistory

                                delegate: ListItem.Standard {
                                    showDivider: index < recentSearches.count - 1
                                    text: query
                                    onClicked: {
                                        searchHistory.addQuery(text)
                                        searchField.text = text
                                    }
                                }
                            }
                        }
                    }
                }

                InverseMouseArea {
                    enabled: searchField.activeFocus

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    height: searchContainer.popover ? parent.height + searchContainer.popover.contentHeight + units.gu(2) : parent.height

                    onPressed: searchField.focus = false
                }
            }
        }
    }

    BorderImage {
        id: bottomBorder
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        source: "graphics/PageHeaderBaseDivider.sci"
    }
}
