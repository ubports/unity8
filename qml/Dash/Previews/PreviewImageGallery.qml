/*
 * Copyright (C) 2014 Canonical, Ltd.
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

/*! This preview widget shows a horizontal list of images.
 *  The URIs for the images should be an array in widgetData["sources"].
 */

PreviewWidget {
    id: root
    implicitHeight: units.gu(22)

    ListView {
        id: previewImageListView
        spacing: units.gu(1)
        anchors.fill: parent
        orientation: ListView.Horizontal
        cacheBuffer: width * 3
        model: root.widgetData["sources"]

        LazyImage {
            objectName: "placeholderScreenshot"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            scaleTo: "height"
            source: "broken_image"
            initialWidth: units.gu(13)
            visible: previewImageListView.count == 0
        }

        delegate: LazyImage {
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            source: modelData ? modelData : ""
            scaleTo: "height"
            initialWidth: units.gu(13)
        }
    }
}
