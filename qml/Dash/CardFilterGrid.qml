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

DashFilterGrid {
    id: genericFilterGrid

    minimumHorizontalSpacing: units.gu(0.5)
    delegateWidth: cardTool.cardWidth
    delegateHeight: cardTool.cardHeight
    verticalSpacing: units.gu(1)
    collapsedRowCount: Math.min(2, template && template["collapsed-rows"] || 2)

    CardTool {
        id: cardTool

        template: genericFilterGrid.template
        // We can't trust the template since it may happen it is carousel
        // that is being should as a grid because of the lack of elements
        categoryLayout: "grid"
        components: genericFilterGrid.components
    }

    delegate: Item {
        width: genericFilterGrid.cellWidth
        height: genericFilterGrid.cellHeight
        Card {
            id: card
            width: cardTool.cardWidth
            height: cardTool.cardHeight
            headerHeight: cardTool.headerHeight
            anchors.horizontalCenter: parent.horizontalCenter
            objectName: "delegate" + index
            cardData: model
            template: genericFilterGrid.template
            components: genericFilterGrid.components

            headerAlignment: cardTool.headerAlignment

            onClicked: genericFilterGrid.clicked(index, card.y)
            onPressAndHold: genericFilterGrid.pressAndHold(index, card.y)
        }
    }
}
