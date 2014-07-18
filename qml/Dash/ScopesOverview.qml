/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Dash 0.1
import Ubuntu.Components 0.1
import "../Components"

Item {
    id: root

    // Properties set by parent
    property real progress: 0
    property var scope: null
    property int currentIndex: 0
    property real scopeScale: 1

    // Properties set and used by parent
    property alias currentTab: tabBar.currentTab

    // Properties used by parent
    property bool growingDashFromPos: false
    readonly property bool searching: scope && scope.searchQuery == ""
    readonly property bool showingNonFavoriteScope: tempScopeItem.scope != null
    readonly property var dashItemEater: {
        if (!forceXYScalerEater && tabBar.currentTab == 0 && middleItems.count > 0) {
            var loaderItem = middleItems.itemAt(0).item;
            return loaderItem && loaderItem.currentItem ? loaderItem.currentItem : null;
        }
        return scopesOverviewXYScaler;
    }
    readonly property size allCardSize: {
        if (middleItems.count > 1) {
            var loaderItem = middleItems.itemAt(1).item;
            if (loaderItem) {
                var cardTool = loaderItem.cardTool;
                return Qt.size(cardTool.cardWidth, cardTool.cardHeight);
            }
        }
        return Qt.size(0, 0);
    }

    // Internal properties
    property bool forceXYScalerEater: false

    signal done()
    signal favoriteSelected(var scopeId)
    signal allFavoriteSelected(var scopeId)
    signal searchSelected(var scopeId, var result, var pos, var size)

    Connections {
        target: scope
        onOpenScope: {
            var itemPos = scopesOverviewXYScaler.restorePosition;
            var itemSize = scopesOverviewXYScaler.restoreSize;
            scopesOverviewXYScaler.scale = itemSize.width / scopesOverviewXYScaler.width;
            scopesOverviewXYScaler.x = itemPos.x -(scopesOverviewXYScaler.width - scopesOverviewXYScaler.width * scopesOverviewXYScaler.scale) / 2;
            scopesOverviewXYScaler.y = itemPos.y -(scopesOverviewXYScaler.height - scopesOverviewXYScaler.height * scopesOverviewXYScaler.scale) / 2;
            scopesOverviewXYScaler.opacity = 0;
            tempScopeItem.scope = scope;
            middleItems.overrideOpacity = 0;
            scopesOverviewXYScaler.scale = 1;
            scopesOverviewXYScaler.x = 0;
            scopesOverviewXYScaler.y = 0;
            scopesOverviewXYScaler.opacity = 1;
        }
    }

    function animateDashFromAll(scopeId) {
        var currentScopePos = allScopeCardPosition(scopeId);
        if (currentScopePos) {
            showDashFromPos(currentScopePos, allCardSize);
        } else {
            console.log("Warning: Could not find Dash OverView All card position for scope", dashContent.currentScopeId);
        }
    }

    function showDashFromPos(itemPos, itemSize) {
        scopesOverviewXYScaler.scale = itemSize.width / scopesOverviewXYScaler.width;
        scopesOverviewXYScaler.x = itemPos.x -(scopesOverviewXYScaler.width - scopesOverviewXYScaler.width * scopesOverviewXYScaler.scale) / 2;
        scopesOverviewXYScaler.y = itemPos.y -(scopesOverviewXYScaler.height - scopesOverviewXYScaler.height * scopesOverviewXYScaler.scale) / 2;
        scopesOverviewXYScaler.opacity = 0;
        root.growingDashFromPos = true;
        scopesOverviewXYScaler.scale = 1;
        scopesOverviewXYScaler.x = 0;
        scopesOverviewXYScaler.y = 0;
        scopesOverviewXYScaler.opacity = 1;
    }

    function allScopeCardPosition(scopeId) {
        if (middleItems.count > 1) {
            var loaderItem = middleItems.itemAt(1).item;
            if (loaderItem) {
                var pos = loaderItem.scopeCardPosition(scopeId);
                return loaderItem.mapToItem(null, pos.x, pos.y);
            }
        }
    }

    onProgressChanged: {
        if (progress == 0) {
            pageHeader.resetSearch();
            pageHeader.unfocus(); // Shouldn't the previous call do this too?
        }
    }

    ScopeStyle {
        id: overviewScopeStyle
        style: { "foreground-color" : "white", "background-color" : "transparent" }
    }

    DashBackground {
        anchors.fill: parent
        Rectangle {
            color: "black"
            anchors.fill: parent
            opacity: 0.6
        }
    }

    Connections {
        target: pageHeader
        onSearchQueryChanged: {
            // Need this in order, otherwise something gets unhappy in rendering
            // of the overlay in carousels because the parent of the dash dies for
            // a moment, this way we make sure it's reparented first
            // by forceXYScalerEater making dashItemEater return scopesOverviewXYScaler
            // before we kill the previous parent by scope.searchQuery
            root.forceXYScalerEater = true;
            root.scope.searchQuery = pageHeader.searchQuery;
            root.forceXYScalerEater = false;
        }
    }

    Item {
        id: scopesOverviewContent
        x: previewListView.open ? -width : 0
        Behavior on x { UbuntuNumberAnimation { } }
        width: parent.width
        height: parent.height

        PageHeader {
            id: pageHeader

            readonly property real yDisplacement: pageHeader.height + tabBar.height + tabBar.anchors.margins

            y: {
                if (root.progress < 0.5) {
                    return -yDisplacement;
                } else {
                    return -yDisplacement + (root.progress - 0.5) * yDisplacement * 2;
                }
            }
            width: parent.width
            clip: true
            title: i18n.tr("Manage Dash")
            scopeStyle: overviewScopeStyle
            showSignatureLine: false
            searchEntryEnabled: true
            searchInProgress: root.scope ? root.scope.searchInProgress : false
        }

        ScopesOverviewTab {
            id: tabBar
            anchors {
                left: parent.left
                right: parent.right
                top: pageHeader.bottom
                margins: units.gu(2)
            }
            height: units.gu(4)

            enabled: opacity == 1
            opacity: !scope || scope.searchQuery == "" ? 1 : 0
            Behavior on opacity { UbuntuNumberAnimation { } }
        }

        Repeater {
            id: middleItems
            property real overrideOpacity: -1
            model: scope && scope.searchQuery == "" ? scope.categories : null
            delegate: Loader {
                id: loader

                height: {
                    if (index == 0) {
                        return root.height;
                    } else {
                        return root.height - pageHeader.height - tabBar.height - tabBar.anchors.margins - units.gu(2)
                    }
                }
                width: {
                    if (index == 0) {
                        return root.width / scopeScale
                    } else {
                        return root.width
                    }
                }
                x: {
                    if (index == 0) {
                        return (root.width - width) / 2;
                    } else {
                        return 0;
                    }
                }
                anchors {
                    bottom: scopesOverviewContent.bottom
                }

                scale: index == 0 ? scopeScale : 1

                opacity: {
                    if (middleItems.overrideOpacity >= 0)
                        return middleItems.overrideOpacity;

                    if (tabBar.currentTab != index)
                        return 0;

                    return index == 0 ? 1 : root.progress;
                }
                Behavior on opacity {
                    enabled: root.progress == 1
                    UbuntuNumberAnimation { }
                }
                enabled: opacity == 1

                clip: index == 1

                CardTool {
                    id: cardTool
                    objectName: "cardTool"
                    count: results.count
                    template: model.renderer
                    components: model.components
                    viewWidth: parent.width
                }

                source: {
                    if (index == 0 && categoryId == "favorites") return "ScopesOverviewFavorites.qml";
                    else if (index == 1 && categoryId == "all") return "ScopesOverviewAll.qml";
                    else return "";
                }

                onLoaded: {
                    item.model = Qt.binding(function() { return results })
                    item.cardTool = cardTool;
                    if (index == 0) {
                        item.scopeWidth = root.width;
                        item.scopeHeight = root.height;
                        item.appliedScale = Qt.binding(function() { return loader.scale })
                        item.currentIndex = Qt.binding(function() { return root.currentIndex })
                    } else if (index == 1) {
                        item.extraHeight = bottomBar.height;
                    }
                }

                Connections {
                    target: loader.item
                    onClicked: {
                        if (tabBar.currentTab == 0) {
                            root.favoriteSelected(itemModel.scopeId)
                        } else {
                            var favoriteScopesItem = middleItems.itemAt(0).item;
                            var scopeIndex = favoriteScopesItem.model.scopeIndex(itemModel.scopeId);
                            if (scopeIndex >= 0) {
                                root.allFavoriteSelected(itemModel.scopeId);
                            } else {
                                // Will result in an openScope from root.scope
                                scopesOverviewXYScaler.restorePosition = item.mapToItem(null, 0, 0);
                                scopesOverviewXYScaler.restoreSize = allCardSize;
                                root.scope.activate(result);
                            }
                        }
                    }
                    onPressAndHold: {
                        previewListView.model = target.model;
                        previewListView.currentIndex = -1
                        previewListView.currentIndex = index;
                        previewListView.open = true
                    }
                }
            }
        }

        GenericScopeView {
            id: searchResultsViewer
            anchors {
                top: pageHeader.bottom
                right: parent.right
                left: parent.left
                bottom: parent.bottom
            }
            scope: root.scope && root.scope.searchQuery != "" ? root.scope : null
            scopeStyle: overviewScopeStyle
            enabled: opacity == 1
            showPageHeader: false
            clip: true
            opacity: searchResultsViewer.scope ? 1 : 0
            Behavior on opacity { UbuntuNumberAnimation { } }

            clickOverride: function (index, result, item, itemModel) {
                pageHeader.closeSearchHistory();
                if (itemModel.scopeId) {
                    // This can end up in openScope so save restorePosition and restoreSize
                    scopesOverviewXYScaler.restorePosition = item.mapToItem(null, 0, 0);
                    scopesOverviewXYScaler.restoreSize = Qt.size(item.width, item.height);
                    root.searchSelected(itemModel.scopeId, result, item.mapToItem(null, 0, 0), Qt.size(item.width, item.height));
                } else {
                    // Not a scope, just activate it
                    searchResultsViewer.scope.activate(result);
                }
            }

            pressAndHoldOverride: function (index) {
                // Do nothing
            }
        }

        Rectangle {
            id: bottomBar
            color: "black"
            height: units.gu(6)
            width: parent.width
            enabled: opacity == 0.4
            opacity: scope && scope.searchQuery == "" ? 0.4 : 0
            Behavior on opacity { UbuntuNumberAnimation { } }
            y: {
                if (root.progress < 0.5) {
                    return parent.height;
                } else {
                    return parent.height - (root.progress - 0.5) * height * 2;
                }
            }

            AbstractButton {
                width: Math.max(label.width + units.gu(2), units.gu(10))
                height: units.gu(4)
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    anchors.fill: parent
                    border.color: "white"
                    border.width: units.dp(1)
                    radius: units.dp(10)
                    color: parent.pressed ? "gray" : "transparent"
                }
                Label {
                    id: label
                    anchors.centerIn: parent
                    text: i18n.tr("Done")
                    color: parent.pressed ? "black" : "white"
                }
                onClicked: root.done();
            }
        }
    }

    PreviewListView {
        id: previewListView
        objectName: "scopesOverviewPreviewListView"
        scope: root.scope
        scopeStyle: overviewScopeStyle
        visible: x != width
        width: parent.width
        height: parent.height
        anchors.left: scopesOverviewContent.right
    }



    Item {
        id: scopesOverviewXYScaler
        width: parent.width
        height: parent.height

        clip: scale != 1.0
        enabled: scale == 1

        property bool animationsEnabled: root.showingNonFavoriteScope || root.growingDashFromPos

        property var restorePosition
        property var restoreSize

        Behavior on x {
            enabled: scopesOverviewXYScaler.animationsEnabled
            UbuntuNumberAnimation { }
        }
        Behavior on y {
            enabled: scopesOverviewXYScaler.animationsEnabled
            UbuntuNumberAnimation { }
        }
        Behavior on opacity {
            enabled: scopesOverviewXYScaler.animationsEnabled
            UbuntuNumberAnimation { }
        }
        Behavior on scale {
            enabled: scopesOverviewXYScaler.animationsEnabled
            UbuntuNumberAnimation {
                onRunningChanged: {
                    if (!running) {
                        if (root.showingNonFavoriteScope && scopesOverviewXYScaler.scale != 1) {
                            root.scope.closeScope(tempScopeItem.scope);
                            tempScopeItem.scope = null;
                        } else if (root.growingDashFromPos) {
                            root.growingDashFromPos = false;
                        }
                    }
                }
            }
        }

        DashBackground
        {
            anchors.fill: tempScopeItem
            visible: tempScopeItem.visible
            parent: tempScopeItem.parent
        }

        GenericScopeView {
            id: tempScopeItem

            width: parent.width
            height: parent.height
            scale: dash.contentScale
            clip: scale != 1.0
            visible: scope != null
            hasBackAction: true
            isCurrent: visible
            onBackClicked: {
                var v = scopesOverviewXYScaler.restoreSize.width / tempScopeItem.width;
                scopesOverviewXYScaler.scale = v;
                scopesOverviewXYScaler.x = scopesOverviewXYScaler.restorePosition.x -(tempScopeItem.width - tempScopeItem.width * v) / 2;
                scopesOverviewXYScaler.y = scopesOverviewXYScaler.restorePosition.y -(tempScopeItem.height - tempScopeItem.height * v) / 2;
                scopesOverviewXYScaler.opacity = 0;
                middleItems.overrideOpacity = -1;
            }
        }
    }
}
