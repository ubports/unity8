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
import Utils 0.1 // For EdgeBarrierSettings
import "../Components/PanelState"

Rectangle {
    id: fakeRectangle
    visible: opacity > 0 && target && !target.anyMaximized // we go from 0.2 to 0.6
    enabled: visible
    color: "#ffffff"
    border.width: units.dp(1)
    border.color: "#99ffffff"
    opacity: 0

    property int edge: -1 // Item.TransformOrigin
    property var target   // appDelegate
    property int leftMargin
    property real appContainerWidth
    property real appContainerHeight

    readonly property bool targetDragging: target && target.moveHandler.dragging

    // Edge push progress
    // Value range is [0.0, 1.0]
    readonly property real progress: Math.min(Math.max(0.0, priv.accumulatedPush / EdgeBarrierSettings.pushThreshold), 1.0)
    onProgressChanged: {
        print("!!! Progress:", progress)
    }

    QtObject {
        id: priv

        property real accumulatedPush: 0

        function push(amount) {
            if (accumulatedPush === EdgeBarrierSettings.pushThreshold) {
                // NO-OP
                print("!!! Accumulated push already at threshold")
                return;
            }

            if (accumulatedPush + amount > EdgeBarrierSettings.pushThreshold) {
                accumulatedPush = EdgeBarrierSettings.pushThreshold;
            } else {
                accumulatedPush += amount;
            }

            if (accumulatedPush === EdgeBarrierSettings.pushThreshold) {
                print("!!! Reached push progress 1, maximizing")
                commit();
            }
        }

        function setup(edge) {
            if (edge !== fakeRectangle.edge) {
                stop(); // a different edge, start anew
            }
            fakeRectangle.x = target.x;
            fakeRectangle.y = target.y;
            fakeRectangle.width = target.width;
            fakeRectangle.height = target.height;
            fakeRectangle.edge = edge;
            fakeRectangle.transformOrigin = edge;
        }

        function projectOpacity() {
            // progress falls into [0,1], opacity moves in [0.2,0.6]
            fakeRectangle.opacity = MathUtils.clampAndProject(progress, 0.0, 1.0, 0.2, 0.6);
        }

        function projectScale() {
            // progress falls into [0,1], scale moves in [1,2] as a hint, when under 10%
            fakeRectangle.scale = MathUtils.clampAndProject(progress, 0, 1, 1, 2);
        }

        function processAnimation(amount, animation) {
            priv.push(amount);

            if (progress > 0.1) { // above 10% we start the full preview animation
                fakeRectangle.scale = 1;
                animation.start();
            } else {
                priv.projectScale();
            }

            priv.projectOpacity();
        }
    }

    function commit() {
        if (progress > 0.1 && edge != -1) {
            print("!!! Committing edge", edge, ", progress:", progress);
            target.moveHandler.handlePressedChanged(false, Qt.LeftButton, 0, 0); // cancel the drag
            if (edge == Item.Top) {
                target.maximize();
            } else if (edge == Item.Left) {
                target.maximizeLeft();
            } else if (edge == Item.Right) {
                target.maximizeRight();
            } else if (edge == Item.TopLeft) {
                target.maximizeTopLeft();
            } else if (edge == Item.TopRight) {
                target.maximizeTopRight();
            } else if (edge == Item.BottomLeft) {
                target.maximizeBottomLeft();
            } else if (edge == Item.BottomRight) {
                target.maximizeBottomRight();
            }
        }
    }

    function stop() {
        print("!!! Stop")
        opacity = 0;
        edge = -1;
        priv.accumulatedPush = 0;
    }

    function maximize(amount) {
        if (fakeRectangle.edge != Item.Top) {
            priv.setup(Item.Top);
        }
        priv.processAnimation(amount, fakeMaximizeAnimation);
    }

    function maximizeLeft(amount) {
        if (fakeRectangle.edge != Item.Left) {
            priv.setup(Item.Left);
        }
        priv.processAnimation(amount, fakeMaximizeLeftAnimation);
    }

    function maximizeRight(amount) {
        if (fakeRectangle.edge != Item.Right) {
            priv.setup(Item.Right);
        }
        priv.processAnimation(amount, fakeMaximizeRightAnimation);
    }

    function maximizeTopLeft(amount) {
        if (fakeRectangle.edge != Item.TopLeft) {
            priv.setup(Item.TopLeft);
        }
        priv.processAnimation(amount, fakeMaximizeTopLeftAnimation);
    }

    function maximizeTopRight(amount) {
        if (fakeRectangle.edge != Item.TopRight) {
            priv.setup(Item.TopRight);
        }
        priv.processAnimation(amount, fakeMaximizeTopRightAnimation);
    }

    function maximizeBottomLeft(amount) {
        if (fakeRectangle.edge != Item.BottomLeft) {
            priv.setup(Item.BottomLeft);
        }
        priv.processAnimation(amount, fakeMaximizeBottomLeftAnimation);
    }

    function maximizeBottomRight(amount) {
        if (fakeRectangle.edge != Item.BottomRight) {
            priv.setup(Item.BottomRight);
        }
        priv.processAnimation(amount, fakeMaximizeBottomRightAnimation);
    }

    Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.BriskDuration } }
    Behavior on scale { UbuntuNumberAnimation { duration: UbuntuAnimation.BriskDuration } }

    ParallelAnimation {
        id: fakeMaximizeAnimation
        UbuntuNumberAnimation { target: fakeRectangle; properties: "x"; duration: UbuntuAnimation.BriskDuration; to: leftMargin }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "y"; duration: UbuntuAnimation.BriskDuration; to: PanelState.panelHeight }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "width"; duration: UbuntuAnimation.BriskDuration; to: appContainerWidth - leftMargin }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "height"; duration: UbuntuAnimation.BriskDuration; to: appContainerHeight }
    }

    ParallelAnimation {
        id: fakeMaximizeLeftAnimation
        UbuntuNumberAnimation { target: fakeRectangle; properties: "x"; duration: UbuntuAnimation.BriskDuration; to: leftMargin }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "y"; duration: UbuntuAnimation.BriskDuration; to: PanelState.panelHeight }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "width"; duration: UbuntuAnimation.BriskDuration; to: (appContainerWidth - leftMargin)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "height"; duration: UbuntuAnimation.BriskDuration; to: appContainerHeight - PanelState.panelHeight }
    }

    ParallelAnimation {
        id: fakeMaximizeRightAnimation
        UbuntuNumberAnimation { target: fakeRectangle; properties: "x"; duration: UbuntuAnimation.BriskDuration; to: (appContainerWidth + leftMargin)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "y"; duration: UbuntuAnimation.BriskDuration; to: PanelState.panelHeight }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "width"; duration: UbuntuAnimation.BriskDuration; to: (appContainerWidth - leftMargin)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "height"; duration: UbuntuAnimation.BriskDuration; to: appContainerHeight - PanelState.panelHeight }
    }

    ParallelAnimation {
        id: fakeMaximizeTopLeftAnimation
        UbuntuNumberAnimation { target: fakeRectangle; properties: "x"; duration: UbuntuAnimation.BriskDuration; to: leftMargin }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "y"; duration: UbuntuAnimation.BriskDuration; to: PanelState.panelHeight }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "width"; duration: UbuntuAnimation.BriskDuration; to: (appContainerWidth - leftMargin)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "height"; duration: UbuntuAnimation.BriskDuration; to: (appContainerHeight - PanelState.panelHeight)/2 }
    }

    ParallelAnimation {
        id: fakeMaximizeTopRightAnimation
        UbuntuNumberAnimation { target: fakeRectangle; properties: "x"; duration: UbuntuAnimation.BriskDuration; to: (appContainerWidth + leftMargin)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "y"; duration: UbuntuAnimation.BriskDuration; to: PanelState.panelHeight }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "width"; duration: UbuntuAnimation.BriskDuration; to: (appContainerWidth - leftMargin)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "height"; duration: UbuntuAnimation.BriskDuration; to: (appContainerHeight - PanelState.panelHeight)/2 }
    }

    ParallelAnimation {
        id: fakeMaximizeBottomLeftAnimation
        UbuntuNumberAnimation { target: fakeRectangle; properties: "x"; duration: UbuntuAnimation.BriskDuration; to: leftMargin }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "y"; duration: UbuntuAnimation.BriskDuration; to: (appContainerHeight + PanelState.panelHeight)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "width"; duration: UbuntuAnimation.BriskDuration; to: (appContainerWidth - leftMargin)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "height"; duration: UbuntuAnimation.BriskDuration; to: appContainerHeight/2 }
    }

    ParallelAnimation {
        id: fakeMaximizeBottomRightAnimation
        UbuntuNumberAnimation { target: fakeRectangle; properties: "x"; duration: UbuntuAnimation.BriskDuration; to: (appContainerWidth + leftMargin)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "y"; duration: UbuntuAnimation.BriskDuration; to: (appContainerHeight + PanelState.panelHeight)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "width"; duration: UbuntuAnimation.BriskDuration; to: (appContainerWidth - leftMargin)/2 }
        UbuntuNumberAnimation { target: fakeRectangle; properties: "height"; duration: UbuntuAnimation.BriskDuration; to: appContainerHeight/2 }
    }
}
