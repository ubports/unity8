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

import "../Components"
import "../Components/ListItems"
import "../Components/Math.js" as MathLocal

Showable {
    id: indicators

    property real openedHeight: units.gu(71)
    property int panelHeight: units.gu(3)
    property bool pinnedMode: true  //should be set true if indicators menu can cover whole screen

    property int hintValue
    readonly property int lockThreshold: openedHeight / 2
    property bool fullyOpened: height == openedHeight
    property bool partiallyOpened: height > panelHeight && !fullyOpened
    property real visualBottom: Math.max(y+height, y+indicatorRow.y+indicatorRow.height)

    // TODO: Perhaps we need a animation standard for showing/hiding? Each showable seems to
    // use its own values. Need to ask design about this.
    showAnimation: StandardAnimation {
        property: "height"
        duration: 350
        to: openedHeight
        easing.type: Easing.OutCubic

        // Re-size if we've changed the openHeight while shown.
        onToChanged: {
            if (indicators.shown) {
                indicators.show();
            }
        }
    }

    hideAnimation: StandardAnimation {
        property: "height"
        duration: 350
        to: panelHeight
        easing.type: Easing.OutCubic
    }

    height: panelHeight

    onHeightChanged: {
        // need to use handle.get_height(). As the handle height depends on indicators.height changes (but this is called first!)
        var revealProgress = indicators.height - panelHeight
        if (!showAnimation.running && !hideAnimation.running) {
            if (revealProgress == 0) {
                indicators.state = "initial";
            } else if (revealProgress <= hintValue) {
                indicators.state = "hint";
            } else if (revealProgress > hintValue && revealProgress < lockThreshold) {
                indicators.state = "reveal";
            } else if (revealProgress >= lockThreshold && lockThreshold > 0) {
                indicators.state = "locked";
            }
        }

        if (revealProgress == 0) {
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
            MathLocal.clamp((indicators.height - handle.height - hintValue) /
                            (lockThreshold - hintValue), 0, 1);

        /*
          Vertical velocity check. Don't change the indicator if we're moving too quickly.
        */
        var verticalSpeed = Math.abs(yVelocityCalculator.calculate());
        if (verticalSpeed >= 0.05 && indicatorRow.currentItem!=null) {
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
        currentItem = indicatorRow.row.childAt(rowCoordinates.x, 0);
        if (currentItem && currentItem != indicatorRow.currentItem ) {
            itemCoordinates = indicatorRow.row.mapToItem(currentItem, rowCoordinates.x, 0);
            distanceFromRightEdge = (currentItem.width - itemCoordinates.x) / (currentItem.width);
            if (Math.abs(currentItem.ownIndex - indicatorRow.currentItemIndex) > 1) {
                bufferExceeded = true;
            } else {
                if (indicatorRow.currentItemIndex < currentItem.ownIndex && distanceFromRightEdge < (1 - effectiveBufferThreshold)) {
                    bufferExceeded = true;
                } else if (indicatorRow.currentItemIndex > currentItem.ownIndex && distanceFromRightEdge > effectiveBufferThreshold) {
                    bufferExceeded = true;
                }
            }
            if ((!useBuffer || (useBuffer && bufferExceeded)) || indicatorRow.currentItem < 0 || indicatorRow.currentItem == null)  {
                indicatorRow.currentItem = currentItem;
            }
        } else if (!currentItem) {
            indicatorRow.setDefaultItem();
        }
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

    VerticalThinDivider {
        anchors {
            top: indicators.top
            topMargin: panelHeight
            bottom: handle.bottom
            right: indicators.left
        }
        width: units.dp(2)
        source: "graphics/VerticalDivider.png"
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
        indicatorsModel: indicatorsModel
        clip: !indicators.fullyOpened

        Connections {
            target: indicatorRow
            onCurrentItemIndexChanged: menuContent.updateCurrentMenu();
        }

        function updateCurrentMenu() {
            if (currentMenuIndex != indicatorRow.currentItemIndex) {
                currentMenuIndex = indicatorRow.currentItemIndex;
            }
        }

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

        color:  menuContent.backgroundColor

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: get_height()
        clip: height < handleImage.height

        function get_height() {
            return Math.max(Math.min(handleImage.height, indicators.height - handleImage.height), 0);
        }

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

    PanelBackground {
        anchors.fill: indicatorRow
    }

    IndicatorsDataModel {
        id: indicatorsModel
    }

    IndicatorRow {
        id: indicatorRow
        objectName: "indicatorRow"
        anchors {
            left: parent.left
            right: parent.right
        }
        height: indicators.panelHeight
        indicatorsModel: indicatorsModel
        state: indicators.state

        Connections {
            target: menuContent
            onCurrentMenuIndexChanged: {
                indicatorRow.setCurrentItem(menuContent.currentMenuIndex);
            }
        }
    }

    Connections {
        target: showAnimation
        onRunningChanged: {
            if (showAnimation.running) {
                indicators.state = "commit";
            }
        }
    }

    Connections {
        target: hideAnimation
        onRunningChanged: {
            if (hideAnimation.running) {
                indicators.state = "initial";
                indicatorRow.currentItem = null;
            }
        }
    }

    property var activeDragHandle: showDragHandle.dragging ? showDragHandle : hideDragHandle.dragging ? hideDragHandle : null
    // connections to the active drag handle
    Connections {
        target: activeDragHandle
        onTouchXChanged: {
            indicators.calculateCurrentItem(activeDragHandle.touchX, true);
        }
        onTouchSceneYChanged: {
            yVelocityCalculator.trackedPosition = activeDragHandle.touchSceneY;
        }
    }

    DragHandle {
        id: showDragHandle
        anchors.bottom: parent.bottom
        // go beyond parent so that it stays reachable, at the top of the screen.
        anchors.bottomMargin: pinnedMode ? 0 : -panelHeight
        anchors.left: parent.left
        anchors.right: parent.right
        height: panelHeight
        direction: Direction.Downwards
        enabled: !indicators.shown
        hintDisplacement: pinnedMode ? indicators.hintValue : 0
        autoCompleteDragThreshold: maxTotalDragDistance / 2
        stretch: true
        maxTotalDragDistance: openedHeight - panelHeight
        distanceThreshold: pinnedMode ? 0 : units.gu(3)

        onStatusChanged: {
            if (status === DirectionalDragArea.Recognized) {
                menuContent.activateContent();
            }
        }
    }
    DragHandle {
        id: hideDragHandle
        anchors.fill: handle
        direction: Direction.Upwards
        enabled: indicators.shown
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
            PropertyChanges {
                target: indicatorRow;
                y: pinnedMode ? 0 : panelHeight
            }
            StateChangeScript {
                script: {
                    if (activeDragHandle) {
                        calculateCurrentItem(activeDragHandle.touchX, false);
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
}
