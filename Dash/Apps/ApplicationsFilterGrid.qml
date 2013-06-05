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

FilterGrid {
    id: filterGrid

    filter: true
    expandable: false
    minimumHorizontalSpacing: units.gu(0.5)
    maximumNumberOfColumns: 6
    delegateWidth: units.gu(11)
    delegateHeight: units.gu(9.5)
    verticalSpacing: units.gu(2)

    signal clicked(int index, variant data)

    delegate: Tile {
        objectName: "delegate" + index
        Application {
            id: application
            desktopFile: model.column_6 ? stripProtocol(model.column_6) : model.desktopFile // FIXME: this is temporary

            function stripProtocol(uri) {
                var chunks = uri.split('file://')
                return chunks[chunks.length-1]
            }
        }

        property string icon: model.column_1 ? model.column_1 : "../../graphics/applicationIcons/" + application.icon + ".png" // FIXME: this is temporary

        width: filterGrid.cellWidth
        height: filterGrid.cellHeight
        text: model.column_4 ? model.column_4 : application.name // FIXME: this is temporary
        imageWidth: units.gu(8)
        imageHeight: units.gu(7.5)
        source: icon.indexOf("/") == -1 ? "image://gicon/" + icon : icon
        onClicked: filterGrid.clicked(index, application.desktopFile);
    }
}
