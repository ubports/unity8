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

    readonly property alias dragging: priv.dragging

    signal fakeMaximizeAnimationRequested(real amount)
    signal fakeMaximizeLeftAnimationRequested(real amount)
    signal fakeMaximizeRightAnimationRequested(real amount)
    signal fakeMaximizeTopLeftAnimationRequested(real amount)
    signal fakeMaximizeTopRightAnimationRequested(real amount)
    signal fakeMaximizeBottomLeftAnimationRequested(real amount)
    signal fakeMaximizeBottomRightAnimationRequested(real amount)
    signal stopFakeAnimation()

    signal shouldCommitSnapWindow()

    QtObject {
        id: priv
        property real distanceX
        property real distanceY
        property bool dragging

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
        if (pressed && pressedButtons === Qt.LeftButton) {
            var pos = mapToItem(target, mouseX, mouseY);
            if (target.anyMaximized) {
                // keep distanceX relative to the normal window width minus the window control buttons (+spacing)
                // so that dragging it back doesn't make the window jump around to weird positions, away from the mouse pointer
                priv.distanceX = MathUtils.clampAndProject(pos.x, 0, target.width, buttonsWidth, target.resizeArea.normalWidth);
                priv.distanceY = MathUtils.clampAndProject(pos.y, 0, target.height, 0, target.resizeArea.normalHeight);
            } else {
                priv.distanceX = pos.x;
                priv.distanceY = pos.y;
            }

            priv.dragging = true;
        } else {
            priv.dragging = false;
            Mir.cursorName = "";
        }
    }

    function handlePositionChanged(mouse, sensingPoints) {
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

            if (sensingPoints) { // edge/corner detection when dragging via the touch overlay
                if (sensingPoints.topLeft.x < priv.triggerArea && sensingPoints.topLeft.y < PanelState.panelHeight + priv.triggerArea
                        && target.canBeCornerMaximized) { // top left
                    priv.progress = priv.progressInCorner(0, PanelState.panelHeight, sensingPoints.topLeft.x, sensingPoints.topLeft.y);
                    priv.resetEdges();
                    priv.nearTopLeftCorner = true;
                    root.fakeMaximizeTopLeftAnimationRequested(priv.progress);
                } else if (sensingPoints.topRight.x > stageWidth - priv.triggerArea && sensingPoints.topRight.y < PanelState.panelHeight + priv.triggerArea
                           && target.canBeCornerMaximized) { // top right
                    priv.progress = priv.progressInCorner(stageWidth, PanelState.panelHeight, sensingPoints.topRight.x, sensingPoints.topRight.y);
                    priv.resetEdges();
                    priv.nearTopRightCorner = true;
                    root.fakeMaximizeTopRightAnimationRequested(priv.progress);
                } else if (sensingPoints.bottomLeft.x < priv.triggerArea && sensingPoints.bottomLeft.y > stageHeight - priv.triggerArea
                           && target.canBeCornerMaximized) { // bottom left
                    priv.progress = priv.progressInCorner(0, stageHeight, sensingPoints.bottomLeft.x, sensingPoints.bottomLeft.y);
                    priv.resetEdges();
                    priv.nearBottomLeftCorner = true;
                    root.fakeMaximizeBottomLeftAnimationRequested(priv.progress);
                } else if (sensingPoints.bottomRight.x > stageWidth - priv.triggerArea && sensingPoints.bottomRight.y > stageHeight - priv.triggerArea
                           && target.canBeCornerMaximized) { // bottom right
                    priv.progress = priv.progressInCorner(stageWidth, stageHeight, sensingPoints.bottomRight.x, sensingPoints.bottomRight.y);
                    priv.resetEdges();
                    priv.nearBottomRightCorner = true;
                    root.fakeMaximizeBottomRightAnimationRequested(priv.progress);
                } else if (sensingPoints.left.x < priv.triggerArea && target.canBeMaximizedLeftRight) { // left
                    priv.progress = MathUtils.clampAndProject(sensingPoints.left.x, priv.triggerArea, 0, 0, 1);
                    priv.resetEdges();
                    priv.nearLeftEdge = true;
                    root.fakeMaximizeLeftAnimationRequested(priv.progress);
                } else if (sensingPoints.right.x > stageWidth - priv.triggerArea && target.canBeMaximizedLeftRight) { // right
                    priv.progress = MathUtils.clampAndProject(sensingPoints.right.x, stageWidth - priv.triggerArea, stageWidth, 0, 1);
                    priv.resetEdges();
                    priv.nearRightEdge = true;
                    root.fakeMaximizeRightAnimationRequested(priv.progress);
                } else if (sensingPoints.top.y < PanelState.panelHeight + priv.triggerArea && target.canBeMaximized) { // top
                    priv.progress = MathUtils.clampAndProject(sensingPoints.top.y, PanelState.panelHeight + priv.triggerArea, 0, 0, 1);
                    priv.resetEdges();
                    priv.nearTopEdge = true;
                    root.fakeMaximizeAnimationRequested(priv.progress);
                } else if (priv.nearLeftEdge || priv.nearRightEdge || priv.nearTopEdge || priv.nearTopLeftCorner || priv.nearTopRightCorner ||
                           priv.nearBottomLeftCorner || priv.nearBottomRightCorner) {
                    priv.progress = 0;
                    priv.resetEdges();
                    root.stopFakeAnimation();
                }
            }
        }
    }

    function handleReleased(touchMode) {
        if (touchMode) {
            root.shouldCommitSnapWindow();
            priv.progress = 0;
            priv.resetEdges();
        }
        if ((target.state == "normal" || target.state == "restored") && priv.progress == 0) {
            // save the x/y to restore to
            target.restoredX = target.x;
            target.restoredY = target.y;
        }
    }
}
