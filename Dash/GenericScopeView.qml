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
    property bool enableHeightBehaviorOnNextCreation: false

    moving: categoryView.moving

    onIsCurrentChanged: {
        pageHeader.resetSearch();
        previewListView.open = false;
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
        onShowDash: previewListView.open = false;
        onHideDash: previewListView.open = false;
    }

    ScopeListView {
        id: categoryView
        objectName: "categoryListView"
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
                        effect.positionPx = Math.max(mapToItem(categoryView, 0, itemY).y, pageHeader.height + units.gu(5));
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
        objectName: "openEffect"
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
        live: !expansionAnimation.running

        property int targetBottomGapPx: height - units.gu(8) - bottomOverflow
        property real gap: previewListView.open ? 1.0 : 0.0

        Behavior on gap {
            NumberAnimation {
                id: expansionAnimation
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

        onCurrentIndexChanged: {
            var row = Math.floor(currentIndex / categoryDelegate.columns);
            if (categoryDelegate.collapsedRowCount <= row) {
                categoryView.expandedCategoryId = categoryId
            }

            if (open) {
                categoryDelegate.highlightIndex = currentIndex
            }

            if (!init && model !== undefined) {
                var item = model.get(currentIndex)
                scopeView.scope.preview(item.uri, item.icon, item.category, 0, item.mimetype, item.title, item.comment, item.dndUri, item.metadata)
            }

            var itemY = categoryView.contentItem.mapFromItem(categoryDelegate.currentItem).y;

            // Find new contentY and effect.postionPx
            var newContentY = itemY - effect.positionPx - categoryDelegate.verticalSpacing;

            // Make sure the item is not covered by a header. Move the effect split down if necessary
            var headerHeight = pageHeader.height + units.gu(5); // sectionHeader's height
            var effectAdjust = Math.max(effect.positionPx, headerHeight);

            // Make sure we don't overscroll the listview. If yes, adjust effect position
            if (newContentY < 0) {
                effectAdjust += newContentY;
                newContentY = 0;
            }
            if (newContentY > Math.max(0, categoryView.contentHeight - categoryView.height)) {
                effectAdjust += -(categoryView.contentHeight - categoryView.height) + newContentY
                newContentY = categoryView.contentHeight - categoryView.height;
            }

            effect.positionPx = effectAdjust;
            categoryView.contentY = newContentY;
        }

        property bool open: false
        property bool onScreen: false

        onOpenChanged: {
            if (open) {
                onScreen = true;
                categoryDelegate.highlightIndex = currentIndex;
                pageHeader.unfocus();
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
            z: -1
        }

        delegate: Loader {
            id: previewLoader
            objectName: "previewLoader" + index
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

            function closePreviewSpinner() {
                if(item) {
                    item.showProcessingAction = false;
                }
            }
        }
    }

    Image {
        objectName: "pointerArrow"
        anchors {
            top: previewListView.bottom
            left: parent.left
            leftMargin: previewListView.categoryDelegate !== undefined && previewListView.categoryDelegate.currentItem ?
                            previewListView.categoryDelegate.currentItem.center + (-width + margins) / 2 : 0

            Behavior on leftMargin {
                SmoothedAnimation {
                    duration: UbuntuAnimation.FastDuration
                }
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
        objectName: "closePreviewMouseArea"
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
