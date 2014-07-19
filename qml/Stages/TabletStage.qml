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
import Unity.Application 0.1
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
    property real maximizedAppTopMargin
    property bool interactive

    // State information propagated to the outside
    readonly property bool locked: spreadView.phase == 2

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
            if (priv.focusedAppId.length > 0) {
                var focusedApp = ApplicationManager.findApplication(focusedAppId);
                if (focusedApp.stage == ApplicationInfoInterface.SideStage) {
                    priv.sideStageAppId = focusedAppId;
                } else {
                    priv.mainStageAppId = focusedAppId;
                }
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
            if (spreadView.interactive) {
                spreadView.snapTo(priv.indexOf(appId));
            } else {
                ApplicationManager.focusApplication(appId);
            }
        }

        onApplicationRemoved: {
            if (priv.mainStageAppId == appId) {
                priv.mainStageAppId = "";
            }
            if (priv.sideStageAppId == appId) {
                priv.sideStageAppId = "";
            }
            if (ApplicationManager.count == 0) {
                spreadView.phase = 0;
                spreadView.contentX = 0;
            }
        }
    }

    Flickable {
        id: spreadView
        anchors.fill: parent
        contentWidth: spreadRow.width
        interactive: (spreadDragArea.status == DirectionalDragArea.Recognized || phase > 1) && draggedIndex == -1

        property int tileDistance: units.gu(20)
        property int sideStageWidth: units.gu(40)
        property bool sideStageVisible: priv.sideStageAppId

        // Phase of the animation:
        // 0: Starting from right edge, a new app (index 1) comes in from the right
        // 1: The app has reached the first snap position.
        // 2: The list is dragged further and snaps into the spread view when entering phase 2
        property int phase

        readonly property int phase0Width: sideStageWidth
        readonly property int phase1Width: sideStageWidth

        // Those markers mark the various positions in the spread (ratio to screen width from right to left):
        // 0 - 1: following finger, snap back to the beginning on release
        readonly property real positionMarker1: 0.2
        // 1 - 2: curved snapping movement, snap to nextInStack on release
        readonly property real positionMarker2: sideStageWidth / spreadView.width
        // 2 - 3: movement follows finger, snaps to phase 2 (full spread) on release
        readonly property real positionMarker3: 0.6
        // passing 3, we detach movement from the finger and snap to phase 2 (full spread)
        readonly property real positionMarker4: 0.8

        readonly property int startSnapPosition: phase0Width * 0.5
        readonly property int endSnapPosition: phase0Width * 0.75
        readonly property real snapPosition: 0.75

        property int selectedIndex: -1
        property int draggedIndex: -1
        property int closingIndex: -1

        property bool sideStageDragging: sideStageDragHandle.dragging
        property real sideStageDragProgress: sideStageDragHandle.progress

        onSideStageDragProgressChanged: {
            if (sideStageDragProgress == 1) {
                ApplicationManager.focusApplication(priv.mainStageAppId);
                priv.sideStageAppId = "";
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
                if (priv.appId0 == priv.mainStageAppId || priv.appId0 == priv.sideStageAppId) {
                    if (priv.appId1 == priv.mainStageAppId || priv.appId1 == priv.sideStageAppId) {
                        return 2;
                    }
                    return 1;
                }
                return 0;
            case "overlay":
                return 1;
            }
            print("Unhandled nextInStack case! This shouldn't happen any more when the Dash is an app!");
            return -1;
        }
        property int nextZInStack: indexToZIndex(nextInStack)

        states: [
            State {
                name: "empty"
            },
            State {
                name: "main"
            },
            State { // Side Stage only in overlay mode
                name: "overlay"
            },
            State { // Main Stage and Side Stage in overlay mode
                name: "mainAndOverlay"
            },
            State { // Main Stage and Side Stage in split mode
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
            return "empty";
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
                snapTo(1);
            } else {
                // Add 1 pixel to make sure we definitely hit positionMarker4 even with rounding errors of the animation.
                snapAnimation.targetContentX = spreadView.width * spreadView.positionMarker4 + 1;
                snapAnimation.start();
            }
        }
        function snapTo(index) {
            spreadView.selectedIndex = index;
            snapAnimation.targetContentX = 0;
            snapAnimation.start();
        }

        // We need to shuffle z ordering a bit in order to keep side stage apps above main stage apps.
        // We don't want to really reorder them in the model because that allows us to keep track
        // of the last focused order.
        function indexToZIndex(index) {
            var app = ApplicationManager.get(index);
            if (!app) {
                return index;
            }

            var isActive = app.appId == priv.mainStageAppId || app.appId == priv.sideStageAppId;
            if (isActive && app.stage == ApplicationInfoInterface.MainStage) {
                // if this app is active, and its the MainStage, always put it to index 0
                return 0;
            }
            if (isActive && app.stage == ApplicationInfoInterface.SideStage) {
                if (!priv.mainStageAppId) {
                    // Only have SS apps running. Put the active one at 0
                    return 0;
                }

                // Precondition now: There's an active MS app and this is SS app:
                if (spreadView.nextInStack >= 0 && ApplicationManager.get(spreadView.nextInStack).stage == ApplicationInfoInterface.MainStage) {
                    // If the next app coming from the right is a MS app, we need to elevate this SS ap above it.
                    // Put it to at least level 2, or higher if there's more apps coming in before this one.
                    return Math.max(index, 2);
                } else {
                    // if this is no next app to come in from the right, place this one at index 1, just on top the active MS app.
                    return 1;
                }
            }
            if (index <= 2 && app.stage == ApplicationInfoInterface.MainStage && priv.sideStageAppId) {
                // Ok, this is an inactive MS app. If there's an active SS app around, we need to place this one
                // in between the active MS app and the active SS app, so that it comes in from there when dragging from the right.
                // If there's now active SS app, just leave it where it is.
                return priv.indexOf(priv.sideStageAppId) < index ? index - 1 : index;
            }
            if (index == spreadView.nextInStack && app.stage == ApplicationInfoInterface.SideStage) {
                // This is a SS app and the next one to come in from the right:
                if (priv.sideStageAppId && priv.mainStageAppId) {
                    // If there's both, an active MS and an active SS app, put this one right on top of that
                    return 2;
                }
                // Or if there's only one other active app, put it on top of that.
                // The case that there isn't any other active app is already handled above.
                return 1;
            }
            if (index == 2 && spreadView.nextInStack == 1 && priv.sideStageAppId) {
                // If its index 2 but not the next one to come in, it means
                // we've pulled another one down to index 2. Move this one up to 2 instead.
                return 3;
            }
            // don't touch all others... (mostly index > 3 + simple cases where the above doesn't shuffle much)
            return index;
        }

        SequentialAnimation {
            id: snapAnimation
            property int targetContentX: 0

            UbuntuNumberAnimation {
                target: spreadView
                property: "contentX"
                to: snapAnimation.targetContentX
                duration: UbuntuAnimation.FastDuration
            }

            ScriptAction {
                script: {
                    if (spreadView.selectedIndex >= 0) {
                        var newIndex = spreadView.selectedIndex;
                        spreadView.selectedIndex = -1;
                        ApplicationManager.focusApplication(ApplicationManager.get(newIndex).appId);
                        spreadView.phase = 0;
                        spreadView.contentX = 0;
                    }
                }
            }
        }

        Rectangle {
            id: spreadRow
            color: "black"
            x: spreadView.contentX
            height: root.height
            width: spreadView.width + Math.max(spreadView.width, ApplicationManager.count * spreadView.tileDistance)

            Rectangle {
                id: sideStageBackground
                color: "black"
                anchors.fill: parent
                anchors.leftMargin: spreadView.width - spreadView.sideStageWidth + spreadView.sideStageWidth * sideStageDragHandle.progress
                z: spreadView.indexToZIndex(priv.indexOf(priv.sideStageAppId))
                opacity: spreadView.phase == 0 ? 1 : 0
                Behavior on opacity { UbuntuNumberAnimation {} }
            }

            Item {
                id: sideStageDragHandle
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left; leftMargin: spreadView.width - spreadView.sideStageWidth - width }
                width: units.gu(2)
                z: sideStageBackground.z
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
                    enabled: spreadView.contentX == 0
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
                            sideStageDragHandle.progress = Math.max(0, (-startX + mouseX) / spreadView.sideStageWidth);
                        }
                        gesturePoints.push(mouseX);
                    }
                    onReleased: {
                        if (priv.mainStageAppId) {
                            var oneWayFlick = priv.evaluateOneWayFlick(gesturePoints);
                            sideStageDragSnapAnimation.to = sideStageDragHandle.progress > 0.5 || oneWayFlick ? 1 : 0;
                            sideStageDragSnapAnimation.start();
                        } else {
                            sideStageDragHandle.dragging = false;
                        }
                    }
                }
                UbuntuNumberAnimation {
                    id: sideStageDragSnapAnimation
                    target: sideStageDragHandle
                    property: "progress"

                    onRunningChanged: {
                        if (!running) {
                            sideStageDragHandle.dragging = false;;
                        }
                    }
                }
            }

            Repeater {
                id: spreadRepeater
                model: ApplicationManager

                delegate: TransformedTabletSpreadDelegate {
                    id: spreadTile
                    height: spreadView.height
                    width: model.stage == ApplicationInfoInterface.MainStage ? spreadView.width : spreadView.sideStageWidth
                    x: spreadView.width
                    z: spreadView.indexToZIndex(index)
                    active: model.appId == priv.mainStageAppId || model.appId == priv.sideStageAppId
                    zIndex: z
                    selected: spreadView.selectedIndex == index
                    otherSelected: spreadView.selectedIndex >= 0 && !selected
                    isInSideStage: priv.sideStageAppId == model.appId
                    interactive: !spreadView.interactive && spreadView.phase === 0 && root.interactive
                    swipeToCloseEnabled: spreadView.interactive
                    maximizedAppTopMargin: root.maximizedAppTopMargin
                    dropShadow: spreadView.contentX > 0 || spreadDragArea.status == DirectionalDragArea.Undecided

                    property real behavioredZIndex: zIndex
                    Behavior on behavioredZIndex {
                        enabled: spreadView.closingIndex >= 0
                        UbuntuNumberAnimation {}
                    }

                    // This is required because none of the bindings are triggered in some cases:
                    // When an app is closed, it might happen that ApplicationManager.get(nextInStack)
                    // returns a different app even though the nextInStackIndex and all the related
                    // bindings (index, mainStageApp, sideStageApp, etc) don't change. Let's force a
                    // binding update in that case.
                    Connections {
                        target: ApplicationManager
                        onApplicationRemoved: spreadTile.z = Qt.binding(function() {
                            return spreadView.indexToZIndex(index);
                        })
                    }

                    progress: {
                        var tileProgress = (spreadView.contentX - behavioredZIndex * spreadView.tileDistance) / spreadView.width;
                        // Some tiles (nextInStack, active) need to move directly from the beginning, normalize progress to immediately start at 0
                        if ((index == spreadView.nextInStack && spreadView.phase < 2) || (active && spreadView.phase < 1)) {
                            tileProgress += behavioredZIndex * spreadView.tileDistance / spreadView.width;
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

                    onClosed: {
                        spreadView.draggedIndex = -1;
                        spreadView.closingIndex = index;
                        ApplicationManager.stopApplication(ApplicationManager.get(index).appId);
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

    EdgeDragArea {
        id: spreadDragArea
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: root.dragAreaWidth
        direction: Direction.Leftwards

        property bool attachedToView: false
        property var gesturePoints: new Array()

        onTouchXChanged: {
            if (!dragging) {
                spreadView.phase = 0;
                spreadView.contentX = 0;
            }

            if (attachedToView) {
                spreadView.contentX = -touchX + spreadDragArea.width;
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
                    spreadView.snapTo(spreadView.nextInStack);
                } else {
                    // otherwise snap to the closest snap position we can find
                    // (might be back to start, to app 1 or to spread)
                    spreadView.snap();
                }
            }
        }
    }
}
