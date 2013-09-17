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

    onIsCurrentChanged: {
        pageHeader.resetSearch();
        previewLoader.open = false;
    }

    onMovementStarted: categoryView.showHeader()

    Binding {
        target: scopeView.scope
        property: "searchQuery"
        value: pageHeader.searchQuery
    }

    Connections {
        target: panel
        onSearchClicked: if (isCurrent) {
            pageHeader.triggerSearch()
            categoryView.showHeader()
        }
    }

    ScopeListView {
        id: categoryView
        anchors.fill: parent
        model: scopeView.categories
        forceNoClip: previewLoader.onScreen

        onAtYEndChanged: if (atYEnd) endReached()
        onMovingChanged: if (moving && atYEnd) endReached()

        property int expandedIndex: -1

        delegate: ListItems.Base {
            highlightWhenPressed: false

            readonly property bool expandable: rendererLoader.item ? rendererLoader.item.expandable : false
            readonly property bool filtered: rendererLoader.item ? rendererLoader.item.filter : true

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
                        var shouldFilter = index != categoryView.expandedIndex;
                        if (shouldFilter != item.filter) {
                            item.filter = shouldFilter;
                        }
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
                    onExpandedIndexChanged: {
                        var item = rendererLoader.item;
                        if (item.expandable) {
                            var shouldFilter = index != categoryView.expandedIndex;
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
                if (categoryView.expandedIndex != delegateIndex)
                    categoryView.expandedIndex = delegateIndex;
                else
                    categoryView.expandedIndex = -1;
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
        switch (rendererId) {
            case "grid": {
                switch (contentType) {
                    case "video": return "Generic/GenericFilterGridPotrait.qml";
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
