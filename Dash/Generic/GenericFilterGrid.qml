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
import "../../Components"
import ".."

DashFilterGrid {
    id: genericFilterGrid

    property int iconWidth: units.gu(8)
    property int iconHeight: units.gu(7.5)

    minimumHorizontalSpacing: units.gu(0.5)
    delegateWidth: units.gu(11)
    delegateHeight: units.gu(9.5)
    verticalSpacing: units.gu(2)

    delegate: Tile {
        id: tile
        objectName: "delegate" + index
        width: genericFilterGrid.cellWidth
        height: genericFilterGrid.cellHeight
        text: model.title
        imageWidth: genericFilterGrid.iconWidth
        imageHeight: genericFilterGrid.iconHeight
        source: model.icon

        onClicked: genericFilterGrid.clicked(index, tile.y)
        onPressAndHold: genericFilterGrid.pressAndHold(index, tile.y)
    }
}
