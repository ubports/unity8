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
    property int stageWidth
    property int stageHeight

    // to be read from outside
    readonly property alias overlayShown: overlay.visible

    signal fakeMaximizeAnimationRequested(real progress)
    signal fakeMaximizeLeftAnimationRequested(real progress)
    signal fakeMaximizeRightAnimationRequested(real progress)
    signal fakeMaximizeTopLeftAnimationRequested(real progress)
    signal fakeMaximizeTopRightAnimationRequested(real progress)
    signal fakeMaximizeBottomLeftAnimationRequested(real progress)
    signal fakeMaximizeBottomRightAnimationRequested(real progress)
    signal stopFakeAnimation()

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
                priv.handlePressedChanged(true, tp.x, tp.y);
            } else if (!moveHandler.containsPress) { // prevent interfering with the central piece drag/move
                priv.dragging = false;
            }
        }

        readonly property point tp: recognizedPress ? Qt.point(touchPoints[0].x, touchPoints[0].y) : Qt.point(-1, -1)
        onUpdated: {
            if (recognizedDrag) {
                priv.handlePositionChanged(tp.x, tp.y);
            }
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
        readonly property bool ensureWindow: root.target.state == "normal" || root.target.state == "restored"

        readonly property int triggerArea: units.gu(8)
        property bool nearLeftEdge: target.maximizedLeft
        property bool nearTopEdge: target.maximized
        property bool nearRightEdge: target.maximizedRight
        property bool nearTopLeftCorner: target.maximizedTopLeft
        property bool nearTopRightCorner: target.maximizedTopRight
        property bool nearBottomLeftCorner: target.maximizedBottomLeft
        property bool nearBottomRightCorner: target.maximizedBottomRight

        function resetEdges() {
            nearLeftEdge = false;
            nearRightEdge = false;
            nearTopEdge = false;
            nearTopLeftCorner = false;
            nearTopRightCorner = false;
            nearBottomLeftCorner = false;
            nearBottomRightCorner = false;
        }

        function handlePressedChanged(pressed, mouseX, mouseY) {
            if (pressed) {
                var pos = mapToItem(root.target, mouseX, mouseY);
                priv.distanceX = pos.x;
                priv.distanceY = pos.y;
                priv.dragging = true;
            } else {
                priv.dragging = false;
            }
        }

        function handlePositionChanged(mouseX, mouseY) {
            var pos = mapToItem(root.target.parent, mouseX, mouseY);
            root.target.requestedX = Math.round(pos.x - priv.distanceX);
            root.target.requestedY = Math.round(Math.max(pos.y - priv.distanceY, PanelState.panelHeight));
        }

        function saveRestoredPos(x, y) {
            var pos = mapToItem(root.target, x, y);
            target.restoredX = Math.round(pos.x);
            target.restoredY = Math.round(pos.y);
        }

        // return the progress of mouse pointer movement from 0 to 1 within a corner square of the screen
        // 0 -> before the mouse enters the square
        // 1 -> mouse is exactly in the very corner
        // a is the corner, b is the mouse pos
        function progressInCorner(ax, ay, bx, by) {
            // distance of two points, a and b, in pixels
            var distance = Math.sqrt(Math.pow(bx-ax, 2) + Math.pow(by-ay, 2));
            // length of the triggerArea square diagonal
            var diagLength = Math.sqrt(2 * priv.triggerArea * priv.triggerArea);
            var ratio = 1 - (distance / diagLength);
            return bx > 0 && bx <= stageWidth && by > 0 && by <= stageHeight ? ratio : 1; // everything "outside" of our square from the center is 1
        }

        property real progress: 0
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
                id: moveHandler
                anchors.fill: parent
                visible: overlay.visible
                enabled: visible
                hoverEnabled: true
                cursorShape: priv.dragging ? Qt.ClosedHandCursor : (overlay.visible ? Qt.OpenHandCursor : Qt.ArrowCursor)

                onPressedChanged: priv.handlePressedChanged(pressed, mouseX, mouseY)
                onPositionChanged: {
                    if (priv.dragging) {
                        priv.handlePositionChanged(mouseX, mouseY);

                        var globalPos = mapToItem(null, mouseX, mouseY);
                        var globalX = globalPos.x;
                        var globalY = globalPos.y;
                        if (globalX < priv.triggerArea && globalY < PanelState.panelHeight) { // top left
                            if (target.canBeCornerMaximized) {
                                priv.progress = priv.progressInCorner(0, PanelState.panelHeight, globalX, globalY);
                                priv.resetEdges();
                                priv.nearTopLeftCorner = true;
                                root.fakeMaximizeTopLeftAnimationRequested(priv.progress);
                            }
                        } else if (globalX > stageWidth - priv.triggerArea && globalY < PanelState.panelHeight) { // top right
                            if (target.canBeCornerMaximized) {
                                priv.progress = priv.progressInCorner(stageWidth, PanelState.panelHeight, globalX, globalY);
                                priv.resetEdges();
                                priv.nearTopRightCorner = true;
                                root.fakeMaximizeTopRightAnimationRequested(priv.progress);
                            }
                        } else if (globalX < priv.triggerArea && globalY > stageHeight - priv.triggerArea) { // bottom left
                            if (target.canBeCornerMaximized) {
                                priv.progress = priv.progressInCorner(0, stageHeight, globalX, globalY);
                                priv.resetEdges();
                                priv.nearBottomLeftCorner = true;
                                root.fakeMaximizeBottomLeftAnimationRequested(priv.progress);
                            }
                        } else if (globalX > stageWidth - priv.triggerArea && globalY > stageHeight - priv.triggerArea) { // bottom right
                            if (target.canBeCornerMaximized) {
                                priv.progress = priv.progressInCorner(stageWidth, stageHeight, globalX, globalY);
                                priv.resetEdges();
                                priv.nearBottomRightCorner = true;
                                root.fakeMaximizeBottomRightAnimationRequested(priv.progress);
                            }
                        } else if (globalX < priv.triggerArea) { // left
                            if (target.canBeMaximizedLeftRight) {
                                priv.progress = MathUtils.clampAndProject(globalX, priv.triggerArea, 0, 0, 1);
                                priv.resetEdges();
                                priv.nearLeftEdge = true;
                                root.fakeMaximizeLeftAnimationRequested(priv.progress);
                            }
                        } else if (globalX > stageWidth - priv.triggerArea) { // right
                            if (target.canBeMaximizedLeftRight) {
                                priv.progress = MathUtils.clampAndProject(globalX, stageWidth - priv.triggerArea, stageWidth, 0, 1);
                                priv.resetEdges();
                                priv.nearRightEdge = true;
                                root.fakeMaximizeRightAnimationRequested(priv.progress);
                            }
                        } else if (globalY < PanelState.panelHeight) { // top
                            if (target.canBeMaximized) {
                                priv.progress = MathUtils.clampAndProject(globalY, Math.max(PanelState.panelHeight, priv.triggerArea), 0, 0, 1);
                                priv.resetEdges();
                                priv.nearTopEdge = true;
                                root.fakeMaximizeAnimationRequested(priv.progress);
                            }
                        } else if (priv.nearLeftEdge || priv.nearRightEdge || priv.nearTopEdge || priv.nearTopLeftCorner || priv.nearTopRightCorner ||
                                   priv.nearBottomLeftCorner || priv.nearBottomRightCorner) {
                            print("!!! Exited")
                            priv.progress = 0;
                            priv.resetEdges();
                            root.stopFakeAnimation();
                        } else if (target.anyMaximized) {
                            priv.progress = 0;
                            target.restoreFromMaximized();
                        }
                    }
                }
                onReleased: {
                    print("Mouse released (left/top/right)", priv.nearLeftEdge, priv.nearTopEdge, priv.nearRightEdge)
                    if (mouse.button == Qt.LeftButton && (target.state == "normal" || target.state == "restored") && priv.progress == 0) {
                        priv.saveRestoredPos(target.x, target.y);
                    } else if (priv.progress < 0.3) { // cancel the preview shape if under 30%
                        priv.progress = 0;
                        priv.resetEdges();
                        root.stopFakeAnimation();
                    } else if (priv.nearLeftEdge) {
                        target.maximizeLeft();
                    } else if (priv.nearTopEdge) {
                        target.maximize();
                    } else if (priv.nearRightEdge) {
                        target.maximizeRight();
                    } else if (priv.nearTopLeftCorner) {
                        target.maximizeTopLeft();
                    } else if (priv.nearTopRightCorner) {
                        target.maximizeTopRight();
                    } else if (priv.nearBottomLeftCorner) {
                        target.maximizeBottomLeft();
                    } else if (priv.nearBottomRightCorner) {
                        target.maximizeBottomRight();
                    }
                }
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
                    mouse.accepted = root.contains(Qt.point(mouse.x, mouse.y));
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
