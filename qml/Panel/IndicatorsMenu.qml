/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1
import "../Components"

Showable {
    id: root
    property int minimizedPanelHeight: units.gu(3)
    property int expandedPanelHeight: units.gu(7)
    property real openedHeight: units.gu(71)
    readonly property int lockThreshold: openedHeight / 2
    property alias indicatorsModel: bar.indicatorsModel
    property alias overFlowWidth: bar.overFlowWidth
    property bool enableHint: true
    property real showHintBottomMargin: 0
    readonly property bool fullyOpened: unitProgress >= 1
    readonly property bool partiallyOpened: unitProgress > 0 && unitProgress < 1.0
    readonly property bool fullyClosed: unitProgress == 0
    readonly property real unitProgress: Math.max(0, (height - minimizedPanelHeight - orangeLine.height) /
                                                     (openedHeight - minimizedPanelHeight - orangeLine.height))
    property color panelColor: "black"

    signal showTapped(point position)

    // TODO: Perhaps we need a animation standard for showing/hiding? Each showable seems to
    // use its own values. Need to ask design about this.
    showAnimation: StandardAnimation {
        property: "height"
        to: openedHeight
        duration: UbuntuAnimation.SlowDuration
        easing.type: Easing.OutCubic
    }

    hideAnimation: StandardAnimation {
        property: "height"
        to: minimizedPanelHeight + orangeLine.height
        duration: UbuntuAnimation.SlowDuration
        easing.type: Easing.OutCubic
    }

    height: minimizedPanelHeight + orangeLine.height
    onHeightChanged: {
        var revealProgress = root.height - minimizedPanelHeight - orangeLine.height - showHintBottomMargin;

        if (!showAnimation.running && !hideAnimation.running) {
            if (revealProgress === 0) {
                root.state = "initial";
            } else if ((revealProgress > 0) && revealProgress < lockThreshold) {
                root.state = "reveal";
            } else {
                root.state = "locked";
            }
        }
    }

    Rectangle {
        id: content
        visible: !fullyClosed
        color: "#221e1c"
        anchors {
            left: parent.left
            right: parent.right
            bottom: handle.top
        }
        height: openedHeight - bar.height - handle.height - orangeLine.height
    }

    Handle {
        id: handle
        anchors {
            left: parent.left
            right: parent.right
            bottom: orangeLine.top
        }
        height: units.gu(2)
        active: d.activeDragHandle ? true : false
    }

    Rectangle {
        anchors.fill: bar
        color: panelColor
    }

    IndicatorsBar {
        id: bar
        anchors {
            left: parent.left
            right: parent.right
        }
        expanded: false
        lateralPosition: -1
        unitProgress: root.unitProgress

        height: expanded ? expandedPanelHeight : minimizedPanelHeight
        Behavior on height { NumberAnimation { duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing } }
    }

    ScrollCalculator {
        id: leftScroller
        width: units.gu(5)
        anchors.left: bar.left
        height: bar.height

        forceScrollingPercentage: 0.3
        thresholdAreaWidth: units.gu(0.5)
        direction: Qt.RightToLeft
        lateralPosition: -1

        onScroll: bar.addScrollOffset(-scrollAmount);
    }

    ScrollCalculator {
        id: rightScroller
        width: units.gu(5)
        anchors.right: bar.right
        height: bar.height

        forceScrollingPercentage: 0.3
        thresholdAreaWidth: units.gu(0.5)
        direction: Qt.LeftToRight
        lateralPosition: -1

        onScroll: bar.addScrollOffset(scrollAmount);
    }

    PanelSeparatorLine {
        id: orangeLine
        width: parent.width
        anchors.bottom: parent.bottom
    }

    DragHandle {
        id: showDragHandle
        anchors.bottom: parent.bottom
        // go beyond parent so that it stays reachable, at the top of the screen.
        anchors.bottomMargin: showHintBottomMargin
        anchors.left: parent.left
        anchors.right: parent.right
        height: minimizedPanelHeight
        direction: Direction.Downwards
        enabled: !root.shown && root.available
        autoCompleteDragThreshold: maxTotalDragDistance / 2
        stretch: true
        distanceThreshold: minimizedPanelHeight

        // using hint regulates minimum to hint displacement, but in fullscreen mode, we need to do it manually.
        overrideStartValue: enableHint ? undefined : expandedPanelHeight + d.handleHeight
        maxTotalDragDistance: openedHeight - (enableHint ? minimizedPanelHeight : expandedPanelHeight + handle.height) - orangeLine.height
        hintDisplacement: enableHint ? expandedPanelHeight - minimizedPanelHeight + handle.height : 0
        onTapped: showTapped(Qt.point(touchSceneX, touchSceneY));
    }

    DragHandle {
        id: hideDragHandle
        anchors.fill: handle
        direction: Direction.Upwards
        enabled: root.shown && root.available
        hintDisplacement: units.gu(3)
        autoCompleteDragThreshold: maxTotalDragDistance / 6
        stretch: true
        maxTotalDragDistance: openedHeight - expandedPanelHeight - d.handleHeight
        distanceThreshold: 0
    }

    AxisVelocityCalculator {
        id: yVelocityCalculator
    }

    Connections {
        target: showAnimation
        onRunningChanged: {
            if (showAnimation.running) {
                root.state = "commit";
            }
        }
    }

    Connections {
        target: hideAnimation
        onRunningChanged: {
            if (hideAnimation.running) {
                root.state = "initial";
            }
        }
    }

    QtObject {
        id: d
        property bool enableIndexChangeSignal: true
        property var activeDragHandle: showDragHandle.dragging ? showDragHandle : hideDragHandle.dragging ? hideDragHandle : null
        property real handleHeight: handle.height + orangeLine.height

        property real rowMappedLateralPosition: {
            if (!d.activeDragHandle) return -1;
            if (!d.activeDragHandle.dragging) return -1;
            return d.activeDragHandle.mapToItem(bar, d.activeDragHandle.touchX, 0).x;
        }
    }

    states: [
        State {
            name: "initial"
        },
        State {
            name: "reveal"
            StateChangeScript {
                script: {
                    yVelocityCalculator.reset();

                    // initial item selection
                    bar.selectItemAt(d.activeDragHandle ? d.activeDragHandle.touchX : -1);
                }
            }
            PropertyChanges {
                target: bar
                expanded: true
                // changes to lateral touch position effect which indicator is selected
                lateralPosition: d.rowMappedLateralPosition
                // vertical velocity determines if changes in lateral position has an effect
                enableLateralChanges: {
                    if (!d.activeDragHandle) return false;
                    if (!d.activeDragHandle.dragging) return false;

                    yVelocityCalculator.trackedPosition = d.activeDragHandle ? d.activeDragHandle.touchSceneY : 0
                    return Math.abs(yVelocityCalculator.calculate()) < 0.1;
                }
            }
            // left scroll bar handling
            PropertyChanges {
                target: leftScroller
                lateralPosition: {
                    if (!d.activeDragHandle) return -1;
                    if (!d.activeDragHandle.dragging) return -1;

                    var mapped = d.activeDragHandle.mapToItem(leftScroller, d.activeDragHandle.touchX, 0);
                    return mapped.x
                }
            }
            // right scroll bar handling
            PropertyChanges {
                target: rightScroller
                lateralPosition: {
                    if (!d.activeDragHandle) return -1;
                    if (!d.activeDragHandle.dragging) return -1;

                    var mapped = d.activeDragHandle.mapToItem(rightScroller, d.activeDragHandle.touchX, 0);
                    return mapped.x
                }
            }
        },
        State {
            name: "locked"
            PropertyChanges { target: bar; expanded: true }
        },
        State {
            name: "commit"
            extend: "locked"
        }
    ]
    state: "initial"
}
