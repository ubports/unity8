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

Item {
    id: root
    enabled: target && !target.fullscreen
    anchors.fill: target

    // to be set from outside
    property Item target // appDelegate
    property alias stageWidth: moveHandler.stageWidth
    property alias stageHeight: moveHandler.stageHeight

    // to be read from outside
    readonly property alias overlayShown: overlay.visible
    readonly property alias moveHandler: moveHandler

    signal fakeMaximizeAnimationRequested(real amount)
    signal fakeMaximizeLeftAnimationRequested(real amount)
    signal fakeMaximizeRightAnimationRequested(real amount)
    signal fakeMaximizeTopLeftAnimationRequested(real amount)
    signal fakeMaximizeTopRightAnimationRequested(real amount)
    signal fakeMaximizeBottomLeftAnimationRequested(real amount)
    signal fakeMaximizeBottomRightAnimationRequested(real amount)
    signal stopFakeAnimation()
    signal shouldCommitSnapWindow()

    TouchGestureArea {
        id: gestureArea
        anchors.fill: parent

        // NB: for testing set to 2, not to clash with unity7 touch overlay controls
        minimumTouchPoints: 3
        maximumTouchPoints: minimumTouchPoints

        readonly property bool recognizedPress: status == TouchGestureArea.Recognized &&
                                                touchPoints.length >= minimumTouchPoints &&
                                                touchPoints.length <= maximumTouchPoints
        onRecognizedPressChanged: {
            if (recognizedPress) {
                target.focus = true;
                overlayTimer.start();
            }
        }

        readonly property bool recognizedDrag: recognizedPress && dragging
        onRecognizedDragChanged: {
            if (recognizedDrag) {
                moveHandler.handlePressedChanged(true, Qt.LeftButton, tp.x, tp.y);
            } else if (!mouseArea.containsPress) { // prevent interfering with the central piece drag/move
                moveHandler.handlePressedChanged(false, Qt.LeftButton);
                moveHandler.handleReleased(true);
            }
        }

        readonly property point tp: recognizedPress ? Qt.point(touchPoints[0].x, touchPoints[0].y) : Qt.point(-1, -1)
        onUpdated: {
            if (recognizedDrag) {
                moveHandler.handlePositionChanged(tp, priv.getSensingPoints());
            }
        }
    }

    // dismiss timer
    Timer {
        id: overlayTimer
        interval: 2000
        repeat: moveHandler.dragging || (priv.resizeArea && priv.resizeArea.dragging)
    }

    QtObject {
        id: priv
        readonly property var resizeArea: root.target && root.target.resizeArea ? root.target.resizeArea : null
        readonly property bool ensureWindow: root.target.state == "normal" || root.target.state == "restored"

        function getSensingPoints() {
            var xPoints = [];
            var yPoints = [];
            for (var i = 0; i < gestureArea.touchPoints.length; i++) {
                var pt = gestureArea.touchPoints[i];
                xPoints.push(pt.x);
                yPoints.push(pt.y);
            }

            var leftmost = Math.min.apply(Math, xPoints);
            var rightmost = Math.max.apply(Math, xPoints);
            var topmost = Math.min.apply(Math, yPoints);
            var bottommost = Math.max.apply(Math, yPoints);

            return {
                left: mapToItem(target.parent, leftmost, (topmost+bottommost)/2),
                top: mapToItem(target.parent, (leftmost+rightmost)/2, topmost),
                right: mapToItem(target.parent, rightmost, (topmost+bottommost)/2),
                topLeft: mapToItem(target.parent, leftmost, topmost),
                topRight: mapToItem(target.parent, rightmost, topmost),
                bottomLeft: mapToItem(target.parent, leftmost, bottommost),
                bottomRight: mapToItem(target.parent, rightmost, bottommost)
            }
        }
    }

    // the visual overlay
    Item {
        id: overlay
        objectName: "windowControlsOverlay"
        anchors.fill: parent
        enabled: overlayTimer.running
        visible: opacity > 0
        opacity: enabled ? 0.95 : 0

        Behavior on opacity {
            UbuntuNumberAnimation {}
        }

        Image {
            source: "graphics/arrows-centre.png"
            width: units.gu(10)
            height: width
            sourceSize: Qt.size(width, height)
            anchors.centerIn: parent
            visible: target && target.width > units.gu(12) && target.height > units.gu(12)

            // move handler
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                visible: overlay.visible
                enabled: visible
                hoverEnabled: true

                onPressedChanged: moveHandler.handlePressedChanged(pressed, pressedButtons, mouseX, mouseY)
                onPositionChanged: moveHandler.handlePositionChanged(mouse)
                onReleased: {
                    root.shouldCommitSnapWindow();
                    moveHandler.handleReleased();
                }
            }

            MoveHandler {
                id: moveHandler
                anchors.fill: mouseArea
                objectName: "moveHandler"
                target: root.target

                onFakeMaximizeAnimationRequested: root.fakeMaximizeAnimationRequested(amount)
                onFakeMaximizeLeftAnimationRequested: root.fakeMaximizeLeftAnimationRequested(amount)
                onFakeMaximizeRightAnimationRequested: root.fakeMaximizeRightAnimationRequested(amount)
                onFakeMaximizeTopLeftAnimationRequested: root.fakeMaximizeTopLeftAnimationRequested(amount)
                onFakeMaximizeTopRightAnimationRequested: root.fakeMaximizeTopRightAnimationRequested(amount)
                onFakeMaximizeBottomLeftAnimationRequested: root.fakeMaximizeBottomLeftAnimationRequested(amount)
                onFakeMaximizeBottomRightAnimationRequested: root.fakeMaximizeBottomRightAnimationRequested(amount)
                onStopFakeAnimation: root.stopFakeAnimation()
                onShouldCommitSnapWindow: root.shouldCommitSnapWindow();
            }

            // dismiss area
            InverseMouseArea {
                anchors.fill: parent
                visible: overlay.visible
                enabled: visible
                onPressed: {
                    if (gestureArea.recognizedPress || gestureArea.recognizedDrag) {
                        mouse.accepted = false;
                        return;
                    }

                    overlayTimer.stop();
                    mouse.accepted = root.contains(mapToItem(root.target, mouse.x, mouse.y));
                }
                propagateComposedEvents: true
            }
        }

        ResizeGrip { // top left
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.top
            visible: priv.ensureWindow || target.maximizedBottomRight
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // top center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top
            rotation: 45
            visible: priv.ensureWindow || target.maximizedHorizontally || target.maximizedBottomLeft || target.maximizedBottomRight
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // top right
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.top
            rotation: 90
            visible: priv.ensureWindow || target.maximizedBottomLeft
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // right
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.verticalCenter
            rotation: 135
            visible: priv.ensureWindow || target.maximizedVertically || target.maximizedLeft ||
                     target.maximizedTopLeft || target.maximizedBottomLeft
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // bottom right
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.bottom
            visible: priv.ensureWindow || target.maximizedTopLeft
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // bottom center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom
            rotation: 45
            visible: priv.ensureWindow || target.maximizedHorizontally || target.maximizedTopLeft || target.maximizedTopRight
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // bottom left
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.bottom
            rotation: 90
            visible: priv.ensureWindow || target.maximizedTopRight
            resizeTarget: priv.resizeArea
        }

        ResizeGrip { // left
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.verticalCenter
            rotation: 135
            visible: priv.ensureWindow || target.maximizedVertically || target.maximizedRight ||
                     target.maximizedTopRight || target.maximizedBottomRight
            resizeTarget: priv.resizeArea
        }
    }
}
