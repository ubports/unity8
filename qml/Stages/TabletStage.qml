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

    // <tutorial-hacks> The Tutorial looks into our implementation details
    property alias sideStageVisible: spreadView.sideStageVisible
    property alias sideStageWidth: spreadView.sideStageWidth
    // The stage the currently focused surface is in
    property int stageFocusedSurface: priv.focusedAppDelegate ? priv.focusedAppDelegate.stage : ApplicationInfoInterface.MainStage
    // </tutorial-hacks>

    paintBackground: spreadView.shiftedContentX !== 0

    // Functions to be called from outside
    function updateFocusedAppOrientation() {
        var mainStageIndex = root.topLevelSurfaceList.indexForId(priv.mainStageItemId);

        if (priv.mainStageItemId && mainStageIndex >= 0 && mainStageIndex < spreadRepeater.count) {
            spreadRepeater.itemAt(mainStageIndex).matchShellOrientation();
        }

        for (var i = 0; i < spreadRepeater.count; ++i) {

            if (i === mainStageIndex) {
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
        var mainStageIndex = root.topLevelSurfaceList.indexForId(priv.mainStageItemId);
        if (priv.mainStageItemId && mainStageIndex >= 0 && mainStageIndex < spreadRepeater.count) {
            spreadRepeater.itemAt(mainStageIndex).animateToShellOrientation();
        }

        var sideStageIndex = root.topLevelSurfaceList.indexForId(priv.sideStageItemId);
        if (sideStageIndex >= 0 && sideStageIndex < spreadRepeater.count) {
            spreadRepeater.itemAt(sideStageIndex).matchShellOrientation();
        }
    }

    function pushRightEdge(amount) {
        if (spreadView.contentX == -spreadView.shift) {
            edgeBarrier.push(amount);
        }
    }

    orientationChangesEnabled: priv.mainAppOrientationChangesEnabled

    mainApp: {
        if (priv.mainStageItemId > 0) {
            var index = root.topLevelSurfaceList.indexForId(priv.mainStageItemId);
            return root.topLevelSurfaceList.applicationAt(index);
        } else {
            return null;
        }
    }

    supportedOrientations: {
        if (mainApp) {
            var orientations = mainApp.supportedOrientations;
            orientations |= Qt.LandscapeOrientation | Qt.InvertedLandscapeOrientation;
            if (priv.sideStageItemId && !spreadView.surfaceDragging) {
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

    // How far left the stage has been dragged, used externally by tutorial code
    dragProgress: spreadRepeater.count > 0 ? spreadRepeater.itemAt(0).animatedProgress : 0

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
                root.applicationManager.requestFocusApplication("unity8-dash");
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

    Connections {
        target: root.topLevelSurfaceList
        onListChanged: priv.updateMainAndSideStageIndexes()
    }

    QtObject {
        id: priv
        objectName: "stagesPriv"

        function updateMainAndSideStageIndexes() {
            var choseMainStage = false;
            var choseSideStage = false;

            if (!root.topLevelSurfaceList)
                return;

            for (var i = 0; i < spreadRepeater.count && (!choseMainStage || !choseSideStage); ++i) {
                var spreadDelegate = spreadRepeater.itemAt(i);
                if (sideStage.shown && spreadDelegate.stage == ApplicationInfoInterface.SideStage
                        && !choseSideStage) {
                    priv.sideStageDelegate = spreadDelegate
                    priv.sideStageItemId = root.topLevelSurfaceList.idAt(i);
                    priv.sideStageAppId = root.topLevelSurfaceList.applicationAt(i).appId;
                    choseSideStage = true;
                } else if (!choseMainStage && spreadDelegate.stage == ApplicationInfoInterface.MainStage) {
                    priv.mainStageDelegate = spreadDelegate;
                    priv.mainStageItemId = root.topLevelSurfaceList.idAt(i);
                    priv.mainStageAppId = root.topLevelSurfaceList.applicationAt(i).appId;
                    choseMainStage = true;
                }
            }
            if (!choseMainStage) {
                priv.mainStageDelegate = null;
                priv.mainStageItemId = 0;
                priv.mainStageAppId = "";
            }
            if (!choseSideStage) {
                priv.sideStageDelegate = null;
                priv.sideStageItemId = 0;
                priv.sideStageAppId = "";
            }
        }

        property var focusedAppDelegate: null

        property bool mainAppOrientationChangesEnabled: false

        property real landscapeHeight: root.orientations.native_ == Qt.LandscapeOrientation ?
                root.nativeHeight : root.nativeWidth

        property bool shellIsLandscape: root.shellOrientation === Qt.LandscapeOrientation
                      || root.shellOrientation === Qt.InvertedLandscapeOrientation

        property var mainStageDelegate: null
        property var sideStageDelegate: null

        property int mainStageItemId: 0
        property int sideStageItemId: 0

        property string mainStageAppId: ""
        property string sideStageAppId: ""

        property int oldInverseProgress: 0

        property int highlightIndex: 0

        property bool focusedAppDelegateIsDislocated: focusedAppDelegate &&
                                                      (focusedAppDelegate.dragOffset !== 0 || focusedAppDelegate.xTranslateAnimating)
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

        readonly property bool sideStageEnabled: root.shellOrientation == Qt.LandscapeOrientation ||
                                                 root.shellOrientation == Qt.InvertedLandscapeOrientation
    }

    Instantiator {
        model: root.applicationManager
        delegate: QtObject {
            property var stateBinding: Binding {
                readonly property bool isDash: model.application ? model.application.appId == "unity8-dash" : false
                target: model.application
                property: "requestedState"

                // NB: the first application clause is just to ensure we never get warnings for trying to access
                //     members of a null variable.
                value: model.application &&
                        (
                          (isDash && root.keepDashRunning)
                           || (!root.suspended && (model.application.appId === priv.mainStageAppId
                                                   || model.application.appId === priv.sideStageAppId))
                        )
                       ? ApplicationInfoInterface.RequestedRunning
                       : ApplicationInfoInterface.RequestedSuspended
            }

            property var lifecycleBinding: Binding {
                target: model.application
                property: "exemptFromLifecycle"
                value: model.application
                            ? (!model.application.isTouchApp || isExemptFromLifecycle(model.application.appId))
                            : false
            }
        }
    }

    Binding {
        target: MirFocusController
        property: "focusedSurface"
        value: priv.focusedAppDelegate ? priv.focusedAppDelegate.surface : null
        when: root.parent && !spreadRepeater.startingUp
    }

    Flickable {
        id: spreadView
        objectName: "spreadView"
        anchors.fill: parent
        interactive: (spreadDragArea.dragging || phase > 1) && draggedDelegateCount === 0
        contentWidth: spreadRow.width - shift
        contentX: -shift

        property int tileDistance: units.gu(20)

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
        property var selectedDelegate: selectedIndex !== -1 ? spreadRepeater.itemAt(selectedIndex) : null

        // <FIXME-contentX> Workaround Flickable's behavior of bringing contentX back between valid boundaries
        // when resized. The proper way to fix this is refactoring PhoneStage so that it doesn't
        // rely on having Flickable.contentX keeping an out-of-bounds value when it's set programatically
        // (as opposed to having contentX reaching an out-of-bounds value through dragging, which will trigger
        // the Flickable.boundsBehavior upon release).
        onContentXChanged: {
            if (!undoContentXReset()) {
                forceItToRemainStillIfBeingResized();
            }
        }
        onShiftChanged: { forceItToRemainStillIfBeingResized(); }
        function forceItToRemainStillIfBeingResized() {
            if (root.beingResized && contentX != -spreadView.shift) {
                contentX = -spreadView.shift;
            }
        }
        function undoContentXReset() {
            if (contentWidth <= 0) {
                contentWidthOnLastContentXChange = contentWidth;
                lastContentX = contentX;
                return false;
            }

            if (contentWidth != contentWidthOnLastContentXChange
                    && lastContentX == -shift && contentX == 0) {
                // Flickable is resetting contentX because contentWidth has changed. Undo it.
                contentX = -shift;
                return true;
            }

            contentWidthOnLastContentXChange = contentWidth;
            lastContentX = contentX;
            return false;
        }
        property real contentWidthOnLastContentXChange: -1
        property real lastContentX: 0
        // </FIXME-contentX>

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

        property real sideStageWidth: units.gu(40)

        property bool surfaceDragging: triGestureArea.recognisedDrag

        readonly property bool sideStageVisible: priv.sideStageItemId != 0

        // In case applicationManager already holds an app when starting up we're missing animations
        // Make sure we end up in the same state
        Component.onCompleted: {
            spreadView.contentX = -spreadView.shift
        }

        property int nextInStack: {
            var mainStageIndex = priv.mainStageDelegate ? priv.mainStageDelegate.index : -1;
            var sideStageIndex = priv.sideStageDelegate ? priv.sideStageDelegate.index : -1;
            switch (state) {
            case "main":
                if (root.topLevelSurfaceList.count > 1) {
                    return 1;
                }
                return -1;
            case "mainAndOverlay":
                if (root.topLevelSurfaceList.count <= 2) {
                    return -1;
                }
                if (mainStageIndex == 0 || sideStageIndex == 0) {
                    if (mainStageIndex == 1 || sideStageIndex == 1) {
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
        property int nextZInStack

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
            if ((priv.mainStageItemId && !priv.sideStageItemId) || !priv.sideStageEnabled) {
                return "main";
            }
            if (!priv.mainStageItemId && priv.sideStageItemId) {
                return "overlay";
            }
            if (priv.mainStageItemId && priv.sideStageItemId) {
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

            var app = root.topLevelSurfaceList.applicationAt(index);
            if (!app) {
                return index;
            }
            var stage = spreadRepeater.itemAt(index) ? spreadRepeater.itemAt(index).stage : app.stage;

            // don't shuffle indexes greater than "actives or next"
            if (index > 2) return index;

            var mainStageIndex = root.topLevelSurfaceList.indexForId(priv.mainStageItemId);

            if (index == mainStageIndex) {
                // Active main stage always at 0
                return 0;
            }

            if (spreadView.nextInStack > 0) {
                var stageOfNextInStack = spreadRepeater.itemAt(spreadView.nextInStack).stage;

                if (index === spreadView.nextInStack) {
                    // this is the next app in stack.

                    if (stage ===  ApplicationInfoInterface.SideStage) {
                        // if the next app in stack is a sidestage app, it must order on top of other side stage app
                        return Math.min(2, root.topLevelSurfaceList.count-1);
                    }
                    return 1;
                }
                if (stageOfNextInStack === ApplicationInfoInterface.SideStage) {
                    // if the next app in stack is a sidestage app, it must order on top of other side stage app
                    return 1;
                }
                return Math.min(2, root.topLevelSurfaceList.count-1);
            }
            return Math.min(index+1, root.topLevelSurfaceList.count-1);
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
                        var application = root.topLevelSurfaceList.applicationAt(newIndex);
                        var spreadDelegate = spreadRepeater.itemAt(newIndex);
                        if (spreadDelegate.stage === ApplicationInfoInterface.SideStage) {
                            sideStage.showNow();
                        }
                        spreadView.selectedIndex = -1;
                        spreadDelegate.focus = true;
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
            width: spreadView.width + Math.max(spreadView.width, root.topLevelSurfaceList.count * spreadView.tileDistance)
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
                    drop.source.spreadDelegate.saveStage(ApplicationInfoInterface.MainStage);
                    drop.source.spreadDelegate.focus = true;
                }
                keys: "SideStage"
            }

            SideStage {
                id: sideStage
                objectName: "sideStage"
                height: priv.landscapeHeight
                x: spreadView.width - width
                z: {
                    if (!priv.mainStageItemId) return 0;

                    if (priv.sideStageItemId && spreadView.nextInStack > 0) {
                        var nextDelegateInStack = spreadRepeater.itemAt(spreadView.nextInStack);

                        if (nextDelegateInStack.stage ===  ApplicationInfoInterface.MainStage) {
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
                    if (!shown && priv.sideStageDelegate && priv.focusedAppDelegate === priv.sideStageDelegate
                            && priv.mainStageDelegate) {
                        priv.mainStageDelegate.focus = true;
                    } else if (shown && priv.sideStageDelegate) {
                        priv.sideStageDelegate.focus = true;
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
                            drop.source.spreadDelegate.saveStage(ApplicationInfoInterface.SideStage);
                            drop.source.spreadDelegate.focus = true;
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

            TopLevelSurfaceRepeater {
                id: spreadRepeater
                objectName: "spreadRepeater"
                model: root.topLevelSurfaceList

                onItemAdded: {
                    priv.updateMainAndSideStageIndexes();
                    if (spreadView.phase == 2) {
                        spreadView.snapTo(index);
                    }
                }

                onItemRemoved: {
                    priv.updateMainAndSideStageIndexes();
                    // Unless we're closing the app ourselves in the spread,
                    // lets make sure the spread doesn't mess up by the changing app list.
                    if (spreadView.closingIndex == -1) {
                        spreadView.phase = 0;
                        spreadView.contentX = -spreadView.shift;
                        focusTopMostApp();
                    }
                }
                function focusTopMostApp() {
                    if (spreadRepeater.count > 0) {
                        var topmostDelegate = spreadRepeater.itemAt(0);
                        topmostDelegate.focus = true;
                    }
                }

                delegate: TransformedTabletSpreadDelegate {
                    id: spreadTile
                    objectName: "spreadDelegate_" + model.id

                    readonly property int index: model.index
                    width: spreadView.width
                    height: spreadView.height
                    active: model.id == priv.mainStageItemId || model.id == priv.sideStageItemId
                    zIndex: selected && stage == ApplicationInfoInterface.MainStage ? 0 : spreadView.indexToZIndex(index)
                    onZIndexChanged: {
                        if (spreadView.nextInStack == model.index) {
                            spreadView.nextZInStack = zIndex;
                        }
                    }
                    selected: spreadView.selectedIndex == index
                    otherSelected: spreadView.selectedIndex >= 0 && !selected
                    isInSideStage: priv.sideStageItemId == model.id
                    interactive: !spreadView.interactive && spreadView.phase === 0 && root.interactive
                    swipeToCloseEnabled: spreadView.interactive && !snapAnimation.running
                    maximizedAppTopMargin: root.maximizedAppTopMargin
                    dragOffset: !isDash && model.id == priv.mainStageItemId && root.inverseProgress > 0
                            && spreadView.phase === 0 ? root.inverseProgress : 0
                    application: model.application
                    surface: model.surface
                    closeable: !isDash
                    highlightShown: root.altTabPressed && priv.highlightIndex == zIndex
                    dropShadow: spreadView.active || priv.focusedAppDelegateIsDislocated

                    readonly property bool wantsMainStage: stage == ApplicationInfoInterface.MainStage

                    readonly property bool isDash: application.appId == "unity8-dash"

                    onFocusChanged: {
                        if (focus && !spreadRepeater.startingUp) {
                            priv.focusedAppDelegate = spreadTile;
                            root.topLevelSurfaceList.raiseId(model.id);
                        }
                        if (focus && priv.sideStageEnabled && stage === ApplicationInfoInterface.SideStage) {
                            sideStage.show();
                        }
                    }
                    Connections {
                        target: model.surface
                        onFocusRequested: spreadTile.focus = true;
                    }
                    Connections {
                        target: spreadTile.application
                        onFocusRequested: {
                            if (!model.surface) {
                                // when an app has no surfaces, we assume there's only one entry representing it:
                                // this delegate.
                                spreadTile.focus = true;
                            } else {
                                // if the application has surfaces, focus request should be at surface-level.
                            }
                        }
                    }

                    fullscreen: {
                        if (priv.mainStageDelegate && stage === ApplicationInfoInterface.SideStage) {
                            return priv.mainStageDelegate.fullscreen;
                        } else if (surface) {
                            return surface.state === Mir.FullscreenState;
                        } else if (application) {
                            return application.fullscreen;
                        } else {
                            return false;
                        }
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

                    function saveStage(newStage) {
                        stage = newStage;
                        WindowStateStorage.saveStage(application.appId, newStage);
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

                    property bool _constructing: true;
                    onStageChanged: {
                        if (!_constructing) {
                            priv.updateMainAndSideStageIndexes();
                        }
                    }

                    Component.onCompleted: {
                        // a top level window is always the focused one when it first appears, unfocusing
                        // any preexisting one
                        focus = true;
                        refreshStage();
                        _constructing = false;
                    }

                    function refreshStage() {
                        var newStage = ApplicationInfoInterface.MainStage;
                        if (priv.sideStageEnabled) {
                            if (!isDash && application && application.supportedOrientations & (Qt.PortraitOrientation|Qt.InvertedPortraitOrientation)) {
                                newStage = WindowStateStorage.getStage(application.appId);
                            }
                        }

                        stage = newStage;
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
                                        if (priv.focusedAppDelegate === spreadTile &&
                                                priv.sideStageEnabled && !sideStage.shown) {
                                            // Sidestage was focused, so show the side stage.
                                            sideStage.show();
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
                                        if (priv.sideStageDelegate === spreadTile &&
                                                mainApp && (mainApp.supportedOrientations & (Qt.PortraitOrientation|Qt.InvertedPortraitOrientation)) == 0) {
                                            // The mainstage app did not natively support portrait orientation, so focus the sidestage.
                                            spreadTile.focus = true;
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
                        if (spreadTile.surface) {
                            spreadTile.surface.close();
                        } else if (spreadTile.application) {
                            root.applicationManager.stopApplication(spreadTile.application.appId);
                        } else {
                            // should never happen
                            console.warn("Can't close topLevelSurfaceList entry as it has neither"
                                         + " a surface nor an application");
                        }
                    }

                    Binding {
                        target: root
                        when: model.id == priv.mainStageItemId
                        property: "mainAppWindowOrientationAngle"
                        value: appWindowOrientationAngle
                    }
                    Binding {
                        target: priv
                        when: model.id == priv.mainStageItemId
                        property: "mainAppOrientationChangesEnabled"
                        value: orientationChangesEnabled
                    }

                    EasingCurve {
                        id: snappingCurve
                        type: EasingCurve.Linear
                        period: (spreadView.positionMarker2 - spreadView.positionMarker1) / 3
                        progress: spreadTile.progress - spreadView.positionMarker1
                    }

                    StagedFullscreenPolicy {
                        id: fullscreenPolicy
                        surface: model.surface
                    }
                    Connections {
                        target: root
                        onStageAboutToBeUnloaded: fullscreenPolicy.active = false
                    }
                }
            }
        }
    }

    TabletSideStageTouchGesture {
        id: triGestureArea
        anchors.fill: parent
        enabled: priv.sideStageEnabled && !spreadView.active

        property Item spreadDelegate

        dragComponent: dragComponent
        dragComponentProperties: { "spreadDelegate": spreadDelegate }

        onPressed: {
            function matchDelegate(obj) { return String(obj.objectName).indexOf("spreadDelegate") >= 0; }

            var delegateAtCenter = Functions.itemAt(spreadRow, x, y, matchDelegate);
            if (!delegateAtCenter) return;

            spreadDelegate = delegateAtCenter;
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
            SurfaceContainer {
                property Item spreadDelegate

                surface: spreadDelegate ? spreadDelegate.surface : null

                consumesInput: false
                interactive: false
                resizeSurface: false
                focus: false

                width: units.gu(40)
                height: units.gu(40)

                Drag.hotSpot.x: width/2
                Drag.hotSpot.y: height/2
                // only accept opposite stage.
                Drag.keys: {
                    if (!surface) return "Disabled";
                    if (spreadDelegate.isDash) return "Disabled";

                    if (spreadDelegate.stage === ApplicationInfo.MainStage) {
                        if (spreadDelegate.application.supportedOrientations
                                & (Qt.PortraitOrientation|Qt.InvertedPortraitOrientation)) {
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

    SwipeArea {
        id: spreadDragArea
        objectName: "spreadDragArea"
        x: parent.width - root.dragAreaWidth
        anchors { top: parent.top; bottom: parent.bottom }
        width: root.dragAreaWidth
        direction: Direction.Leftwards
        enabled: (spreadView.phase != 2 && root.spreadEnabled) || dragging

        property var gesturePoints: new Array()

        onTouchPositionChanged: {
            if (!dragging) {
                spreadView.phase = 0;
                spreadView.contentX = -spreadView.shift;
            }

            if (dragging) {
                var dragX = -touchPosition.x + spreadDragArea.width - spreadView.shift;
                var maxDrag = spreadView.width * spreadView.positionMarker4 - spreadView.shift;
                spreadView.contentX = Math.min(dragX, maxDrag);
            }
            gesturePoints.push(touchPosition.x);
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
