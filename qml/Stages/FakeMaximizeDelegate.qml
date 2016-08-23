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
import "../Components/PanelState"

Rectangle {
    id: fakeRectangle
    visible: opacity > 0 // we go from 0.2 to 0.6
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

    QtObject {
        id: priv

        property real progress: 0

        function setup(edge) {
            fakeRectangle.x = target.x;
            fakeRectangle.y = target.y;
            fakeRectangle.width = target.width;
            fakeRectangle.height = target.height;
            fakeRectangle.edge = edge;
            fakeRectangle.transformOrigin = edge;
        }

        function projectOpacity(progress) {
            // progress falls into [0,1], opacity moves in [0.2,0.6]
            fakeRectangle.opacity = MathUtils.clampAndProject(progress, 0.0, 1.0, 0.2, 0.6);
        }

        function projectScale(progress) {
            // progress falls into [0,1], scale moves in [1,2] as a hint, when under 30%
            fakeRectangle.scale = MathUtils.clampAndProject(progress, 0, 1, 1, 2);
        }

        function processAnimation(progress, animation) {
            if (priv.progress >= 0.3) {
                fakeRectangle.scale = 1;
                animation.start();
            } else if (progress > priv.progress) {
                priv.progress += progress;
                priv.projectScale(progress);
            }
            priv.projectOpacity(progress);
        }
    }

    function stop() {
        print("!!! Stop")
        opacity = 0;
        edge = -1;
        priv.progress = 0;
    }

    function maximize(progress) {
        if (fakeRectangle.edge != Item.Top) {
            priv.setup(Item.Top);
        }
        priv.processAnimation(progress, fakeMaximizeAnimation);
    }

    function maximizeLeft(progress) {
        if (fakeRectangle.edge != Item.Left) {
            priv.setup(Item.Left);
        }
        priv.processAnimation(progress, fakeMaximizeLeftAnimation);
    }

    function maximizeRight(progress) {
        if (fakeRectangle.edge != Item.Right) {
            priv.setup(Item.Right);
        }
        priv.processAnimation(progress, fakeMaximizeRightAnimation);
    }

    function maximizeTopLeft(progress) {
        if (fakeRectangle.edge != Item.TopLeft) {
            priv.setup(Item.TopLeft);
        }
        priv.processAnimation(progress, fakeMaximizeTopLeftAnimation);
    }

    function maximizeTopRight(progress) {
        if (fakeRectangle.edge != Item.TopRight) {
            priv.setup(Item.TopRight);
        }
        priv.processAnimation(progress, fakeMaximizeTopRightAnimation);
    }

    function maximizeBottomLeft(progress) {
        if (fakeRectangle.edge != Item.BottomLeft) {
            priv.setup(Item.BottomLeft);
        }
        priv.processAnimation(progress, fakeMaximizeBottomLeftAnimation);
    }

    function maximizeBottomRight(progress) {
        if (fakeRectangle.edge != Item.BottomRight) {
            priv.setup(Item.BottomRight);
        }
        priv.processAnimation(progress, fakeMaximizeBottomRightAnimation);
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
