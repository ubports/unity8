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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Gestures 0.1
import "../Components"
import "Indicators"

Showable {
    id: root
    property alias indicatorsModel: bar.indicatorsModel
    property alias showDragHandle: __showDragHandle
    property alias hideDragHandle: __hideDragHandle
    property alias overFlowWidth: bar.overFlowWidth
    property alias verticalVelocityThreshold: yVelocityCalculator.velocityThreshold
    property alias currentIndicator: bar.currentIndicator
    property int minimizedPanelHeight: units.gu(3)
    property int expandedPanelHeight: units.gu(7)
    property real openedHeight: units.gu(71)
    readonly property real unitProgress: Math.max(0, (height - minimizedPanelHeight) / (openedHeight - minimizedPanelHeight))
    readonly property bool fullyOpened: unitProgress >= 1
    readonly property bool partiallyOpened: unitProgress > 0 && unitProgress < 1.0
    readonly property bool fullyClosed: unitProgress == 0
    property bool enableHint: true
    property bool showOnClick: true
    property color panelColor: theme.palette.normal.background

    signal showTapped(point position)

    // TODO: Perhaps we need a animation standard for showing/hiding? Each showable seems to
    // use its own values. Need to ask design about this.
    showAnimation: StandardAnimation {
        property: "height"
        to: openedHeight
        duration: UbuntuAnimation.BriskDuration
        easing.type: Easing.OutCubic
    }

    hideAnimation: StandardAnimation {
        property: "height"
        to: minimizedPanelHeight
        duration: UbuntuAnimation.BriskDuration
        easing.type: Easing.OutCubic
    }

    height: minimizedPanelHeight

    onUnitProgressChanged: d.updateState()
    clip: root.partiallyOpened

    IndicatorsLight {
        id: indicatorLights
    }

    // eater
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    MenuContent {
        id: content
        objectName: "menuContent"

        anchors {
            left: parent.left
            right: parent.right
            top: bar.bottom
        }
        height: openedHeight - bar.height - handle.height
        indicatorsModel: root.indicatorsModel
        visible: root.unitProgress > 0
        currentMenuIndex: bar.currentItemIndex
    }

    Handle {
        id: handle
        objectName: "handle"
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(2)
        active: d.activeDragHandle ? true : false

        //small shadow gradient at bottom of menu
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.top
            }
            height: units.gu(0.5)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: theme.palette.normal.background }
            }
            opacity: 0.3
        }
    }

    Rectangle {
        anchors.fill: bar
        color: panelColor
    }

    IndicatorsBar {
        id: bar
        objectName: "indicatorsBar"

        anchors {
            left: parent.left
            right: parent.right
        }
        expanded: false
        enableLateralChanges: false
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

        forceScrollingPercentage: 0.33
        stopScrollThreshold: units.gu(0.75)
        direction: Qt.RightToLeft
        lateralPosition: -1

        onScroll: bar.addScrollOffset(-scrollAmount);
    }

    ScrollCalculator {
        id: rightScroller
        width: units.gu(5)
        anchors.right: bar.right
        height: bar.height

        forceScrollingPercentage: 0.33
        stopScrollThreshold: units.gu(0.75)
        direction: Qt.LeftToRight
        lateralPosition: -1

        onScroll: bar.addScrollOffset(scrollAmount);
    }

    MouseArea {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: minimizedPanelHeight
        enabled: __showDragHandle.enabled && showOnClick
        onClicked: {
            bar.selectItemAt(mouseX)
            root.show()
        }
    }

    DragHandle {
        id: __showDragHandle
        objectName: "showDragHandle"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: minimizedPanelHeight
        direction: Direction.Downwards
        enabled: !root.shown && root.available
        autoCompleteDragThreshold: maxTotalDragDistance / 2
        stretch: true

        onPressedChanged: {
            if (pressed) {
                touchPressTime = new Date().getTime();
            } else {
                var touchReleaseTime = new Date().getTime();
                if (touchReleaseTime - touchPressTime <= 300) {
                    root.showTapped(Qt.point(touchSceneX, touchSceneY));
                }
            }
        }
        property var touchPressTime

        // using hint regulates minimum to hint displacement, but in fullscreen mode, we need to do it manually.
        overrideStartValue: enableHint ? minimizedPanelHeight : expandedPanelHeight + handle.height
        maxTotalDragDistance: openedHeight - (enableHint ? minimizedPanelHeight : expandedPanelHeight + handle.height)
        hintDisplacement: enableHint ? expandedPanelHeight - minimizedPanelHeight + handle.height : 0
    }

    MouseArea {
        anchors.fill: __hideDragHandle
        enabled: __hideDragHandle.enabled
        onClicked: root.hide()
    }

    DragHandle {
        id: __hideDragHandle
        objectName: "hideDragHandle"
        anchors.fill: handle
        direction: Direction.Upwards
        enabled: root.shown && root.available
        hintDisplacement: units.gu(3)
        autoCompleteDragThreshold: maxTotalDragDistance / 6
        stretch: true
        maxTotalDragDistance: openedHeight - expandedPanelHeight - handle.height

        onTouchSceneXChanged: {
            if (root.state === "locked") {
                d.xDisplacementSinceLock += (touchSceneX - d.lastHideTouchSceneX)
                d.lastHideTouchSceneX = touchSceneX;
            }
        }
    }

    PanelVelocityCalculator {
        id: yVelocityCalculator
        velocityThreshold: d.hasCommitted ? 0.1 : 0.3
        trackedValue: d.activeDragHandle ? d.activeDragHandle.touchSceneY : 0

        onVelocityAboveThresholdChanged: d.updateState()
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
        property var activeDragHandle: showDragHandle.dragging ? showDragHandle : hideDragHandle.dragging ? hideDragHandle : null
        property bool hasCommitted: false
        property real lastHideTouchSceneX: 0
        property real xDisplacementSinceLock: 0
        onXDisplacementSinceLockChanged: d.updateState()

        property real rowMappedLateralPosition: {
            if (!d.activeDragHandle) return -1;
            return d.activeDragHandle.mapToItem(bar, d.activeDragHandle.touchX, 0).x;
        }

        function updateState() {
            if (!showAnimation.running && !hideAnimation.running && d.activeDragHandle) {
                if (unitProgress <= 0) {
                    root.state = "initial";
                // lock indicator if we've been committed and aren't moving too much laterally or too fast up.
                } else if (d.hasCommitted && (Math.abs(d.xDisplacementSinceLock) < units.gu(2) || yVelocityCalculator.velocityAboveThreshold)) {
                    root.state = "locked";
                } else {
                    root.state = "reveal";
                }
            }
        }
    }

    states: [
        State {
            name: "initial"
            PropertyChanges { target: d; hasCommitted: false; restoreEntryValues: false }
        },
        State {
            name: "reveal"
            StateChangeScript {
                script: {
                    yVelocityCalculator.reset();
                    // initial item selection
                    if (!d.hasCommitted) bar.selectItemAt(d.activeDragHandle ? d.activeDragHandle.touchX : -1);
                    d.hasCommitted = false;
                }
            }
            PropertyChanges {
                target: bar
                expanded: true
                // changes to lateral touch position effect which indicator is selected
                lateralPosition: d.rowMappedLateralPosition
                // vertical velocity determines if changes in lateral position has an effect
                enableLateralChanges: d.activeDragHandle &&
                                      !yVelocityCalculator.velocityAboveThreshold
            }
            // left scroll bar handling
            PropertyChanges {
                target: leftScroller
                lateralPosition: {
                    if (!d.activeDragHandle) return -1;
                    var mapped = d.activeDragHandle.mapToItem(leftScroller, d.activeDragHandle.touchX, 0);
                    return mapped.x;
                }
            }
            // right scroll bar handling
            PropertyChanges {
                target: rightScroller
                lateralPosition: {
                    if (!d.activeDragHandle) return -1;
                    var mapped = d.activeDragHandle.mapToItem(rightScroller, d.activeDragHandle.touchX, 0);
                    return mapped.x;
                }
            }
        },
        State {
            name: "locked"
            StateChangeScript {
                script: {
                    d.xDisplacementSinceLock = 0;
                    d.lastHideTouchSceneX = hideDragHandle.touchSceneX;
                }
            }
            PropertyChanges { target: bar; expanded: true }
        },
        State {
            name: "commit"
            extend: "locked"
            PropertyChanges { target: bar; interactive: true }
            PropertyChanges {
                target: d;
                hasCommitted: true
                lastHideTouchSceneX: 0
                xDisplacementSinceLock: 0
                restoreEntryValues: false
            }
        }
    ]
    state: "initial"
}
