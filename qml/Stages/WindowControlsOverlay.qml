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
import Unity.Application 0.1
import "../Components/PanelState"
import "../Components/TouchControlsState"

Item {
    id: root

    // to be set from outside
    property Item target // appDelegate

    TouchGestureArea {
        id: gestureArea
        anchors.fill: parent

        // NB: for testing set to 2, not to clash with unity7 touch overlay controls
        minimumTouchPoints: 2
        maximumTouchPoints: minimumTouchPoints
        recognitionPeriod: 500
        releaseRejectPeriod: 500

        readonly property bool recognizedPress: status == TouchGestureArea.Recognized &&
                                                touchPoints.length >= minimumTouchPoints &&
                                                touchPoints.length <= maximumTouchPoints

        onRecognizedPressChanged: {
            if (recognizedPress && target && !target.fullscreen) {
                print("!!! RECOGNIZED")
                overlayTimer.start();
            }
        }

        onStatusChanged: {
            print("Status changed:", status)
        }
    }

    // dismiss timer
    Timer {
        id: overlayTimer
        interval: 2000
        repeat: priv.dragging || (priv.resizeArea && priv.resizeArea.dragging)
    }

    QtObject {
        id: priv
        property real distanceX
        property real distanceY
        property bool dragging

        readonly property var resizeArea: root.target && root.target.resizeArea ? root.target.resizeArea : null
    }

    Binding {
        target: TouchControlsState
        property: "overlayShown"
        value: overlay.visible
    }

    // the visual overlay
    Item {
        id: overlay
        objectName: "windowControlsOverlay"
        anchors.fill: parent
        visible: target.surface == MirFocusController.focusedSurface && overlayTimer.running
        opacity: visible ? 1 : 0

        Behavior on opacity {
            OpacityAnimator { duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing }
        }

        readonly property bool anyMaximized: target && (target.maximized || target.maximizedLeft || target.maximizedRight)

        Image {
            source: "graphics/arrows-centre.png"
            width: units.gu(10)
            height: width
            sourceSize: Qt.size(width, height)
            anchors.centerIn: parent
            opacity: 0.95
            visible: target && target.width > units.gu(12) && target.height > units.gu(12)

            // move handler
            MouseArea {
                anchors.fill: parent
                visible: overlay.visible
                enabled: visible
                hoverEnabled: true
                cursorShape: priv.dragging ? Qt.ClosedHandCursor : (overlay.visible ? Qt.OpenHandCursor : Qt.ArrowCursor)

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

            // dismiss area
            InverseMouseArea {
                anchors.fill: parent
                visible: overlay.visible
                enabled: visible
                onPressed: {
                    overlayTimer.stop();
                    mouse.accepted = false;
                }
                propagateComposedEvents: true
            }
        }

        ResizeGrip { // top left
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.top
            visible: target && !overlay.anyMaximized
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // top center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top
            rotation: 45
            visible: target && !overlay.anyMaximized
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // top right
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.top
            rotation: 90
            visible: target && !overlay.anyMaximized
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // right
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.verticalCenter
            rotation: 135
            visible: target && !target.maximizedRight && !target.maximized
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // bottom right
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.bottom
            visible: target && !overlay.anyMaximized
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // bottom center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom
            rotation: 45
            visible: target && !overlay.anyMaximized
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // bottom left
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.bottom
            rotation: 90
            visible: target && !overlay.anyMaximized
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // left
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.verticalCenter
            rotation: 135
            visible: target && !target.maximizedLeft && !target.maximized
            resizeTarget: priv.resizeArea
        }
    }
}
