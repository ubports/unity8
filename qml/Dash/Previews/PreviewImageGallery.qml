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

        onCurrentIndexChanged: overlay.updateInitialItem()

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
                    previewImageListView.currentIndex = index;
                    overlay.updateInitialItem();
                    overlay.show();
                }
            }
        }
    }

    PreviewOverlay {
        id: overlay
        objectName: "overlay"
        parent: rootItem
        anchors.fill: parent

        function updateInitialItem() {
            initialX = rootItem.mapFromItem(previewImageListView.currentItem, 0, 0).x;
            initialY = rootItem.mapFromItem(previewImageListView.currentItem, 0, 0).y;
            initialWidth = previewImageListView.currentItem.width;
            initialHeight = previewImageListView.currentItem.height;
        }

        delegate: ListView {
            id: overlayListView
            objectName: "overlayListView"
            anchors.fill: parent
            orientation: ListView.Horizontal
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 0
            snapMode: ListView.SnapOneItem
            boundsBehavior: Flickable.DragAndOvershootBounds
            model: root.widgetData["sources"]
            currentIndex: previewImageListView.currentIndex

            onCurrentIndexChanged: {
                // if the index changed while overlay is visible, it was from user interaction,
                // let's update the index of the original listview
                if (overlay.visible) {
                    previewImageListView.highlightMoveDuration = 0;
                    previewImageListView.highlightResizeDuration = 0;
                    previewImageListView.currentIndex = currentIndex;
                    previewImageListView.highlightMoveDuration = -1;
                    previewImageListView.highlightResizeDuration = -1;
                }
            }

            delegate: Image {
                id: screenshot
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: overlay.width
                source: modelData ? modelData : ""
                fillMode: Image.PreserveAspectFit
                sourceSize { width: screenshot.width; height: screenshot.height }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: overlay.headerShown = !overlay.headerShown
            }
        }
    }
}
