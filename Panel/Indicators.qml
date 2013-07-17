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

    property int referenceOpenedHeight: units.gu(71)
    property real openedHeight: pinnedMode ? referenceOpenedHeight - panelHeight
                                           : referenceOpenedHeight
    property int panelHeight: units.gu(3)
    property bool pinnedMode: true  //should be set true if indicators menu can cover whole screen

    property int hintValue
    readonly property int lockThreshold: referenceOpenedHeight / 2
    property bool fullyOpened: height == openedHeight
    property bool partiallyOpened: height > panelHeight && !fullyOpened

    // TODO: Perhaps we need a animation standard for showing/hiding? Each showable seems to
    // use its own values. Need to ask design about this.
    showAnimation: StandardAnimation {
        property: "height"
        duration: 350
        to: openedHeight
        easing.type: Easing.OutCubic
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
        var contentProgress = indicators.height - handle.get_height()
        if (!showAnimation.running && !hideAnimation.running) {
            if (contentProgress <= hintValue && indicators.state == "reveal") {
                indicators.state = "hint"
            } else if (contentProgress > hintValue && contentProgress < lockThreshold) {
                indicators.state = "reveal"
            } else if (contentProgress >= lockThreshold && lockThreshold > 0) {
                indicators.state = "locked"
            }
        }

        if (contentProgress == 0) {
            menuContent.releaseContent()
        }
    }

    function calculateCurrentItem(xValue, useBuffer) {
        var rowCoordinates
        var itemCoordinates
        var currentItem
        var distanceFromRightEdge
        var bufferExceeded = false

        if (indicators.state == "commit" || indicators.state == "locked" || showAnimation.running || hideAnimation.running) return

        /*
          If user drags the indicator handle bar down a distance hintValue or less, this is 0.
          If bar is dragged down a distance greater than or equal to lockThreshold, this is 1.
          Otherwise it contains the bar's location as a fraction of the distance between hintValue (is 0) and lockThreshold (is 1).
        */
        var verticalProgress =
            MathLocal.clamp((indicators.height - handle.height - hintValue) /
                            (lockThreshold - hintValue), 0, 1)

        /*
          Percentage of an indicator icon's width the user's press can stray horizontally from the
          focused icon before we change focus to another icon. E.g. a value of 0.5 means you must
          go right a distance of half an icon's width before focus moves to the icon on the right
        */
        var maxBufferThreshold = 0.5

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
            distanceFromRightEdge = (currentItem.width - itemCoordinates.x) / (currentItem.width)
            if (Math.abs(currentItem.ownIndex - indicatorRow.currentItemIndex) > 1) {
                bufferExceeded = true
            } else {
                if (indicatorRow.currentItemIndex < currentItem.ownIndex && distanceFromRightEdge < (1 - effectiveBufferThreshold)) {
                    bufferExceeded = true
                } else if (indicatorRow.currentItemIndex > currentItem.ownIndex && distanceFromRightEdge > effectiveBufferThreshold) {
                    bufferExceeded = true
                }
            }
            if ((!useBuffer || (useBuffer && bufferExceeded)) || indicatorRow.currentItem < 0 || indicatorRow.currentItem == null)  {
                indicatorRow.currentItem = currentItem;
            }
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
            bottom: parent.bottom
        }
        indicatorsModel: indicatorsModel
        animate: false
        clip: indicators.partiallyOpened

        onMenuSelected: {
            indicatorRow.setItem(index)
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
            top: menuContent.bottom
        }
        height: get_height()
        clip: height < handleImage.height

        function get_height() {
            return Math.max(Math.min(handleImage.height, indicators.height - handleImage.height), 0)
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

    PanelSeparatorLine {
        id: indicatorsSeparatorLine
        visible: true
        anchors {
            top: handle.bottom
            left: indicators.left
            right: indicators.right
        }
    }

    BorderImage {
        id: dropShadow
        anchors {
            top: indicators.top
            bottom: indicatorsSeparatorLine.bottom
            left: indicators.left
            right: indicators.right
            margins: -units.gu(1)
        }
        visible: indicators.height > panelHeight
        source: "graphics/rectangular_dropshadow.sci"
    }

    PanelBackground {
        anchors.fill: indicatorRow
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

        onCurrentItemIndexChanged: menuContent.currentIndex = currentItemIndex

    }

    IndicatorsDataModel {
        id: indicatorsModel
    }

    Connections {
        target: hideAnimation
        onRunningChanged: {
            if (hideAnimation.running) {
                indicators.state = "initial"
                menuContent.hideAll()
            } else  {
                if (state == "initial") indicatorRow.setDefaultItem()
            }
        }
    }
    Connections {
        target: showAnimation
        onRunningChanged: {
            if (showAnimation.running) {
                indicators.calculateCurrentItem(dragHandle.touchX, false)
                indicators.state = "commit"
            }
        }
    }

    Connections {
        target: dragHandle
        onTouchXChanged: {
            var buffer = dragHandle.dragging ? true : false
            indicators.calculateCurrentItem(dragHandle.touchX, buffer)
        }
    }

    // We start with pinned states. (default pinnedMode: true)
    states: pinnedModeStates
    // because of dynamic assignment of states, we need to assign state after completion.
    Component.onCompleted: state = "initial"

    // changing states will reset state to "".
    onPinnedModeChanged: {
        var last_state = state;
        states = (pinnedMode) ? pinnedModeStates : offScreenModeStates;
        state = last_state;
    }

    property var dragHandle: showDragHandle.dragging ? showDragHandle : hideDragHandle
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
        maxTotalDragDistance: openedHeight - handle.height
        distanceThreshold: pinnedMode ? 0 : units.gu(3)

        onStatusChanged: {
            if (status === DirectionalDragArea.Recognized) {
                menuContent.hideAll()
                menuContent.activateContent()
            }
        }
    }
    DragHandle {
        id: hideDragHandle
        anchors.fill: handle
        height: panelHeight
        direction: Direction.Upwards
        enabled: indicators.shown
        hintDisplacement: units.gu(2)
        autoCompleteDragThreshold: maxTotalDragDistance / 6
        stretch: true
        maxTotalDragDistance: referenceOpenedHeight - 2*panelHeight
        distanceThreshold: 0
    }

    property list<State> offScreenModeStates: [
        State {
            name: "initial"
        },
        State {
            name: "hint"
            PropertyChanges { target: indicatorRow; y: panelHeight }
        },
        State {
            name: "reveal"
            extend: "hint"
            PropertyChanges { target: menuContent; animate: true }
            StateChangeScript { script: calculateCurrentItem(dragHandle.touchX, false); }
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

    property list<State> pinnedModeStates: [
        State {
            name: "initial"
        },
        State {
            name: "hint"
        },
        State {
            name: "reveal"
            PropertyChanges { target: menuContent; animate: true }
            StateChangeScript { script: calculateCurrentItem(dragHandle.touchX, false); }
        },
        State {
            name: "locked"
        },
        State {
            name: "commit"
        }
    ]

    transitions: [
        Transition  {
            NumberAnimation {targets: [indicatorRow, menuContent]; property: "y"; duration: 300; easing.type: Easing.OutCubic}
        }
    ]
}
