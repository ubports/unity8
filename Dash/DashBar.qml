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
    id: dashBar

    property var model
    property alias currentIndex: row.currentIndex

    property int lineHeight: units.dp(2)
    property int itemSize: units.gu(7)
    property int iconSize: units.gu(3.5)

    signal itemSelected(int index)

    width: units.gu(40)
    height: units.gu(6)

    function startNavigation() {
        timeout.stop()
        panel.opened = true
    }

    function stopNavigation() {
        timeout.restart()
    }

    function finishNavigation() {
        panel.opened = false
    }

    Timer {
        id: timeout
        interval: 1500
        running: false
        repeat: false
        onTriggered: finishNavigation()
    }

    Panel {
        id: panel
        objectName: "panel"
        anchors.fill: parent

        locked: true // TODO: remove this when lp bug #1179569 will be fixed

        Rectangle {
            color: "black"
            anchors.fill: parent

            ListView {
                id: row
                objectName: "row"
                model: dashBar.model
                orientation: ListView.Horizontal
                width: Math.min(Math.max(dashBar.width/2, units.gu(40)), count * itemSize)
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                onMovingChanged: if (moving) { timeout.stop() } else { timeout.restart() }
                interactive: visibleArea.widthRatio < 1 && panel.opened
                highlightFollowsCurrentItem: false

                onCurrentItemChanged: {
                    highlightLine.width = currentItem.width
                    highlightLine.x = x + currentItem.x
                }

                delegate:
                    Item {
                        signal clicked()

                        width: itemSize
                        height: dashBar.height
                        anchors.top: parent.top

                        onClicked: {
                            dashBar.itemSelected(index)
                            timeout.restart()
                        }

                        Image {
                            anchors.centerIn: parent
                            source: scope.iconHint
                            sourceSize { width: iconSize; height: iconSize }
                            // opacity: index == currentIndex ? 1 : 1 // same opacity for now
                        }
                    }
            }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: dashBar.lineHeight
        color: "black"

        Rectangle {
            id: highlightLine
            color: Theme.palette.selected.foreground
            height: parent.height
            anchors.bottom: parent.bottom
            z: 1

            Behavior on x {NumberAnimation { duration: 150; easing.type: Easing.OutCubic}}
            Behavior on width {NumberAnimation { duration: 150; easing.type: Easing.OutCubic}}
        }
    }
}
