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
import "../Components/IconUtil.js" as IconUtil
import "Generic"

ScopeView {
    id: scopeView

    onIsCurrentChanged: {
        pageHeader.resetSearch();
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
        onAtYEndChanged: if (atYEnd) endReached()
        onMovingChanged: if (moving && atYEnd) endReached()

        delegate: ListItems.Base {
            highlightWhenPressed: false

            FilterGrid {
                id: filtergrid
                model: results

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                filter: false
                minimumHorizontalSpacing: units.gu(0.5)
                delegateWidth: units.gu(11)
                delegateHeight: units.gu(18)
                verticalSpacing: units.gu(2)

                delegate: Tile {
                    width: filtergrid.cellWidth
                    height: filtergrid.cellHeight
                    text: title
                    imageWidth: units.gu(11)
                    imageHeight: units.gu(16)

                    source: IconUtil.from_gicon(icon)

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                            mouse.accepted = true
                            effect.positionPx = mapToItem(categoryView, 0, 0).y
                            scopeView.scope.activate(column_0, column_1,
                                                     column_2, column_3,
                                                     column_4, column_5,
                                                     column_6, column_7,
                                                     column_8)
                        }
                        onPressAndHold: {
                            mouse.accepted = true
                            effect.positionPx = mapToItem(categoryView, 0, 0).y
                            scopeView.scope.preview(column_0, column_1,
                                                    column_2, column_3,
                                                    column_4, column_5,
                                                    column_6, column_7,
                                                    column_8)
                        }
                    }
                }
            }
        }

        sectionProperty: "name"
        sectionDelegate: ListItems.Header {
            width: categoryView.width
            text: section
        }
        pageHeader: PageHeader {
            id: pageHeader
            objectName: "pageHeader"
            width: categoryView.width
            text: scopeView.scope.name
            searchEntryEnabled: true
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
            item.previewData = previewLoader.previewData
        }
    }
}
