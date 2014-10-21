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
        }
        scaleTo: "height"
        source: widgetData["source"]

        borderSource: mouseArea.pressed ? "radius_pressed.sci" : "radius_idle.sci"

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                zoomableImageContainer.initialX = rootItem.mapFromItem(parent, 0, 0).x
                zoomableImageContainer.initialY = rootItem.mapFromItem(parent, 0, 0).y
                zoomableImageContainer.visible = true;
            }
        }
    }

    Rectangle {
        id: zoomableImageContainer
        objectName: "zoomableImageContainer"

        readonly property real initialScale: lazyImage.height / rootItem.height
        readonly property real scaleProgress: (scale - initialScale) / (1.0 - initialScale)
        property real initialX: 0
        property real initialY: 0

        parent: rootItem
        width: parent.width
        height: parent.height
        visible: false
        clip: visible && scale < 1.0
        scale: visible ? 1.0 : initialScale
        transformOrigin: Item.TopLeft
        transform: Translate {
            x: zoomableImageContainer.initialX - zoomableImageContainer.initialX * zoomableImageContainer.scaleProgress
            y: zoomableImageContainer.initialY - zoomableImageContainer.initialY * zoomableImageContainer.scaleProgress
        }
        color: "black"
        radius: units.gu(1) - units.gu(1) * zoomableImageContainer.scaleProgress

        Behavior on scale {
            enabled: !zoomableImageContainer.visible
            UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration }
        }

        ZoomableImage {
            id: screenshot
            anchors.fill: parent
            source: widgetData["source"]
            zoomable: widgetData["zoomable"] ? widgetData["zoomable"] : false
        }

        Rectangle {
            id: zoomableImageHeader

            anchors {
                left: parent.left
                right: parent.right
            }
            height: units.gu(7)
            visible: opacity > 0
            opacity: zoomableImageContainer.scaleProgress > 0.6 ? 0.8 : 0
            color: "black"

            Behavior on opacity {
                UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration }
            }

            AbstractButton {
                id: zoomableImageCloseButton
                objectName: "zoomableImageCloseButton"
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: units.gu(8)
                height: width

                onClicked: zoomableImageContainer.visible = false

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.3)
                    visible: zoomableImageCloseButton.pressed
                }

                Icon {
                    id: icon
                    anchors.centerIn: parent
                    width: units.gu(2.5)
                    height: width
                    color: Theme.palette.normal.foregroundText
                    name: "close"
                }
            }
        }
    }
}
