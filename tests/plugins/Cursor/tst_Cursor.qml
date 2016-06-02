/*
 * Copyright (C) 2016 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


import QtQuick 2.4
import Cursor 1.1

Rectangle {
    id: root
    color: "blue"
    width: 400
    height: 600

    property string themeName: "default"
    property string cursorName: "left_ptr"

    CursorImageInfo {
        id: imageInfo
        themeName: root.themeName
        cursorName: root.cursorName
    }

    Item {
        id: cursor
        x: (200 - animatedSprite.width) / 2
        y: (root.height - animatedSprite.height) / 2

        AnimatedSprite {
            id: animatedSprite

            x: -imageInfo.hotspot.x
            y: -imageInfo.hotspot.y
            source: "image://cursor/" + root.themeName + "/" + root.cursorName

            interpolate: false

            width: imageInfo.frameWidth
            height: imageInfo.frameHeight

            frameCount: imageInfo.frameCount
            frameDuration: imageInfo.frameDuration
            frameWidth: imageInfo.frameWidth
            frameHeight: imageInfo.frameHeight
        }
    }

    Rectangle {
        id: hotspotCrossH
        color: "red"
        width: 200
        height: 1
        anchors.top: cursor.top
        opacity: 0.6
    }
    Rectangle {
        id: hotspotCrossV
        color: "red"
        width: 1
        anchors.left: cursor.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        opacity: 0.6
    }
    MouseArea {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: controls.left
        onClicked: {
            if (hotspotCrossH.visible) {
                hotspotCrossH.visible = false;
                hotspotCrossV.visible = false;
            } else {
                hotspotCrossH.visible = true;
                hotspotCrossV.visible = true;
            }
        }
    }

    Rectangle {
        id: controls
        color: "lightgrey"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.width - 200

        Column {
            anchors.fill: parent
            anchors.margins: 10

            TextEntry { id: themeNameEntry; name: "themeName"; value: "default" }

            Item {width: 10; height: 20}

            TextEntry { id: cursorNameEntry; name: "cursorName"; value: "left_ptr" }

            Item {width: 10; height: 40}

            Rectangle {
                color: applyMouseArea.pressed ? "green" : "lightslategray"
                width: parent.width - 20
                height: 40
                Text { anchors.centerIn: parent; text: "Apply" }
                MouseArea {
                    id: applyMouseArea
                    anchors.fill: parent
                    onClicked: {
                        root.themeName = themeNameEntry.value;
                        root.cursorName = cursorNameEntry.value;
                    }
                }
            }

            Item {width: 10; height: 10}
            Rectangle {
                color: "black"
                height: 2
                anchors.left: parent.left
                anchors.right: parent.right
            }
            Item {width: 10; height: 10}

            Text { text: "frameWidth: " + imageInfo.frameWidth }
            Text { text: "frameHeight: " + imageInfo.frameHeight }
            Text { text: "frameCount: " + imageInfo.frameCount }
            Text { text: "frameDuration: " + imageInfo.frameDuration }
            Text { text: "currentFrame: " + animatedSprite.currentFrame }
        }
    }
}
