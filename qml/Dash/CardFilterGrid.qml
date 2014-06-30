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
import "../Components"

DashRenderer {
    id: genericFilterGrid

    expandable: filterGrid.expandable
    collapsedHeight: filterGrid.collapsedHeight
    uncollapsedHeight: filterGrid.uncollapsedHeight
    originY: filterGrid.originY
    height: filterGrid.height
    filtered: filterGrid.filtered

    function setFilter(filter, animate) {
        filterGrid.setFilter(filter, animate)
    }

    FilterGrid {
        id: filterGrid
        width: genericFilterGrid.width
        minimumHorizontalSpacing: units.gu(1)
        delegateWidth: cardTool.cardWidth
        delegateHeight: cardTool.cardHeight
        verticalSpacing: units.gu(1)
        model: genericFilterGrid.model
        collapsedRowCount: Math.min(2, cardTool && cardTool.template && cardTool.template["collapsed-rows"] || 2)
        displayMarginBeginning: genericFilterGrid.displayMarginBeginning
        displayMarginEnd: genericFilterGrid.displayMarginEnd
        delegate: Item {
            width: filterGrid.cellWidth
            height: filterGrid.cellHeight
            Loader {
                id: loader
                sourceComponent: cardTool.cardComponent
                anchors.horizontalCenter: parent.horizontalCenter
                onLoaded: {
                    item.objectName = "delegate" + index;
                    item.width = Qt.binding(function() { return cardTool.cardWidth; });
                    item.height = Qt.binding(function() { return cardTool.cardHeight; });
                    item.fixedArtShapeSize = Qt.binding(function() { return cardTool.artShapeSize; });
                    item.cardData = Qt.binding(function() { return model; });
                    item.template = Qt.binding(function() { return cardTool.template; });
                    item.components = Qt.binding(function() { return cardTool.components; });
                    item.headerAlignment = Qt.binding(function() { return cardTool.headerAlignment; });
                }
                Connections {
                    target: loader.item
                    onClicked: genericFilterGrid.clicked(index, result)
                    onPressAndHold: genericFilterGrid.pressAndHold(index)
                }
            }
        }
    }
}
