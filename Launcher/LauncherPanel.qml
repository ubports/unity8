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

Item {
    id: root

    rotation: inverted ? 180 : 0

    property var model
    property bool inverted: false
    property bool dragging: false
    property bool moving: launcherFlickable.moving
    property int dragPosition: 0
    property int highlightIndex: -1

    signal applicationSelected(string desktopFile)
    signal dashItemSelected(int index)

    onDragPositionChanged: {
        var effectiveDragPosition = root.inverted ? launcherFlickable.height - dragPosition : dragPosition - mainColumn.anchors.margins

        var hiddenContentHeight = launcherFlickable.contentHeight - launcherFlickable.height
        // Shortening scrollable height because the first/last item needs to be fully expanded before reaching the top/bottom
        var scrollableHeight = launcherFlickable.height - (launcherFlickable.itemSize + launcherColumn.spacing) *2
        // As we shortened the scrollableHeight, lets move everything down by the itemSize
        var shortenedEffectiveDragPosition = effectiveDragPosition - launcherFlickable.itemSize - launcherColumn.spacing
        var newContentY = shortenedEffectiveDragPosition * hiddenContentHeight / scrollableHeight

        // limit top/bottom to prevent overshooting
        launcherFlickable.contentY = Math.min(hiddenContentHeight, Math.max(0, newContentY));

        // Now calculate the current index:
        // > the current mouse position + the hidden/scolled content on top is the mouse position in the averall view
        // > adjust that removing all the margins
        // > divide by itemSize to get index
        highlightIndex = (effectiveDragPosition + launcherFlickable.contentY - mainColumn.anchors.margins*3 - launcherColumn.spacing/2) / (launcherFlickable.itemSize + launcherColumn.spacing)
    }

    BorderImage {
        id: background
        source: "graphics/launcher_bg.sci"
        anchors.fill: parent
    }

    Column {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: units.gu(1)
        spacing: units.gu(1)

        LauncherDelegate {
            id: dashItem
            objectName: "dashItem"
            width: launcherFlickable.itemSize
            height: launcherFlickable.itemSize
            anchors.horizontalCenter: parent.horizontalCenter
            iconName: "dash"
            onClicked: root.dashItemSelected(0)
        }
        Flickable {
            id: launcherFlickable
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - dashItem.height - parent.spacing
            contentHeight: launcherColumn.height

            property int itemSize: width

            Column {
                id: launcherColumn
                width: parent.width
                spacing: units.gu(1)
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    id: iconRepeater
                    model: root.model

                    LauncherDelegate {
                        id: launcherDelegate
                        objectName: "launcherDelegate" + index
                        width: launcherFlickable.itemSize
                        height: launcherFlickable.itemSize
                        iconName: model.icon
                        inverted: root.inverted
                        highlighted: root.dragging && index === root.highlightIndex
                        z: -Math.abs(offset)
                        state: "docked"

                        maxAngle: 60

                        itemsBeforeThis: index
                        itemsAfterThis: iconRepeater.count - (index+1)

                        onClicked: {
                            root.applicationSelected(launcherModel.get(index).desktopFile);
                        }
                    }
                }
            }
        }
    }
}
