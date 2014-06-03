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
import Mir.Application 0.1
import Utils 0.1
import "../Components"

Item {
    id: root
    objectName: "stages"
    anchors.fill: parent

    // Controls to be set from outside
    property bool shown: false
    property bool moving: false
    property int dragAreaWidth

    // State information propagated to the outside
    readonly property bool painting: true
    property bool fullscreen: true
    property bool overlayMode: false

    readonly property int overlayWidth: priv.overlayOverride ? 0 : spreadView.sideStageWidth

    QtObject {
        id: priv

        property string focusedAppId: ApplicationManager.focusedApplicationId
        property string oldFocusedAppId: ""

        property string mainStageAppId
        property string sideStageAppId

        // For convenience, keep properties of the first two apps in the model
        property string appId0
        property string appId1

        onFocusedAppIdChanged: {
            print("focused appid changed", priv.focusedAppId)
            var focusedApp = ApplicationManager.findApplication(focusedAppId);
            if (focusedApp.stage == ApplicationInfoInterface.SideStage) {
                priv.sideStageAppId = focusedAppId;
            } else {
                priv.mainStageAppId = focusedAppId;
            }

            appId0 = ApplicationManager.count >= 1 ? ApplicationManager.get(0).appId : "";
            appId1 = ApplicationManager.count > 1 ? ApplicationManager.get(1).appId : "";
        }

        function indexOf(appId) {
            for (var i = 0; i < ApplicationManager.count; i++) {
                if (ApplicationManager.get(i).appId == appId) {
                    return i;
                }
            }
            return -1;
        }

        function evaluateOneWayFlick(gesturePoints) {
            // Need to have at least 3 points to recognize it as a flick
            if (gesturePoints.length < 3) {
                return false;
            }
            // Need to have a movement of at least 2 grid units to recognize it as a flick
            if (Math.abs(gesturePoints[gesturePoints.length - 1] - gesturePoints[0]) < units.gu(2)) {
                return false;
            }

            var oneWayFlick = true;
            var smallestX = gesturePoints[0];
            var leftWards = gesturePoints[1] < gesturePoints[0];
            for (var i = 1; i < gesturePoints.length; i++) {
                if ((leftWards && gesturePoints[i] >= smallestX)
                        || (!leftWards && gesturePoints[i] <= smallestX)) {
                    oneWayFlick = false;
                    break;
                }
                smallestX = gesturePoints[i];
            }
            return oneWayFlick;
        }
    }

    Connections {
        target: ApplicationManager
        onFocusRequested: {
            printStack()
            if (spreadView.interactive) {
                spreadView.snapTo(priv.indexOf(appId));
            } else {
//                priv.switchToApp(appId);
                ApplicationManager.focusApplication(appId)
            }
        }
    }

    function printStack() {
        for (var i = 0; i < ApplicationManager.count; i++) {
            print("AppMan item", i, ":", ApplicationManager.get(i).appId)
        }
    }

    Flickable {
        id: spreadView
        anchors.fill: parent
        contentWidth: spreadRow.width
        interactive: phase == 2

        property int tileDistance: units.gu(20)
        property int sideStageWidth: units.gu(40)
        property bool sideStageVisible: priv.sideStageAppId

        property int phase

        property int phase0Width: sideStageWidth
        property int phase1Width: sideStageWidth

        property real positionMarker1: 0.2
        property real positionMarker2: sideStageWidth / spreadView.width
        property real positionMarker3: 0.6
        property real positionMarker4: 0.8

        property int startSnapPosition: phase0Width * 0.5
        property int endSnapPosition: phase0Width * 0.75
        property real snapPosition: 0.75

        property int selectedIndex: -1
        onSelectedIndexChanged: print("selected index changed", selectedIndex)

        property bool sideStageDragging: sideStageDragHandle.dragging
        property real sideStageDragProgress: sideStageDragHandle.progress

        onSideStageDragProgressChanged: {
            if (sideStageDragProgress == 1) {
                ApplicationManager.focusApplication(priv.mainStageAppId)
                priv.sideStageAppId = ""
            }
        }

        property int nextInStack: {
            switch (state) {
            case "main":
                if (ApplicationManager.count > 1) {
                    return 1;
                }
                return -1;
            case "mainAndOverlay":
                if (ApplicationManager.count <= 2) {
                    return -1;
                }
                print("nextinstack calculation! appId0", priv.appId0, "appid1", priv.appId1, "MS", priv.mainStageAppId, "SS", priv.sideStageAppId)
                if (priv.appId0 == priv.mainStageAppId || priv.appId0 == priv.sideStageAppId) {
                    if (priv.appId1 == priv.mainStageAppId || priv.appId1 == priv.sideStageAppId) {
                        return 2;
                    }
                    return 1;
                }
                return 0;
            case "overlay":
                print("foo", priv.appId0, priv.appId1)
                return 1;
            }
            print("unhandled nextInStack case!!!!!");
            return -1;

        }
        property int nextZInStack: indexToZIndex(nextInStack)
        onNextInStackChanged: print("next in stack is", nextInStack)

        states: [
            State {
                name: "invalid"
            },
            State {
                name: "main"
            },
            State {
                name: "overlay"
            },
            State {
                name: "mainAndOverlay"
            },
            State {
                name: "mainAndSplit"
            }
        ]
        state: {
            if (priv.mainStageAppId && !priv.sideStageAppId) {
                return "main";
            }
            if (!priv.mainStageAppId && priv.sideStageAppId) {
                return "overlay";
            }
            if (priv.mainStageAppId && priv.sideStageAppId) {
                return "mainAndOverlay";
            }
            return "invalid";
        }

        onContentXChanged: {
            if (spreadView.phase == 0 && spreadView.contentX > spreadView.width * spreadView.positionMarker2) {
                spreadView.phase = 1;
            } else if (spreadView.phase == 1 && spreadView.contentX > spreadView.width * spreadView.positionMarker4) {
                spreadView.phase = 2;
            } else if (spreadView.phase == 1 && spreadView.contentX < spreadView.width * spreadView.positionMarker2) {
                spreadView.phase = 0;
            }
        }

        function snap() {
            if (contentX < phase0Width) {
                snapAnimation.targetContentX = 0;
                snapAnimation.start();
            } else if (contentX < phase1Width) {
                snapTo(1)
//            } else if (contentX < phase1Width + units.gu(5)) {
//                snapTo(1)
            } else {
                // Add 1 pixel to make sure we definitely hit positionMarker4 even with rounding errors of the animation.
                snapAnimation.targetContentX = spreadView.width * spreadView.positionMarker4 + 1;
                snapAnimation.start();
            }
        }
        function snapTo(index) {
            print("snapping to index", index)
            spreadView.selectedIndex = index;
//            root.fullscreen = ApplicationManager.get(index).fullscreen;
            snapAnimation.targetContentX = 0;
            snapAnimation.start();
        }

        // We need to shuffle z ordering a bit in order to keep side stage apps above main stage apps.
        // We don't want to really reorder them in the model because that allows us to keep track
        // of the last focused order.
        function indexToZIndex(index) {
            print("zIndex calc for index", index);
            var app = ApplicationManager.get(index);
            if (!app) {
                return index;
            }

            var isActive = app.appId == priv.mainStageAppId || app.appId == priv.sideStageAppId;
            print("got app", app.appId, isActive)
            if (isActive && app.stage == ApplicationInfoInterface.MainStage) return 0;
            if (isActive && app.stage == ApplicationInfoInterface.SideStage) {
                if (!priv.mainStageAppId) {
                    // only have SS apps running
                    return 0;
                }

                if (spreadView.nextInStack >= 0 && ApplicationManager.get(spreadView.nextInStack).stage == ApplicationInfoInterface.MainStage) {
                    return Math.max(index, 2);
                } else {
                    return 1;
                }
            }
            if (index <= 2 && app.stage == ApplicationInfoInterface.MainStage && priv.sideStageAppId) {
                return priv.indexOf(priv.sideStageAppId) < index ? index - 1 : index;
            }
            if (index == spreadView.nextInStack && app.stage == ApplicationInfoInterface.SideStage) {
                if (priv.sideStageAppId && priv.mainStageAppId) {
                    return 2;
                }
                return 1;
            }
            return index;
        }

        SequentialAnimation {
            id: snapAnimation
            property int targetContentX: 0

            UbuntuNumberAnimation {
                target: spreadView
                property: "contentX"
                to: snapAnimation.targetContentX
                duration: UbuntuAnimation.SlowDuration
//                duration: UbuntuAnimation.FastDuration
            }

            ScriptAction {
                script: {
                    if (spreadView.selectedIndex >= 0) {
                        var newIndex = spreadView.selectedIndex;
                        spreadView.selectedIndex = -1
                        ApplicationManager.focusApplication(ApplicationManager.get(newIndex).appId);
                        spreadView.phase = 0;
                        spreadView.contentX = 0;
                    }
                }
            }
        }

        Rectangle {
            id: spreadRow
            x: spreadView.contentX
            height: root.height
//            width: root.width
            width: spreadView.width + Math.max(spreadView.width, ApplicationManager.count * spreadView.tileDistance)

            color: "black"

            Repeater {
                id: spreadRepeater
                model: ApplicationManager

                delegate: TransformedTabletSpreadDelegate {
                    id: spreadTile
                    height: spreadView.height
                    width: model.stage == ApplicationInfoInterface.MainStage ? spreadView.width : spreadView.sideStageWidth
                    x: spreadView.width
                    z: spreadView.indexToZIndex(index)

                    onWidthChanged: print("width changed!", width)

                    active: model.appId == priv.mainStageAppId || model.appId == priv.sideStageAppId
                    zIndex: z
                    selected: spreadView.selectedIndex == index
                    otherSelected: spreadView.selectedIndex >= 0 && !selected
                    isInSideStage: priv.sideStageAppId == model.appId
                    interactive: !spreadView.interactive

                    progress: {
                        var tileProgress = (spreadView.contentX - zIndex * spreadView.tileDistance) / spreadView.width;
                        // Some tiles (nextInStack, active) need to move directly from the beginning, normalize progress to immediately start at 0
                        if ((index == spreadView.nextInStack && spreadView.phase < 2) || (active && spreadView.phase < 1)) {
                            tileProgress += zIndex * spreadView.tileDistance / spreadView.width;
                        }
                        return tileProgress;
                    }

                    animatedProgress: {
                        if (spreadView.phase == 0 && (spreadTile.active || spreadView.nextInStack == index)) {
                            if (progress < spreadView.positionMarker1) {
                                return progress;
                            } else if (progress < spreadView.positionMarker1 + snappingCurve.period){
                                return spreadView.positionMarker1 + snappingCurve.value * 3;
                            } else {
                                return spreadView.positionMarker2;
                            }
                        }
                        return progress;
                    }

                    onClicked: {
                        if (spreadView.phase == 2) {
                            if (ApplicationManager.focusedApplicationId == ApplicationManager.get(index).appId) {
                                spreadView.snapTo(index);
                            } else {
                                ApplicationManager.requestFocusApplication(ApplicationManager.get(index).appId);
                            }
                        }
                    }

                    EasingCurve {
                        id: snappingCurve
                        type: EasingCurve.Linear
                        period: (spreadView.positionMarker2 - spreadView.positionMarker1) / 3
                        progress: spreadTile.progress - spreadView.positionMarker1
                    }
                }
            }
        }
    }

    Rectangle {
        id: sideStageDragHandle
        color: "transparent"
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right; rightMargin: spreadView.sideStageWidth }
        width: units.gu(2)
        opacity: spreadView.phase <= 0 && spreadView.sideStageVisible ? 1 : 0
        property real progress: 0
        property bool dragging: false

        Behavior on opacity { UbuntuNumberAnimation {} }

        Connections {
            target: spreadView
            onSideStageVisibleChanged: {
                if (spreadView.sideStageVisible) {
                    sideStageDragHandle.progress = 0;
                }
            }
        }

        Image {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: parent.progress * spreadView.sideStageWidth - (width - parent.width) / 2
            width: sideStageDragHandleMouseArea.pressed ? parent.width * 2 : parent.width
            height: parent.height
            source: "graphics/sidestage_handle@20.png"
            Behavior on width { UbuntuNumberAnimation {} }
        }

        MouseArea {
            id: sideStageDragHandleMouseArea
            anchors.fill: parent
            property int startX
            property var gesturePoints: new Array()
            onPressed: {
                gesturePoints = [];
                startX = mouseX;
                sideStageDragHandle.progress = 0;
                sideStageDragHandle.dragging = true;
            }
            onMouseXChanged: {
                if (priv.mainStageAppId) {
                    sideStageDragHandle.progress = Math.max(0, (-startX + mouseX) / spreadView.sideStageWidth)
                }
                gesturePoints.push(mouseX);
            }
            onReleased: {
                var oneWayFlick = priv.evaluateOneWayFlick(gesturePoints);
                gesturePoints = [];
                sideStageDragSnapAnimation.to = sideStageDragHandle.progress > 0.5 || oneWayFlick ? 1 : 0
                sideStageDragSnapAnimation.start();
            }
        }
        UbuntuNumberAnimation {
            id: sideStageDragSnapAnimation
            target: sideStageDragHandle
            property: "progress"

            onRunningChanged: {
                if (!running) {
                    sideStageDragHandle.dragging = false;
                }
            }
        }
    }

    EdgeDragArea {
        id: spreadDragArea
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: root.dragAreaWidth

//        Rectangle { anchors.fill: parent; color: "#4400FF00"}

        property bool attachedToView: false
        property var gesturePoints: new Array()

        onTouchXChanged: {
            if (!dragging) {
                spreadView.phase = 0;
                spreadView.contentX = 0;
            }

            if (attachedToView) {
                spreadView.contentX = -touchX + spreadDragArea.width
                if (spreadView.contentX > spreadView.phase0Width + spreadView.phase1Width / 2) {
                    attachedToView = false;
                    spreadView.snap();
                }
            }
            gesturePoints.push(touchX);
        }

        onStatusChanged: {
            if (status == DirectionalDragArea.Recognized) {
                attachedToView = true;
            }
        }

        onDraggingChanged: {
            if (dragging) {
                // Gesture recognized. Start recording this gesture
                gesturePoints = [];
                return;
            }

            // Ok. The user released. Find out if it was a one-way movement.
            var oneWayFlick = priv.evaluateOneWayFlick(gesturePoints);
            gesturePoints = [];

            if (oneWayFlick && spreadView.contentX < spreadView.positionMarker1 * spreadView.width) {
                // If it was a short one-way movement, do the Alt+Tab switch
                // no matter if we didn't cross positionMarker1 yet.
                spreadView.snapTo(spreadView.nextInStack);
            } else if (!dragging && attachedToView) {
                if (spreadView.contentX < spreadView.width * spreadView.positionMarker1) {
                    spreadView.snap();
                } else if (spreadView.contentX < spreadView.width * spreadView.positionMarker2) {
                    spreadView.snapTo(spreadView.nextInStack)
                } else {
                    // otherwise snap to the closest snap position we can find
                    // (might be back to start, to app 1 or to spread)
                    spreadView.snap();
                }
            }
        }
    }
}
