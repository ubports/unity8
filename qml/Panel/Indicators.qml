/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Unity.Indicators 0.1 as Indicators

import "../Components"
import "../Components/ListItems"
import "Indicators"

Showable {
    id: indicators

    property real openedHeight: units.gu(71)
    property int panelHeight: units.gu(3)
    property alias overFlowWidth: indicatorRow.overFlowWidth
    property alias showAll: indicatorRow.showAll
    // TODO: This should be sourced by device type (eg "desktop", "tablet", "phone"...)
    property string profile: indicatorProfile

    readonly property real hintValue: panelHeight + menuContent.headerHeight
    readonly property int lockThreshold: openedHeight / 2
    property bool fullyOpened: height == openedHeight
    property bool partiallyOpened: height > panelHeight && !fullyOpened
    property bool contentEnabled: true
    property bool initalizeItem: true
    readonly property alias content: menuContent
    property real unitProgress: (height - panelHeight) / (openedHeight - panelHeight)
    property bool enableHint: true
    property real showHintBottomMargin: 0

    signal showTapped(point position)

    // TODO: Perhaps we need a animation standard for showing/hiding? Each showable seems to
    // use its own values. Need to ask design about this.
    showAnimation: StandardAnimation {
        property: "height"
        to: openedHeight
    }

    hideAnimation: StandardAnimation {
        property: "height"
        duration: 350
        to: panelHeight
        easing.type: Easing.OutCubic
    }

    onOpenedHeightChanged: {
        if (showAnimation.running) {
            showAnimation.restart();
        } else if (indicators.shown) {
            height = openedHeight;
        }
    }

    height: panelHeight
    onHeightChanged: updateRevealProgressState(indicators.height - panelHeight - showHintBottomMargin, true)

    function updateRevealProgressState(revealProgress, enableRelease) {
        if (!showAnimation.running && !hideAnimation.running) {
            if (revealProgress === 0) {
                indicators.state = "initial";
            } else if (enableHint && revealProgress > 0 && revealProgress <= hintValue) {
                indicators.state = "hint";
            } else if ((!enableHint || revealProgress > hintValue) && revealProgress < lockThreshold) {
                indicators.state = "reveal";
            } else if (revealProgress >= lockThreshold && lockThreshold > 0) {
                indicators.state = "locked";
            }
        }

        if (enableRelease && revealProgress === 0) {
            menuContent.releaseContent();
        }
    }

    function calculateCurrentItem(xValue, useBuffer) {
        var rowCoordinates;
        var itemCoordinates;
        var currentItem;
        var distanceFromRightEdge;
        var bufferExceeded = false;

        if (indicators.state == "commit" || indicators.state == "locked" || showAnimation.running || hideAnimation.running) return;

        /*
          If user drags the indicator handle bar down a distance hintValue or less, this is 0.
          If bar is dragged down a distance greater than or equal to lockThreshold, this is 1.
          Otherwise it contains the bar's location as a fraction of the distance between hintValue (is 0) and lockThreshold (is 1).
        */
        var verticalProgress =
            MathUtils.clamp((indicators.height - handle.height - hintValue) /
                            (lockThreshold - hintValue), 0, 1);

        /*
          Vertical velocity check. Don't change the indicator if we're moving too quickly.
        */
        var verticalSpeed = Math.abs(yVelocityCalculator.calculate());
        if (verticalSpeed >= 0.05 && !initalizeItem) {
            return;
        }

        /*
          Percentage of an indicator icon's width the user's press can stray horizontally from the
          focused icon before we change focus to another icon. E.g. a value of 0.5 means you must
          go right a distance of half an icon's width before focus moves to the icon on the right
        */
        var maxBufferThreshold = 0.5;

        /*
          To help users find the indicator of their choice while opening the indicators, we add logic to add a
          left/right buffer to each icon so it is harder for the focus to be moved accidentally to another icon,
          as the user moves their finger down, but yet allows them to switch indicator if they want.
          This buffer is wider the further the user's finger is from the top of the screen.
        */
        var effectiveBufferThreshold = maxBufferThreshold * verticalProgress;

        rowCoordinates = indicatorRow.mapToItem(indicatorRow.row, xValue, 0);
        // get the current delegate
        currentItem = indicatorRow.row.itemAt(rowCoordinates.x, 0);
        if (currentItem) {
            itemCoordinates = indicatorRow.row.mapToItem(currentItem, rowCoordinates.x, 0);
            distanceFromRightEdge = (currentItem.width - itemCoordinates.x) / (currentItem.width);
            if (currentItem != indicatorRow.currentItem) {
                if (Math.abs(currentItem.ownIndex - indicatorRow.currentItemIndex) > 1) {
                    bufferExceeded = true;
                } else {
                    if (indicatorRow.currentItemIndex < currentItem.ownIndex && distanceFromRightEdge < (1 - effectiveBufferThreshold)) {
                        bufferExceeded = true;
                    } else if (indicatorRow.currentItemIndex > currentItem.ownIndex && distanceFromRightEdge > effectiveBufferThreshold) {
                        bufferExceeded = true;
                    }
                }
                if ((!useBuffer || (useBuffer && bufferExceeded)) || indicatorRow.currentItemIndex < 0 || indicatorRow.currentItem == null)  {
                    indicatorRow.setCurrentItem(currentItem);
                }

                // need to re-init the distanceFromRightEdge for offset calculation
                itemCoordinates = indicatorRow.row.mapToItem(indicatorRow.currentItem, rowCoordinates.x, 0);
                distanceFromRightEdge = (indicatorRow.currentItem.width - itemCoordinates.x) / (indicatorRow.currentItem.width);
            }
            indicatorRow.currentItemOffset = 1 - (distanceFromRightEdge * 2);
        } else if (initalizeItem) {
            indicatorRow.setDefaultItem();
            indicatorRow.currentItemOffset = 0;
        }
        initalizeItem = indicatorRow.currentItem == null;
    }

    // eater
    MouseArea {
        anchors {
            top: parent.top
            bottom: handle.bottom
            left: parent.left
            right: parent.right
        }
    }

    VisibleIndicators {
        id: visibleIndicators
    }

    MenuContent {
        id: menuContent
        objectName: "menuContent"

        anchors {
            left: parent.left
            right: parent.right
            top: indicatorRow.bottom
            bottom: handle.top
        }
        indicatorsModel: visibleIndicators.model
        visible: indicators.fullyOpened || indicators.partiallyOpened
        clip: indicators.partiallyOpened
        enabled: contentEnabled

        //small shadow gradient at bottom of menu
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: units.gu(0.5)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "black" }
            }
            opacity: 0.4
        }
    }

    Rectangle {
        id: handle

        color:  menuContent.color

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: Math.max(Math.min(handleImage.height, indicators.height - handleImage.height), 0)
        clip: height < handleImage.height

        BorderImage {
            id: handleImage
            source: "graphics/handle.sci"
            height: panelHeight
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }
        MouseArea { //prevent clicks passing through
            anchors.fill: parent
        }
    }

    IndicatorRow {
        id: indicatorRow
        objectName: "indicatorRow"
        anchors {
            left: parent.left
            right: parent.right
        }
        height: indicators.panelHeight
        indicatorsModel: visibleIndicators.model
        state: indicators.state
        unitProgress: indicators.unitProgress

        EdgeDragArea {
            id: rowDragArea
            anchors.fill: indicatorRow
            direction: Direction.Downwards
            maxSilenceTime: 2000
            distanceThreshold: 0

            enabled: fullyOpened
            onDraggingChanged: {
                if (dragging) {
                    initalizeItem = true;
                    updateRevealProgressState(Math.max(touchSceneY - panelHeight, hintValue), false);
                    indicators.calculateCurrentItem(touchX, false);
                } else {
                    indicators.state = "commit";
                    indicatorRow.currentItemOffset = 0;
                }
            }

            onTouchXChanged: {
                indicators.calculateCurrentItem(touchX, true);
            }
            onTouchSceneYChanged: {
                updateRevealProgressState(Math.max(touchSceneY - panelHeight, hintValue), false);
                yVelocityCalculator.trackedPosition = touchSceneY;
            }
        }
    }

    Connections {
        target: showAnimation
        onRunningChanged: {
            if (showAnimation.running) {
                indicators.state = "commit";
                indicatorRow.currentItemOffset = 0;
            }
        }
    }

    Connections {
        target: hideAnimation
        onRunningChanged: {
            if (hideAnimation.running) {
                indicators.state = "initial";
                initalizeItem = true;
                indicatorRow.currentItemOffset = 0;
            }
        }
    }

    QtObject {
        id: d
        property bool enableIndexChangeSignal: true
        property var activeDragHandle: showDragHandle.dragging ? showDragHandle : hideDragHandle.dragging ? hideDragHandle : null
    }

    Connections {
        target: menuContent
        onCurrentMenuIndexChanged: {
            var oldActive = d.enableIndexChangeSignal;
            if (!oldActive) return;
            d.enableIndexChangeSignal = false;

            indicatorRow.setCurrentItemIndex(menuContent.currentMenuIndex);

            d.enableIndexChangeSignal = oldActive;
        }
    }

    Connections {
        target: indicatorRow
        onCurrentItemIndexChanged: {
            var oldActive = d.enableIndexChangeSignal;
            if (!oldActive) return;
            d.enableIndexChangeSignal = false;

            menuContent.setCurrentMenuIndex(indicatorRow.currentItemIndex, fullyOpened || partiallyOpened);

            d.enableIndexChangeSignal = oldActive;
        }
    }
    // connections to the active drag handle
    Connections {
        target: d.activeDragHandle
        onTouchXChanged: {
            indicators.calculateCurrentItem(d.activeDragHandle.touchX, true);
        }
        onTouchSceneYChanged: {
            yVelocityCalculator.trackedPosition = d.activeDragHandle.touchSceneY;
        }
    }

    DragHandle {
        id: showDragHandle
        anchors.bottom: parent.bottom
        // go beyond parent so that it stays reachable, at the top of the screen.
        anchors.bottomMargin: showHintBottomMargin
        anchors.left: parent.left
        anchors.right: parent.right
        height: panelHeight
        direction: Direction.Downwards
        enabled: !indicators.shown && indicators.available
        hintDisplacement: enableHint ? indicators.hintValue : 0
        autoCompleteDragThreshold: maxTotalDragDistance / 2
        stretch: true
        maxTotalDragDistance: openedHeight - panelHeight
        distanceThreshold: panelHeight

        onStatusChanged: {
            if (status === DirectionalDragArea.Recognized) {
                menuContent.activateContent();
            }
        }

        onTapped: showTapped(Qt.point(touchSceneX, touchSceneY));
    }

    DragHandle {
        id: hideDragHandle
        anchors.fill: handle
        direction: Direction.Upwards
        enabled: indicators.shown && indicators.available
        hintDisplacement: indicators.hintValue
        autoCompleteDragThreshold: maxTotalDragDistance / 6
        stretch: true
        maxTotalDragDistance: openedHeight - panelHeight
        distanceThreshold: 0
    }

    AxisVelocityCalculator {
        id: yVelocityCalculator
    }

    states: [
        State {
            name: "initial"
        },
        State {
            name: "hint"
            StateChangeScript {
                script: {
                    if (d.activeDragHandle) {
                        calculateCurrentItem(d.activeDragHandle.touchX, false);
                    }
                }
            }
        },
        State {
            name: "reveal"
            extend: "hint"
        },
        State {
            name: "locked"
            extend: "hint"
        },
        State {
            name: "commit"
            extend: "hint"
        }
    ]
    state: "initial"

    transitions: [
        Transition  {
            NumberAnimation {targets: [indicatorRow, menuContent]; property: "y"; duration: 300; easing.type: Easing.OutCubic}
        }
    ]

    Component.onCompleted: initialise();
    function initialise() {
        visibleIndicators.load(profile);
        indicatorRow.setDefaultItem();
    }
}
