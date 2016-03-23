/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import Unity.Application 0.1
import Utils 0.1
import Powerd 0.1
import "../Components"

AbstractStage {
    id: root
    objectName: "stages"
    anchors.fill: parent

    // Functions to be called from outside
    function updateFocusedAppOrientation() {
        var mainStageAppIndex = priv.indexOf(priv.mainStageAppId);
        if (mainStageAppIndex >= 0 && mainStageAppIndex < spreadRepeater.count) {
            spreadRepeater.itemAt(mainStageAppIndex).matchShellOrientation();
        }

        for (var i = 0; i < spreadRepeater.count; ++i) {

            if (i === mainStageAppIndex) {
                continue;
            }

            var spreadDelegate = spreadRepeater.itemAt(i);

            var delta = spreadDelegate.appWindowOrientationAngle - root.shellOrientationAngle;
            if (delta < 0) { delta += 360; }
            delta = delta % 360;

            var supportedOrientations = spreadDelegate.supportedOrientations;
            if (supportedOrientations === Qt.PrimaryOrientation) {
                supportedOrientations = spreadDelegate.orientations.primary;
            }

            if (delta === 180 && (supportedOrientations & spreadDelegate.shellOrientation)) {
                spreadDelegate.matchShellOrientation();
            }
        }
    }
    function updateFocusedAppOrientationAnimated() {
        var mainStageAppIndex = priv.indexOf(priv.mainStageAppId);
        if (mainStageAppIndex >= 0 && mainStageAppIndex < spreadRepeater.count) {
            spreadRepeater.itemAt(mainStageAppIndex).animateToShellOrientation();
        }

        if (priv.sideStageAppId) {
            var sideStageAppIndex = priv.indexOf(priv.sideStageAppId);
            if (sideStageAppIndex >= 0 && sideStageAppIndex < spreadRepeater.count) {
                spreadRepeater.itemAt(sideStageAppIndex).matchShellOrientation();
            }
        }
    }

    function pushRightEdge(amount) {
        if (spreadView.contentX == -spreadView.shift) {
            edgeBarrier.push(amount);
        }
    }

    orientationChangesEnabled: priv.mainAppOrientationChangesEnabled

    supportedOrientations: {
        if (mainApp) {
            var orientations = mainApp.supportedOrientations;
            orientations |= Qt.LandscapeOrientation | Qt.InvertedLandscapeOrientation;
            if (priv.sideStageAppId && !spreadView.surfaceDragging) {
                // If we have a sidestage app, support Portrait orientation
                // so that it will switch the sidestage app to mainstage on rotate
                orientations |= Qt.PortraitOrientation|Qt.InvertedPortraitOrientation;
            }
            return orientations;
        } else {
            // we just don't care
            return Qt.PortraitOrientation |
                   Qt.LandscapeOrientation |
                   Qt.InvertedPortraitOrientation |
                   Qt.InvertedLandscapeOrientation;
        }
    }

    onWidthChanged: {
        spreadView.selectedIndex = -1;
        spreadView.phase = 0;
        spreadView.contentX = -spreadView.shift;
    }

    onInverseProgressChanged: {
        // This can't be a simple binding because that would be triggered after this handler
        // while we need it active before doing the anition left/right
        spreadView.animateX = (inverseProgress == 0)
        if (inverseProgress == 0 && priv.oldInverseProgress > 0) {
            // left edge drag released. Minimum distance is given by design.
            if (priv.oldInverseProgress > units.gu(22)) {
                ApplicationManager.requestFocusApplication("unity8-dash");
            }
        }
        priv.oldInverseProgress = inverseProgress;
    }

    onAltTabPressedChanged: {
        if (!spreadEnabled) {
            return;
        }
        if (altTabPressed) {
            priv.highlightIndex = Math.min(spreadRepeater.count - 1, 1);
            spreadView.snapToSpread();
        } else {
            for (var i = 0; i < spreadRepeater.count; i++) {
                if (spreadRepeater.itemAt(i).zIndex === priv.highlightIndex) {
                    spreadView.snapTo(i);
                    return;
                }
            }
        }
    }

    FocusScope {
        focus: root.altTabPressed

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Tab:
                priv.highlightIndex = (priv.highlightIndex + 1) % spreadRepeater.count
                break;
            case Qt.Key_Backtab:
                priv.highlightIndex = (priv.highlightIndex + spreadRepeater.count - 1) % spreadRepeater.count
                break;
            }
        }
    }

    QtObject {
        id: priv
        objectName: "stagesPriv"

        property string focusedAppId: ApplicationManager.focusedApplicationId
        readonly property var focusedAppDelegate: {
            var index = indexOf(focusedAppId);
            return index >= 0 && index < spreadRepeater.count ? spreadRepeater.itemAt(index) : null
        }

        property string oldFocusedAppId: ""
        property bool mainAppOrientationChangesEnabled: false

        property real landscapeHeight: root.orientations.native_ == Qt.LandscapeOrientation ?
                root.nativeHeight : root.nativeWidth

        property bool shellIsLandscape: root.shellOrientation === Qt.LandscapeOrientation
                      || root.shellOrientation === Qt.InvertedLandscapeOrientation

        property string mainStageAppId
        property string sideStageAppId

        // For convenience, keep properties of the first two apps in the model
        property string appId0
        property string appId1

        property int oldInverseProgress: 0

        property int highlightIndex: 0

        onFocusedAppIdChanged: updateStageApps()

        onFocusedAppDelegateChanged: {
            if (focusedAppDelegate) {
                focusedAppDelegate.focus = true;
            }
        }

        property bool focusedAppDelegateIsDislocated: focusedAppDelegate &&
                                                      (focusedAppDelegate.dragOffset !== 0 || focusedAppDelegate.xTranslateAnimating)
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

        onHighlightIndexChanged: {
            spreadView.contentX = highlightIndex * spreadView.contentWidth / (spreadRepeater.count + 2)
        }

        function getTopApp(stage) {
            for (var i = 0; i < ApplicationManager.count; i++) {
                var app = ApplicationManager.get(i)
                if (app.stage === stage) {
                    return app;
                }
            }
            return null;
        }

        function setAppStage(appId, stage, save) {
            var app = ApplicationManager.findApplication(appId);
            if (app) {
                app.stage = stage;
                if (save) {
                    WindowStateStorage.saveStage(appId, stage);
                }
            }
        }

        function updateStageApps() {
            var app = priv.getTopApp(ApplicationInfoInterface.MainStage);
            priv.mainStageAppId = app ? app.appId : ""
            root.mainApp = app;

            if (sideStage.shown) {
                app = priv.getTopApp(ApplicationInfoInterface.SideStage);
                priv.sideStageAppId = app ? app.appId : ""
            } else {
                priv.sideStageAppId = "";
            }

            appId0 = ApplicationManager.count >= 1 ? ApplicationManager.get(0).appId : "";
            appId1 = ApplicationManager.count > 1 ? ApplicationManager.get(1).appId : "";
        }

        readonly property bool sideStageEnabled: root.shellOrientation == Qt.LandscapeOrientation ||
                                                 root.shellOrientation == Qt.InvertedLandscapeOrientation
        Component.onCompleted: updateStageApps();
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

        onApplicationAdded: {
            if (spreadView.phase == 2) {
                spreadView.snapTo(ApplicationManager.count - 1);
            } else {
                spreadView.phase = 0;
                spreadView.contentX = -spreadView.shift;
                ApplicationManager.focusApplication(appId);
            }
        }

        onApplicationRemoved: {
            if (priv.mainStageAppId == appId) {
                ApplicationManager.focusApplication("unity8-dash")
            }
            if (priv.sideStageAppId == appId) {
                var app = priv.getTopApp(ApplicationInfoInterface.SideStage);
                priv.sideStageAppId = app === null ? "" : app.appId;
            }

            if (ApplicationManager.count == 0) {
                spreadView.phase = 0;
                spreadView.contentX = -spreadView.shift;
            } else if (spreadView.closingIndex == -1) {
                // Unless we're closing the app ourselves in the spread,
                // lets make sure the spread doesn't mess up by the changing app list.
                spreadView.phase = 0;
                spreadView.contentX = -spreadView.shift;

                ApplicationManager.focusApplication(ApplicationManager.get(0).appId);
            }
        }
    }

    Flickable {
        id: spreadView
        objectName: "spreadView"
        anchors.fill: parent
        interactive: (spreadDragArea.dragging || phase > 1) && draggedDelegateCount === 0
        contentWidth: spreadRow.width - shift
        contentX: -shift

        property int tileDistance: units.gu(20)
        property int sideStageWidth: units.gu(40)
        property bool sideStageVisible: priv.sideStageAppId

        // This indicates when the spreadView is active. That means, all the animations
        // are activated and tiles need to line up for the spread.
        readonly property bool active: shiftedContentX > 0 || spreadDragArea.dragging

        // The flickable needs to fill the screen in order to get touch events all over.
        // However, we don't want to the user to be able to scroll back all the way. For
        // that, the beginning of the gesture starts with a negative value for contentX
        // so the flickable wants to pull it into the view already. "shift" tunes the
        // distance where to "lock" the content.
        readonly property real shift: width / 2
        readonly property real shiftedContentX: contentX + shift

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
        property int draggedDelegateCount: 0
        property int closingIndex: -1
        property var selectedApplication: selectedIndex !== -1 ? ApplicationManager.get(selectedIndex) : null

        // FIXME: Workaround Flickable's not keepping its contentX still when resized
        onContentXChanged: { forceItToRemainStillIfBeingResized(); }
        onShiftChanged: { forceItToRemainStillIfBeingResized(); }
        function forceItToRemainStillIfBeingResized() {
            if (root.beingResized && contentX != -shift) {
                contentX = -shift;
            }
        }

        property bool animateX: true
        property bool beingResized: root.beingResized
        onBeingResizedChanged: {
            if (beingResized) {
                // Brace yourselves for impact!
                selectedIndex = -1;
                phase = 0;
                contentX = -shift;
            }
        }

        property real sideStageDragProgress: sideStage.progress
        property bool surfaceDragging: triGestureArea.recognisedDrag

        // In case the ApplicationManager already holds an app when starting up we're missing animations
        // Make sure we end up in the same state
        Component.onCompleted: {
            spreadView.contentX = -spreadView.shift
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
            if ((priv.mainStageAppId && !priv.sideStageAppId) || !priv.sideStageEnabled) {
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

        onShiftedContentXChanged: {
            if (root.beingResized) {
                // Flickabe.contentX wiggles during resizes. Don't react to it.
                return;
            }

            switch (phase) {
            case 0:
                // the "spreadEnabled" part is because when code does "phase = 0; contentX = -shift" to
                // dismiss the spread because spreadEnabled went to false, for some reason, during tests,
                // Flickable might jump in and change contentX value back, causing the code below to do
                // "phase = 1" which will make the spread stay.
                // It sucks that we have no control whatsoever over whether or when Flickable animates its
                // contentX.
                if (root.spreadEnabled && shiftedContentX > width * positionMarker2) {
                    phase = 1;
                }
                break;
            case 1:
                if (shiftedContentX < width * positionMarker2) {
                    phase = 0;
                } else if (shiftedContentX >= width * positionMarker4 && !spreadDragArea.dragging) {
                    phase = 2;
                }
                break;
            }
        }

        function snap() {
            if (shiftedContentX < phase0Width) {
                snapAnimation.targetContentX = -shift;
                snapAnimation.start();
            } else if (shiftedContentX < phase1Width) {
                snapTo(1);
            } else {
                snapToSpread();
            }
        }

        function snapToSpread() {
            // Add 1 pixel to make sure we definitely hit positionMarker4 even with rounding errors of the animation.
            snapAnimation.targetContentX = (spreadView.width * spreadView.positionMarker4) + 1 - shift;
            snapAnimation.start();
        }

        function snapTo(index) {
            snapAnimation.stop();
            spreadView.selectedIndex = index;
            snapAnimation.targetContentX = -shift;
            snapAnimation.start();
        }

        // We need to shuffle z ordering a bit in order to keep side stage apps above main stage apps.
        // We don't want to really reorder them in the model because that allows us to keep track
        // of the last focused order.
        function indexToZIndex(index) {
            // only shuffle when we've got a main and overlay
            if (state !== "mainAndOverlay") return index;

            var app = ApplicationManager.get(index);
            if (!app) {
                return index;
            }

            // don't shuffle indexes greater than "actives or next"
            if (index > 2) return index;

            if (app.appId === priv.mainStageAppId) {
                // Active main stage always at 0
                return 0;
            }

            if (spreadView.nextInStack > 0) {
                var nextAppInStack = ApplicationManager.get(spreadView.nextInStack);

                if (index === spreadView.nextInStack) {
                    // this is the next app in stack.

                    if (app.stage ===  ApplicationInfoInterface.SideStage) {
                        // if the next app in stack is a sidestage app, it must order on top of other side stage app
                        return Math.min(2, ApplicationManager.count-1);
                    }
                    return 1;
                }
                if (nextAppInStack.stage ===  ApplicationInfoInterface.SideStage) {
                    // if the next app in stack is a sidestage app, it must order on top of other side stage app
                    return 1;
                }
                return Math.min(2, ApplicationManager.count-1);
            }
            return Math.min(index+1, ApplicationManager.count-1);
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
                        var newIndex = spreadView.selectedIndex;
                        var application = ApplicationManager.get(newIndex);
                        if (application.stage === ApplicationInfoInterface.SideStage) {
                            sideStage.showNow();
                        }
                        spreadView.selectedIndex = -1;
                        ApplicationManager.focusApplication(application.appId);
                        spreadView.phase = 0;
                        spreadView.contentX = -spreadView.shift;
                    }
                }
            }
        }

        Behavior on contentX {
            enabled: root.altTabPressed
            UbuntuNumberAnimation {}
        }

        MouseArea {
            id: spreadRow
            x: spreadView.contentX
            width: spreadView.width + Math.max(spreadView.width, ApplicationManager.count * spreadView.tileDistance)
            height: root.height

            onClicked: {
                spreadView.snapTo(0);
            }

            DropArea {
                objectName: "MainStageDropArea"
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: spreadView.width - sideStage.width
                enabled: priv.sideStageEnabled

                onDropped: {
                    priv.setAppStage(drag.source.appId, ApplicationInfoInterface.MainStage, true);
                    ApplicationManager.focusApplication(drag.source.appId);
                }
                keys: "SideStage"
            }

            SideStage {
                id: sideStage
                objectName: "sideStage"
                height: priv.landscapeHeight
                x: spreadView.width - width
                z: {
                    if (!priv.mainStageAppId) return 0;

                    if (priv.sideStageAppId && spreadView.nextInStack > 0) {
                        var nextAppInStack = ApplicationManager.get(spreadView.nextInStack);

                        if (nextAppInStack.stage ===  ApplicationInfoInterface.MainStage) {
                            // if the next app in stack is a main stage app, put the sidestage on top of it.
                            return 2;
                        }
                        return 1;
                    }

                    return 1;
                }
                visible: progress != 0
                enabled: priv.sideStageEnabled && sideStageDropArea.dropAllowed
                opacity: priv.sideStageEnabled && !spreadView.active ? 1 : 0
                Behavior on opacity { UbuntuNumberAnimation {} }

                onShownChanged: {
                    if (!shown && ApplicationManager.focusedApplicationId == priv.sideStageAppId) {
                        ApplicationManager.requestFocusApplication(priv.mainStageAppId);
                    }
                    priv.updateStageApps();
                    if (shown && priv.sideStageAppId) {
                        ApplicationManager.requestFocusApplication(priv.sideStageAppId);
                    }
                }

                DropArea {
                    id: sideStageDropArea
                    objectName: "SideStageDropArea"
                    anchors.fill: parent

                    property bool dropAllowed: true

                    onEntered: {
                        dropAllowed = drag.keys != "Disabled";
                    }
                    onExited: {
                        dropAllowed = true;
                    }
                    onDropped: {
                        if (drop.keys == "MainStage") {
                            priv.setAppStage(drop.source.appId, ApplicationInfoInterface.SideStage, true);
                            ApplicationManager.requestFocusApplication(drop.source.appId);
                        }
                    }
                    drag {
                        onSourceChanged: {
                            if (!sideStageDropArea.drag.source) {
                                dropAllowed = true;
                            }
                        }
                    }
                }
            }

            Repeater {
                id: spreadRepeater
                objectName: "spreadRepeater"
                model: ApplicationManager

                delegate: TransformedTabletSpreadDelegate {
                    id: spreadTile
                    objectName: model.appId ? "tabletSpreadDelegate_" + model.appId
                                            : "tabletSpreadDelegate_null";
                    width: spreadView.width
                    height: spreadView.height
                    active: appId == priv.mainStageAppId || appId == priv.sideStageAppId
                    zIndex: selected && stage == ApplicationInfoInterface.MainStage ? 0 : spreadView.indexToZIndex(index)
                    selected: spreadView.selectedIndex == index
                    otherSelected: spreadView.selectedIndex >= 0 && !selected
                    isInSideStage: priv.sideStageAppId === appId
                    interactive: !spreadView.interactive && spreadView.phase === 0 && root.interactive
                    swipeToCloseEnabled: spreadView.interactive && !snapAnimation.running
                    maximizedAppTopMargin: root.maximizedAppTopMargin
                    dragOffset: !isDash && appId == priv.mainStageAppId && root.inverseProgress > 0 && spreadView.phase === 0 ? root.inverseProgress : 0
                    application: ApplicationManager.get(index)
                    closeable: !isDash
                    highlightShown: root.altTabPressed && priv.highlightIndex == zIndex

                    readonly property bool wantsMainStage: model.stage == ApplicationInfoInterface.MainStage

                    readonly property string appId: model.appId
                    readonly property bool isDash: model.appId == "unity8-dash"

                    stage: model.stage
                    fullscreen: {
                        if (mainApp && stage === ApplicationInfoInterface.SideStage) {
                            return mainApp.fullscreen;
                        }
                        return application ? application.fullscreen : false;
                    }

                    supportedOrientations: {
                        if (application) {
                            var orientations = application.supportedOrientations;
                            if (stage == ApplicationInfoInterface.MainStage) {
                                // When an app is in the mainstage, it always supports Landscape|InvertedLandscape
                                // so that we can drag it from the main stage to the side stage
                                orientations |= Qt.LandscapeOrientation | Qt.InvertedLandscapeOrientation;
                            }
                            return orientations;
                        } else {
                            // we just don't care
                            return Qt.PortraitOrientation |
                                   Qt.LandscapeOrientation |
                                   Qt.InvertedPortraitOrientation |
                                   Qt.InvertedLandscapeOrientation;
                        }
                    }


                    Binding {
                        target: spreadTile.application
                        property: "exemptFromLifecycle"
                        value: !model.isTouchApp || isExemptFromLifecycle(model.appId)
                    }

                    Binding {
                        target: spreadTile.application
                        property: "requestedState"
                        value: (isDash && root.keepDashRunning)
                                   || (!root.suspended && (model.appId == priv.mainStageAppId
                                                           || model.appId == priv.sideStageAppId))
                               ? ApplicationInfoInterface.RequestedRunning
                               : ApplicationInfoInterface.RequestedSuspended
                    }

                    // FIXME: A regular binding doesn't update any more after closing an app.
                    // Using a Binding for now.
                    Binding {
                        target: spreadTile
                        property: "z"
                        value: (!spreadView.active && isDash && !active) ? -1 : spreadTile.zIndex
                    }
                    x: spreadView.width

                    property real behavioredZIndex: zIndex
                    Behavior on behavioredZIndex {
                        enabled: spreadView.closingIndex >= 0
                        UbuntuNumberAnimation {}
                    }
                    Connections {
                        target: priv
                        onSideStageEnabledChanged: refreshStage()
                    }

                    Component.onCompleted: {
                        refreshStage()
                        stageChanged.connect(priv.updateStageApps);
                    }

                    function refreshStage() {
                        var stage = ApplicationInfoInterface.MainStage;
                        if (priv.sideStageEnabled) {
                            if (application && application.supportedOrientations & (Qt.PortraitOrientation|Qt.InvertedPortraitOrientation)) {
                                stage = WindowStateStorage.getStage(appId);
                            }
                        }

                        if (model.stage !== stage) {
                            priv.setAppStage(appId, stage, false);
                        }
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
                        var tileProgress = (spreadView.shiftedContentX - behavioredZIndex * spreadView.tileDistance) / spreadView.width;
                        // Some tiles (nextInStack, active) need to move directly from the beginning, normalize progress to immediately start at 0
                        if ((index == spreadView.nextInStack && spreadView.phase < 2) || (active && spreadView.phase < 1)) {
                            tileProgress += behavioredZIndex * spreadView.tileDistance / spreadView.width;
                        }
                        return tileProgress;
                    }

                    // TODO: Hiding tile when progress is such that it will be off screen.
                    property bool occluded: {
                        if (spreadView.active && !offScreen) return false;
                        else if (spreadTile.active) return false;
                        else if (xTranslateAnimating) return false;
                        else if (z <= 1 && priv.focusedAppDelegateIsDislocated) return false;
                        return true;
                    }

                    visible: Powerd.status == Powerd.On &&
                             !greeter.fullyShown &&
                             !occluded

                    animatedProgress: {
                        if (spreadView.phase == 0 && (spreadTile.active || spreadView.nextInStack == index)) {
                            if (progress < spreadView.positionMarker1) {
                                return progress;
                            } else if (progress < spreadView.positionMarker1 + snappingCurve.period) {
                                return spreadView.positionMarker1 + snappingCurve.value * 3;
                            } else {
                                return spreadView.positionMarker2;
                            }
                        }
                        return progress;
                    }

                    shellOrientationAngle: root.shellOrientationAngle
                    shellOrientation: root.shellOrientation
                    orientations: root.orientations

                    states: [
                        State {
                            name: "MainStage"
                            when: spreadTile.stage == ApplicationInfoInterface.MainStage
                        },
                        State {
                            name: "SideStage"
                            when: spreadTile.stage == ApplicationInfoInterface.SideStage

                            PropertyChanges {
                                target: spreadTile
                                width: spreadView.sideStageWidth
                                height: priv.landscapeHeight

                                supportedOrientations: Qt.PortraitOrientation
                                shellOrientationAngle: 0
                                shellOrientation: Qt.PortraitOrientation
                                orientations: sideStageOrientations
                            }
                        }
                    ]

                    Orientations {
                        id: sideStageOrientations
                        primary: Qt.PortraitOrientation
                        native_: Qt.PortraitOrientation
                        portrait: root.orientations.portrait
                        invertedPortrait: root.orientations.invertedPortrait
                        landscape: root.orientations.landscape
                        invertedLandscape: root.orientations.invertedLandscape
                    }

                    transitions: [
                        Transition {
                            to: "SideStage"
                            SequentialAnimation {
                                PropertyAction {
                                    target: spreadTile
                                    properties: "width,height,supportedOrientations,shellOrientationAngle,shellOrientation,orientations"
                                }
                                ScriptAction {
                                    script: {
                                        // rotate immediately.
                                        spreadTile.matchShellOrientation();
                                        if (ApplicationManager.focusedApplicationId === spreadTile.appId &&
                                                priv.sideStageEnabled && !sideStage.shown) {
                                            // Sidestage was focused, so show the side stage.
                                            sideStage.show();
                                        // if we've switched to a main app which doesnt support portrait, hide the side stage.
                                        } else if (mainApp && (mainApp.supportedOrientations & (Qt.PortraitOrientation|Qt.InvertedPortraitOrientation)) == 0) {
                                            sideStage.hideNow();
                                        }
                                    }
                                }
                            }
                        },
                        Transition {
                            from: "SideStage"
                            SequentialAnimation {
                                ScriptAction {
                                    script: {
                                        if (priv.sideStageAppId === spreadTile.appId &&
                                                mainApp && (mainApp.supportedOrientations & (Qt.PortraitOrientation|Qt.InvertedPortraitOrientation)) == 0) {
                                            // The mainstage app did not natively support portrait orientation, so focus the sidestage.
                                            ApplicationManager.requestFocusApplication(spreadTile.appId);
                                        }
                                    }
                                }
                                PropertyAction {
                                    target: spreadTile
                                    properties: "width,height,supportedOrientations,shellOrientationAngle,shellOrientation,orientations"
                                }
                                ScriptAction { script: { spreadTile.matchShellOrientation(); } }
                            }
                        }
                    ]

                    onClicked: {
                        if (spreadView.phase == 2) {
                            spreadView.snapTo(index);
                        }
                    }

                    onDraggedChanged: {
                        if (dragged) {
                            spreadView.draggedDelegateCount++;
                        } else {
                            spreadView.draggedDelegateCount--;
                        }
                    }

                    onClosed: {
                        spreadView.closingIndex = index;
                        ApplicationManager.stopApplication(ApplicationManager.get(index).appId);
                    }

                    onFocusChanged: {
                        if (focus && ApplicationManager.focusedApplicationId !== appId) {
                            ApplicationManager.focusApplication(appId);
                        }

                        if (focus && priv.sideStageEnabled && stage === ApplicationInfoInterface.SideStage) {
                            sideStage.show();
                        }
                    }

                    Binding {
                        target: root
                        when: model.appId == priv.mainStageAppId
                        property: "mainAppWindowOrientationAngle"
                        value: appWindowOrientationAngle
                    }
                    Binding {
                        target: priv
                        when: model.appId == priv.mainStageAppId
                        property: "mainAppOrientationChangesEnabled"
                        value: orientationChangesEnabled
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

    TabletSideStageTouchGesture {
        id: triGestureArea
        anchors.fill: parent
        enabled: priv.sideStageEnabled && !spreadView.active
        property var dragObject: null
        property string appId: ""
        dragComponent: dragComponent
        dragComponentProperties: { "appId": appId }

        onPressed: {
            function matchDelegate(obj) { return String(obj.objectName).indexOf("tabletSpreadDelegate") >= 0; }

            var delegateAtCenter = Functions.itemAt(spreadRow, x, y, matchDelegate);
            if (!delegateAtCenter) return;

            appId = delegateAtCenter.appId;
        }

        onClicked: {
            if (sideStage.shown) {
               sideStage.hide();
            } else  {
               sideStage.show();
            }
        }

        onDragStarted: {
            // If we're dragging to the sidestage.
            if (!sideStage.shown) {
                sideStage.show();
            }
        }

        Component {
            id: dragComponent
            SessionContainer {
                property string appId: ""
                property var application: ApplicationManager.findApplication(appId)

                session: application ? application.session : null
                interactive: false
                resizeSurface: false
                focus: false

                width: units.gu(40)
                height: units.gu(40)

                Drag.hotSpot.x: width/2
                Drag.hotSpot.y: height/2
                // only accept opposite stage.
                Drag.keys: {
                    if (!application) return "Disabled";

                    if (application.stage === ApplicationInfo.MainStage) {
                        if (application.supportedOrientations & (Qt.PortraitOrientation|Qt.InvertedPortraitOrientation)) {
                            return "MainStage";
                        }
                        return "Disabled";
                    }
                    return "SideStage";
                }
            }
        }
    }

    //eat touch events during the right edge gesture
    MouseArea {
        anchors.fill: parent
        enabled: spreadDragArea.dragging
    }

    DirectionalDragArea {
        id: spreadDragArea
        objectName: "spreadDragArea"
        x: parent.width - root.dragAreaWidth
        anchors { top: parent.top; bottom: parent.bottom }
        width: root.dragAreaWidth
        direction: Direction.Leftwards
        enabled: (spreadView.phase != 2 && root.spreadEnabled) || dragging

        property var gesturePoints: new Array()

        onTouchXChanged: {
            if (!dragging) {
                spreadView.phase = 0;
                spreadView.contentX = -spreadView.shift;
            }

            if (dragging) {
                var dragX = -touchX + spreadDragArea.width - spreadView.shift;
                var maxDrag = spreadView.width * spreadView.positionMarker4 - spreadView.shift;
                spreadView.contentX = Math.min(dragX, maxDrag);
            }
            gesturePoints.push(touchX);
        }

        onDraggingChanged: {
            if (dragging) {
                // Gesture recognized. Start recording this gesture
                gesturePoints = [];
            } else {
                // Ok. The user released. Find out if it was a one-way movement.
                var oneWayFlick = priv.evaluateOneWayFlick(gesturePoints);
                gesturePoints = [];

                if (oneWayFlick && spreadView.shiftedContentX < spreadView.positionMarker1 * spreadView.width) {
                    // If it was a short one-way movement, do the Alt+Tab switch
                    // no matter if we didn't cross positionMarker1 yet.
                    spreadView.snapTo(spreadView.nextInStack);
                } else {
                    if (spreadView.shiftedContentX < spreadView.width * spreadView.positionMarker1) {
                        spreadView.snap();
                    } else if (spreadView.shiftedContentX < spreadView.width * spreadView.positionMarker2) {
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

    EdgeBarrier {
        id: edgeBarrier

        // NB: it does its own positioning according to the specified edge
        edge: Qt.RightEdge

        onPassed: {
            spreadView.snapToSpread();
        }
        material: Component {
            Item {
                Rectangle {
                    width: parent.height
                    height: parent.width
                    rotation: 90
                    anchors.centerIn: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(0.16,0.16,0.16,0.7)}
                        GradientStop { position: 1.0; color: Qt.rgba(0.16,0.16,0.16,0)}
                    }
                }
            }
        }
    }
}
