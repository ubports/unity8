/*
 * Copyright (C) 2013,2015,2016 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3
import "../Components"

Item {
    id: root
    objectName: "pageHeader"
    implicitHeight: headerContainer.height + signatureLineHeight
    readonly property real signatureLineHeight: showSignatureLine ? units.gu(2) : 0

    property int activeFiltersCount: 0
    property bool scopeHasFilters: false
    property bool showBackButton: false
    property bool backIsClose: false
    property string title
    property var extraPanel
    property string navigationTag

    property bool storeEntryEnabled: false
    property bool searchEntryEnabled: false
    property bool settingsEnabled: false
    property bool favoriteEnabled: false
    property bool favorite: false
    property ListModel searchHistory
    property alias searchQuery: searchTextField.text
    property alias searchHint: searchTextField.placeholderText
    property bool showSignatureLine: true

    property int paginationCount: 0
    property int paginationIndex: -1

    property var scopeStyle: null

    signal clearSearch(bool keepPanelOpen)
    signal backClicked()
    signal storeClicked()
    signal settingsClicked()
    signal favoriteClicked()
    signal searchTextFieldFocused()
    signal showFiltersPopup(var item)

    onScopeStyleChanged: refreshLogo()
    onSearchQueryChanged: {
        // Make sure we are at the search page if the search query changes behind our feet
        if (searchQuery) {
            headerContainer.showSearch = true;
        }
    }
    onNavigationTagChanged: {
        // Make sure we are at the search page if the navigation tag changes behind our feet
        if (navigationTag) {
            headerContainer.showSearch = true;
        }
    }

    function triggerSearch() {
        if (searchEntryEnabled) {
            headerContainer.showSearch = true;
            searchTextField.forceActiveFocus();
        }
    }

    function closePopup(keepFocus, keepSearch) {
        if (extraPanel.visible) {
            extraPanel.visible = false;
        }
        if (!keepFocus) {
            unfocus(keepSearch);
        }
        if (!keepSearch && !searchTextField.text && !root.navigationTag && searchHistory.count == 0) {
            headerContainer.showSearch = false;
        }
    }

    function resetSearch(keepFocus) {
        if (searchHistory) {
            searchHistory.addQuery(searchTextField.text);
        }
        searchTextField.text = "";
        closePopup(keepFocus);
    }

    function unfocus(keepSearch) {
        searchTextField.focus = false;
        if (!keepSearch && !searchTextField.text && !root.navigationTag) {
            headerContainer.showSearch = false;
        }
    }

    function openPopup() {
        if (openSearchAnimation.running) {
            openSearchAnimation.openPopup = true;
        } else if (extraPanel.hasContents) {
            // Show extraPanel
            extraPanel.visible = true;
        }
    }

    function refreshLogo() {
        if (root.scopeStyle ? root.scopeStyle.headerLogo != "" : false) {
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
        anchors { fill: parent; margins: units.gu(1); bottomMargin: units.gu(3) + (extraPanel ? extraPanel.height : 0) }
        visible: headerContainer.showSearch
        onPressed: {
            closePopup(/* keepFocus */false);
            mouse.accepted = false;
        }
    }

    Item {
        id: headerContainer
        objectName: "headerContainer"
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: header.__styleInstance.contentHeight

        property bool showSearch: false

        state: headerContainer.showSearch ? "search" : ""

        states: State {
            name: "search"

            AnchorChanges {
                target: headersColumn
                anchors.top: parent.top
                anchors.bottom: undefined
            }
        }

        transitions: Transition {
            id: openSearchAnimation
            AnchorAnimation {
                duration: UbuntuAnimation.FastDuration
                easing: UbuntuAnimation.StandardEasing
            }

            property bool openPopup: false

            onRunningChanged: {
                headerContainer.clip = running;
                if (!running && openSearchAnimation.openPopup) {
                    openSearchAnimation.openPopup = false;
                    root.openPopup();
                }
            }
        }

        Background {
            id: background
            objectName: "headerBackground"
            style: scopeStyle.headerBackground
        }

        Column {
            id: headersColumn
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            PageHeader {
                id: searchHeader
                anchors { left: parent.left; right: parent.right }
                opacity: headerContainer.clip || headerContainer.showSearch ? 1 : 0 // setting visible false cause column to relayout

                StyleHints {
                    foregroundColor: root.scopeStyle ? root.scopeStyle.headerForeground : theme.palette.normal.baseText
                    backgroundColor: "transparent"
                    dividerColor: "transparent"
                }

                contents: Item {
                    anchors.fill: parent

                    Keys.onEscapePressed: { // clear the search text, dismiss the search in the second step
                        if (searchTextField.text != "") {
                            root.clearSearch(true);
                        } else {
                            root.clearSearch(false);
                            headerContainer.showSearch = false;
                        }
                    }

                    TextField {
                        id: searchTextField
                        objectName: "searchTextField"
                        inputMethodHints: Qt.ImhNoPredictiveText
                        hasClearButton: false
                        anchors {
                            top: parent.top
                            topMargin: units.gu(1)
                            left: parent.left
                            bottom: parent.bottom
                            bottomMargin: units.gu(1)
                            right: settingsButton.left
                            rightMargin: settingsButton.visible ? 0 : units.gu(2)
                        }

                        primaryItem: Rectangle {
                            color: "#F5F4F5"
                            width: root.navigationTag != "" ? tagLabel.width + units.gu(2) : 0
                            height: root.navigationTag != "" ? tagLabel.height + units.gu(1) : 0
                            radius: units.gu(0.5)
                            Label {
                                id: tagLabel
                                text: root.navigationTag
                                anchors.centerIn: parent
                                color: "#333333"
                            }
                        }

                        secondaryItem: AbstractButton {
                            id: clearButton
                            height: searchTextField.height
                            width: height
                            enabled: searchTextField.text.length > 0 || root.navigationTag != ""

                            Image {
                                objectName: "clearIcon"
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                source: "image://theme/clear"
                                sourceSize.width: width
                                sourceSize.height: height
                                opacity: parent.enabled
                                visible: opacity > 0
                                Behavior on opacity {
                                    UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration }
                                }
                            }

                            onClicked: {
                                root.clearSearch(true);
                            }
                        }

                        onActiveFocusChanged: {
                            if (activeFocus) {
                                root.searchTextFieldFocused();
                                root.openPopup();
                            }
                        }

                        onTextChanged: {
                            if (text != "") {
                                closePopup(/* keepFocus */true);
                            }
                        }
                    }

                    AbstractButton {
                        id: settingsButton
                        objectName: "settingsButton"

                        width: root.scopeHasFilters ? height : 0
                        visible: width > 0
                        anchors {
                            top: parent.top
                            right: cancelButton.left
                            bottom: parent.bottom
                            rightMargin: units.gu(-1)
                        }

                        Icon {
                            anchors.fill: parent
                            anchors.margins: units.gu(2)
                            name: "filters"
                            color: root.activeFiltersCount > 0 ? theme.palette.normal.positive : header.__styleInstance.foregroundColor
                        }

                        onClicked: {
                            root.showFiltersPopup(settingsButton);
                        }
                    }

                    AbstractButton {
                        id: cancelButton
                        objectName: "cancelButton"
                        width: cancelLabel.width + cancelLabel.anchors.rightMargin + cancelLabel.anchors.leftMargin
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                        }
                        onClicked: {
                            root.clearSearch(false);
                            headerContainer.showSearch = false;
                        }
                        Label {
                            id: cancelLabel
                            text: i18n.tr("Cancel")
                            color: header.__styleInstance.foregroundColor
                            verticalAlignment: Text.AlignVCenter
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: units.gu(2)
                                leftMargin: units.gu(1)
                            }
                        }
                    }
                }
            }

            PageHeader {
                id: header
                objectName: "innerPageHeader"
                anchors { left: parent.left; right: parent.right }
                height: headerContainer.height
                opacity: headerContainer.clip || !headerContainer.showSearch ? 1 : 0 // setting visible false cause column to relayout
                title: root.title

                StyleHints {
                    foregroundColor: root.scopeStyle ? root.scopeStyle.headerForeground : theme.palette.normal.baseText
                    backgroundColor: "transparent"
                    dividerColor: "transparent"
                }

                leadingActionBar.actions: Action {
                    iconName: backIsClose ? "close" : "back"
                    visible: root.showBackButton
                    onTriggered: root.backClicked()
                }

                trailingActionBar {
                    actions: [
                        Action {
                            objectName: "store"
                            text: i18n.ctr("Button: Open the Ubuntu Store", "Store")
                            iconName: "ubuntu-store-symbolic"
                            visible: root.storeEntryEnabled
                            onTriggered: root.storeClicked();
                        },
                        Action {
                            objectName: "search"
                            text: i18n.ctr("Button: Start a search in the current dash scope", "Search")
                            iconName: "search"
                            visible: root.searchEntryEnabled
                            onTriggered: {
                                headerContainer.showSearch = true;
                                searchTextField.forceActiveFocus();
                            }
                        },
                        Action {
                            objectName: "settings"
                            text: i18n.ctr("Button: Show the current dash scope settings", "Settings")
                            iconName: "settings"
                            visible: root.settingsEnabled
                            onTriggered: root.settingsClicked()
                        },
                        Action {
                            objectName: "favorite"
                            text: root.favorite ? i18n.tr("Remove from Favorites") : i18n.tr("Add to Favorites")
                            iconName: root.favorite ? "starred" : "non-starred"
                            visible: root.favoriteEnabled
                            onTriggered: root.favoriteClicked()
                        }
                    ]
                }

                Component.onCompleted: root.refreshLogo()

                Component {
                    id: imageComponent

                    Item {
                        anchors { fill: parent; topMargin: units.gu(1.5); bottomMargin: units.gu(1.5) }
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

    Rectangle {
        id: bottomBorder
        visible: showSignatureLine
        anchors {
            top: headerContainer.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        color: root.scopeStyle ? root.scopeStyle.headerDividerColor : "#e0e0e0"

        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: units.dp(1)
            color: Qt.darker(parent.color, 1.1)
        }
    }

    Row {
        visible: bottomBorder.visible
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

    // FIXME this doesn't work with solid scope backgrounds due to z-ordering
    Item {
        id: bottomHighlight
        visible: bottomBorder.visible
        anchors {
            top: parent.bottom
            left: parent.left
            right: parent.right
        }
        z: 1
        height: units.dp(1)
        opacity: 0.6

        Rectangle {
            anchors.fill: parent
            color: if (root.scopeStyle) {
                       Qt.lighter(Qt.rgba(root.scopeStyle.background.r,
                                          root.scopeStyle.background.g,
                                          root.scopeStyle.background.b, 1.0), 1.2);
                   } else "#CCFFFFFF"
        }
    }
}
