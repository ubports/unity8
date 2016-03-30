/*
 * Copyright (C) 2016 Canonical, Ltd.
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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Gestures 0.1
import "../Components/PanelState"

Item {
    id: root
    // to be set from outside
    property Item target // appDelegate
    property Item resizeTarget // WindowResizeArea
    property int borderThickness

    TabletSideStageTouchGesture {
        id: gestureArea
        anchors.fill: parent
        minimumTouchPoints: 2
        maximumTouchPoints: 2

        onRecognisedPressChanged: {
            print("Press recognized:", recognisedPress)
            if (recognisedPress) {
                overlayTimer.running = true;
            }
        }
        onRecognisedDragChanged: {
            print("Drag recognized:", recognisedDrag)
        }
        onPressed: print("Pressed:", x, y)
        onDropped: print("Dropped")
    }


    // dismiss timer
    Timer {
        id: overlayTimer
        interval: 2000
        repeat: priv.dragging || root.resizeTarget.dragging
    }


    // dismiss area
    InverseMouseArea {
        anchors.fill: overlay
        onClicked: overlayTimer.stop()
    }


    // move handler
    MouseArea {
        anchors.fill: overlay
        visible: overlay.visible
        enabled: visible

        onPressedChanged: {
            if (pressed) {
                var pos = mapToItem(root.target, mouseX, mouseY);
                priv.distanceX = pos.x;
                priv.distanceY = pos.y;
                priv.dragging = true;
            } else {
                priv.dragging = false;
            }
        }

        onPositionChanged: {
            if (priv.dragging) {
                var pos = mapToItem(root.target.parent, mouseX, mouseY);
                root.target.x = pos.x - priv.distanceX;
                root.target.y = Math.max(pos.y - priv.distanceY, PanelState.panelHeight);
            }
        }
    }

    QtObject {
        id: priv
        property real distanceX
        property real distanceY
        property bool dragging
    }


    // the visual overlay
    Item {
        id: overlay
        anchors.fill: parent
        opacity: overlayTimer.running && target && !target.maximized && !target.fullscreen ? 1 : 0
        visible: opacity == 1
        enabled: visible

        Behavior on opacity {
            OpacityAnimator { duration: UbuntuNumberAnimation.duration; easing: UbuntuNumberAnimation.easing }
        }

        Image {
            source: "graphics/arrows-centre.png"
            width: units.gu(6)
            height: width
            anchors.centerIn: parent
        }

        ResizeGrip { // top left
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: borderThickness
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: borderThickness
            visible: resizeTarget && !resizeTarget.maximizedLeft && !resizeTarget.maximizedRight
            resizeTarget: root.resizeTarget
        }

        ResizeGrip { // top center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: borderThickness
            rotation: 45
            visible: resizeTarget && !resizeTarget.maximizedLeft && !resizeTarget.maximizedRight
            resizeTarget: root.resizeTarget
        }

        ResizeGrip { // top right
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -borderThickness
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: borderThickness
            rotation: 90
            visible: resizeTarget && !resizeTarget.maximizedLeft && !resizeTarget.maximizedRight
            resizeTarget: root.resizeTarget
        }

        ResizeGrip { // right
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -borderThickness
            anchors.verticalCenter: parent.verticalCenter
            rotation: 135
            visible: resizeTarget && !resizeTarget.maximizedRight
            resizeTarget: root.resizeTarget
        }

        ResizeGrip { // bottom right
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -borderThickness
            anchors.verticalCenter: parent.bottom
            anchors.verticalCenterOffset: -borderThickness
            visible: resizeTarget && !resizeTarget.maximizedLeft && !resizeTarget.maximizedRight
            resizeTarget: root.resizeTarget
        }

        ResizeGrip { // bottom center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom
            anchors.verticalCenterOffset: -borderThickness
            rotation: 45
            visible: resizeTarget && !resizeTarget.maximizedLeft && !resizeTarget.maximizedRight
            resizeTarget: root.resizeTarget
        }

        ResizeGrip { // bottom left
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: borderThickness
            anchors.verticalCenter: parent.bottom
            anchors.verticalCenterOffset: -borderThickness
            rotation: 90
            visible: resizeTarget && !resizeTarget.maximizedLeft && !resizeTarget.maximizedRight
            resizeTarget: root.resizeTarget
        }

        ResizeGrip { // left
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: borderThickness
            anchors.verticalCenter: parent.verticalCenter
            rotation: 135
            visible: resizeTarget && !resizeTarget.maximizedLeft
            resizeTarget: root.resizeTarget
        }
    }
}
