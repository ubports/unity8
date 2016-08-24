/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import Unity.Application 0.1 // For Mir singleton
import Ubuntu.Components 1.3
import Utils 0.1
import "../Components"
import "../Components/PanelState"

Item {
    id: root

    property Item target // appDelegate
    property int stageWidth
    property int stageHeight
    property real buttonsWidth: 0

    signal fakeMaximizeAnimationRequested(real progress)
    signal fakeMaximizeLeftAnimationRequested(real progress)
    signal fakeMaximizeRightAnimationRequested(real progress)
    signal fakeMaximizeTopLeftAnimationRequested(real progress)
    signal fakeMaximizeTopRightAnimationRequested(real progress)
    signal fakeMaximizeBottomLeftAnimationRequested(real progress)
    signal fakeMaximizeBottomRightAnimationRequested(real progress)
    signal stopFakeAnimation()

    QtObject {
        id: priv
        property real distanceX
        property real distanceY
        property bool dragging

        readonly property int triggerArea: units.gu(3)
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

        // return the progress of mouse pointer movement from 0 to 1 within a corner square of the screen
        // 0 -> before the mouse enters the square
        // 1 -> mouse is in the outer corner
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

    function handlePressedChanged(pressed, pressedButtons, mouseX, mouseY) {
        if (pressed && pressedButtons == Qt.LeftButton) {
            var pos = mapToItem(target, mouseX, mouseY);
            if (target.anyMaximized) {
                // keep distanceX relative to the normal window width minus the window control buttons (+spacing)
                // so that dragging it back doesn't make the window jump around to weird positions, away from the mouse pointer
                priv.distanceX = MathUtils.clampAndProject(pos.x, 0, target.width, buttonsWidth, target.resizeArea.normalWidth);
            } else {
                priv.distanceX = pos.x;
            }

            priv.distanceY = pos.y;
            priv.dragging = true;
        } else {
            priv.dragging = false;
            Mir.cursorName = "";
        }
    }

    function handlePositionChanged(mouse) {
        if (priv.dragging) {
            Mir.cursorName = "grabbing";

            if (target.anyMaximized) { // restore from maximized when dragging away from edges/corners
                priv.progress = 0;
                target.restore(false, WindowStateStorage.WindowStateNormal);
            }

            var pos = mapToItem(target.parent, mouse.x, mouse.y);
            // Use integer coordinate values to ensure that target is left in a pixel-aligned
            // position. Mouse movement could have subpixel precision, yielding a fractional
            // mouse position.
            target.requestedX = Math.round(pos.x - priv.distanceX);
            target.requestedY = Math.round(Math.max(pos.y - priv.distanceY, PanelState.panelHeight));

            var globalPos = mapToItem(null, mouse.x, mouse.y);
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
            }
        }
    }

    function handleReleased(mouse) {
        print("Mouse released (left/top/right)", priv.nearLeftEdge, priv.nearTopEdge, priv.nearRightEdge)
        if (mouse.button == Qt.LeftButton && (target.state == "normal" || target.state == "restored") && priv.progress == 0) {
            // save the x/y to restore to
            target.restoredX = target.x;
            target.restoredY = target.y;
        } else if (priv.progress < 0.3) { // cancel the preview shape if under 30%
            priv.progress = 0;
            priv.resetEdges();
            root.stopFakeAnimation();
        } else if (priv.nearLeftEdge) {
            target.maximizeLeft();
            priv.resetEdges();
        } else if (priv.nearTopEdge) {
            target.maximize();
            priv.resetEdges();
        } else if (priv.nearRightEdge) {
            target.maximizeRight();
            priv.resetEdges();
        } else if (priv.nearTopLeftCorner) {
            target.maximizeTopLeft();
            priv.resetEdges();
        } else if (priv.nearTopRightCorner) {
            target.maximizeTopRight();
            priv.resetEdges();
        } else if (priv.nearBottomLeftCorner) {
            target.maximizeBottomLeft();
            priv.resetEdges();
        } else if (priv.nearBottomRightCorner) {
            target.maximizeBottomRight();
            priv.resetEdges();
        }
    }
}
