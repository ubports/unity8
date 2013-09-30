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
import "../../Components"

FilterGrid {
    id: filterGrid

    minimumHorizontalSpacing: units.gu(2)
    maximumNumberOfColumns: 5
    delegateWidth: units.gu(17)
    delegateHeight: iconHeight + units.gu(3.5)
    verticalSpacing: units.gu(2)

    readonly property int iconWidth: (width / columns) * 0.8
    readonly property int iconHeight: iconWidth

    signal clicked(int index, var delegateItem, real itemY)
    signal pressAndHold(int index, var delegateItem, real itemY)

    delegate: AlbumTile {
        id: tile
        objectName: "delegate" + index
        width: filterGrid.cellWidth
        height: filterGrid.cellHeight
        iconWidth: filterGrid.iconWidth
        iconHeight: filterGrid.iconHeight

        artist: model.title
        album: model.comment
        source: model.icon

        onClicked: {
            var data = { model: model }
            filterGrid.clicked(index, data, tile.y)
        }

        onPressAndHold: {
            var data = { model: model }
            filterGrid.pressAndHold(index, data, tile.y)
        }
    }
}
