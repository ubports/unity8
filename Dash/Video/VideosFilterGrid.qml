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
    id: filtergrid

    expandable: false
    minimumHorizontalSpacing: units.gu(0.5)
    maximumNumberOfColumns: 5
    delegateWidth: units.gu(11)
    delegateHeight: iconHeight + units.gu(2.5)
    verticalSpacing: units.gu(2)

    readonly property int iconWidth: (width / columns) * 0.8
    readonly property int iconHeight: iconWidth * 16 / 11

    signal clicked(int index, var data, real itemY)

    delegate: Tile {
        id: tile
        objectName: "delegate" + index
        width: filtergrid.cellWidth
        height: filtergrid.cellHeight
        text: model.column_5
        imageWidth: filtergrid.iconWidth
        imageHeight: filtergrid.iconHeight
        source: model.column_1
        fillMode: Image.PreserveAspectCrop
        onClicked: {
            var fileUri = model.column_0.replace(/^[^:]+:/, "")
            var data = {fileUri: fileUri, nfoUri: model.column_6}
            filtergrid.clicked(index, data, tile.y);
        }
    }
}
