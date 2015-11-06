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

import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Components"

/*! \brief Zoomable for image.

    This widget shows image contained in source,
    can be zoomable accordingly with zoomable.
 */

Item {
    id: root
    property alias source: imageRenderer.source
    property var zoomable: false
    property alias imageStatus: imageRenderer.status
    property alias asynchronous: imageRenderer.asynchronous
    readonly property alias status: imageRenderer.status

    Flickable {
        id: flickable
        objectName: "flickable"
        clip: true // FIXME maybe we can remove this, or just not clip in few cases
        contentHeight: imageContainer.height
        contentWidth: imageContainer.width

        onHeightChanged: image.resetScale()
        onWidthChanged: image.resetScale()
        anchors.fill: parent

        Item {
            id: imageContainer
            objectName: "imageContainer"
            width: Math.max(image.width * image.scale, flickable.width)
            height: Math.max(image.height * image.scale, flickable.height)

            Item {
                id: image
                objectName: "image"
                property alias imageStatus: imageRenderer.status
                property var prevScale
                anchors.centerIn: parent

                signal imageReloaded

                Image {
                    id: imageRenderer
                    objectName: "imageRenderer"
                    smooth: !flickable.movingVertically
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit

                    readonly property int sourceSizeMultiplier: 3

                    sourceSize.width: root.width * sourceSizeMultiplier <= root.height * sourceSizeMultiplier ? root.width * sourceSizeMultiplier : 0
                    sourceSize.height: root.height * sourceSizeMultiplier <= root.width * sourceSizeMultiplier ? root.height * sourceSizeMultiplier : 0

                    onStatusChanged: {
                        if (status === Image.Ready) {
                            image.imageReloaded();
                        }
                    }
                }

                onImageReloaded: {
                    image.height = imageRenderer.implicitHeight
                    image.width = imageRenderer.implicitWidth
                    image.resetScale();
                }

                function resetScale() {
                    image.scale = Math.min(flickable.width / image.width, flickable.height / image.height);
                    pinchArea.minScale = image.scale;
                    prevScale = Math.min(image.scale, 1);
                }

                onScaleChanged: {
                    var currentWidth = width * scale
                    var currentHeight = height * scale
                    var scaleRatio = scale / prevScale
                    if (currentWidth > flickable.width) {
                        var xpos = flickable.width / 2 + flickable.contentX;
                        var xoff = xpos * scaleRatio;
                        flickable.contentX = xoff - flickable.width / 2;
                    }
                    if (currentHeight > flickable.height) {
                        var ypos = flickable.height / 2 + flickable.contentY;
                        var yoff = ypos * scaleRatio;
                        flickable.contentY = yoff - flickable.height / 2;
                    }
                    prevScale = scale;
                }
            }
        }

        PinchArea {
            id: pinchArea
            objectName: "pinchArea"
            property real minScale: 1.0
            anchors.fill: parent
            enabled: zoomable ? zoomable : false

            pinch.target: image
            pinch.minimumScale: minScale
            pinch.maximumScale: 10

            onPinchFinished: flickable.returnToBounds()
        }

        MouseArea {
            id: mouseArea
            objectName: "mouseArea"

            anchors.fill: parent
            enabled: zoomable ? zoomable : false

            onWheel: {
                var startScale = image.scale;
                if (wheel.angleDelta.y > 0) {
                    image.scale = startScale + 0.1;
                } else if (wheel.angleDelta.y < 0) {
                    if (image.scale > 0.1 && image.scale > pinchArea.minScale) {
                        image.scale = startScale - 0.1;
                    }
                }
                wheel.accepted = true;
            }

            onPressed: {
                mouse.accepted = false;
            }

            onReleased: {
                mouse.accepted = false;
            }

            onClicked: {
                mouse.accepted = false;
            }
        }
    }
}
