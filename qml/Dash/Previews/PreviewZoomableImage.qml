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
import Ubuntu.Components 0.1
import "../../Components"

/*! \brief Preview widget for image.

    This widget shows image contained in widgetData["source"],
    can be zoomable accordingly with widgetData["zoomable"].
 */

PreviewWidget {
    id: root
    implicitHeight: units.gu(22)

    ZoomableImage {
        id: image
        objectName: "image"
        source: widgetData["source"]
        zoomable: widgetData["zoomable"] ? widgetData["zoomable"] : false
        anchors.fill: parent
        asynchronous: true
    }
}
