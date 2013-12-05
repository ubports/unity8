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
    // FIXME calculate the size correctly
    delegateWidth: grid.currentItem.width
    delegateHeight: grid.currentItem.height
    verticalSpacing: units.gu(2)

    delegate: Card {
        id: tile
        objectName: "delegate" + index
        cardData: model
        template: genericFilterGrid.template
        components: {
            "art": {
                "aspect-ratio": 1.0,
                "fill-mode": "crop"
            }
        }

        //onClicked: genericFilterGrid.clicked(index, tile.y)
        //onPressAndHold: genericFilterGrid.pressAndHold(index, tile.y)
    }
}
