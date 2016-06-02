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
        onTriggered: priv.focusedAppDelegate.maximized || priv.focusedAppDelegate.maximizedLeft || priv.focusedAppDelegate.maximizedRight
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
        property int animationDuration: UbuntuAnimation.SleepyDuration

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
        onClose: { if (priv.focusedAppDelegate) { priv.focusedAppDelegate.close(); } }
        onMinimize: { if (priv.focusedAppDelegate) { priv.focusedAppDelegate.minimize(); } }
        onMaximize: { if (priv.focusedAppDelegate) { priv.focusedAppDelegate.restoreFromMaximized(); } }
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
        focus: spread.state !== "altTab"

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
                property int requestedWidth: -1
                property int requestedHeight: -1
                property alias minimumWidth: decoratedWindow.minimumWidth
                property alias minimumHeight: decoratedWindow.minimumHeight
                property alias maximumWidth: decoratedWindow.maximumWidth
                property alias maximumHeight: decoratedWindow.maximumHeight
                property alias widthIncrement: decoratedWindow.widthIncrement
                property alias heightIncrement: decoratedWindow.heightIncrement

                QtObject {
                    id: appDelegatePrivate
                    property bool maximized: false
                    property bool maximizedLeft: false
                    property bool maximizedRight: false
                    property bool minimized: false
                }
                readonly property alias maximized: appDelegatePrivate.maximized
                readonly property alias maximizedLeft: appDelegatePrivate.maximizedLeft
                readonly property alias maximizedRight: appDelegatePrivate.maximizedRight
                readonly property alias minimized: appDelegatePrivate.minimized
                readonly property alias fullscreen: decoratedWindow.fullscreen

                readonly property var application: model.application
                property bool animationsEnabled: true
                property alias title: decoratedWindow.title
                readonly property string appName: model.application ? model.application.name : ""
                property bool visuallyMaximized: false
                property bool visuallyMinimized: false

                readonly property var surface: model.surface

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

                onFocusChanged: {
                    if (appRepeater.startingUp)
                        return;

                    if (focus) {
                        print("app surface gained focus:", model.application.appId)
                        print("setting focusedAppDelegate to", appDelegate.application.appId)
                        priv.focusedAppDelegate = appDelegate;

                        // If we're orphan (!parent) it means this stage is no longer the current one
                        // and will be deleted shortly. So we should no longer have a say over the model
                        if (root.parent) {
                            print("raising surface in model", model.id)
                            topLevelSurfaceList.raiseId(model.id);
                        }
                    } else if (!focus && priv.focusedAppDelegate === appDelegate) {
                        priv.focusedAppDelegate = null;
                        // FIXME: No idea why the Binding{} doens't update when focusedAppDelegate turns null
                        MirFocusController.focusedSurface = null;
                    }
                }
                Component.onCompleted: {
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
                    appDelegatePrivate.minimized = false;
                    appDelegatePrivate.maximized = true;
                    appDelegatePrivate.maximizedLeft = false;
                    appDelegatePrivate.maximizedRight = false;
                }
                function maximizeLeft() {
                    appDelegatePrivate.minimized = false;
                    appDelegatePrivate.maximized = false;
                    appDelegatePrivate.maximizedLeft = true;
                    appDelegatePrivate.maximizedRight = false;
                }
                function maximizeRight() {
                    appDelegatePrivate.minimized = false;
                    appDelegatePrivate.maximized = false;
                    appDelegatePrivate.maximizedLeft = false;
                    appDelegatePrivate.maximizedRight = true;
                }
                function minimize(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    appDelegatePrivate.minimized = true;
                }
                function restoreFromMaximized(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    appDelegatePrivate.minimized = false;
                    appDelegatePrivate.maximized = false;
                    appDelegatePrivate.maximizedLeft = false;
                    appDelegatePrivate.maximizedRight = false;
                }
                function restore(animated) {
                    animationsEnabled = (animated === undefined) || animated;
                    appDelegatePrivate.minimized = false;
                    if (maximized)
                        maximize();
                    else if (maximizedLeft)
                        maximizeLeft();
                    else if (maximizedRight)
                        maximizeRight();

                    print("***** focusing because of window restore", model.application.appId)
                    focus = true;
                }

                function playFocusAnimation() {
                    focusAnimation.start()
                }

                UbuntuNumberAnimation {
                    id: focusAnimation
                    target: appDelegate
                    property: "scale"
                    from: 0.98
                    to: 1
                    duration: UbuntuAnimation.SnapDuration
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
                onRequestedWidthChanged: if (index == 0) print("requestedWidth", requestedWidth)
                states: [
                    State {
                        name: "spread"; when: root.state == "spread"
                        PropertyChanges {
                            target: appDelegate;
                            x: spreadMaths.animatedX
                            y: spreadMaths.animatedY
                            z: index
                            height: appContainer.height
                        }
                        PropertyChanges {
                            target: decoratedWindow;
                            showDecoration: false;
                            height: units.gu(15)
                            width: units.gu(15)
                            angle: spreadMaths.animatedAngle
                            requestedWidth: decoratedWindow.oldRequestedWidth
                            requestedHeight: decoratedWindow.oldRequestedHeight
                        }
                        PropertyChanges { target: inputBlocker; enabled: true }
                    },
                    State {
                        name: "stagedrightedge"; when: root.state == "stagedrightedge"
                        PropertyChanges {
                            target: stagedRightEdgeMaths
                            progress: rightEdgeDragArea.progress
                        }
                        PropertyChanges {
                            target: appDelegate
                            y: PanelState.panelHeight
                            x: stagedRightEdgeMaths.animatedX
                            z: index
                        }
                        PropertyChanges {
                            target: decoratedWindow;
                            showDecoration: false
                            requestedWidth: stagedRightEdgeMaths.animatedWidth
                            requestedHeight: stagedRightEdgeMaths.animatedHeight
                            width: appContainer.width - root.leftMargin
                            height: appContainer.height
                            angle: stagedRightEdgeMaths.animatedAngle
                        }
                    },
                    State {
                        name: "staged"; when: root.state == "staged"
                        PropertyChanges {
                            target: appDelegate
                            x: appDelegate.focus ? 0 : root.width; y: appDelegate.fullscreen ? 0 : PanelState.panelHeight
                            visuallyMaximized: true
                        }
                        PropertyChanges {
                            target: decoratedWindow
                            requestedWidth: appContainer.width - root.leftMargin;
                            requestedHeight: appContainer.height;
                            width: requestedWidth
                            height: requestedHeight
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
                        }
                        PropertyChanges {
                            target: decoratedWindow
                            requestedWidth: appContainer.width - root.leftMargin;
                            requestedHeight: appContainer.height;
                        }
                    },
                    State {
                        name: "fullscreen"; when: decoratedWindow.fullscreen && !appDelegate.minimized
                        PropertyChanges {
                            target: appDelegate;
                            x: 0;
                            y: -PanelState.panelHeight
                            requestedWidth: appContainer.width;
                            requestedHeight: appContainer.height;
                        }
                    },
                    State {
                        name: "normal";
                        when: !appDelegate.maximized && !appDelegate.minimized
                              && !appDelegate.maximizedLeft && !appDelegate.maximizedRight
                        PropertyChanges {
                            target: appDelegate;
                            visuallyMinimized: false;
                            visuallyMaximized: false
                        }
                        PropertyChanges {
                            target: decoratedWindow
                            width: appDelegate.width
                            height: appDelegate.height
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
                        name: "minimized"; when: appDelegate.minimized
                        PropertyChanges {
                            target: appDelegate;
                            x: -appDelegate.width / 2;
                            scale: units.gu(5) / appDelegate.width;
                            opacity: 0
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
                        UbuntuNumberAnimation { target: appDelegate; properties: "x,y,opacity,requestedWidth,requestedHeight,scale"; duration: UbuntuAnimation.FastDuration }
                        UbuntuNumberAnimation { target: decoratedWindow; properties: "requestedWidth,requestedHeight"; duration: UbuntuAnimation.FastDuration }
                    },
                    Transition {
                        to: "minimized"
                        enabled: appDelegate.animationsEnabled
                        PropertyAction { target: appDelegate; property: "visuallyMaximized" }
                        SequentialAnimation {
                            ParallelAnimation {
                                UbuntuNumberAnimation { target: appDelegate; properties: "x,y,opacity,scale"; duration: UbuntuAnimation.FastDuration }
                                UbuntuNumberAnimation { target: decoratedWindow; properties: "requestedWidth,requestedHeight"; duration: UbuntuAnimation.FastDuration }
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
                        to: "maximized,fullscreen" //maximized and fullscreen
                        enabled: appDelegate.animationsEnabled
                        PropertyAction { target: appDelegate; property: "visuallyMinimized" }
                        SequentialAnimation {
                            ParallelAnimation {
                                UbuntuNumberAnimation { target: appDelegate; properties: "x,y,opacity,scale"; duration: UbuntuAnimation.FastDuration }
                                UbuntuNumberAnimation { target: decoratedWindow; properties: "requestedWidth,requestedHeight"; duration: UbuntuAnimation.FastDuration }
                            }
                            PropertyAction { target: appDelegate; property: "visuallyMaximized" }
                        }
                    },
                    Transition {
                        to: "spread"
                        PropertyAnimation { target: appDelegate; properties: "x,y"; duration: priv.animationDuration }
                        PropertyAnimation { target: decoratedWindow; properties: "width,height,angle"; duration: priv.animationDuration }
                    },
                    Transition {
                        from: "spread"; to: "staged"
                        PropertyAnimation { target: appDelegate; properties: "x,y"; duration: priv.animationDuration }
                        PropertyAnimation { target: decoratedWindow; properties: "angle,width,height"; duration: priv.animationDuration }
                    },
                    Transition { // Ordering is important. This generic case needs to be after spread -> staged
                        to: "staged";
                        PropertyAnimation { target: appDelegate; properties: "x,y,width,height"; duration: priv.animationDuration }
                    }
                ]

//                Binding {
//                    id: previewBinding
//                    target: appDelegate
//                    property: "z"
//                    value: topLevelSurfaceList.count + 1
//                    when: index == spread.highlightedIndex
//                }

                WindowResizeArea {
                    id: resizeArea
                    objectName: "windowResizeArea"
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

                    requestedWidth: appDelegate.requestedWidth
                    requestedHeight: appDelegate.requestedHeight

                    property int oldRequestedWidth: -1
                    property int oldRequestedHeight: -1
                    onRequestedWidthChanged: oldRequestedWidth = requestedWidth
                    onRequestedHeightChanged: oldRequestedHeight = requestedHeight

                    onClose: { appDelegate.close(); }
                    onMaximize: appDelegate.maximized || appDelegate.maximizedLeft || appDelegate.maximizedRight
                                ? appDelegate.restoreFromMaximized() : appDelegate.maximize()
                    onMinimize: appDelegate.minimize()
                    onDecorationPressed: {
                        print("***** focusing because of decoration press", model.application.appId)
                        appDelegate.focus = true;
                    }

                    property real angle: 0
                    transform: [
//                        Scale {
//                            origin.x: itemScaleOriginX
//                            origin.y: itemScaleOriginY
//                            xScale: itemScale
//                            yScale: itemScale
//                        },
                        Rotation {
    //                        origin { x: 0; y: (clippedSpreadDelegate.height - (clippedSpreadDelegate.height * itemScale / 2)) }
                            axis { x: 0; y: 1; z: 0 }
                            angle: decoratedWindow.angle
                        }
                    ]
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
                Rectangle {
                    anchors.fill: parent
                    color: "blue"
                    opacity: .4
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

    DirectionalDragArea {
        id: rightEdgeDragArea
        direction: Direction.Leftwards
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: root.dragAreaWidth

        property var gesturePoints: new Array()

        property real progress: -touchX / root.width
        onProgressChanged: print("dda progress", progress, root.width, touchX, root.width + touchX)

//        Rectangle { color: "blue"; anchors.fill: parent }
        onTouchXChanged: {
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

            gesturePoints.push(touchX);
        }

        onDraggingChanged: {
            print("dda dragging changed", dragging)
            if (dragging) {
                // A potential edge-drag gesture has started. Start recording it
                gesturePoints = [];
            } else {
                if (gesturePoints[gesturePoints.length - 1] < -root.width / 2) {
                    priv.goneToSpread = true;
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
