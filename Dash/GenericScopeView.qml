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
import "../Components"
import "../Components/ListItems" as ListItems

ScopeView {
    id: scopeView
    readonly property alias previewShown: previewLoader.onScreen
    property bool enableHeightBehaviorOnNextCreation: false

    moving: categoryView.moving

    onIsCurrentChanged: {
        pageHeader.resetSearch();
        previewLoader.open = false;
    }

    onMovementStarted: categoryView.showHeader()

    onPositionedAtBeginning: categoryView.positionAtBeginning()

    Binding {
        target: scopeView.scope
        property: "searchQuery"
        value: pageHeader.searchQuery
    }

    Binding {
        target: pageHeader
        property: "searchQuery"
        value: scopeView.scope.searchQuery
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
        onShowDash: previewLoader.open = false;
        onHideDash: previewLoader.open = false;
        onActivated: previewLoader.closePreviewSpinner();
    }

    ScopeListView {
        id: categoryView
        objectName: "categoryListView"
        anchors.fill: parent
        model: scopeView.categories
        forceNoClip: previewLoader.onScreen

        onAtYEndChanged: if (atYEnd) endReached()
        onMovingChanged: if (moving && atYEnd) endReached()

        property string expandedCategoryId: ""

        delegate: ListItems.Base {
            id: baseItem
            highlightWhenPressed: false

            readonly property bool expandable: rendererLoader.item ? rendererLoader.item.expandable : false
            readonly property bool filtered: rendererLoader.item ? rendererLoader.item.filter : true
            readonly property string category: categoryId

            Loader {
                id: rendererLoader
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                source: getRenderer(model.renderer, model.contentType, model.rendererHint)

                onLoaded: {
                    if (item.enableHeightBehavior !== undefined && item.enableHeightBehaviorOnNextCreation !== undefined) {
                        item.enableHeightBehavior = scopeView.enableHeightBehaviorOnNextCreation;
                        scopeView.enableHeightBehaviorOnNextCreation = false;
                    }
                    if (source.toString().indexOf("Apps/RunningApplicationsGrid.qml") != -1) {
                        // TODO: the running apps grid doesn't support standard scope results model yet
                        item.firstModel = Qt.binding(function() { return results.firstModel })
                        item.secondModel = Qt.binding(function() { return results.secondModel })
                        item.canEnableTerminationMode = Qt.binding(function() { return scopeView.isCurrent })
                    } else {
                        item.model = Qt.binding(function() { return results })
                    }
                    item.objectName = Qt.binding(function() { return categoryId })
                    if (item.expandable) {
                        var shouldFilter = categoryId != categoryView.expandedCategoryId;
                        if (shouldFilter != item.filter) {
                            item.filter = shouldFilter;
                        }
                    }
                    updateDelegateCreationRange();
                }

                Component.onDestruction: {
                    if (item.enableHeightBehavior !== undefined && item.enableHeightBehaviorOnNextCreation !== undefined) {
                        scopeView.enableHeightBehaviorOnNextCreation = item.enableHeightBehaviorOnNextCreation;
                    }
                }

                Connections {
                    target: rendererLoader.item
                    onClicked: {
                        effect.positionPx = mapToItem(categoryView, 0, itemY).y
                        scopeView.scope.activate(delegateItem.model.uri,
                                                 delegateItem.model.icon,
                                                 delegateItem.model.category,
                                                 0,
                                                 delegateItem.model.mimetype,
                                                 delegateItem.model.title,
                                                 delegateItem.model.comment,
                                                 delegateItem.model.dndUri,
                                                 delegateItem.model.metadata)
                    }
                    onPressAndHold: {
                        effect.positionPx = mapToItem(categoryView, 0, itemY).y
                        scopeView.scope.preview( delegateItem.model.uri,
                                                 delegateItem.model.icon,
                                                 delegateItem.model.category,
                                                 0,
                                                 delegateItem.model.mimetype,
                                                 delegateItem.model.title,
                                                 delegateItem.model.comment,
                                                 delegateItem.model.dndUri,
                                                 delegateItem.model.metadata)
                    }
                }
                Connections {
                    target: categoryView
                    onExpandedCategoryIdChanged: {
                        var item = rendererLoader.item;
                        if (item.expandable) {
                            var shouldFilter = categoryId != categoryView.expandedCategoryId;
                            if (shouldFilter != item.filter) {
                                // If the filter animation will be seen start it, otherwise, just flip the switch
                                var shrinkingVisible = shouldFilter && y + item.collapsedHeight < categoryView.height;
                                var growingVisible = !shouldFilter && y + height < categoryView.height;
                                if (shrinkingVisible || growingVisible) {
                                    item.startFilterAnimation(shouldFilter)
                                } else {
                                    item.filter = shouldFilter;
                                }
                                if (!shouldFilter) {
                                    categoryView.maximizeVisibleArea(index, item.uncollapsedHeight);
                                }
                            }
                        }
                    }
                    onContentYChanged: rendererLoader.updateDelegateCreationRange();
                    onHeightChanged: rendererLoader.updateDelegateCreationRange();
                }

                function updateDelegateCreationRange() {
                    // Do not update the range if we are overshooting up or down, since we'll come back
                    // to the stable position and delete/create items without any reason
                    if (categoryView.contentY < categoryView.originY) {
                        return;
                    } else if (categoryView.contentY + categoryView.height > categoryView.contentHeight) {
                        return;
                    }

                    if (item.hasOwnProperty("delegateCreationBegin")) {
                        if (baseItem.y + baseItem.height <= 0) {
                            // Not visible (item at top of the list)
                            item.delegateCreationBegin = baseItem.height
                            item.delegateCreationEnd = baseItem.height
                        } else if (baseItem.y >= categoryView.height) {
                            // Not visible (item at bottom of the list)
                            item.delegateCreationBegin = 0
                            item.delegateCreationEnd = 0
                        } else {
                            item.delegateCreationBegin = Math.max(-baseItem.y, 0)
                            item.delegateCreationEnd = Math.min(categoryView.height + item.delegateCreationBegin, baseItem.height)
                        }
                    }
                }
            }
        }

        sectionProperty: "name"
        sectionDelegate: ListItems.Header {
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
        pageHeader: PageHeader {
            id: pageHeader
            objectName: "pageHeader"
            width: categoryView.width
            text: scopeView.scope.name
            searchEntryEnabled: true
            scope: scopeView.scope
        }
    }

    function getDefaultRendererId(contentType) {
        switch (contentType) {
            default: return "grid";
        }
    }

    function getRenderer(rendererId, contentType, rendererHint) {
        if (rendererId == "default") {
            rendererId = getDefaultRendererId(contentType);
        }
        switch (rendererId) {
            case "carousel": {
                switch (contentType) {
                    case "music": return "Music/MusicCarouselLoader.qml";
                    case "video": return "Video/VideoCarouselLoader.qml";
                    default: return "Generic/GenericCarouselLoader.qml";
                }
            }
            case "grid": {
                switch (contentType) {
                    case "apps": {
                        if (rendererHint == "toggled")
                            return "Apps/DashPluginFilterGrid.qml";
                        else
                            return "Generic/GenericFilterGrid.qml";
                    }
                    case "music": return "Music/MusicFilterGrid.qml";
                    case "video": return "Video/VideoFilterGrid.qml";
                    case "weather": return "Generic/WeatherFilterGrid.qml";
                    default: return "Generic/GenericFilterGrid.qml";
                }
            }
            case "special": {
                switch (contentType) {
                    case "apps": return "Apps/RunningApplicationsGrid.qml";
                    default: return "Generic/GenericFilterGrid.qml";
                }
            }
            default: return "Generic/GenericFilterGrid.qml";
        }
    }

    OpenEffect {
        id: effect
        anchors {
            fill: parent
            bottomMargin: -bottomOverflow
        }
        sourceItem: categoryView

        enabled: gap > 0.0

        topGapPx: (1 - gap) * positionPx
        topOpacity: (1 - gap * 1.2)
        bottomGapPx: positionPx + gap * (targetBottomGapPx - positionPx)
        bottomOverflow: units.gu(20)
        bottomOpacity: 1 - (gap * 0.8)

        property int targetBottomGapPx: height - units.gu(8) - bottomOverflow
        property real gap: previewLoader.open ? 1.0 : 0.0

        Behavior on gap {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
                onRunningChanged: {
                    if (!previewLoader.open && !running) {
                        previewLoader.onScreen = false
                    }
                }
            }
        }
    }

    Connections {
        target: scopeView.scope
        onPreviewReady: {
            previewLoader.previewData = preview
            previewLoader.open = true
        }
    }

    PreviewDelegateMapper {
        id: previewDelegateMapper
    }

    Connections {
        ignoreUnknownSignals: true
        target: previewLoader.valid ? previewLoader.item : null
        onClose: {
            previewLoader.open = false
        }
    }

    Loader {
        objectName: "previewLoader"
        id: previewLoader
        property var previewData
        height: effect.bottomGapPx - effect.topGapPx
        anchors {
            top: parent.top
            topMargin: effect.topGapPx
            left: parent.left
            right: parent.right
        }
        source: onScreen ? previewDelegateMapper.map(previewLoader.previewData.rendererName) : ""

        property bool open: false
        property bool onScreen: false
        property bool valid: item !== null

        onOpenChanged: {
            if (open) {
                onScreen = true
            }
        }

        onLoaded: {
            item.previewData = Qt.binding(function() { return previewLoader.previewData })
        }

        function closePreviewSpinner() {
            if(item) {
                item.showProcessingAction = false;
            }
        }
    }

    // TODO: Move as InverseMouseArea to DashPreview
    MouseArea {
        enabled: previewLoader.onScreen
        anchors {
            fill: parent
            topMargin: effect.bottomGapPx
        }
        onClicked: {
            previewLoader.open = false;
        }
    }
}
