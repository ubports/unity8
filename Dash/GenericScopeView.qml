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
    readonly property alias previewShown: previewListView.onScreen

    onIsCurrentChanged: {
        pageHeader.resetSearch();
        previewListView.open = false;
    }

    onMovementStarted: categoryView.showHeader()

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
        onShowDash: previewListView.open = false;
        onHideDash: previewListView.open = false;
    }

    ScopeListView {
        id: categoryView
        anchors.fill: parent
        model: scopeView.categories
        forceNoClip: previewListView.onScreen

        onAtYEndChanged: if (atYEnd) endReached()
        onMovingChanged: if (moving && atYEnd) endReached()

        property string expandedCategoryId: ""
        signal correctExpandedCategory();

        Behavior on contentY {
            enabled: previewListView.open
            UbuntuNumberAnimation {}
        }

        delegate: ListItems.Base {
            id: rendererDelegate
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

                source: getRenderer(model.renderer, model.contentType)

                onLoaded: {
                    if (source.toString().indexOf("Apps/RunningApplicationsGrid.qml") != -1) {
                        // TODO: the running apps grid doesn't support standard scope results model yet
                        item.firstModel = Qt.binding(function() { return results.firstModel })
                        item.secondModel = Qt.binding(function() { return results.secondModel })
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
                }

                Connections {
                    target: rendererLoader.item
                    onClicked: {
                        // Prepare the preview in case activate() triggers a preview only
                        effect.positionPx = mapToItem(categoryView, 0, itemY).y
                        previewListView.categoryId = categoryId
                        previewListView.categoryDelegate = rendererLoader.item
                        previewListView.model = model;
                        previewListView.init = true;
                        previewListView.currentIndex = index;

                        var item = model.get(index);

                        if ((scopeView.scope.id == "applications.scope" && categoryId == "installed")
                                || (scopeView.scope.id == "home.scope" && categoryId == "applications.scope")) {
                            scopeView.scope.activate(item.uri, item.icon, item.category, 0, item.mimetype, item.title,
                                                     item.comment, item.dndUri, item.metadata)
                        } else {
                            previewListView.open = true

                            scopeView.scope.preview( item.uri, item.icon, item.category, 0, item.mimetype, item.title,
                                                     item.comment, item.dndUri, item.metadata)
                        }
                    }
                    onPressAndHold: {
                        effect.positionPx = mapToItem(categoryView, 0, itemY).y
                        previewListView.categoryId = categoryId
                        previewListView.categoryDelegate = rendererLoader.item
                        previewListView.model = model;
                        previewListView.init = true;
                        previewListView.currentIndex = index;
                        previewListView.open = true

                        var item = model.get(index)
                        scopeView.scope.preview( item.uri, item.icon, item.category, 0, item.mimetype, item.title,
                                                item.comment, item.dndUri, item.metadata)
                    }
                }
                Connections {
                    target: categoryView
                    onExpandedCategoryIdChanged: {
                        collapseAllButExpandedCategory();
                    }
                    onCorrectExpandedCategory: {
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
                                    if (shrinkingVisible || growingVisible) {
                                        item.startFilterAnimation(shouldFilter)
                                    } else {
                                        item.filter = shouldFilter;
                                    }
                                    if (!shouldFilter && !previewListView.open) {
                                        categoryView.maximizeVisibleArea(index, item.uncollapsedHeight);
                                    }
                                }
                            }
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
        }
    }

    function getDefaultRendererId(contentType) {
        switch (contentType) {
            default: return "grid";
        }
    }

    function getRenderer(rendererId, contentType) {
        if (rendererId == "default") {
            rendererId = getDefaultRendererId(contentType);
        }
        return "Generic/GenericCarousel.qml";
        switch (rendererId) {
            case "grid": {
                switch (contentType) {
                    case "video": return "Generic/GenericFilterGridPotrait.qml";
                    case "music": return "Music/MusicFilterGrid.qml";
                    default: return "Generic/GenericFilterGrid.qml";
                }
            }
            case "carousel": return "Generic/GenericCarousel.qml";
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
        live: true

        property int targetBottomGapPx: height - units.gu(8) - bottomOverflow
        property real gap: previewListView.open ? 1.0 : 0.0

        Behavior on gap {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
                onRunningChanged: {
                    if (!previewListView.open && !running) {
                        previewListView.onScreen = false
                    }
                }
            }
        }
        Behavior on positionPx {
            enabled: previewListView.open
            UbuntuNumberAnimation {}
        }
    }

    Connections {
        target: scopeView.scope
        onPreviewReady: {
            if (previewListView.init) {
                // Preview was triggered because of a click on the item. Need to expand now.
                if (!previewListView.open) {
                    previewListView.open = true
                }

                var index = previewListView.currentIndex
                previewListView.currentIndex = -1
                previewListView.currentIndex = index
                previewListView.init = false
            }
            previewListView.currentItem.previewData = preview
        }
    }

    PreviewDelegateMapper {
        id: previewDelegateMapper
    }

    ListView  {
        id: previewListView
        objectName: "previewListView"
        height: effect.bottomGapPx - effect.topGapPx
        anchors {
            top: parent.top
            topMargin: effect.topGapPx
            left: parent.left
            right: parent.right
        }
        orientation: ListView.Horizontal
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.DragAndOvershootBounds
        highlightMoveDuration: 250
        flickDeceleration: units.gu(625)
        maximumFlickVelocity: width * 5
        cacheBuffer: 0

        // To be set before opening the preview
        property string categoryId: ""
        property var categoryDelegate

        // because the ListView is built asynchronous, setting the
        // currentIndex directly won't work. We need to refresh it
        // when the first preview is ready to be displayed.
        property bool init: true

        // Used internally
        property int oldRow: -1
        property bool categoryWasFiltered: false
        property int initialContenY: 0

        onCurrentIndexChanged: {
            var row = Math.floor(currentIndex / categoryDelegate.columns);
            if (!init && model !== undefined) {
                var item = model.get(currentIndex)
                scopeView.scope.preview( item.uri, item.icon, item.category, 0, item.mimetype, item.title, item.comment, item.dndUri, item.metadata)
                if (oldRow != -1) {
                    if (row < oldRow) {
                        if (categoryView.contentY - categoryDelegate.cellHeight < 0) {
                            effect.positionPx -= categoryDelegate.cellHeight - categoryView.contentY
                        }
                        categoryView.contentY = Math.max(0, categoryView.contentY - categoryDelegate.cellHeight)
                    } else if (row > oldRow){
                        if (categoryView.contentY + categoryDelegate.cellHeight > categoryView.contentHeight - categoryView.height) {
                            effect.positionPx += categoryDelegate.cellHeight - (categoryView.contentY - (categoryView.contentHeight - categoryView.height))
                        }
                        categoryView.contentY = Math.min(categoryView.contentHeight - categoryView.height, categoryView.contentY + categoryDelegate.cellHeight)
                    }
                }
            }
            oldRow = row;
            if (categoryDelegate.collapsedRowCount <= row) {
                categoryView.expandedCategoryId = categoryId
            }

            if (open) {
                categoryDelegate.highlightIndex = currentIndex
            }
        }

        property bool open: false
        property bool onScreen: false

        onOpenChanged: {
            if (open) {
                onScreen = true;
                categoryDelegate.highlightIndex = currentIndex;
            } else {
                // Cancel any pending preview requests or actions
                if (previewListView.currentItem.previewData !== undefined) {
                    previewListView.currentItem.previewData.cancelAction();
                }
                scopeView.scope.cancelActivation();
                model = undefined;
                categoryView.correctExpandedCategory();
                categoryDelegate.highlightIndex = -1;
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, .3)
        }

        delegate: Loader {
            id: previewLoader
            objectName: "previewLoader"
            height: previewListView.height
            width: previewListView.width
            asynchronous: true
            source: previewListView.onScreen ?
                         (previewData !== undefined ? previewDelegateMapper.map(previewData.rendererName) : "DashPreviewPlaceholder.qml") : ""

            onPreviewDataChanged: {
                if (previewData !== undefined && source.toString().indexOf("DashPreviewPlaceholder.qml") != -1) {
                    previewLoader.opacity = 0;
                }
            }

            onSourceChanged: {
                if (previewData !== undefined) {
                    fadeIn.start()
                }
            }

            PropertyAnimation {
                id: fadeIn
                target: previewLoader
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: UbuntuAnimation.BriskDuration
            }

            property var previewData
            property bool valid: item !== null

            onLoaded: {
                if (previewListView.onScreen && previewData !== undefined) {
                    item.previewData = Qt.binding(function() { return previewData })
                }
            }

            Connections {
                ignoreUnknownSignals: true
                target: item
                onClose: {
                    previewListView.open = false
                }
            }
        }
    }

    Image {
        anchors {
            top: previewListView.bottom
            left: parent.left
            leftMargin: previewListView.categoryDelegate.currentItem ?
                            previewListView.categoryDelegate.currentItem.center - (width + margins) / 2 : 0

            Behavior on leftMargin {
                UbuntuNumberAnimation {}
            }
        }
        height: units.gu(1)
        width: units.gu(2)
        property int margins: previewListView.categoryDelegate ? previewListView.categoryDelegate.margins : 0
        opacity: previewListView.open ? .5 : 0

        source: "graphics/tooltip_arrow.png"
    }

    // TODO: Move as InverseMouseArea to DashPreview
    MouseArea {
        enabled: previewListView.onScreen
        anchors {
            fill: parent
            topMargin: effect.bottomGapPx
        }
        onClicked: {
            previewListView.open = false;
        }
    }
}
