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
import ListViewWithPageHeader 0.1
import Dee 3.0
import Unity 0.1
import Utils 0.1
import "../Components"
import "../Components/ListItems" as ListItems
import "People"

LensView {
    id: lensView
    property alias previewShown: previewLoader.onScreen

    onIsCurrentChanged: {
        pageHeader.resetSearch();
    }

    onMovementStarted: categoryView.showHeader()

    Binding {
        target: lensView.lens
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
                        previewLoader.onScreen = false;
                    }
                }
            }
        }
    }

    ListViewWithPageHeader {
        id: categoryView
        anchors.fill: parent
        model: lensView.categories
        onAtYEndChanged: if (atYEnd) endReached()
        onMovingChanged: if (moving && atYEnd) endReached()
        // clipListView: !previewLoader.onScreen

        delegate: ListItems.Base {
            id: base
            property int categoryIndex: index
            property int categoryId: id
            highlightWhenPressed: false

            Loader {
                width: categoryView.width
                sourceComponent: base.categoryId == 0 ? peopleCarouselComponent : peopleGridComponent

                onLoaded: {
                    item.categoryId = Qt.binding(function() { return base.categoryId; })
                    item.categoryIndex = Qt.binding(function() { return base.categoryIndex; })
                    item.model = results;
                }
            }
        }

//         sectionProperty: "name"
//         sectionDelegate: ListItems.Header {
//             width: categoryView.width
//             text: section
//         }
        pageHeader: PageHeader {
            id: pageHeader
            width: categoryView.width
            text: i18n.tr("People")
            searchEntryEnabled: true
            searchHistory: lensView.searchHistory
        }
    }

    Component {
        id: peopleCarouselComponent
        PeopleCarousel {
            id: peopleCarousel

            property int categoryId
            property int categoryIndex

            onClicked: {
                effect.positionPx = mapToItem(categoryView, 0, itemY).y;
                previewData.model = delegateItem.dataModel;
                previewData.uri = delegateItem.dataModel.uri;
                previewLoader.open = true;
            }
        }
    }

    Component {
        id: peopleGridComponent
        PeopleFilterGrid {
            id: peopleGrid

            property int categoryIndex

            onClicked: {
                if (peopleGrid.columnCount == 1) {
                    if (categoryIndex >= categoryView.model.count -1 && index >= peopleGrid.model.count - 1) {
                        effect.positionPx = mapToItem(categoryView, 0, itemY).y;
                    } else {
                        effect.positionPx = mapToItem(categoryView, 0, itemY + peopleGrid.cellHeight).y
                    }
                } else {
                    effect.positionPx = mapToItem(categoryView, 0, itemY).y
                }
                previewData.model = data;
                previewData.uri = data.uri
                previewLoader.open = true;
            }
        }
    }

    Loader {
        id: previewLoader
        height: effect.bottomGapPx - effect.topGapPx
        anchors {
            top: parent.top
            topMargin: effect.topGapPx
            left: parent.left
            right: parent.right
        }
        sourceComponent: onScreen ? previewComponent : undefined

        property bool open: false
        property bool onScreen: false
        property QtObject videoItem

        onOpenChanged: {
            if (open) {
                onScreen = true
            }
        }

        onLoaded: {
            if (previewData.ready) {
                item.model = previewData;
            }
        }
    }

    Component {
        id: previewComponent

        PeoplePreview {
            id: preview
            anchors.fill: parent
            forceSquare: true
            onClose: {
                open = false;
            }
        }
    }

    PeoplePreviewData {
        id: previewData
        lens: lensView.lens
        property Data model

        onError: previewLoader.open = false
        onReadyChanged: {
            if (previewLoader.item) {
                previewLoader.item.model = ready ? previewData : undefined
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
