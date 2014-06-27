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
import Ubuntu.Components 1.1
import Unity 0.2
import "../Components"
import "Previews" as Previews

Item {
    id: root

    property var scope: null

    property alias open: previewListView.open
    property alias model: previewListView.model
    property alias currentIndex: previewListView.currentIndex
    property alias currentItem: previewListView.currentItem
    property alias count: previewListView.count

    PageHeader {
        id: header
        objectName: root.objectName + "_pageHeader"
        width: parent.width
        title: scope.name
        showBackButton: true
        searchEntryEnabled: false

        onBackClicked: root.open = false
    }

    ListView  {
        id: previewListView
        objectName: root.objectName + "_listView"
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        orientation: ListView.Horizontal
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.DragAndOvershootBounds
        highlightMoveDuration: 250
        flickDeceleration: units.gu(625)
        maximumFlickVelocity: width * 5
        cacheBuffer: 0

        // To be set before opening the preview
        property string categoryId: ""

        // because the ListView is built asynchronous, setting the
        // currentIndex directly won't work. We need to refresh it
        // when the first preview is ready to be displayed.
        property bool init: true

        property bool open: false

        onOpenChanged: {
            if (open) {
                pageHeader.unfocus();
            } else {
                // Cancel any pending preview requests or actions
                if (previewListView.currentItem && previewListView.currentItem.previewData !== undefined) {
                    previewListView.currentItem.previewData.cancelAction();
                }
                scope.cancelActivation();
                model = undefined;
            }
        }

        delegate: Item {
            objectName: "previewItem" + index
            height: previewListView.height
            width: previewListView.width

            readonly property bool ready: preview.previewModel.loaded

            Previews.Preview {
                id: preview
                objectName: "preview" + index
                anchors.fill: parent

                isCurrent: parent.ListView.isCurrentItem

                previewModel: {
                    var previewStack = root.scope.preview(result);
                    return previewStack.getPreviewModel(0);
                }
            }

            MouseArea {
                id: processingMouseArea
                objectName: "processingMouseArea"
                anchors.fill: parent
                enabled: !preview.previewModel.loaded || preview.previewModel.processingAction

                ActivityIndicator {
                    anchors.centerIn: parent
                    visible: root.open && parent.enabled
                    running: visible
                }
            }
        }
    }
}
