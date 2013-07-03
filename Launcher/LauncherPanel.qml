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
import Unity 0.1
import "../Components/ListItems"

Item {
    id: root

    rotation: inverted ? 180 : 0

    property var model
    property bool inverted: true
    property bool dragging: false
    property bool moving: launcherListView.moving || launcherListView.flicking
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
                highlightRangeMode: ListView.ApplyRange
                preferredHighlightBegin: (height - itemSize) / 2
                preferredHighlightEnd: (height + itemSize) / 2
                snapMode: ListView.SnapToItem

                // The height of the area where icons start getting folded
                property int foldingAreaHeight: itemSize * 0.75
                property int itemSize: width
                property int clickFlickSpeed: units.gu(60)

                // Setting snapMode delayed to make sure the ListView stays positioned
                // at the beginning. If the SnapMode is already set when the model
                // delivers the items, it's going to snap immediately. Depending on
                // the height of the list, this might cause the first item to be half
                // folded at the beginning. Once the list is populated we can set the
                // snapMode and actual snapping will only happen when the user
                // interacts with the list.
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        topFoldingArea.clicked(undefined)
                        //launcherListView.snapMode = ListView.SnapToItem
//                        launcherListView.flick(0, -units.gu(2000000));
//                        launcherListView.contentY = -launcherListView.topMargin;
                    }
                }

                delegate: LauncherDelegate {
                    id: launcherDelegate
                    objectName: "launcherDelegate" + index
                    width: launcherListView.itemSize
                    height: launcherListView.itemSize
                    iconName: model.icon
                    inverted: root.inverted
                    highlighted: root.dragging && index === root.highlightIndex
                    z: -Math.abs(offset)
                    state: "docked"
                    maxAngle: 60

                    onClicked: {
                        // First/last item do the scrolling at more than 12 degrees
                        if (index == 0 || index == launcherListView.count -1) {
                            if (angle > 12) {
                                launcherListView.flick(0, -launcherListView.clickFlickSpeed);
                            } else if (angle < -12) {
                                launcherListView.flick(0, launcherListView.clickFlickSpeed);
                            } else {
                                root.applicationSelected(launcherModel.get(index).desktopFile);
                            }
                            return;
                        }

                        // the rest launches apps up to an angle of 30 degrees
                        if (angle > 30) {
                            launcherListView.flick(0, -launcherListView.clickFlickSpeed);
                        } else if (angle < -30) {
                            launcherListView.flick(0, launcherListView.clickFlickSpeed);
                        } else {
                            root.applicationSelected(launcherModel.get(index).desktopFile);
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
}
