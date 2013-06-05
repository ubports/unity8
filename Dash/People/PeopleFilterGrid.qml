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
import "../../Components/ListItems" as ListItems

FilterGrid {
    id: filterGrid

    filter: true
    minimumHorizontalSpacing: 0
    delegateWidth: units.gu(40)
    delegateHeight: showStatusMessage ? units.gu(11.5) : units.gu(10)
    verticalSpacing: 0
    collapsedRowCount: 50 / columns
    expandable: false

    property int categoryId
    property bool showStatusMessage: categoryId == 1 || categoryId == 2

    readonly property int columnCount: width / cellWidth

    signal clicked(int index, variant data, real itemY)

    delegate: ListItems.Base {
        id: tile
        objectName: "delegate" + index
        width: filterGrid.cellWidth
        showDivider: index < Math.floor((filterGrid.model.count-1) / filterGrid.columnCount) * filterGrid.columnCount

        onClicked: {
            filterGrid.clicked(index, data, tile.y);
        }

        Delegate {
            width: filterGrid.cellWidth
            height: filterGrid.cellHeight
            // This caches the Delegate into FBO because:
            // - People data Delegates are slow because of their item count
            // - FilterGrid is "height: childrenRect.height" so all delegates are always loaded
            // TODO: Optimize this by:
            // - not loading all delegates all the time and remove layer.enabled and/or
            // - destroy whole lens when not visible/needed to free the GPU memory
            layer.enabled: true

            dataModel: data
            subtitleType: filterGrid.showStatusMessage ? "status" : "data"

            Data {
                id: data
                uri: column_0
                text: column_5
                name: column_4
                avatar: column_1
                favorite: filterGrid.categoryId == 0
                recent: filterGrid.showStatusMessage
            }
        }
    }
}
