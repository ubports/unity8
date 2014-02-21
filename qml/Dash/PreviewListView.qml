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
import Ubuntu.Components 0.1
import Unity 0.2
import "../Components"
import "Previews" as Previews

Item {
    id: root

    property OpenEffect openEffect: null
    property Scope scope: null
    property var pageHeader: null

    property alias open: previewListView.open
    property alias onScreen: previewListView.onScreen
    property alias model: previewListView.model
    property alias currentIndex: previewListView.currentIndex
    property alias currentItem: previewListView.currentItem
    property alias count: previewListView.count

    PageHeader {
        id: header
        anchors.topMargin: openEffect.topGapPx
        width: parent.width
        searchEntryEnabled: false
        scope: root.scope
        height: units.gu(8.5)
        showBackButton: true
        onBackClicked: {
            visibleOnce = false;
            root.open = false;
        }
        visible: previewListView.open && previewListView.currentItem && previewListView.currentItem.ready || visibleOnce
        onVisibleChanged: visibleOnce = visible
        property bool visibleOnce: false

        childItem: Label {
            id: label
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            text: scope ? i18n.tr("%1 Preview").arg(scope.name) : ""
            color: "#888888"
            font.family: "Ubuntu"
            font.weight: Font.Light
            fontSize: "x-large"
            elide: Text.ElideRight
        }
    }

    ListView  {
        id: previewListView
        objectName: "previewListView"
        height: openEffect.bottomGapPx - openEffect.topGapPx
        anchors {
            top: header.bottom
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
        property bool onScreen: false

        onOpenChanged: {
            if (open) {
                onScreen = true;
                pageHeader.unfocus();
            } else {
                // Cancel any pending preview requests or actions
                if (previewListView.currentItem.previewData !== undefined) {
                    previewListView.currentItem.previewData.cancelAction();
                }
                scope.cancelActivation();
                model = undefined;
            }
        }

        delegate: Previews.Preview {
            id: preview
            objectName: "preview" + index
            height: previewListView.height
            width: previewListView.width

            isCurrent: ListView.isCurrentItem

            onPreviewModelChanged: preview.opacity = 0;
            onReadyChanged: if (ready) fadeIn.start()
            previewModel: {
                // TODO
                // We need the isCurrent because the scope fails to
                // deliver the preview if we ask for one after other very quickly
                // If we remove the isCurrent, we will have to think another way of
                // doing the fadeIn or just don't do it at all or just decide
                // this code is good enough and remove the TODO
                if (isCurrent) {
                    var previewStack = root.scope.preview(result);
                    return previewStack.get(0);
                } else {
                    ready = false;
                    return null;
                }
            }

//            onClose: {
//                previewListView.open = false
//            }

            PropertyAnimation {
                id: fadeIn
                target: preview
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: UbuntuAnimation.BriskDuration
            }
        }
    }
}
