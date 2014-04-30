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
import Utils 0.1
import Unity 0.2
import Unity.Application 0.1
import "../Components"
import "../Components/ListItems" as ListItems

FocusScope {
    id: scopeView

    property Scope scope: null
    property SortFilterProxyModel categories: categoryFilter
    property bool isCurrent: false
    property alias moving: categoryView.moving
    property int tabBarHeight: 0
    property PageHeader pageHeader: null
    property Item previewListView: null

    property bool enableHeightBehaviorOnNextCreation: false
    property var categoryView: categoryView

    onScopeChanged: {
        if (scope) {
            scope.activateApplication.connect(activateApp);
        }
    }

    function activateApp(appId) {
        shell.activateApplication(appId);
    }

    function positionAtBeginning() {
        categoryView.positionAtBeginning()
    }

    function showHeader() {
        categoryView.showHeader()
    }

    Binding {
        target: scope
        property: "isActive"
        value: isCurrent && !previewListView.open
    }

    SortFilterProxyModel {
        id: categoryFilter
        model: scope ? scope.categories : null
        dynamicSortFilter: true
        filterRole: Categories.RoleCount
        filterRegExp: /^0$/
        invertMatch: true
    }

    onIsCurrentChanged: {
        pageHeader.resetSearch();
        previewListView.open = false;
    }

    Binding {
        target: scopeView.scope
        property: "searchQuery"
        value: pageHeader.searchQuery
        when: isCurrent
    }

    Binding {
        target: pageHeader
        property: "searchQuery"
        value: scopeView.scope ? scopeView.scope.searchQuery : ""
        when: isCurrent
    }

    Connections {
        target: panel
        onSearchClicked: if (isCurrent) {
            pageHeader.triggerSearch()
            categoryView.showHeader()
        }
    }

    Connections {
        target: scopeView.scope
        onShowDash: previewListView.open = false;
        onHideDash: previewListView.open = false;
    }

    ScopeListView {
        id: categoryView
        objectName: "categoryListView"
        anchors.fill: parent
        model: scopeView.categories
        forceNoClip: previewListView.open

        property string expandedCategoryId: ""

        onContentYChanged: pageHeader.positionRealHeader();
        onOriginYChanged: pageHeader.positionRealHeader();
        onContentHeightChanged: pageHeader.positionRealHeader();

        delegate: ListItems.Base {
            id: baseItem
            objectName: "dashCategory" + category
            highlightWhenPressed: false
            showDivider: false

            readonly property bool expandable: rendererLoader.item ? rendererLoader.item.expandable : false
            readonly property bool filtered: rendererLoader.item ? rendererLoader.item.filtered : true
            readonly property string category: categoryId
            readonly property var item: rendererLoader.item

            CardTool {
                id: cardTool

                count: results.count
                template: model.renderer
//                 onTemplateChanged: console.log("TCH", cardTool, JSON.stringify(template))
                components: model.components
//                 onComponentsChanged: console.log("CCH", cardTool, JSON.stringify(components))
                viewWidth: parent.width
            }

            Loader {
                id: rendererLoader
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                source: {
                    switch (cardTool.categoryLayout) {
                        case "carousel": return "CardCarousel.qml";
                        case "running-apps": return "Apps/RunningApplicationsGrid.qml";
                        case "grid":
                        default: return "CardFilterGrid.qml";
                    }
                }

                onLoaded: {
                    if (item.enableHeightBehavior !== undefined && item.enableHeightBehaviorOnNextCreation !== undefined) {
                        item.enableHeightBehavior = scopeView.enableHeightBehaviorOnNextCreation;
                        scopeView.enableHeightBehaviorOnNextCreation = false;
                    }
                    if (source.toString().indexOf("Apps/RunningApplicationsGrid.qml") != -1) {
                        // TODO: this is still a kludge :D Ideally add some kind of hook so that we
                        // can do this from DashApps.qml or think a better way that needs no special casing
                        item.model = Qt.binding(function() { return runningApps; })
                        item.canEnableTerminationMode = Qt.binding(function() { return scopeView.isCurrent })
                    } else {
                        item.model = Qt.binding(function() { return results })
                    }
                    item.objectName = Qt.binding(function() { return categoryId })
                    if (item.expandable) {
                        var shouldFilter = categoryId != categoryView.expandedCategoryId;
                        item.setFilter(shouldFilter, false /*animate*/);
                    }
                    updateDelegateCreationRange();
                    item.cardTool = cardTool;
                    console.log("rendererLoader onLoaded");
                }

                Component.onDestruction: {
                    if (item.enableHeightBehavior !== undefined && item.enableHeightBehaviorOnNextCreation !== undefined) {
                        scopeView.enableHeightBehaviorOnNextCreation = item.enableHeightBehaviorOnNextCreation;
                    }
                }

                Connections {
                    target: rendererLoader.item
                    onClicked: {
                        if (scopeView.scope.id === "scopes" || (scopeView.scope.id == "clickscope" && categoryId == "local")) {
                            // TODO Technically it is possible that calling activate() will make the scope emit
                            // previewRequested so that we show a preview but there's no scope that does that yet
                            // so it's not implemented
                            var item = target.model.get(index);
                            scopeView.scope.activate(item.result)
                        } else {
                            previewListView.model = target.model;
                            previewListView.currentIndex = -1
                            previewListView.currentIndex = index;
                            previewListView.open = true
                        }
                    }
                    onPressAndHold: {
                        previewListView.model = target.model;
                        previewListView.currentIndex = -1
                        previewListView.currentIndex = index;
                        previewListView.open = true
                    }
                }
                Connections {
                    target: categoryView
                    onExpandedCategoryIdChanged: {
                        collapseAllButExpandedCategory();
                    }
                    function collapseAllButExpandedCategory() {
                        var item = rendererLoader.item;
                        if (item.expandable) {
                            var shouldFilter = categoryId != categoryView.expandedCategoryId;
                            if (shouldFilter != item.filter) {
                                // If the filter animation will be seen start it, otherwise, just flip the switch
                                var shrinkingVisible = shouldFilter && y + item.collapsedHeight < categoryView.height;
                                var growingVisible = !shouldFilter && y + height < categoryView.height;
                                if (!previewListView.open || !shouldFilter) {
                                    var animate = shrinkingVisible || growingVisible;
                                    item.setFilter(shouldFilter, animate)
                                    if (!shouldFilter && !previewListView.open) {
                                        categoryView.maximizeVisibleArea(index, item.uncollapsedHeight);
                                    }
                                }
                            }
                        }
                    }
                    onOriginYChanged: rendererLoader.updateDelegateCreationRange();
                    onContentYChanged: rendererLoader.updateDelegateCreationRange();
                    onHeightChanged: rendererLoader.updateDelegateCreationRange();
                    onContentHeightChanged: rendererLoader.updateDelegateCreationRange();
                }

                function updateDelegateCreationRange() {
                    if (categoryView.moving) {
                        // Do not update the range if we are overshooting up or down, since we'll come back
                        // to the stable position and delete/create items without any reason
                        if (categoryView.contentY < categoryView.originY) {
                            return;
                        } else if (categoryView.contentHeight - categoryView.originY > categoryView.height &&
                                   categoryView.contentY + categoryView.height > categoryView.contentHeight) {
                            return;
                        }
                    }

                    if (item && item.hasOwnProperty("delegateCreationBegin")) {
                        if (baseItem.y + baseItem.height <= 0) {
                            // Not visible (item at top of the list viewport)
                            item.delegateCreationBegin = item.originY + baseItem.height
                            item.delegateCreationEnd = item.originY + baseItem.height
                        } else if (baseItem.y >= categoryView.height) {
                            // Not visible (item at bottom of the list viewport)
                            item.delegateCreationBegin = item.originY
                            item.delegateCreationEnd = item.originY
                        } else {
                            item.delegateCreationBegin = item.originY + Math.max(-baseItem.y, 0)
                            item.delegateCreationEnd = item.originY + Math.min(categoryView.height + item.delegateCreationBegin, baseItem.height)
                        }
                    }
                }

                Image {
                    visible: index != 0
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    fillMode: Image.Stretch
                    source: "graphics/dash_divider_top_lightgrad.png"
                    z: -1
                }

                Image {
                    // FIXME Should not rely on model.count but view.count, but ListViewWithPageHeader doesn't expose it yet.
                    visible: index != categoryView.model.count - 1
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                    fillMode: Image.Stretch
                    source: "graphics/dash_divider_top_darkgrad.png"
                    z: -1
                }
            }

            onHeightChanged: rendererLoader.updateDelegateCreationRange();
            onYChanged: rendererLoader.updateDelegateCreationRange();
        }

        sectionProperty: "name"
        sectionDelegate: ListItems.Header {
            objectName: "dashSectionHeader" + (delegate ? delegate.category : "")
            property var delegate: categoryView.item(delegateIndex)
            width: categoryView.width
            text: section
            image: {
                if (delegate && delegate.expandable)
                    return delegate.filtered ? "graphics/header_handlearrow.png" : "graphics/header_handlearrow2.png"
                return "";
            }
            onClicked: {
                if (categoryView.expandedCategoryId != delegate.category)
                    categoryView.expandedCategoryId = delegate.category;
                else
                    categoryView.expandedCategoryId = "";
            }
        }
        pageHeader: Item {
            implicitHeight: scopeView.tabBarHeight
            onHeightChanged: {
                if (scopeView.pageHeader && scopeView.isCurrent) {
                    scopeView.pageHeader.height = height;
                }
            }
            onYChanged: positionRealHeader();

            function positionRealHeader() {
                if (scopeView.pageHeader && scopeView.isCurrent) {
                    scopeView.pageHeader.y = y + parent.y;
                }
            }
        }
    }
}
