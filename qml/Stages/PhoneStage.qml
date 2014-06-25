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

    // Controls to be set from outside
    property int dragAreaWidth
    property real maximizedAppTopMargin

    // State information propagated to the outside
    property bool fullscreen: priv.focusedApplication ? priv.focusedApplication.fullscreen : false
    property bool locked: spreadView.visible

    function select(appId) {
        spreadView.snapTo(priv.indexOf(appId))
    }

    onWidthChanged: {
        spreadView.selectedIndex = -1;
        spreadView.phase = 0;
        spreadView.contentX = -spreadView.shift;
    }

    Connections {
        target: ApplicationManager

        onFocusRequested: {
            if (spreadView.visible) {
                spreadView.snapTo(priv.indexOf(appId));
            } else {
                priv.switchToApp(appId);
            }
        }

        onFocusedApplicationIdChanged: {
            if (ApplicationManager.focusedApplicationId.length > 0) {
                if (priv.secondApplicationStarting || priv.applicationStarting) {
                    appSplashTimer.restart();
                } else {
                    var application = priv.focusedApplication;
                    root.fullscreen = application.fullscreen;
                }
            } else {
                spreadView.selectedIndex = -1;
                spreadView.phase = 0;
                spreadView.contentX = -spreadView.shift;
            }
        }

        onApplicationAdded: {
            spreadView.snapTo(0);
        }
    }

    QtObject {
        id: priv

        property string focusedAppId: ApplicationManager.focusedApplicationId
        property var focusedApplication: ApplicationManager.findApplication(focusedAppId)

        property bool applicationStarting: false
        property bool secondApplicationStarting: false

        property string newFocusedAppId

        function switchToApp(appId) {
            if (priv.focusedAppId) {
                priv.newFocusedAppId = appId;
                root.fullscreen = ApplicationManager.findApplication(appId).fullscreen;
                applicationSwitchingAnimation.start();
            } else {
                ApplicationManager.focusApplication(appId);
            }
        }

        function indexOf(appId) {
            for (var i = 0; i < ApplicationManager.count; i++) {
                if (ApplicationManager.get(i).appId == appId) {
                    return i;
                }
            }
            return -1;
        }

    }

    Rectangle {
        id: coverFlipBackground
        anchors.fill: parent
        color: "black"
        visible: spreadView.visible
    }


    Flickable {
        id: spreadView
        objectName: "spreadView"
        anchors.fill: parent
        interactive: (spreadDragArea.status == DirectionalDragArea.Recognized || phase > 1) && draggedIndex == -1
        contentWidth: spreadRow.width - shift
        contentX: -shift

        // The flickable needs to fill the screen in order to get touch events all over.
        // However, we don't want to the user to be able to scroll back all the way. For
        // that, the beginning of the gesture starts with a negative value for contentX
        // so the flickable wants to pull it into the view already. "shift" tunes the
        // distance where to "lock" the content.
        readonly property real shift: width / 2
        readonly property real shiftedContentX: contentX + shift

        property int tileDistance: width / 4

        // Those markers mark the various positions in the spread (ratio to screen width from right to left):
        // 0 - 1: following finger, snap back to the beginning on release
        property real positionMarker1: 0.3
        // 1 - 2: curved snapping movement, snap to app 1 on release
        property real positionMarker2: 0.45
        // 2 - 3: movement follows finger, snaps back to app 1 on release
        property real positionMarker3: 0.6
        // passing 3, we detach movement from the finger and snap to 4
        property real positionMarker4: 0.9

        // This is where the first app snaps to when bringing it in from the right edge.
        property real snapPosition: 0.75

        // Phase of the animation:
        // 0: Starting from right edge, a new app (index 1) comes in from the right
        // 1: The app has reached the first snap position.
        // 2: The list is dragged further and snaps into the spread view when entering phase 2
        property int phase: 0

        property int selectedIndex: -1
        property int draggedIndex: -1
        property int closingIndex: -1

        onShiftedContentXChanged: {
            switch (phase) {
            case 0:
                if (shiftedContentX > width * positionMarker2) {
                    phase = 1;
                }
                break;
            case 1:
                if (shiftedContentX < width * positionMarker2) {
                    phase = 0;
                } else if (shiftedContentX >= width * positionMarker4) {
                    phase = 2;
                }
                break;
            }
        }

        function snap() {
            if (shiftedContentX < positionMarker1 * width) {
                snapAnimation.targetContentX = -shift;
                snapAnimation.start();
            } else if (shiftedContentX < positionMarker2 * width) {
                snapTo(1)
            } else if (shiftedContentX < positionMarker3 * width) {
                snapTo(1)
            } else if (phase < 2){
                // Add 1 pixel to make sure we definitely hit positionMarker4 even with rounding errors of the animation.
                snapAnimation.targetContentX = width * positionMarker4 + 1 - shift;
                snapAnimation.start();
            }
        }
        function snapTo(index) {
            spreadView.selectedIndex = index;
            root.fullscreen = ApplicationManager.get(index).fullscreen;
            snapAnimation.targetContentX = -shift;
            snapAnimation.start();
        }

        SequentialAnimation {
            id: snapAnimation
            property int targetContentX: -spreadView.shift

            UbuntuNumberAnimation {
                target: spreadView
                property: "contentX"
                to: snapAnimation.targetContentX
                duration: UbuntuAnimation.FastDuration
            }

            ScriptAction {
                script: {
                    if (spreadView.selectedIndex >= 0) {
                        ApplicationManager.focusApplication(ApplicationManager.get(spreadView.selectedIndex).appId);

                        spreadView.selectedIndex = -1
                        spreadView.phase = 0;
                        spreadView.contentX = -spreadView.shift;
                    }
                }
            }
        }

        Item {
            id: spreadRow
            // This width controls how much the spread can be flicked left/right. It's composed of:
            //  tileDistance * app count (with a minimum of 3 apps, in order to also allow moving 1 and 2 apps a bit)
            //  + some constant value (still scales with the screen width) which looks good and somewhat fills the screen
            width: Math.max(3, ApplicationManager.count) * spreadView.tileDistance + (spreadView.width - spreadView.tileDistance) * 1.5
            Behavior on width {
                enabled: spreadView.closingIndex >= 0
                UbuntuNumberAnimation {}
            }
            onWidthChanged: {
                if (spreadView.closingIndex >= 0) {
                    spreadView.contentX = Math.min(spreadView.contentX, width - spreadView.width - spreadView.shift)
                }
            }

            x: spreadView.contentX

            Repeater {
                id: spreadRepeater
                model: ApplicationManager
                delegate: TransformedSpreadDelegate {
                    id: appDelegate
                    objectName: "appDelegate" + index
                    startAngle: 45
                    endAngle: 5
                    startScale: 1.1
                    endScale: 0.7
                    startDistance: spreadView.tileDistance
                    endDistance: units.gu(.5)
                    width: spreadView.width
                    height: spreadView.height
                    selected: spreadView.selectedIndex == index
                    otherSelected: spreadView.selectedIndex >= 0 && !selected
                    interactive: !spreadView.interactive
                    maximizedAppTopMargin: root.maximizedAppTopMargin
                    dropShadow: spreadView.shiftedContentX > 0 || spreadDragArea.status == DirectionalDragArea.Undecided

                    z: behavioredIndex
                    x: index == 0 ? 0 : spreadView.width + (index - 1) * spreadView.tileDistance
                    property real behavioredIndex: index
                    Behavior on behavioredIndex {
                        enabled: spreadView.closingIndex >= 0
                        UbuntuNumberAnimation {
                            onRunningChanged: {
                                if (!running) {
                                    spreadView.closingIndex = -1
                                }
                            }
                        }
                    }

                    // Each tile has a different progress value running from 0 to 1.
                    // A progress value of 0 means the tile is at the right edge. 1 means the tile has reched the left edge.
                    progress: {
                        var tileProgress = (spreadView.shiftedContentX - behavioredIndex * spreadView.tileDistance) / spreadView.width;
                        // Tile 1 needs to move directly from the beginning...
                        if (behavioredIndex == 1 && spreadView.phase < 2) {
                            tileProgress += spreadView.tileDistance / spreadView.width;
                        }
                        return tileProgress;
                    }

                    // This mostly is the same as progress, just adds the snapping to phase 1 for tiles 0 and 1
                    animatedProgress: {
                        if (spreadView.phase == 0 && index < 2) {
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

                    EasingCurve {
                        id: snappingCurve
                        type: EasingCurve.Linear
                        period: 0.05
                        progress: appDelegate.progress - spreadView.positionMarker1
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
                        spreadView.draggedIndex = -1
                        spreadView.closingIndex = index
                        ApplicationManager.stopApplication(ApplicationManager.get(index).appId)
                    }
                }
            }
        }
    }

    EdgeDragArea {
        id: spreadDragArea
        direction: Direction.Leftwards
        enabled: ApplicationManager.count > 1 && spreadView.phase != 2

        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: root.dragAreaWidth

        // Sitting at the right edge of the screen, this EdgeDragArea directly controls the spreadView when
        // attachedToView is true. When the finger movement passes positionMarker3 we detach it from the
        // spreadView and make the spreadView snap to positionMarker4.
        property bool attachedToView: true

        property var gesturePoints: new Array()

        onTouchXChanged: {
            if (!dragging) {
                // Initial touch. Let's reset the spreadView to the starting position.
                spreadView.phase = 0;
                spreadView.contentX = -spreadView.shift;
            }
            if (dragging && attachedToView) {
                // Gesture recognized. Let's move the spreadView with the finger
                spreadView.contentX = -touchX - spreadView.shift;
            }
            if (attachedToView && spreadView.shiftedContentX >= spreadView.width * spreadView.positionMarker3) {
                // We passed positionMarker3. Detach from spreadView and snap it.
                attachedToView = false;
                spreadView.snap();
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
            var oneWayFlick = true;
            var smallestX = spreadDragArea.width;
            for (var i = 0; i < gesturePoints.length; i++) {
                if (gesturePoints[i] >= smallestX) {
                    oneWayFlick = false;
                    break;
                }
                smallestX = gesturePoints[i];
            }
            gesturePoints = [];

            if (oneWayFlick && spreadView.shiftedContentX > units.gu(2) &&
                    spreadView.shiftedContentX < spreadView.positionMarker1 * spreadView.width) {
                // If it was a short one-way movement, do the Alt+Tab switch
                // no matter if we didn't cross positionMarker1 yet.
                spreadView.snapTo(1);
            } else if (!dragging && attachedToView) {
                // otherwise snap to the closest snap position we can find
                // (might be back to start, to app 1 or to spread)
                spreadView.snap();
            }
        }
    }

}
