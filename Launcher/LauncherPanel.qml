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
import Ubuntu.Components.ListItems 0.1 as ListItems
import Unity 0.1
import Unity.Launcher 0.1
import "../Components/ListItems"

Item {
    id: root

    rotation: inverted ? 180 : 0

    property var model
    property bool inverted: true
    property bool dragging: false
    property bool moving: launcherListView.moving || launcherListView.flicking || dndArea.draggedIndex >= 0
    property int highlightIndex: -1

    signal applicationSelected(string desktopFile)
    signal dashItemSelected(int index)

    BorderImage {
        id: background
        source: "graphics/launcher_bg.sci"
        anchors.fill: parent
        anchors.rightMargin: root.inverted ? 0 : -units.gu(1)
        anchors.leftMargin: root.inverted ? -units.gu(1) : 0
        rotation: root.rotation
    }

    Column {
        id: mainColumn
        anchors {
            fill: parent
            leftMargin: units.gu(0.5)
            rightMargin: units.gu(0.5)
        }

        MouseArea {
            id: dashItem
            width: parent.width
            height: units.gu(7)
            onClicked: root.dashItemSelected(0)
            z: 1
            Image {
                objectName: "dashItem"
                width: units.gu(5.5)
                height: width
                anchors.centerIn: parent
                source: "graphics/home.png"
                rotation: root.rotation
            }
        }
        ThinDivider {
            anchors {
                left: parent.left
                right: parent.right
                margins: -mainColumn.anchors.leftMargin
            }
            rotation: root.rotation
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - dashItem.height - parent.spacing*2

            Item {
                anchors.fill: parent
                clip: true

                ListView {
                    id: launcherListView
                    objectName: "launcherListView"
                    anchors {
                        fill: parent
                        topMargin: -extensionSize + units.gu(0.5)
                        bottomMargin: -extensionSize + units.gu(1)
                    }
                    topMargin: extensionSize
                    bottomMargin: extensionSize
                    height: parent.height - dashItem.height - parent.spacing*2
                    model: root.model
                    cacheBuffer: itemHeight * 3
                    snapMode: interactive ? ListView.SnapToItem : ListView.NoSnap
                    highlightRangeMode: ListView.ApplyRange
                    preferredHighlightBegin: (height - itemHeight) / 2
                    preferredHighlightEnd: (height + itemHeight) / 2
                    spacing: units.gu(0.5)

                    // The size of the area the ListView is extended to make sure items are not
                    // destroyed when dragging them outside the list. This needs to be at least
                    // itemHeight to prevent folded items from disappearing and DragArea limits
                    // need to be smaller than this size to avoid breakage.
                    property int extensionSize: itemHeight * 3

                    // The height of the area where icons start getting folded
                    property int foldingAreaHeight: itemHeight * 0.75
                    property int itemWidth: width
                    property int itemHeight: width * 7.5 / 8
                    property int clickFlickSpeed: units.gu(60)
                    property int draggedIndex: dndArea.draggedIndex
                    property real realContentY: contentY - originY + topMargin
                    property int realItemHeight: itemHeight + spacing

                    displaced: Transition {
                        NumberAnimation { properties: "x,y"; duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing }
                    }

                    delegate: FoldingLauncherDelegate {
                        id: launcherDelegate
                        objectName: "launcherDelegate" + index
                        itemHeight: launcherListView.itemHeight
                        itemWidth: launcherListView.itemWidth
                        width: itemWidth
                        height: itemHeight
                        iconName: model.icon
                        count: model.count
                        progress: model.progress
                        inverted: root.inverted
                        highlighted: dragging && index === root.highlightIndex
                        z: -Math.abs(offset)
                        maxAngle: 60
                        property bool dragging: false

                        ThinDivider {
                            id: dropIndicator
                            objectName: "dropIndicator"
                            anchors.centerIn: parent
                            width: parent.width + mainColumn.anchors.leftMargin + mainColumn.anchors.rightMargin
                            opacity: 0
                        }

                        states: [
                            State {
                                name: "selected"
                                when: dndArea.selectedItem === launcherDelegate && fakeDragItem.visible && !dragging
                                PropertyChanges {
                                    target: launcherDelegate
                                    itemOpacity: 0
                                }
                            },
                            State {
                                name: "dragging"
                                when: dragging
                                PropertyChanges {
                                    target: launcherDelegate
                                    height: units.gu(1)
                                    itemOpacity: 0
                                }
                                PropertyChanges {
                                    target: dropIndicator
                                    opacity: 1
                                }
                            },
                            State {
                                name: "expanded"
                                when: dndArea.draggedIndex >= 0 && (dndArea.preDragging || dndArea.dragging || dndArea.postDragging) && dndArea.draggedIndex != index
                                PropertyChanges {
                                    target: launcherDelegate
                                    angle: 0
                                    offset: 0
                                    itemOpacity: 0.6
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: ""
                                to: "selected"
                                NumberAnimation { properties: "itemOpacity"; duration: UbuntuAnimation.FastDuration }
                            },
                            Transition {
                                from: "*"
                                to: "expanded"
                                NumberAnimation { properties: "itemOpacity"; duration: UbuntuAnimation.FastDuration }
                                UbuntuNumberAnimation { properties: "angle,offset" }
                            },
                            Transition {
                                from: "expanded"
                                to: ""
                                NumberAnimation { properties: "itemOpacity"; duration: UbuntuAnimation.BriskDuration }
                                UbuntuNumberAnimation { properties: "angle,offset" }
                            },
                            Transition {
                                from: "selected"
                                to: "dragging"
                                UbuntuNumberAnimation { properties: "height" }
                                NumberAnimation { target: dropIndicator; properties: "opacity"; duration: UbuntuAnimation.FastDuration }
                            },
                            Transition {
                                from: "dragging"
                                to: "*"
                                NumberAnimation { target: dropIndicator; properties: "opacity"; duration: UbuntuAnimation.FastDuration }
                                NumberAnimation { properties: "itemOpacity"; duration: UbuntuAnimation.BriskDuration }
                                SequentialAnimation {
                                    UbuntuNumberAnimation { properties: "height" }
                                    PropertyAction { target: dndArea; property: "postDragging"; value: false }
                                    PropertyAction { target: dndArea; property: "draggedIndex"; value: -1 }
                                }
                            }
                        ]
                    }

                    MouseArea {
                        id: dndArea
                        anchors {
                            fill: parent
                            topMargin: launcherListView.topMargin
                            bottomMargin: launcherListView.bottomMargin
                        }
                        drag.minimumY: -launcherListView.topMargin
                        drag.maximumY: height + launcherListView.bottomMargin

                        property int draggedIndex: -1
                        property var selectedItem
                        property bool preDragging: false
                        property bool dragging: selectedItem !== undefined && selectedItem.dragging
                        property bool postDragging: false
                        property int startX
                        property int startY

                        onPressed: {
                            selectedItem = launcherListView.itemAt(mouseX, mouseY + launcherListView.realContentY)
                            selectedItem.highlighted = true
                        }

                        onClicked: {
                            var index = Math.floor((mouseY + launcherListView.realContentY) / launcherListView.realItemHeight);
                            var clickedItem = launcherListView.itemAt(mouseX, mouseY + launcherListView.realContentY)

                            // First/last item do the scrolling at more than 12 degrees
                            if (index == 0 || index == launcherListView.count - 1) {
                                if (clickedItem.angle > 12) {
                                    launcherListView.flick(0, -launcherListView.clickFlickSpeed);
                                } else if (clickedItem.angle < -12) {
                                    launcherListView.flick(0, launcherListView.clickFlickSpeed);
                                } else {
                                    root.applicationSelected(LauncherModel.get(index).desktopFile);
                                }
                                return;
                            }

                            // the rest launches apps up to an angle of 30 degrees
                            if (clickedItem.angle > 30) {
                                launcherListView.flick(0, -launcherListView.clickFlickSpeed);
                            } else if (clickedItem.angle < -30) {
                                launcherListView.flick(0, launcherListView.clickFlickSpeed);
                            } else {
                                root.applicationSelected(LauncherModel.get(index).desktopFile);
                            }
                        }

                        onCanceled: {
                            selectedItem.highlighted = false
                            selectedItem = undefined;
                            preDragging = false;
                            postDragging = false;
                        }

                        onReleased: {
                            var droppedIndex = draggedIndex;
                            if (dragging) {
                                postDragging = true;
                            } else {
                                draggedIndex = -1;
                            }

                            selectedItem.highlighted = false
                            selectedItem.dragging = false;
                            selectedItem = undefined;
                            preDragging = false;

                            drag.target = undefined

                            progressiveScrollingTimer.stop();
                            launcherListView.interactive = true;
                            if (droppedIndex >= launcherListView.count - 2 && postDragging) {
                                launcherListView.flick(0, -launcherListView.clickFlickSpeed);
                            }
                        }

                        onPressAndHold: {
                            if (Math.abs(selectedItem.angle) > 30) {
                                return;
                            }

                            draggedIndex = Math.floor((mouseY + launcherListView.realContentY) / launcherListView.realItemHeight);

                            launcherListView.interactive = false

                            var yOffset = draggedIndex > 0 ? (mouseY + launcherListView.realContentY) % (draggedIndex * launcherListView.realItemHeight) : mouseY + launcherListView.realContentY

                            fakeDragItem.iconName = launcherListView.model.get(draggedIndex).icon
                            fakeDragItem.x = 0
                            fakeDragItem.y = mouseY - yOffset + launcherListView.anchors.topMargin + launcherListView.topMargin
                            fakeDragItem.angle = selectedItem.angle * (root.inverted ? -1 : 1)
                            fakeDragItem.offset = selectedItem.offset * (root.inverted ? -1 : 1)
                            fakeDragItem.count = LauncherModel.get(draggedIndex).count
                            fakeDragItem.progress = LauncherModel.get(draggedIndex).progress
                            fakeDragItem.flatten()
                            drag.target = fakeDragItem

                            startX = mouseX
                            startY = mouseY
                        }

                        onPositionChanged: {
                            if (draggedIndex >= 0) {
                                if (!selectedItem.dragging) {
                                    var distance = Math.max(Math.abs(mouseX - startX), Math.abs(mouseY - startY))
                                    if (!preDragging && distance > units.gu(1.5)) {
                                        preDragging = true;
                                    }
                                    if (distance > launcherListView.itemHeight) {
                                        selectedItem.dragging = true
                                        preDragging = false;
                                    }
                                }
                                if (!selectedItem.dragging) {
                                    return
                                }

                                var itemCenterY = fakeDragItem.y + fakeDragItem.height / 2

                                // Move it down by the the missing size to compensate index calculation with only expanded items
                                itemCenterY += (launcherListView.itemHeight - selectedItem.height) / 2

                                if (mouseY > launcherListView.height - launcherListView.topMargin - launcherListView.bottomMargin - launcherListView.realItemHeight) {
                                    progressiveScrollingTimer.downwards = false
                                    progressiveScrollingTimer.start()
                                } else if (mouseY < launcherListView.realItemHeight) {
                                    progressiveScrollingTimer.downwards = true
                                    progressiveScrollingTimer.start()
                                } else {
                                    progressiveScrollingTimer.stop()
                                }

                                var newIndex = (itemCenterY + launcherListView.realContentY) / launcherListView.realItemHeight

                                if (newIndex > draggedIndex + 1) {
                                    newIndex = draggedIndex + 1
                                } else if (newIndex < draggedIndex) {
                                    newIndex = draggedIndex -1
                                } else {
                                    return
                                }

                                if (newIndex >= 0 && newIndex < launcherListView.count) {
                                    launcherListView.model.move(draggedIndex, newIndex)
                                    draggedIndex = newIndex
                                }
                            }
                        }
                    }
                    Timer {
                        id: progressiveScrollingTimer
                        interval: 2
                        repeat: true
                        running: false
                        property bool downwards: true
                        onTriggered: {
                            if (downwards) {
                                var minY =  -launcherListView.topMargin
                                if (launcherListView.contentY > minY) {
                                    launcherListView.contentY = Math.max(launcherListView.contentY - units.dp(2), minY)
                                }
                            } else {
                                var maxY = launcherListView.contentHeight - launcherListView.height + launcherListView.topMargin + launcherListView.originY
                                if (launcherListView.contentY < maxY) {
                                    launcherListView.contentY = Math.min(launcherListView.contentY + units.dp(2), maxY)
                                }
                            }
                        }
                    }
                }
            }

            LauncherDelegate {
                id: fakeDragItem
                objectName: "fakeDragItem"
                visible: dndArea.draggedIndex >= 0 && !dndArea.postDragging
                itemWidth: launcherListView.itemWidth
                itemHeight: launcherListView.itemHeight
                height: itemHeight
                width: itemWidth
                rotation: root.rotation
                highlighted: true
                itemOpacity: 0.8

                function flatten() {
                    fakeDragItemAnimation.start();
                }

                UbuntuNumberAnimation {
                    id: fakeDragItemAnimation
                    target: fakeDragItem;
                    properties: "angle,offset";
                    to: 0
                }
            }
        }
    }
}
