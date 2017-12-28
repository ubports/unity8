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

QtObject {
    id: root

    property Item target // appDelegate
    property real buttonsWidth: 0
    property Item boundsItem
    property real boundsTopMargin: 0

    readonly property bool dragging: priv.dragging
    readonly property bool moving: priv.moving

    signal fakeMaximizeAnimationRequested(real amount)
    signal fakeMaximizeLeftAnimationRequested(real amount)
    signal fakeMaximizeRightAnimationRequested(real amount)
    signal fakeMaximizeTopLeftAnimationRequested(real amount)
    signal fakeMaximizeTopRightAnimationRequested(real amount)
    signal fakeMaximizeBottomLeftAnimationRequested(real amount)
    signal fakeMaximizeBottomRightAnimationRequested(real amount)
    signal stopFakeAnimation()

    property QtObject priv: QtObject {
        property real distanceX
        property real distanceY
        property bool dragging
        property bool moving

        readonly property int triggerArea: units.gu(8)
        property bool nearLeftEdge: target.maximizedLeft
        property bool nearTopEdge: target.maximized
        property bool nearRightEdge: target.maximizedRight
        property bool nearTopLeftCorner: target.maximizedTopLeft
        property bool nearTopRightCorner: target.maximizedTopRight
        property bool nearBottomLeftCorner: target.maximizedBottomLeft
        property bool nearBottomRightCorner: target.maximizedBottomRight

        property Timer mouseDownTimer: Timer {
            interval: 175
            onTriggered: Mir.cursorName = "grabbing"
        }

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

            // everything "outside" of our square from the center is 1
            var mousePosBoundsCoords = target.mapToItem(root.boundsItem, bx, by);
            return root.boundsItem.contains(mousePosBoundsCoords) ? ratio : 1;
        }
        property real progress: 0
    }

    function handlePressedChanged(pressed, pressedButtons, mouseX, mouseY) {
        if (pressed && pressedButtons === Qt.LeftButton) {
            var pos = mapToItem(target, mouseX, mouseY);
            if (target.anyMaximized) {
                // keep distanceX relative to the normal window width minus the window control buttons (+spacing)
                // so that dragging it back doesn't make the window jump around to weird positions, away from the mouse pointer
                priv.distanceX = MathUtils.clampAndProject(pos.x, 0, target.width, buttonsWidth, target.normalWidth);
                priv.distanceY = MathUtils.clampAndProject(pos.y, 0, target.height, 0, target.normalHeight);
            } else {
                priv.distanceX = pos.x;
                priv.distanceY = pos.y;
            }

            priv.dragging = true;
            priv.mouseDownTimer.start();
        } else {
            priv.dragging = false;
            priv.mouseDownTimer.stop();
            Mir.cursorName = "";
        }
    }

    function handlePositionChanged(mouse, sensingPoints) {
        if (priv.dragging) {
            priv.moving = true;
            priv.mouseDownTimer.stop();
            Mir.cursorName = "grabbing";

            // restore from maximized when dragging away from edges/corners; guard against inadvertent changes when going into maximized state
            if (target.anyMaximized && !target.windowedTransitionRunning) {
                priv.progress = 0;
                target.requestRestore();
            }

            var pos = mapToItem(target.parent, mouse.x, mouse.y); // How can that work if we're just a QtObject (not an Item)?
            var bounds = boundsItem.mapToItem(target.parent, 0, 0, boundsItem.width, boundsItem.height);
            bounds.y += boundsTopMargin;
            bounds.height -= boundsTopMargin;
            // Use integer coordinate values to ensure that target is left in a pixel-aligned
            // position. Mouse movement could have subpixel precision, yielding a fractional
            // mouse position.
            target.windowedX = Math.round(pos.x - priv.distanceX);
            target.windowedY = Math.round(Math.max(pos.y - priv.distanceY, bounds.top));

            if (sensingPoints) { // edge/corner detection when dragging via the touch overlay
                if (sensingPoints.topLeft.x < priv.triggerArea && sensingPoints.topLeft.y < bounds.top + priv.triggerArea
                        && target.canBeCornerMaximized) { // top left
                    priv.progress = priv.progressInCorner(bounds.left, bounds.top, sensingPoints.topLeft.x, sensingPoints.topLeft.y);
                    priv.resetEdges();
                    priv.nearTopLeftCorner = true;
                    root.fakeMaximizeTopLeftAnimationRequested(priv.progress);
                } else if (sensingPoints.topRight.x > bounds.right - priv.triggerArea && sensingPoints.topRight.y < bounds.top + priv.triggerArea
                           && target.canBeCornerMaximized) { // top right
                    priv.progress = priv.progressInCorner(bounds.right, bounds.top, sensingPoints.topRight.x, sensingPoints.topRight.y);
                    priv.resetEdges();
                    priv.nearTopRightCorner = true;
                    root.fakeMaximizeTopRightAnimationRequested(priv.progress);
                } else if (sensingPoints.bottomLeft.x < priv.triggerArea && sensingPoints.bottomLeft.y > bounds.bottom - priv.triggerArea
                           && target.canBeCornerMaximized) { // bottom left
                    priv.progress = priv.progressInCorner(bounds.left, bounds.bottom, sensingPoints.bottomLeft.x, sensingPoints.bottomLeft.y);
                    priv.resetEdges();
                    priv.nearBottomLeftCorner = true;
                    root.fakeMaximizeBottomLeftAnimationRequested(priv.progress);
                } else if (sensingPoints.bottomRight.x > bounds.right - priv.triggerArea && sensingPoints.bottomRight.y > bounds.bottom - priv.triggerArea
                           && target.canBeCornerMaximized) { // bottom right
                    priv.progress = priv.progressInCorner(bounds.right, bounds.bottom, sensingPoints.bottomRight.x, sensingPoints.bottomRight.y);
                    priv.resetEdges();
                    priv.nearBottomRightCorner = true;
                    root.fakeMaximizeBottomRightAnimationRequested(priv.progress);
                } else if (sensingPoints.left.x < priv.triggerArea && target.canBeMaximizedLeftRight) { // left
                    priv.progress = MathUtils.clampAndProject(sensingPoints.left.x, priv.triggerArea, 0, 0, 1);
                    priv.resetEdges();
                    priv.nearLeftEdge = true;
                    root.fakeMaximizeLeftAnimationRequested(priv.progress);
                } else if (sensingPoints.right.x > bounds.right - priv.triggerArea && target.canBeMaximizedLeftRight) { // right
                    priv.progress = MathUtils.clampAndProject(sensingPoints.right.x, bounds.right - priv.triggerArea, bounds.right, 0, 1);
                    priv.resetEdges();
                    priv.nearRightEdge = true;
                    root.fakeMaximizeRightAnimationRequested(priv.progress);
                } else if (sensingPoints.top.y < bounds.top + priv.triggerArea && target.canBeMaximized) { // top
                    priv.progress = MathUtils.clampAndProject(sensingPoints.top.y, bounds.top + priv.triggerArea, 0, 0, 1);
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
        priv.moving = false;
        if (touchMode) {
            priv.progress = 0;
            priv.resetEdges();
        }
    }

    function cancelDrag() {
        priv.dragging = false;
        root.stopFakeAnimation();
        priv.mouseDownTimer.stop();
        Mir.cursorName = "";
        priv.progress = 0;
        priv.resetEdges();
    }
}
