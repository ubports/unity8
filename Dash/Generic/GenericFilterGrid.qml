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
import "../../Components/IconUtil.js" as IconUtil

FilterGrid {
    id: filtergrid

    minimumHorizontalSpacing: units.gu(0.5)
    delegateWidth: units.gu(11)
    delegateHeight: units.gu(9.5)
    verticalSpacing: units.gu(2)

    property int iconWidth: units.gu(8)
    property int iconHeight: units.gu(7.5)

    signal clicked(int index, var delegateItem, real itemY)
    signal pressAndHold(int index, var delegateItem, real itemY)

    delegate: Tile {
        id: tile
        objectName: "delegate" + index
        width: filtergrid.cellWidth
        height: filtergrid.cellHeight
        text: model.title
        imageWidth: filtergrid.iconWidth
        imageHeight: filtergrid.iconHeight

        source: IconUtil.from_gicon(model.icon)

        fillMode: Image.PreserveAspectCrop

        onClicked: {
            var data = { model: model }
            filtergrid.clicked(index, data, tile.y)
        }

        onPressAndHold: {
            var data = { model: model }
            filtergrid.pressAndHold(index, data, tile.y)
        }
    }
}
