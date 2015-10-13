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
import Ubuntu.Components.ListItems 1.0
import "../Components"

Item {
    id: root
    objectName: "pageHeader"
    implicitHeight: headerContainer.height + bottomContainer.height + signatureLineHeight
    readonly property real signatureLineHeight: showSignatureLine ? units.gu(2) : 0

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

    property alias bottomItem: bottomContainer.children
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

    function triggerSearch() {
        if (searchEntryEnabled) {
            headerContainer.showSearch = true;
            searchTextField.forceActiveFocus();
        }
    }

    function closePopup(keepFocus) {
        if (extraPanel.visible) {
            extraPanel.visible = false;
        } else if (!keepFocus) {
            unfocus();
        }
        if (!searchTextField.text && !root.navigationTag && searchHistory.count == 0) {
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

    function unfocus() {
        searchTextField.focus = false;
        if (!searchTextField.text && !root.navigationTag) {
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
        anchors { fill: parent; margins: units.gu(1); bottomMargin: units.gu(3) + bottomContainer.height }
        visible: headerContainer.showSearch
        onPressed: {
            closePopup(/* keepFocus */false);
            mouse.accepted = false;
        }
    }

    Flickable {
        id: headerContainer
        objectName: "headerContainer"
        clip: contentY < height
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: units.gu(7)
        contentHeight: headersColumn.height
        interactive: false
        contentY: showSearch ? 0 : height

        property bool showSearch: false

        Background {
            id: background
            objectName: "headerBackground"
            style: scopeStyle.headerBackground
        }

        Behavior on contentY {
            UbuntuNumberAnimation {
                id: openSearchAnimation
                property bool openPopup: false

                onRunningChanged: {
                    if (!running && openSearchAnimation.openPopup) {
                        openSearchAnimation.openPopup = false;
                        root.openPopup();
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
                __separator_visible: false
                // Required to keep PageHeadStyle noise down as it expects the Page's properties around.
                property var styledItem: searchHeader
                property string title
                property color dividerColor: "transparent" // Doesn't matter as we don't have PageHeadSections
                property color panelColor: background.topColor
                panelForegroundColor: config.foregroundColor
                property var config: PageHeadConfiguration {
                    foregroundColor: root.scopeStyle ? root.scopeStyle.headerForeground : Theme.palette.normal.baseText
                }
                property var contents: Item {
                    anchors.fill: parent

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
                            right: cancelLabel.left
                            rightMargin: units.gu(1)
                        }

                        readonly property bool clearIsSettings: !searchTextField.focus && root.scopeHasFilters

                        primaryItem: Label {
                            text: root.navigationTag
                        }

                        secondaryItem: AbstractButton {
                            id: clearOrSettingsButton
                            height: searchTextField.height
                            width: height
                            enabled: searchTextField.text.length > 0 || root.navigationTag != ""

                            Image {
                                objectName: "clearIcon"
                                anchors.fill: parent
                                anchors.margins: units.gu(.75)
                                source: searchTextField.clearIsSettings ? "image://theme/settings" : "image://theme/clear"
                                opacity: parent.enabled
                                visible: opacity > 0
                                Behavior on opacity {
                                    UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration }
                                }
                            }

                            onClicked: {
                                if (searchTextField.clearIsSettings) {
                                    root.showFiltersPopup(clearOrSettingsButton);
                                } else {
                                    root.clearSearch(true);
                                }
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

                    Label {
                        id: cancelLabel
                        text: i18n.tr("Cancel")
                        verticalAlignment: Text.AlignVCenter
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                            margins: units.gu(1)
                        }
                        AbstractButton {
                            anchors.fill: parent
                            onClicked: {
                                root.clearSearch(false);
                                headerContainer.showSearch = false;
                            }
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
                __separator_visible: false
                property var styledItem: header
                property string title: root.title
                property color dividerColor: "transparent" // Doesn't matter as we don't have PageHeadSections
                property color panelColor: background.topColor
                panelForegroundColor: config.foregroundColor
                property var config: PageHeadConfiguration {
                    foregroundColor: root.scopeStyle ? root.scopeStyle.headerForeground : Theme.palette.normal.baseText
                    backAction: Action {
                        iconName: backIsClose ? "close" : "back"
                        visible: root.showBackButton
                        onTriggered: root.backClicked()
                    }

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

                    contents: Label {
                        LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        text: header.title
                        font.weight: header.fontWeight
                        fontSize: header.fontSize
                        color: header.titleColor
                        elide: Text.ElideRight
                        AbstractButton {
                            anchors.fill: parent
                            enabled: root.searchEntryEnabled
                            onClicked: {
                                headerContainer.showSearch = true;
                                searchTextField.forceActiveFocus();
                            }
                        }
                    }
                }

                property var contents: null
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
            bottom: bottomContainer.top
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
            top: bottomContainer.top
            left: parent.left
            right: parent.right
        }
        z: 1
        height: units.dp(1)
        opacity: 0.6

        // FIXME this should be a shader when bottomItem exists
        // to support image backgrounds
        Rectangle {
            anchors.fill: parent
            color: if (bottomItem && bottomItem.background) {
                       Qt.lighter(Qt.rgba(bottomItem.background.topColor.r,
                                          bottomItem.background.topColor.g,
                                          bottomItem.background.topColor.b, 1.0), 1.2);
                   } else if (!bottomItem && root.scopeStyle) {
                       Qt.lighter(Qt.rgba(root.scopeStyle.background.r,
                                          root.scopeStyle.background.g,
                                          root.scopeStyle.background.b, 1.0), 1.2);
                   } else "#CCFFFFFF"
        }
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
