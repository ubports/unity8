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

Item {
    // to be set from outside
    property Item target // appDelegate
    property int borderThickness

    TabletSideStageTouchGesture {
        id: gestureArea
        minimumTouchPoints: 2
        maximumTouchPoints: 2
        anchors.fill: parent

        onRecognisedPressChanged: {
            print("Press recognized:", recognisedPress)
            if (recognisedPress) {
                overlayTimer.running = true;
            }
        }
        onRecognisedDragChanged: {
            print("Drag recognized:", recognisedDrag)
        }
        onDragStarted: print("Drag started")
        onDropped: print("Dropped")
        onCancelled: print("Cancelled")
    }

    Timer { // dismiss timer
        id: overlayTimer
        interval: 2000
    }

    InverseMouseArea { // dismiss area
        anchors.fill: overlay
        onClicked: overlayTimer.stop()
    }

    Item {
        id: overlay
        anchors.fill: parent
        visible: (overlayTimer.running && target && !target.maximized && !target.fullscreen) ||
                 gestureArea.recognisedDrag
        enabled: visible

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
            visible: target && !target.maximizedLeft && !target.maximizedRight
        }

        ResizeGrip { // top center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: borderThickness
            rotation: 45
            visible: target && !target.maximizedLeft && !target.maximizedRight
        }

        ResizeGrip { // top right
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -borderThickness
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: borderThickness
            rotation: 90
            visible: target && !target.maximizedLeft && !target.maximizedRight
        }

        ResizeGrip { // right
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -borderThickness
            anchors.verticalCenter: parent.verticalCenter
            rotation: 135
            visible: target && !target.maximizedRight
        }

        ResizeGrip { // bottom right
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -borderThickness
            anchors.verticalCenter: parent.bottom
            anchors.verticalCenterOffset: -borderThickness
            visible: target && !target.maximizedLeft && !target.maximizedRight
        }

        ResizeGrip { // bottom center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom
            anchors.verticalCenterOffset: -borderThickness
            rotation: 45
            visible: target && !target.maximizedLeft && !target.maximizedRight
        }

        ResizeGrip { // bottom left
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: borderThickness
            anchors.verticalCenter: parent.bottom
            anchors.verticalCenterOffset: -borderThickness
            rotation: 90
            visible: target && !target.maximizedLeft && !target.maximizedRight
        }

        ResizeGrip { // left
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: borderThickness
            anchors.verticalCenter: parent.verticalCenter
            rotation: 135
            visible: target && !target.maximizedLeft
        }
    }
}
