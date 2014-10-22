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

    property Item rootItem: QuickUtils.rootItem(root)

    LazyImage {
        id: lazyImage
        objectName: "lazyImage"
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        scaleTo: "height"
        source: widgetData["source"]

        borderSource: mouseArea.pressed ? "radius_pressed.sci" : "radius_idle.sci"

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                overlay.initialX = rootItem.mapFromItem(parent, 0, 0).x;
                overlay.initialY = rootItem.mapFromItem(parent, 0, 0).y;
                overlay.show();
            }
        }
    }

    PreviewOverlay {
        id: overlay
        objectName: "overlay"
        parent: rootItem
        width: parent.width
        height: parent.height
        initialScale: lazyImage.height / rootItem.height

        delegate: ZoomableImage {
            anchors.fill: parent
            source: widgetData["source"]
            zoomable: widgetData["zoomable"] ? widgetData["zoomable"] : false
        }
    }
}
