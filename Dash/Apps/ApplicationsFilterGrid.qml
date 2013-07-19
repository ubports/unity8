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
import "../../Applications"
import "../../Components/IconUtil.js" as IconUtil

FilterGrid {
    id: filterGrid

    filter: false
    expandable: false
    minimumHorizontalSpacing: units.gu(0.5)
    maximumNumberOfColumns: 6
    delegateWidth: units.gu(11)
    delegateHeight: units.gu(9.5)
    verticalSpacing: units.gu(2)

    signal clicked(int index, variant data, real itemY)

    delegate: Tile {
        id: tile
        objectName: "delegate" + index
        Application {
            id: application
            desktopFile: model.dndUri ? stripProtocol(model.dndUri) : model.desktopFile // FIXME: this is temporary

            function stripProtocol(uri) {
                var chunks = uri.split('file://')
                return chunks[chunks.length-1]
            }
        }

        property string icon: model.icon ? model.icon : "../../graphics/applicationIcons/" + application.icon + ".png" // FIXME: this is temporary

        width: filterGrid.cellWidth
        height: filterGrid.cellHeight
        text: model.title ? model.title : application.name // FIXME: this is temporary
        imageWidth: units.gu(8)
        imageHeight: units.gu(7.5)
        source: IconUtil.from_gicon(icon)
        onClicked: filterGrid.clicked(index, application.desktopFile, tile.y);
    }
}
