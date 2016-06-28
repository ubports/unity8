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
import Unity.Application 0.1
import "../Components/PanelState"
import "../Components"
import Utils 0.1
import Ubuntu.Gestures 0.1
import GlobalShortcut 1.0

AbstractStage {
    id: root
    anchors.fill: parent
    paintBackground: false

    // functions to be called from outside
    function updateFocusedAppOrientation() { /* TODO */ }
    function updateFocusedAppOrientationAnimated() { /* TODO */}
    function pushRightEdge(amount) {
        if (spread.state === "") {
            edgeBarrier.push(amount);
        }
    }

    property string mode: "staged"

    // Used by TutorialRight
    property bool spreadShown: state == "altTab"

    mainApp: priv.focusedAppDelegate ? priv.focusedAppDelegate.application : null

    // application windows never rotate independently
    mainAppWindowOrientationAngle: shellOrientationAngle

    orientationChangesEnabled: true

    GlobalShortcut {
        id: closeWindowShortcut
        shortcut: Qt.AltModifier|Qt.Key_F4
        onTriggered: { if (priv.focusedAppDelegate) { priv.focusedAppDelegate.close(); } }
        active: priv.focusedAppDelegate !== null
    }

    GlobalShortcut {
        id: showSpreadShortcut
        shortcut: Qt.MetaModifier|Qt.Key_W
        onTriggered: state = "altTab"
    }

    GlobalShortcut {
        id: minimizeAllShortcut
        shortcut: Qt.MetaModifier|Qt.ControlModifier|Qt.Key_D
        onTriggered: priv.minimizeAllWindows()
    }

    GlobalShortcut {
        id: maximizeWindowShortcut
        shortcut: Qt.MetaModifier|Qt.ControlModifier|Qt.Key_Up
        onTriggered: priv.focusedAppDelegate.maximize()
        active: priv.focusedAppDelegate !== null
    }

    GlobalShortcut {
        id: maximizeWindowLeftShortcut
        shortcut: Qt.MetaModifier|Qt.ControlModifier|Qt.Key_Left
        onTriggered: priv.focusedAppDelegate.maximizeLeft()
        active: priv.focusedAppDelegate !== null
    }

    GlobalShortcut {
        id: maximizeWindowRightShortcut
        shortcut: Qt.MetaModifier|Qt.ControlModifier|Qt.Key_Right
        onTriggered: priv.focusedAppDelegate.maximizeRight()
        active: priv.focusedAppDelegate !== null
    }

    GlobalShortcut {
        id: minimizeRestoreShortcut
        shortcut: Qt.MetaModifier|Qt.ControlModifier|Qt.Key_Down
        onTriggered: priv.focusedAppDelegate.maximized || priv.focusedAppDelegate.maximizedLeft || priv.focusedAppDelegate.maximizedRight ||
                     priv.focusedAppDelegate.maximizedHorizontally || priv.focusedAppDelegate.maximizedVertically
                     ? priv.focusedAppDelegate.restoreFromMaximized() : priv.focusedAppDelegate.minimize()
        active: priv.focusedAppDelegate !== null
    }

    GlobalShortcut {
        shortcut: Qt.AltModifier|Qt.Key_Print
        onTriggered: root.itemSnapshotRequested(priv.focusedAppDelegate)
        active: priv.focusedAppDelegate !== null
    }

    Connections {
        target: root.topLevelSurfaceList
        onCountChanged: {
            if (root.state == "spread") {
                priv.goneToSpread = false;
            }
        }
    }

    QtObject {
        id: priv
        objectName: "DesktopStagePrivate"

        property var focusedAppDelegate: null
        onFocusedAppDelegateChanged: {
            print("focusedAppDelegate changed", focusedAppDelegate.objectName)
            if (root.state == "spread") {
                goneToSpread = false;
            }
        }

        property var foregroundMaximizedAppDelegate: null // for stuff like drop shadow and focusing maximized app by clicking panel

        property bool goneToSpread: false
        property int animationDuration: UbuntuAnimation.FastDuration// 4000//UbuntuAnimation.SleepyDuration

        function updateForegroundMaximizedApp() {
            var found = false;
            for (var i = 0; i < appRepeater.count && !found; i++) {
                var item = appRepeater.itemAt(i);
                if (item && item.visuallyMaximized) {
                    foregroundMaximizedAppDelegate = item;
                    found = true;
                }
            }
            if (!found) {
                foregroundMaximizedAppDelegate = null;
            }
        }

        function minimizeAllWindows() {
            for (var i = 0; i < appRepeater.count; i++) {
                var appDelegate = appRepeater.itemAt(i);
                if (appDelegate && !appDelegate.minimized) {
                    appDelegate.minimize();
                }
            }
        }

        function focusNext() {
            for (var i = 0; i < appRepeater.count; i++) {
                var appDelegate = appRepeater.itemAt(i);
                if (appDelegate && !appDelegate.minimized) {
                    print("***** focusing because of focusNext() call", appDelegate.application.appId)
                    appDelegate.focus = true;
                    return;
                }
            }
        }
    }

    Connections {
        target: PanelState
        onCloseClicked: { if (priv.focusedAppDelegate) { priv.focusedAppDelegate.close(); } }
        onMinimizeClicked: { if (priv.focusedAppDelegate) { priv.focusedAppDelegate.minimize(); } }
        onRestoreClicked: { if (priv.focusedAppDelegate) { priv.focusedAppDelegate.restoreFromMaximized(); } }
        onFocusMaximizedApp: {
            if (priv.foregroundMaximizedAppDelegate) {
                print("***** focusing because of Panel request", model.application.appId)
                priv.foregroundMaximizedAppDelegate.focus = true;
             }
        }
    }

    Binding {
        target: PanelState
        property: "buttonsVisible"
        value: priv.focusedAppDelegate !== null && priv.focusedAppDelegate.maximized // FIXME for Locally integrated menus
               && spread.state == ""
    }

    Binding {
        target: PanelState
        property: "title"
        value: {
//            if (priv.focusedAppDelegate !== null && spread.state == "") {
//                if (priv.focusedAppDelegate.maximized)
//                    return priv.focusedAppDelegate.title
//                else
//                    return priv.focusedAppDelegate.appName
//            }
            return ""
        }
        when: priv.focusedAppDelegate
    }

    Binding {
        target: PanelState
        property: "dropShadow"
        value: priv.focusedAppDelegate && !priv.focusedAppDelegate.maximized && priv.foregroundMaximizedAppDelegate !== null
    }

    Binding {
        target: PanelState
        property: "closeButtonShown"
        value: priv.focusedAppDelegate && priv.focusedAppDelegate.maximized && priv.focusedAppDelegate.application.appId !== "unity8-dash"
    }

    Component.onDestruction: {
        PanelState.title = "";
        PanelState.buttonsVisible = false;
        PanelState.dropShadow = false;
    }

    Instantiator {
        model: root.applicationManager
        delegate: Binding {
            target: model.application
            property: "requestedState"

            // TODO: figure out some lifecycle policy, like suspending minimized apps
            //       if running on a tablet or something.
            // TODO: If the device has a dozen suspended apps because it was running
            //       in staged mode, when it switches to Windowed mode it will suddenly
            //       resume all those apps at once. We might want to avoid that.
            value: ApplicationInfoInterface.RequestedRunning // Always running for now
        }
    }

    Binding {
        target: MirFocusController
        property: "focusedSurface"
        value: priv.focusedAppDelegate ? priv.focusedAppDelegate.surface : null
        when: !appRepeater.startingUp && root.parent
    }

    states: [
        State {
            name: "spread"; when: root.altTabPressed || priv.goneToSpread
        },
        State {
            name: "stagedrightedge"; when: rightEdgeDragArea.dragging && root.mode == "staged"
        },
        State {
            name: "windowedrightedge"; when: rightEdgeDragArea.dragging && root.mode == "windowed"
        },
        State {
            name: "staged"; when: root.mode === "staged"
        },
        State {
            name: "windowed"; when: root.mode === "windowed"
        }
    ]
    onStateChanged: print("spread going to state:", state)

    FocusScope {
        id: appContainer
        objectName: "appContainer"
        anchors.fill: parent
        focus: root.state !== "altTab"

        CrossFadeImage {
            id: wallpaper
            anchors.fill: parent
            source: root.background
            sourceSize { height: root.height; width: root.width }
            fillMode: Image.PreserveAspectCrop
        }

        TopLevelSurfaceRepeater {
            id: appRepeater
            model: topLevelSurfaceList
            objectName: "appRepeater"

            delegate: FocusScope {
                id: appDelegate
                objectName: "appDelegate_" + model.id
                // z might be overriden in some cases by effects, but we need z ordering
                // to calculate occlusion detection
                property int normalZ: topLevelSurfaceList.count - index
                onNormalZChanged: {
                    if (visuallyMaximized) {
                        priv.updateForegroundMaximizedApp();
                    }
                }
                z: normalZ
                x: priv.focusedAppDelegate ? priv.focusedAppDelegate.x + units.gu(3) : (normalZ - 1) * units.gu(3)
                y: priv.focusedAppDelegate ? priv.focusedAppDelegate.y + units.gu(3) : normalZ * units.gu(3)

                width: decoratedWindow.implicitWidth
                height: decoratedWindow.implicitHeight

                Connections {
                    target: root
                    onShellOrientationAngleChanged: {
                        // at this point decoratedWindow.surfaceOrientationAngle is the old shellOrientationAngle
                        if (application && application.rotatesWindowContents) {
                            if (state == "normal") {
                                var angleDiff = decoratedWindow.surfaceOrientationAngle - shellOrientationAngle;
                                angleDiff = (360 + angleDiff) % 360;
                                if (angleDiff === 90 || angleDiff === 270) {
                                    var aux = decoratedWindow.requestedHeight;
                                    decoratedWindow.requestedHeight = decoratedWindow.requestedWidth + decoratedWindow.visibleDecorationHeight;
                                    decoratedWindow.requestedWidth = aux - decoratedWindow.visibleDecorationHeight;
                                }
                            }
                            decoratedWindow.surfaceOrientationAngle = shellOrientationAngle;
                        } else {
                            decoratedWindow.surfaceOrientationAngle = 0;
                        }
                    }
                }

                readonly property alias application: decoratedWindow.application
                readonly property alias minimumWidth: decoratedWindow.minimumWidth
                readonly property alias minimumHeight: decoratedWindow.minimumHeight
                readonly property alias maximumWidth: decoratedWindow.maximumWidth
                readonly property alias maximumHeight: decoratedWindow.maximumHeight
                readonly property alias widthIncrement: decoratedWindow.widthIncrement
                readonly property alias heightIncrement: decoratedWindow.heightIncrement

                property int requestedWidth: -1
                property int requestedHeight: -1

                readonly property bool maximized: windowState & WindowStateStorage.WindowStateMaximized
                readonly property bool maximizedLeft: windowState & WindowStateStorage.WindowStateMaximizedLeft
                readonly property bool maximizedRight: windowState & WindowStateStorage.WindowStateMaximizedRight
                readonly property bool maximizedHorizontally: windowState & WindowStateStorage.WindowStateMaximizedHorizontally
                readonly property bool maximizedVertically: windowState & WindowStateStorage.WindowStateMaximizedVertically
                readonly property bool minimized: windowState & WindowStateStorage.WindowStateMinimized
                readonly property alias fullscreen: decoratedWindow.fullscreen

                property int windowState: WindowStateStorage.WindowStateNormal
                property bool animationsEnabled: true
                property alias title: decoratedWindow.title
                readonly property string appName: model.application ? model.application.name : ""
                property bool visuallyMaximized: false
                property bool visuallyMinimized: false

                readonly property var surface: model.surface
                readonly property alias resizeArea: resizeArea

                function claimFocus() {
//                    if (spread.state == "altTab") {
//                        spread.cancel();
//                    }
//                    appDelegate.restore();
                }
                Connections {
                    target: model.surface
                    onFocusRequested: {
                        print("model surface requesting focus", model.application.appId)
                        claimFocus();
                    }
                }
                Connections {
                    target: model.application
                    onFocusRequested: {
                        if (!model.surface) {
                            // when an app has no surfaces, we assume there's only one entry representing it:
                            // this delegate.
                            claimFocus();
                        } else {
                            // if the application has surfaces, focus request should be at surface-level.
                        }
                    }
                }

//                Timer {
//                    interval: 1000
//                    repeat: true
//                    running: index == 0
//                    onTriggered: print("index", index, "focused:", appDelegate.focus, "x", appDelegate.x, "state", appDelegate.state)
//                }

                onFocusChanged: {
                    if (appRepeater.startingUp)
                        return;

                    if (focus) {
                        print("app surface gained focus:", model.application.appId)
                        print("setting focusedAppDelegate to", appDelegate.application.appId)
                        print("raising surface in model", model.id)
                        topLevelSurfaceList.raiseId(model.id);
                        priv.focusedAppDelegate = appDelegate;
                        topLevelSurfaceList.raiseId(model.id);
                    } else if (!focus && priv.focusedAppDelegate === appDelegate) {
                        priv.focusedAppDelegate = null;
                        // FIXME: No idea why the Binding{} doens't update when focusedAppDelegate turns null
                        MirFocusController.focusedSurface = null;
                    }
                }
                Component.onCompleted: {
                    if (application && application.rotatesWindowContents) {
                        decoratedWindow.surfaceOrientationAngle = shellOrientationAngle;
                    } else {
                        decoratedWindow.surfaceOrientationAngle = 0;
                    }

                    // NB: We're differentiating if this delegate was created in response to a new entry in the model
                    //     or if the Repeater is just populating itself with delegates to match the model it received.
                    if (!appRepeater.startingUp) {
                        // a top level window is always the focused one when it first appears, unfocusing
                        // any preexisting one
                        print("***** focusing after starting up", model.application.appId)
                        focus = true;
                    }
                }
                Component.onDestruction: {
                    if (!root.parent) {
                        // This stage is about to be destroyed. Don't mess up with the model at this point
                        return;
                    }

                    if (visuallyMaximized) {
                        priv.updateForegroundMaximizedApp();
                    }

                    if (focus) {
                        // focus some other window
                        for (var i = 0; i < appRepeater.count; i++) {
                            var appDelegate = appRepeater.itemAt(i);
                            if (appDelegate && !appDelegate.minimized && i != index) {
                                print("***** focusing because of previously focused window disappeared", appDelegate.application.appId)
                                appDelegate.focus = true;
                                return;
                            }
                        }
                    }
                }

                onVisuallyMaximizedChanged: priv.updateForegroundMaximizedApp()

//                visible: (
//                          !visuallyMinimized
//                          && !greeter.fullyShown
//                          && (priv.foregroundMaximizedAppDelegate === null || priv.foregroundMaximizedAppDelegate.normalZ <= z)
//                         )
//                         || decoratedWindow.fullscreen
//                       //  || (root.state == "altTab" && index === spread.highlightedIndex)

                function close() {
                    model.surface.close();
                }

                function maximize(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    windowState = WindowStateStorage.WindowStateMaximized;
                }
                function maximizeLeft(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    windowState = WindowStateStorage.WindowStateMaximizedLeft;
                }
                function maximizeRight(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    windowState = WindowStateStorage.WindowStateMaximizedRight;
                }
                function maximizeHorizontally(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    windowState = WindowStateStorage.WindowStateMaximizedHorizontally;
                }
                function maximizeVertically(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    windowState = WindowStateStorage.WindowStateMaximizedVertically;
                }
                function minimize(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    windowState |= WindowStateStorage.WindowStateMinimized; // add the minimized bit
                }
                function restoreFromMaximized(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    windowState = WindowStateStorage.WindowStateNormal;
                }
                function restore(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    windowState &= ~WindowStateStorage.WindowStateMinimized; // clear the minimized bit
                    if (maximized)
                        maximize();
                    else if (maximizedLeft)
                        maximizeLeft();
                    else if (maximizedRight)
                        maximizeRight();
                    else if (maximizedHorizontally)
                        maximizeHorizontally();
                    else if (maximizedVertically)
                        maximizeVertically();

                    print("***** focusing because of window restore", model.application.appId)
                    focus = true;
                }

                function playFocusAnimation() {
                    if (state == "stagedrightedge") {
                        rightEdgeFocusAnimation.start()
                    } else {
                        focusAnimation.start()
                    }
                }
                function playHidingAnimation() {
                    hidingAnimation.start()
                }

                UbuntuNumberAnimation {
                    id: focusAnimation
                    target: appDelegate
                    property: "scale"
                    from: 0.98
                    to: 1
                    duration: UbuntuAnimation.SnapDuration
                }
                ParallelAnimation {
                    id: rightEdgeFocusAnimation
                    UbuntuNumberAnimation { target: appDelegate; properties: "x"; to: 0; duration: priv.animationDuration }
                    UbuntuNumberAnimation { target: decoratedWindow; properties: "angle"; to: 0; duration: priv.animationDuration }
                    onStopped: appDelegate.focus = true
                }
                ParallelAnimation {
                    id: hidingAnimation
                    UbuntuNumberAnimation { target: appDelegate; property: "opacity"; to: 0; duration: priv.animationDuration }
                    onStopped: appDelegate.opacity = 1
                }

                SpreadMaths {
                    id: spreadMaths
                    itemIndex: index
                    totalItems: appRepeater.count
                    flickable: floatingFlickable
                }
                StagedRightEdgeMaths {
                    id: stagedRightEdgeMaths
                    itemIndex: index
                    sceneWidth: appContainer.width - root.leftMargin
                    sceneHeight: appContainer.height
                    progress: 0
                    targetX: spreadMaths.animatedX
                    targetAngle: spreadMaths.animatedAngle
                }

//                onXChanged: if (model.application.appId == "unity8-dash") print("dash moved to", x)
//                onRequestedWidthChanged: if (index == 0) print("requestedWidth", requestedWidth)
                onStateChanged: if (model.application.appId == "unity8-dash") print("state changed", state)
                states: [
                    State {
                        name: "spread"; when: root.state == "spread"
                        PropertyChanges {
                            target: appDelegate;
                            x: spreadMaths.animatedX
                            y: spreadMaths.animatedY
                            z: index
                            height: decoratedWindow.height + windowInfoItem.height + units.gu(2)
                            requestedWidth: decoratedWindow.oldRequestedWidth
                            requestedHeight: decoratedWindow.oldRequestedHeight
                        }
                        PropertyChanges {
                            target: decoratedWindow;
                            showDecoration: false;
                            height: units.gu(40)
                            width: units.gu(40)
                            angle: spreadMaths.animatedAngle
                        }
                        PropertyChanges { target: inputBlocker; enabled: true }
                        PropertyChanges { target: windowInfoItem; opacity: 1 }
                        PropertyChanges { target: floatingFlickable; enabled: true }
                    },
                    State {
                        name: "stagedrightedge";
                        when: root.state == "stagedrightedge" || rightEdgeFocusAnimation.running || hidingAnimation.running
                        PropertyChanges {
                            target: stagedRightEdgeMaths
                            progress: rightEdgeDragArea.progress
                        }
                        PropertyChanges {
                            target: appDelegate
                            y: PanelState.panelHeight
                            x: stagedRightEdgeMaths.animatedX
                            z: index +1
                        }
                        PropertyChanges {
                            target: decoratedWindow;
                            showDecoration: false
                            requestedWidth: stagedRightEdgeMaths.animatedWidth
                            requestedHeight: stagedRightEdgeMaths.animatedHeight - PanelState.panelHeight
//                            width: appContainer.width - root.leftMargin
//                            height: appContainer.height
                            angle: stagedRightEdgeMaths.animatedAngle
                        }
                    },
                    State {
                        name: "staged"; when: root.state == "staged"
                        PropertyChanges {
                            target: appDelegate
                            x: appDelegate.focus ? 0 : root.width
                            y: appDelegate.fullscreen ? 0 : PanelState.panelHeight
                            requestedWidth: appContainer.width
                            requestedHeight: appContainer.height - PanelState.panelHeight
                            visuallyMaximized: true
                        }
                        PropertyChanges {
                            target: decoratedWindow
                            showDecoration: false
                        }
                        PropertyChanges {
                            target: resizeArea
                            enabled: false
                        }
                    },
                    State {
                        name: "maximized"; when: root.state === "windowed" && appDelegate.maximized && !appDelegate.minimized
                        PropertyChanges {
                            target: appDelegate;
                            x: root.leftMargin;
                            y: 0;
                            visuallyMinimized: false;
                            visuallyMaximized: true
                            requestedWidth: appContainer.width - root.leftMargin;
                            requestedHeight: appContainer.height;
                        }
                    },
                    State {
                        name: "fullscreen"; when: decoratedWindow.fullscreen && !appDelegate.minimized
                        PropertyChanges {
                            target: appDelegate;
                            x: rotation == 0 ? 0 : (parent.width - width) / 2 + (shellOrientationAngle == 90 ? -PanelState.panelHeight : PanelState.panelHeight)
                            y: rotation == 0 ? -PanelState.panelHeight : (parent.height - height) / 2
                            requestedWidth: appContainer.width;
                            requestedHeight: appContainer.height;
                        }
                    },
                    State {
                        name: "normal";
                        when: appDelegate.windowState == WindowStateStorage.WindowStateNormal
                        PropertyChanges {
                            target: appDelegate;
                            visuallyMinimized: false;
                            visuallyMaximized: false;
                        }
                    },
                    State {
                        name: "maximizedLeft"; when: appDelegate.maximizedLeft && !appDelegate.minimized
                        PropertyChanges {
                            target: appDelegate
                            x: root.leftMargin
                            y: PanelState.panelHeight
                        }
                        PropertyChanges {
                            target: decoratedWindow
                            requestedWidth: (appContainer.width - root.leftMargin)/2
                            requestedHeight: appContainer.height - PanelState.panelHeight
                        }
                    },
                    State {
                        name: "maximizedRight"; when: appDelegate.maximizedRight && !appDelegate.minimized
                        PropertyChanges {
                            target: appDelegate;
                            x: (appContainer.width + root.leftMargin)/2
                            y: PanelState.panelHeight
                        }
                        PropertyChanges {
                            target: decoratedWindow
                            requestedWidth: (appContainer.width - root.leftMargin)/2
                            requestedHeight: appContainer.height - PanelState.panelHeight
                        }
                    },
                    State {
                        name: "maximizedHorizontally"; when: appDelegate.maximizedHorizontally && !appDelegate.minimized
                        PropertyChanges { target: appDelegate; x: root.leftMargin }
                        PropertyChanges { target: decoratedWindow; requestedWidth: appContainer.width - root.leftMargin }
                    },
                    State {
                        name: "maximizedVertically"; when: appDelegate.maximizedVertically && !appDelegate.minimized
                        PropertyChanges { target: appDelegate; y: PanelState.panelHeight }
                        PropertyChanges { target: decoratedWindow; requestedHeight: appContainer.height - PanelState.panelHeight }
                    },
                    State {
                        name: "minimized"; when: appDelegate.minimized
                        PropertyChanges {
                            target: appDelegate;
                            x: -appDelegate.width / 2;
                            scale: units.gu(5) / appDelegate.width;
                            opacity: 0;
                            visuallyMinimized: true;
                            visuallyMaximized: false
                        }
                    }

                ]
                transitions: [
                    Transition {
                        to: "normal"
                        enabled: appDelegate.animationsEnabled
                        PropertyAction { target: appDelegate; properties: "visuallyMinimized,visuallyMaximized" }
                        UbuntuNumberAnimation { target: appDelegate; properties: "x,y,opacity,requestedWidth,requestedHeight,scale"; duration: priv.animationDuration }
                    },
                    Transition {
                        to: "minimized"
                        enabled: appDelegate.animationsEnabled
                        PropertyAction { target: appDelegate; property: "visuallyMaximized" }
                        SequentialAnimation {
                            ParallelAnimation {
                                UbuntuNumberAnimation { target: appDelegate; properties: "x,y,opacity,scale"; duration: priv.animationDuration }
                                UbuntuNumberAnimation { target: decoratedWindow; properties: "requestedWidth,requestedHeight"; duration: priv.animationDuration }
                            }
                            PropertyAction { target: appDelegate; property: "visuallyMinimized" }
                            ScriptAction {
                                script: {
                                    if (appDelegate.minimized) {
                                        appDelegate.focus = false;
                                        priv.focusNext();
                                    }
                                }
                            }
                        }
                    },
                    Transition {
                        to: "maximized,fullscreen"
                        enabled: appDelegate.animationsEnabled
                        SequentialAnimation {
                            PropertyAction { target: appDelegate; property: "visuallyMinimized" }
                            ParallelAnimation {
                                UbuntuNumberAnimation { target: appDelegate; properties: "x,y,opacity,scale,requestedWidth,requestedHeight"; duration: UbuntuAnimation.FastDuration }
                            }
                            PropertyAction { target: appDelegate; property: "visuallyMaximized" }
                        }
                    },
                    Transition {
                        to: "spread"
                        PropertyAnimation { target: appDelegate; properties: "x,y,height"; duration: priv.animationDuration }
                        PropertyAnimation { target: decoratedWindow; properties: "width,height,angle"; duration: priv.animationDuration }
                    },
                    Transition {
                        from: "spread"; to: "staged,normal"
                        PropertyAnimation { target: appDelegate; properties: "x,y,height"; duration: priv.animationDuration }
                        PropertyAnimation { target: decoratedWindow; properties: "angle,width,height"; duration: priv.animationDuration }
                    },
                    Transition {
                        from: "normal"; to: "staged";
                        PropertyAnimation { target: appDelegate; properties: "x,y,requestedWidth,requestedHeight"; duration: priv.animationDuration }
                    },
                    Transition {
                        to: "staged"
                        PropertyAnimation { target: appDelegate; properties: "x,y"; duration: priv.animationDuration }
                        PropertyAnimation { target: appDelegate; properties: "requestedWidth,requestedHeight"; duration: priv.animationDuration }
                    }

                ]

//                Binding {
//                    id: previewBinding
//                    target: appDelegate
//                    property: "z"
//                    value: topLevelSurfaceList.count + 1
//                    when: index == spread.highlightedIndex
//                }

                Binding {
                    target: PanelState
                    property: "buttonsAlwaysVisible"
                    value: appDelegate && appDelegate.maximized && touchControls.overlayShown
                }

                WindowResizeArea {
                    id: resizeArea
                    objectName: "windowResizeArea"

                    // workaround so that it chooses the correct resize borders when you drag from a corner ResizeGrip
                    anchors.margins: touchControls.overlayShown ? borderThickness/2 : -borderThickness

                    target: appDelegate
                    minWidth: units.gu(10)
                    minHeight: units.gu(10)
                    borderThickness: units.gu(2)
                    windowId: model.application.appId // FIXME: Change this to point to windowId once we have such a thing
                    screenWidth: appContainer.width
                    screenHeight: appContainer.height
                    leftMargin: root.leftMargin

                    onPressed: {
                        print("***** focusing because of resize area press", model.application.appId)
                        appDelegate.focus = true;
                    }

                    Component.onCompleted: {
                        loadWindowState();
                    }

                    property bool saveStateOnDestruction: true
                    Connections {
                        target: root
                        onStageAboutToBeUnloaded: {
                            resizeArea.saveWindowState();
                            resizeArea.saveStateOnDestruction = false;
                            fullscreenPolicy.active = false;
                        }
                    }
                    Component.onDestruction: {
                        if (saveStateOnDestruction) {
                            saveWindowState();
                        }
                    }
                }

                DecoratedWindow {
                    id: decoratedWindow
                    objectName: "decoratedWindow"
                    anchors.left: appDelegate.left
                    anchors.top: appDelegate.top
                    application: model.application
                    surface: model.surface
                    active: appDelegate.focus
                    focus: true
                    showDecoration: true
                    overlayShown: touchControls.overlayShown
                    width: implicitWidth
                    height: implicitHeight

                    requestedWidth: appDelegate.requestedWidth
                    requestedHeight: appDelegate.requestedHeight

                    property int oldRequestedWidth: -1
                    property int oldRequestedHeight: -1

                    onRequestedWidthChanged: oldRequestedWidth = requestedWidth
                    onRequestedHeightChanged: oldRequestedHeight = requestedHeight

                    onCloseClicked: { appDelegate.close(); }
                    onMaximizeClicked: appDelegate.maximized || appDelegate.maximizedLeft || appDelegate.maximizedRight
                                       || appDelegate.maximizedHorizontally || appDelegate.maximizedVertically
                                       ? appDelegate.restoreFromMaximized() : appDelegate.maximize()
                    onMaximizeHorizontallyClicked: appDelegate.maximizedHorizontally ? appDelegate.restoreFromMaximized() : appDelegate.maximizeHorizontally()
                    onMaximizeVerticallyClicked: appDelegate.maximizedVertically ? appDelegate.restoreFromMaximized() : appDelegate.maximizeVertically()
                    onMinimizeClicked: appDelegate.minimize()
                    onDecorationPressed: { appDelegate.focus = true; }

                    property real angle: 0
                    property real itemScale: 1
                    transform: [
//                        Scale {
//                            origin.x: itemScaleOriginX
//                            origin.y: itemScaleOriginY
//                            xScale: itemScale
//                            yScale: itemScale
//                        },
                        Rotation {
                            origin { x: 0; y: (decoratedWindow.height - (decoratedWindow.height * decoratedWindow.itemScale / 2)) }
                            axis { x: 0; y: 1; z: 0 }
                            angle: decoratedWindow.angle
                        }
                    ]
                }

                WindowControlsOverlay {
                    id: touchControls
                    anchors.fill: appDelegate
                    target: appDelegate
                }

                WindowedFullscreenPolicy {
                    id: fullscreenPolicy
                    active: true
                    surface: model.surface
                }

                MouseArea {
                    id: inputBlocker
                    anchors.fill: parent
                    enabled: false
                    onPressed: mouse.accepted = true;
                    onClicked: {
                        print("focusing because of inputBlocker click")
                        appDelegate.focus = true
                        priv.goneToSpread = false;
                    }
                }
//                Rectangle {
//                    anchors.fill: parent
//                    color: "blue"
//                    opacity: .4
//                }

                WindowInfoItem {
                    id: windowInfoItem
                    anchors { left: parent.left; bottom: parent.bottom }
                    title: decoratedWindow.title
                    iconSource: model.application.icon
                    opacity: 0
                    visible: opacity > 0
                    Behavior on opacity { UbuntuNumberAnimation { duration: priv.animationDuration } }
                }
            }
        }
    }

    EdgeBarrier {
        id: edgeBarrier

        // NB: it does its own positioning according to the specified edge
        edge: Qt.RightEdge

        onPassed: { spread.show(); }
        material: Component {
            Item {
                Rectangle {
                    width: parent.height
                    height: parent.width
                    rotation: 90
                    anchors.centerIn: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(0.16,0.16,0.16,0.5)}
                        GradientStop { position: 1.0; color: Qt.rgba(0.16,0.16,0.16,0)}
                    }
                }
            }
        }
    }

    FloatingFlickable {
        id: floatingFlickable
        anchors.fill: parent
        enabled: false

        property int minContentWidth: 6 * Math.min(height / 4, width / 5)
        contentWidth: Math.max(6, appRepeater.count) * Math.min(height / 4, width / 5)

    }

    PropertyAnimation {
        id: shortRightEdgeSwipeAnimation
        property: "x"
        to: 0
        duration: priv.animationDuration
    }

    SwipeArea {
        id: rightEdgeDragArea
        direction: Direction.Leftwards
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: root.dragAreaWidth

        property var gesturePoints: new Array()

        property real progress: -touchPosition.x / root.width
        onProgressChanged: print("dda progress", progress, root.width, touchPosition.x, root.width + touchPosition.x)

//        Rectangle { color: "blue"; anchors.fill: parent }
        onTouchPositionChanged: {
            if (dragging) {
                // Gesture recognized. Let's move the spreadView with the finger
//                var dragX = Math.min(touchX + width, width); // Prevent dragging rightwards
//                dragX = -dragX + spreadDragArea.width - spreadView.shift;
//                // Don't allow dragging further than the animation crossing with phase2's animation
//                var maxMovement =  spreadView.width * spreadView.positionMarker4 - spreadView.shift;

//                spreadView.contentX = Math.min(dragX, maxMovement);
            } else {
//                // Initial touch. Let's reset the spreadView to the starting position.
//                spreadView.phase = 0;
//                spreadView.contentX = -spreadView.shift;
            }

            gesturePoints.push(touchPosition.x);
        }

        onDraggingChanged: {
            print("dda dragging changed", dragging)
            if (dragging) {
                // A potential edge-drag gesture has started. Start recording it
                gesturePoints = [];
            } else {
                if (gesturePoints[gesturePoints.length - 1] < -root.width / 2) {
                    priv.goneToSpread = true;
                } else {
                    appRepeater.itemAt(0).playHidingAnimation()
                    appRepeater.itemAt(1).playFocusAnimation()
                }

//                // Ok. The user released. Find out if it was a one-way movement.
//                var oneWayFlick = true;
//                var smallestX = spreadDragArea.width;
//                for (var i = 0; i < gesturePoints.length; i++) {
//                    if (gesturePoints[i] >= smallestX) {
//                        oneWayFlick = false;
//                        break;
//                    }
//                    smallestX = gesturePoints[i];
//                }
//                gesturePoints = [];

//                if (oneWayFlick && spreadView.shiftedContentX > units.gu(2) &&
//                        spreadView.shiftedContentX < spreadView.positionMarker1 * spreadView.width) {
//                    // If it was a short one-way movement, do the Alt+Tab switch
//                    // no matter if we didn't cross positionMarker1 yet.
//                    spreadView.snapTo(1);
//                } else if (!dragging) {
//                    // otherwise snap to the closest snap position we can find
//                    // (might be back to start, to app 1 or to spread)
//                    spreadView.snap();
//                }
            }
        }
    }

//    DesktopSpread {
//        id: spread
//        objectName: "spread"
//        anchors.fill: appContainer
//        workspace: appContainer
//        focus: state == "altTab"
//        altTabPressed: root.altTabPressed

//        onPlayFocusAnimation: {
//            appRepeater.itemAt(index).playFocusAnimation();
//        }
//    }
}
