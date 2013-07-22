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
    property int dragPosition: 0
    property int highlightIndex: -1

    signal applicationSelected(string desktopFile)
    signal dashItemSelected(int index)

    onDragPositionChanged: {
        var effectiveDragPosition = root.inverted ? launcherListView.height - dragPosition : dragPosition - mainColumn.anchors.margins

        var hiddenContentHeight = launcherListView.contentHeight - launcherListView.height
        // Shortening scrollable height because the first/last item needs to be fully expanded before reaching the top/bottom
        var scrollableHeight = launcherListView.height - (launcherListView.itemSize + launcherColumn.spacing) *2
        // As we shortened the scrollableHeight, lets move everything down by the itemSize
        var shortenedEffectiveDragPosition = effectiveDragPosition - launcherListView.itemSize - launcherColumn.spacing
        var newContentY = shortenedEffectiveDragPosition * hiddenContentHeight / scrollableHeight

        // limit top/bottom to prevent overshooting
        launcherListView.contentY = Math.min(hiddenContentHeight, Math.max(0, newContentY));

        // Now calculate the current index:
        // > the current mouse position + the hidden/scolled content on top is the mouse position in the averall view
        // > adjust that removing all the margins
        // > divide by itemSize to get index
        highlightIndex = (effectiveDragPosition + launcherListView.contentY - mainColumn.anchors.margins*3 - launcherColumn.spacing/2) / (launcherListView.itemSize + launcherColumn.spacing)
    }

    BorderImage {
        id: background
        source: "graphics/launcher_bg.sci"
        anchors.fill: parent
    }

    Column {
        id: mainColumn
        anchors {
            fill: parent
            topMargin: units.gu(0.5)
            bottomMargin: units.gu(1)
            leftMargin: units.gu(0.5)
            rightMargin: units.gu(0.5)
        }
        spacing: units.gu(0.5)

        MouseArea {
            id: dashItem
            width: parent.width
            height: units.gu(6.5)
            onClicked: root.dashItemSelected(0)
            z: 1
            Image {
                objectName: "dashItem"
                width: units.gu(5.5)
                height: width
                anchors.centerIn: parent
                source: "graphics/home.png"
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
            ListView {
                id: launcherListView
                objectName: "launcherListView"
                anchors.fill: parent
                anchors.topMargin: -itemSize
                anchors.bottomMargin: -itemSize
                topMargin: itemSize
                bottomMargin: itemSize
                height: parent.height - dashItem.height - parent.spacing*2
                model: root.model
                cacheBuffer: itemSize * 3
                snapMode: interactive ? ListView.SnapToItem : ListView.NoSnap
                highlightRangeMode: ListView.ApplyRange
                preferredHighlightBegin: (height - itemSize) / 2
                preferredHighlightEnd: (height + itemSize) / 2

                // The height of the area where icons start getting folded
                property int foldingAreaHeight: itemSize * 0.75
                property int itemSize: width
                property int clickFlickSpeed: units.gu(60)

                displaced: Transition {
                    NumberAnimation { properties: "x,y"; duration: 100 }
                }

                delegate: LauncherDelegate {
                    id: launcherDelegate
                    objectName: "launcherDelegate" + index
                    width: launcherListView.itemSize
                    height: dragging ? units.gu(2) : launcherListView.itemSize
                    iconName: model.icon
                    inverted: root.inverted
                    highlighted: dragging && index === root.highlightIndex
                    z: -Math.abs(offset)
                    maxAngle: 60
                    property bool dragging: false

                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }

                    onClicked: {
                        // First/last item do the scrolling at more than 12 degrees
                        if (index == 0 || index == launcherListView.count -1) {
                            if (angle > 12) {
                                launcherListView.flick(0, -launcherListView.clickFlickSpeed);
                            } else if (angle < -12) {
                                launcherListView.flick(0, launcherListView.clickFlickSpeed);
                            } else {
                                root.applicationSelected(LauncherModel.get(index).desktopFile);
                            }
                            return;
                        }

                        // the rest launches apps up to an angle of 30 degrees
                        if (angle > 30) {
                            launcherListView.flick(0, -launcherListView.clickFlickSpeed);
                        } else if (angle < -30) {
                            launcherListView.flick(0, launcherListView.clickFlickSpeed);
                        } else {
                            root.applicationSelected(LauncherModel.get(index).desktopFile);
                        }
                    }
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


                    Item {
                        id: fakeDragItem
                        width: launcherListView.itemSize
                        height: launcherListView.itemSize
                        visible: dndArea.draggedIndex >= 0
                        property string iconName

                        UbuntuShape {
                            id: iconShape
                            anchors.fill: parent
                            anchors.margins: units.gu(0.5)
                            radius: "medium"

                            image: Image {
                                id: iconImage
                                sourceSize.width: iconShape.width
                                sourceSize.height: iconShape.height
                                source: "../graphics/applicationIcons/" + fakeDragItem.iconName + ".png"
                            }
                        }
                        BorderImage {
                            id: overlayHighlight
                            anchors.centerIn: fakeDragItem
                            rotation: inverted ? 180 : 0
                            source: isSelected ? "graphics/selected.sci" : "graphics/non-selected.sci"
                            width: fakeDragItem.width + units.gu(0.5)
                            height: width
                        }
                    }

/*                    LauncherDelegate {
                        id: fakeDragItem
                        visible: dndArea.draggedItem !== undefined
                        iconName: "gmail"
                        height: launcherListView.itemSize
                        width: height
                        rotation: root.rotation
                    }
*/
                    onPressed: {
                        var realContentY = launcherListView.contentY + launcherListView.topMargin
                        selectedItem = launcherListView.itemAt(mouseX, mouseY + realContentY)
                        selectedItem.highlighted = true

                    }

                    onClicked: {
                    }

                    onCanceled: {
                        selectedItem.highlighted = false
                    }

                    onReleased: {
                        print("released");
                        selectedItem.highlighted = false
                        selectedItem.opacity = 1
                        selectedItem.dragging = false;
                        selectedItem = undefined;

                        draggedIndex = -1;
                        drag.target = undefined
                        launcherListView.interactive = true;
                    }

                    onPressAndHold: {
                        var realItemSize = launcherListView.itemSize + launcherListView.spacing
                        var realContentY = launcherListView.contentY + launcherListView.topMargin
                        draggedIndex = Math.floor((mouseY + realContentY) / realItemSize);

                        launcherListView.interactive = false

                        var yOffset = draggedIndex > 0 ? (mouseY + realContentY) % (draggedIndex * realItemSize) : mouseY + realContentY

                        fakeDragItem.iconName = launcherListView.model.get(draggedIndex).icon
                        fakeDragItem.x = 0
                        fakeDragItem.y = mouseY - yOffset
                        drag.target = fakeDragItem

                        selectedItem.opacity = 0

                        startX = mouseX
                        startY = mouseY
                    }

                    onPositionChanged: {
                        if (draggedIndex >= 0) {

                            if (!selectedItem.dragging) {
                                var distance = Math.max(Math.abs(mouseX - startX), Math.abs(mouseY - startY))
                                if (distance > launcherListView.itemSize) {
                                    print("starting drag")
                                    selectedItem.dragging = true
                                }
                            }
                            if (!selectedItem.dragging) {
                                return
                            }

                            //launcherPanel.dragPosition = inverted ? launcherListView.height - y : y
                            //launcherPanel.dragPosition = mouseY

                            var realContentY = launcherListView.contentY + launcherListView.topMargin
                            var realItemSize = launcherListView.itemSize + launcherListView.spacing
                            var itemCenterY = fakeDragItem.y + fakeDragItem.height / 2

                            // Move it down by the the missing size to compensate index calculation with only expanded items
                            itemCenterY += selectedItem.height / 2

                            var newIndex = (itemCenterY + realContentY) / realItemSize

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
                    height: launcherListView.itemSize / 2
                    enabled: launcherListView.contentHeight - launcherListView.height - launcherListView.contentY > -launcherListView.bottomMargin
                    onClicked: launcherListView.flick(0, -launcherListView.clickFlickSpeed)
                }
            }
        }
    }

    Component {
        id: popoverComponent
        Popover {
            id: popover
            width: units.gu(20)

            Column {
                width: parent.width
                height: childrenRect.height
                Repeater {
                    model: 2
                    ListItems.Standard {
                        text: "foo bar baz"
                    }
                }
            }
        }
    }

}
