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

    // Used by TutorialRight
    property bool spreadShown: spread.state == "altTab"

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
        onTriggered: spread.state = "altTab"
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
            if (spread.state == "altTab") {
                spread.cancel();
            }
        }
    }

    QtObject {
        id: priv
        objectName: "DesktopStagePrivate"

        property var focusedAppDelegate: null
        onFocusedAppDelegateChanged: {
            if (spread.state == "altTab") {
                spread.state = "";
            }
        }

        property var foregroundMaximizedAppDelegate: null // for stuff like drop shadow and focusing maximized app by clicking panel

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
            if (priv.focusedAppDelegate !== null && spread.state == "") {
                if (priv.focusedAppDelegate.maximized)
                    return priv.focusedAppDelegate.title
                else
                    return priv.focusedAppDelegate.appName
            }
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

                width: decoratedWindow.width
                height: decoratedWindow.height

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
                    if (spread.state == "altTab") {
                        spread.cancel();
                    }
                    appDelegate.restore();
                }
                Connections {
                    target: model.surface
                    onFocusRequested: claimFocus();
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
                        // If we're orphan (!parent) it means this stage is no longer the current one
                        // and will be deleted shortly. So we should no longer have a say over the model
                        if (root.parent) {
                            topLevelSurfaceList.raiseId(model.id);
                        }

                        priv.focusedAppDelegate = appDelegate;
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
                                appDelegate.focus = true;
                                return;
                            }
                        }
                    }
                }

                onVisuallyMaximizedChanged: priv.updateForegroundMaximizedApp()

                visible: (
                          !visuallyMinimized
                          && !greeter.fullyShown
                          && (priv.foregroundMaximizedAppDelegate === null || priv.foregroundMaximizedAppDelegate.normalZ <= z)
                         )
                         || decoratedWindow.fullscreen
                         || (spread.state == "altTab" && index === spread.highlightedIndex)

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

                states: [
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
                            visuallyMaximized: false
                        }
                    },
                    State {
                        name: "maximized"; when: appDelegate.maximized && !appDelegate.minimized
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
                        to: "*" //maximized and fullscreen
                        enabled: appDelegate.animationsEnabled
                        PropertyAction { target: appDelegate; property: "visuallyMinimized" }
                        SequentialAnimation {
                            ParallelAnimation {
                                UbuntuNumberAnimation { target: appDelegate; properties: "x,y,opacity,scale"; duration: UbuntuAnimation.FastDuration }
                                UbuntuNumberAnimation { target: decoratedWindow; properties: "requestedWidth,requestedHeight"; duration: UbuntuAnimation.FastDuration }
                            }
                            PropertyAction { target: appDelegate; property: "visuallyMaximized" }
                        }
                    }
                ]

                Binding {
                    id: previewBinding
                    target: appDelegate
                    property: "z"
                    value: topLevelSurfaceList.count + 1
                    when: index == spread.highlightedIndex && spread.ready
                }

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

                    onPressed: { appDelegate.focus = true; }

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
                    overlayShown: touchControls.overlayShown

                    requestedWidth: appDelegate.requestedWidth
                    requestedHeight: appDelegate.requestedHeight

                    onCloseClicked: { appDelegate.close(); }
                    onMaximizeClicked: appDelegate.maximized || appDelegate.maximizedLeft || appDelegate.maximizedRight
                                       || appDelegate.maximizedHorizontally || appDelegate.maximizedVertically
                                       ? appDelegate.restoreFromMaximized() : appDelegate.maximize()
                    onMaximizeHorizontallyClicked: appDelegate.maximizedHorizontally ? appDelegate.restoreFromMaximized() : appDelegate.maximizeHorizontally()
                    onMaximizeVerticallyClicked: appDelegate.maximizedVertically ? appDelegate.restoreFromMaximized() : appDelegate.maximizeVertically()
                    onMinimizeClicked: appDelegate.minimize()
                    onDecorationPressed: { appDelegate.focus = true; }
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

    SwipeArea {
        direction: Direction.Leftwards
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: units.gu(1)
        onDraggingChanged: { if (dragging) { spread.show(); } }
    }

    DesktopSpread {
        id: spread
        objectName: "spread"
        anchors.fill: appContainer
        workspace: appContainer
        focus: state == "altTab"
        altTabPressed: root.altTabPressed

        onPlayFocusAnimation: {
            appRepeater.itemAt(index).playFocusAnimation();
        }
    }
}
