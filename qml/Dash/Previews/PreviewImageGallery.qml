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
import Ubuntu.Components 1.1
import "../../Components"

/*! This preview widget shows a horizontal list of images.
 *  The URIs for the images should be an array in widgetData["sources"].
 */

PreviewWidget {
    id: root
    implicitHeight: units.gu(22)

    property Item rootItem: QuickUtils.rootItem(root)

    ListView {
        id: previewImageListView
        objectName: "previewImageListView"
        spacing: units.gu(1)
        anchors.fill: parent
        orientation: ListView.Horizontal
        cacheBuffer: width * 3
        model: root.widgetData["sources"]
        clip: true

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
            objectName: "previewImage" + index
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            source: modelData ? modelData : ""
            scaleTo: "height"
            initialWidth: units.gu(13)
            borderSource: mouseArea.pressed ? "radius_pressed.sci" : "radius_idle.sci"

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    slideShowListView.currentIndex = index;
                    slideShow.initialX = rootItem.mapFromItem(parent, 0, 0).x
                    slideShow.initialY = rootItem.mapFromItem(parent, 0, 0).y
                    slideShow.visible = true;
                }
            }
        }
    }

    Rectangle {
        id: slideShow
        objectName: "slideShow"

        readonly property real initialScale: previewImageListView.height / rootItem.height
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
            x: slideShow.initialX - slideShow.initialX * slideShow.scaleProgress
            y: slideShow.initialY - slideShow.initialY * slideShow.scaleProgress
        }
        color: "black"
        radius: units.gu(1) - units.gu(1) * slideShow.scaleProgress

        Behavior on scale {
            enabled: !slideShow.visible
            UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration }
        }

        ListView  {
            id: slideShowListView
            objectName: "slideShowListView"
            anchors.fill: parent
            orientation: ListView.Horizontal
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 0
            snapMode: ListView.SnapOneItem
            boundsBehavior: Flickable.DragAndOvershootBounds
            model: root.widgetData["sources"]

            delegate: Image {
                id: screenshot
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: slideShow.width
                source: modelData ? modelData : ""
                fillMode: Image.PreserveAspectFit
                sourceSize { width: screenshot.width; height: screenshot.height }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: slideShowHeader.shown = !slideShowHeader.shown
            }
        }

        Rectangle {
            id: slideShowHeader

            property bool shown: true

            anchors {
                left: parent.left
                right: parent.right
            }
            height: units.gu(7)
            visible: opacity > 0
            opacity: slideShow.scaleProgress > 0.6 && shown ? 0.8 : 0
            color: "black"

            Behavior on opacity {
                UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration }
            }

            AbstractButton {
                id: slideShowCloseButton
                objectName: "slideShowCloseButton"
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: units.gu(8)
                height: width

                onClicked: slideShow.visible = false

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.3)
                    visible: slideShowCloseButton.pressed
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
