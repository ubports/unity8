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
import "../Generic"

GenericFilterGrid {
    id: filtergrid

    delegateWidth: units.gu(11)
    delegateHeight: units.gu(15)

    iconWidth: units.gu(11)
    iconHeight: units.gu(11)

    delegate: Tile {
        id: tile
        objectName: "delegate" + index
        width: filtergrid.cellWidth
        height: filtergrid.cellHeight
        text: model.title
        imageWidth: filtergrid.iconWidth
        imageHeight: filtergrid.iconHeight
        source: model.icon
        maximumLineCount: 2
        horizontalAlignment: Text.AlignLeft

        style: VideoTileStyle {}

        onClicked: {
            filtergrid.clicked(index, filtergrid.model, tile.y)
        }

        onPressAndHold: {
            filtergrid.pressAndHold(index, filtergrid.model, tile.y)
        }
    }
}
