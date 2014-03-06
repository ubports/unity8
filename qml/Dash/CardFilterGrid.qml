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
            template: cardTool.template
            components: cardTool.components

            headerAlignment: cardTool.headerAlignment

            onClicked: genericFilterGrid.clicked(index, card.y)
            onPressAndHold: genericFilterGrid.pressAndHold(index, card.y)
        }
    }
}
