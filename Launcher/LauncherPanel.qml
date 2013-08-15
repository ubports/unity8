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
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItems
import Unity 0.1
import Unity.Launcher 0.1
import "../Components/ListItems"

Item {
    id: root

    rotation: inverted ? 180 : 0

    property var model
    property bool inverted: false
    property bool dragging: false
    property bool moving: launcherListView.moving || launcherListView.flicking || dndArea.draggedItem !== undefined
    property int highlightIndex: -1

    signal applicationSelected(string desktopFile)
    signal dashItemSelected(int index)

    BorderImage {
        id: background
        source: "graphics/launcher_bg.sci"
        anchors.fill: parent
    }

    Column {
        id: mainColumn
        anchors {
            fill: parent
            leftMargin: units.gu(0.5)
            rightMargin: units.gu(0.5)
        }
        //spacing: units.gu(0.5)

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
                    topMargin: -itemHeight + units.gu(0.5)
                    bottomMargin: -itemHeight + units.gu(1)
                }
                topMargin: itemHeight
                bottomMargin: itemHeight
                height: parent.height - dashItem.height - parent.spacing*2
                model: root.model
                cacheBuffer: itemHeight * 3
                snapMode: interactive ? ListView.SnapToItem : ListView.NoSnap
                highlightRangeMode: ListView.ApplyRange
                preferredHighlightBegin: (height - itemHeight) / 2
                preferredHighlightEnd: (height + itemHeight) / 2
                layoutDirection: root.inverted ? Qt.RightToLeft : Qt.LeftToRight
                spacing: units.gu(0.5)

                // The height of the area where icons start getting folded
                property int foldingAreaHeight: itemHeight * 0.75
                property int itemWidth: width
                property int itemHeight: width * 7.5 / 8
                property int clickFlickSpeed: units.gu(60)
                property int draggedIndex: dndArea.draggedIndex

                displaced: Transition {
                    NumberAnimation { properties: "x,y"; duration: 100 }
                }

                onContentYChanged: print("contentY", contentY)

                delegate: LauncherListDelegate {
                    id: launcherDelegate
                    objectName: "launcherDelegate" + index
                    itemHeight: launcherListView.itemHeight
                    itemWidth: launcherListView.itemWidth
                    width: itemWidth
                    height: itemHeight
                    iconName: model.icon
                    inverted: root.inverted
                    highlighted: dragging && index === root.highlightIndex
                    z: -Math.abs(offset)
                    maxAngle: 60
                    property bool dragging: false

                    ThinDivider {
                        anchors.centerIn: parent
                        width: parent.width + mainColumn.anchors.leftMargin + mainColumn.anchors.rightMargin
                        visible: parent.dragging
                    }

                    states: [
                        State {
                            name: "pre-dragging"
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
                                angle: root.inverted ? -80 : 80
                                offset: effectiveHeight / 2
                                height: effectiveHeight
                                itemOpacity: 0
                            }
                        },
                        State {
                            name: "expanded"
                            when: dndArea.draggedIndex >= 0 && !dragging
                            PropertyChanges {
                                target: launcherDelegate
                                angle: 0
                                offset: 0
                            }
                        }

                    ]
                    transitions: [
                        Transition {
                            from: "*"
                            to: "*"
                            NumberAnimation { properties: "height,itemOpacity"; duration: 150 }
                        },
                        Transition {
                            from: "dragging"
                            to: "*"
                            NumberAnimation { properties: "itemOpacity"; duration: 150 }
                        }
                    ]
                }

                MouseArea {
                    id: dndArea
                    anchors.fill: parent
                    anchors.topMargin: launcherListView.topMargin
                    anchors.bottomMargin: launcherListView.bottomMargin

                    property int draggedIndex: -1
                    property var selectedItem
                    property int startX
                    property int startY
                    property var quickListPopover

                    onPressed: {
                        var realContentY = launcherListView.contentY + launcherListView.topMargin
                        selectedItem = launcherListView.itemAt(mouseX, mouseY + realContentY)
                        selectedItem.highlighted = true
                    }

                    onClicked: {
                        var realItemHeight = launcherListView.itemHeight + launcherListView.spacing
                        var realContentY = launcherListView.contentY + launcherListView.topMargin
                        var index = Math.floor((mouseY + realContentY) / realItemHeight);
                        var clickedItem = launcherListView.itemAt(mouseX, mouseY + realContentY)

                        print("clicked on", index, clickedItem)

                        // First/last item do the scrolling at more than 12 degrees
                        if (index == 0 || index == launcherListView.count -1) {
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
                    }

                    onReleased: {
                        print("released");
                        selectedItem.highlighted = false
                        selectedItem.dragging = false;
                        selectedItem = undefined;

                        var droppedIndex = draggedIndex;
                        draggedIndex = -1;
                        drag.target = undefined

                        progressiveScrollingTimer.stop();

                        // FIXME: remove the if condition once the ListView position bug is fixed.
                        // Right now setting currentIndex to 0 causes more issues than it helps.
//                        if (droppedIndex > 2) {
//                            launcherListView.currentIndex = -1;
//                            launcherListView.currentIndex = droppedIndex;
//                        }
                        launcherListView.interactive = true;
                    }

                    onPressAndHold: {
                        var realItemHeight = launcherListView.itemHeight + launcherListView.spacing
                        var realContentY = launcherListView.contentY + launcherListView.topMargin
                        draggedIndex = Math.floor((mouseY + realContentY) / realItemHeight);

                        launcherListView.interactive = false

                        var quickListModel = launcherListView.model.get(draggedIndex).quickList
                        var quickListAppId = launcherListView.model.get(draggedIndex).appId
                        quickListPopover = PopupUtils.open(popoverComponent, selectedItem,
                                                           {model: quickListModel, appId: quickListAppId})

                        var yOffset = draggedIndex > 0 ? (mouseY + realContentY) % (draggedIndex * realItemHeight) : mouseY + realContentY

                        fakeDragItem.iconName = launcherListView.model.get(draggedIndex).icon
                        fakeDragItem.x = 0
                        fakeDragItem.y = mouseY - yOffset
                        drag.target = fakeDragItem

                        startX = mouseX
                        startY = mouseY
                    }

                    onPositionChanged: {
                        if (draggedIndex >= 0) {

                            if (!selectedItem.dragging) {
                                var distance = Math.max(Math.abs(mouseX - startX), Math.abs(mouseY - startY))
                                if (distance > launcherListView.itemHeight) {
                                    print("starting drag")
                                    selectedItem.dragging = true
                                    PopupUtils.close(quickListPopover)
                                }
                            }
                            if (!selectedItem.dragging) {
                                return
                            }

                            //launcherPanel.dragPosition = inverted ? launcherListView.height - y : y
                            //root.dragPosition = mouseY

                            var realContentY = launcherListView.contentY + launcherListView.topMargin
                            var realItemHeight = launcherListView.itemHeight + launcherListView.spacing
                            var itemCenterY = fakeDragItem.y + fakeDragItem.height / 2

                            // Move it down by the the missing size to compensate index calculation with only expanded items
                            itemCenterY += selectedItem.height / 2

//                            print("mouseY", mouseY, launcherListView.height - launcherListView.topMargin - launcherListView.bottomMargin - realItemHeight)
                            if (mouseY > launcherListView.height - launcherListView.topMargin - launcherListView.bottomMargin - realItemHeight) {
//                                print("entered bottom area")
                                progressiveScrollingTimer.downwards = false
                                progressiveScrollingTimer.start()
                            } else if (mouseY < realItemHeight) {
                                progressiveScrollingTimer.downwards = true
                                progressiveScrollingTimer.start()
//                                print("entered top area")
                            } else {
                                progressiveScrollingTimer.stop()
//                                print("not in any area")
                            }

                            var newIndex = (itemCenterY + realContentY) / realItemHeight

                            if (newIndex > draggedIndex + 1) {
                                newIndex = draggedIndex + 1
                            } else if (newIndex < draggedIndex) {
                                newIndex = draggedIndex -1
                            } else {
                                return
                            }

                            if (newIndex >= 0 && newIndex < launcherListView.count) {
                                print("moving", draggedIndex, "to", newIndex)
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
                            var maxY = launcherListView.contentHeight - launcherListView.height + launcherListView.topMargin + dndArea.selectedItem.effectiveHeight*2
                            if (launcherListView.contentY < maxY) {
                                print("moving upwards", launcherListView.contentHeight, launcherListView.height, launcherListView.topMargin, dndArea.selectedItem.height, dndArea.selectedItem.effectiveHeight)
                                launcherListView.contentY = Math.min(launcherListView.contentY + units.dp(2), maxY)
                            }
                        }
                    }
                }

                MouseArea {
                    id: topFoldingArea
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        topMargin: launcherListView.topMargin
                    }
                    height: launcherListView.itemSize / 2
                    enabled: launcherListView.contentY > -launcherListView.topMargin
                    onClicked: launcherListView.flick(0, launcherListView.clickFlickSpeed)
                }

                MouseArea {
                    id: bottomFoldingArea
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        bottomMargin: launcherListView.bottomMargin
                    }
                    height: launcherListView.itemHeight / 2
                    enabled: launcherListView.contentHeight - launcherListView.height - launcherListView.contentY > -launcherListView.bottomMargin
                    onClicked: launcherListView.flick(0, -launcherListView.clickFlickSpeed)
                }
            }
            }

            LauncherDelegate {
                id: fakeDragItem
                visible: dndArea.draggedIndex >= 0
                itemWidth: launcherListView.itemWidth
                itemHeight: launcherListView.itemHeight
                height: itemHeight
                width: itemWidth
                rotation: root.rotation
                highlighted: true
            }
        }

    }

    Component {
        id: popoverComponent
        Popover {
            id: popover
            width: units.gu(20)
            property var model
            property string appId

            Column {
                width: parent.width
                height: childrenRect.height
                Repeater {
                    model: popover.model
                    ListItems.Standard {
                        text: model.label
                        onClicked: {
                            LauncherModel.quickListActionInvoked(appId, index)
                            PopupUtils.close(popover)
                        }
                    }
                }
            }
        }
    }
}
