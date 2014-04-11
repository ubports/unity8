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
    margins: filterGrid.margins
    uncollapsedHeight: filterGrid.uncollapsedHeight
    originY: filterGrid.originY
    verticalSpacing: units.gu(1)
    currentItem: filterGrid.currentItem
    height: filterGrid.height

    function startFilterAnimation(filter) {
        filterGrid.startFilterAnimation(filter)
    }

    FilterGrid {
        id: filterGrid
        width: genericFilterGrid.width
        minimumHorizontalSpacing: units.gu(1)
        delegateWidth: cardTool.cardWidth
        delegateHeight: cardTool.cardHeight
        verticalSpacing: genericFilterGrid.verticalSpacing
        model: genericFilterGrid.model
        filter: genericFilterGrid.filter
        collapsedRowCount: Math.min(2, cardTool && cardTool.template && cardTool.template["collapsed-rows"] || 2)
        delegateCreationBegin: genericFilterGrid.delegateCreationBegin
        delegateCreationEnd: genericFilterGrid.delegateCreationEnd
        delegate: Item {
            width: filterGrid.cellWidth
            height: filterGrid.cellHeight
            Card {
                id: card
                width: cardTool.cardWidth
                height: cardTool.cardHeight
                headerHeight: cardTool.headerHeight
                anchors.horizontalCenter: parent.horizontalCenter
                objectName: "delegate" + index
                cardData: model
                template: cardTool.template
                components: cardTool.components

                headerAlignment: cardTool.headerAlignment

                onClicked: genericFilterGrid.clicked(index, card.y)
                onPressAndHold: genericFilterGrid.pressAndHold(index, card.y)
            }
        }

        onFilterChanged: {
            genericFilterGrid.filter = filter
            filter = Qt.binding(function() { return genericFilterGrid.filter })
        }
    }
}
