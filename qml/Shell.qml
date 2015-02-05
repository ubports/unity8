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
import QtQuick.Window 2.0
import AccountsService 0.1
import GSettings 1.0
import Unity.Application 0.1
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Gestures 0.1
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Launcher 0.1
import Utils 0.1
import LightDM 0.1 as LightDM
import Powerd 0.1
import SessionBroadcast 0.1
import "Greeter"
import "Launcher"
import "Panel"
import "Components"
import "Notifications"
import "Stages"
import "Tutorial"
import "Wizard"
import Unity.Notifications 1.0 as NotificationBackend
import Unity.Session 0.1
import Unity.DashCommunicator 0.1
import Unity.Indicators 0.1 as Indicators

Item {
    id: shell

    // Disable everything while greeter is waiting, so that the user can't swipe
    // the greeter or launcher until we know whether the session is locked.
    enabled: !greeter.waiting

    // this is only here to select the width / height of the window if not running fullscreen
    property bool tablet: false
    width: tablet ? units.gu(160) : applicationArguments.hasGeometry() ? applicationArguments.width() : units.gu(40)
    height: tablet ? units.gu(100) : applicationArguments.hasGeometry() ? applicationArguments.height() : units.gu(71)

    property real edgeSize: units.gu(2)
    property url defaultBackground: Qt.resolvedUrl(shell.width >= units.gu(60) ? "graphics/tablet_background.jpg" : "graphics/phone_background.jpg")
    property url background: asImageTester.status == Image.Ready ? asImageTester.source
                             : gsImageTester.status == Image.Ready ? gsImageTester.source : defaultBackground
    readonly property real panelHeight: panel.panelHeight

    property bool sideStageEnabled: shell.width >= units.gu(100)
    readonly property string focusedApplicationId: ApplicationManager.focusedApplicationId

    property int orientation
    readonly property int deviceOrientationAngle: Screen.angleBetween(Screen.primaryOrientation, Screen.orientation)
    onDeviceOrientationAngleChanged: {
        if (!OrientationLock.enabled) {
            orientation = Screen.orientation;
        }
    }
    readonly property bool orientationLockEnabled: OrientationLock.enabled
    onOrientationLockEnabledChanged: {
        if (orientationLockEnabled) {
            OrientationLock.savedOrientation = Screen.orientation;
        } else {
            orientation = Screen.orientation;
        }
    }

    function activateApplication(appId) {
        if (ApplicationManager.findApplication(appId)) {
            ApplicationManager.requestFocusApplication(appId);
        } else {
            var execFlags = shell.sideStageEnabled ? ApplicationManager.NoFlag : ApplicationManager.ForceMainStage;
            ApplicationManager.startApplication(appId, execFlags);
        }
    }

    function startLockedApp(app) {
        if (greeter.locked) {
            greeter.lockedApp = app;
        }
        shell.activateApplication(app);
    }

    // This is a dummy image to detect if the custom AS set wallpaper loads successfully.
    Image {
        id: asImageTester
        source: AccountsService.backgroundFile != undefined && AccountsService.backgroundFile.length > 0 ? AccountsService.backgroundFile : ""
        height: 0
        width: 0
        sourceSize.height: 0
        sourceSize.width: 0
    }

    GSettings {
        id: backgroundSettings
        objectName: "backgroundSettings"
        schema.id: "org.gnome.desktop.background"
    }

    // This is a dummy image to detect if the custom GSettings set wallpaper loads successfully.
    Image {
        id: gsImageTester
        source: backgroundSettings.pictureUri != undefined && backgroundSettings.pictureUri.length > 0 ? backgroundSettings.pictureUri : ""
        height: 0
        width: 0
        sourceSize.height: 0
        sourceSize.width: 0
    }

    GSettings {
        id: usageModeSettings
        schema.id: "com.canonical.Unity8"
    }

    Binding {
        target: LauncherModel
        property: "applicationManager"
        value: ApplicationManager
    }

    Component.onCompleted: {
        Theme.name = "Ubuntu.Components.Themes.SuruGradient"
        if (ApplicationManager.count > 0) {
            ApplicationManager.focusApplication(ApplicationManager.get(0).appId);
        }
        if (orientationLockEnabled) {
            orientation = OrientationLock.savedOrientation;
        }
    }

    VolumeControl {
        id: volumeControl
    }

    DashCommunicator {
        id: dash
        objectName: "dashCommunicator"
    }

    ScreenGrabber {
        id: screenGrabber
        z: dialogs.z + 10
        enabled: Powerd.status === Powerd.On
    }

    Binding {
        target: ApplicationManager
        property: "forceDashActive"
        value: launcher.shown || launcher.dashSwipe
    }

    VolumeKeyFilter {
        id: volumeKeyFilter
        onVolumeDownPressed: volumeControl.volumeDown()
        onVolumeUpPressed: volumeControl.volumeUp()
        onBothVolumeKeysPressed: screenGrabber.capture()
    }

    WindowKeysFilter {
        Keys.onPressed: {
            // Nokia earpieces give TogglePlayPause, while the iPhone's earpiece gives Play
            if (event.key == Qt.Key_MediaTogglePlayPause || event.key == Qt.Key_MediaPlay) {
                event.accepted = callManager.handleMediaKey(false);
            } else if (event.key == Qt.Key_PowerOff || event.key == Qt.Key_PowerDown) {
                // FIXME: We only consider power key presses if the screen is
                // on because of bugs 1410830/1409003.  The theory is that when
                // those bugs are encountered, there is a >2s delay between the
                // power press event and the power release event, which causes
                // the shutdown dialog to appear on resume.  So to avoid that
                // symptom while we investigate the root cause, we simply won't
                // initiate any dialogs when the screen is off.
                if (Powerd.status === Powerd.On) {
                    dialogs.onPowerKeyPressed();
                }
                event.accepted = true;
            } else {
                volumeKeyFilter.onKeyPressed(event.key);
                event.accepted = false;
            }
        }

        Keys.onReleased: {
            if (event.key == Qt.Key_PowerOff || event.key == Qt.Key_PowerDown) {
                dialogs.onPowerKeyReleased();
                event.accepted = true;
            } else {
                volumeKeyFilter.onKeyReleased(event.key);
                event.accepted = false;
            }
        }
    }

    Item {
        id: stages
        objectName: "stages"
        width: parent.width
        height: parent.height
        visible: !ApplicationManager.empty

        Connections {
            target: ApplicationManager

            onFocusRequested: {
                if (appId === "dialer-app" && callManager.hasCalls && greeter.locked) {
                    // If we are in the middle of a call, make dialer lockedApp and show it.
                    // This can happen if user backs out of dialer back to greeter, then
                    // launches dialer again.
                    greeter.lockedApp = appId;
                }

                greeter.notifyAppFocused(appId);
            }

            onFocusedApplicationIdChanged: {
                greeter.notifyAppFocused(ApplicationManager.focusedApplicationId);
                panel.indicators.hide();
            }

            onApplicationAdded: {
                if (tutorial.running && appId != "unity8-dash") {
                    // If this happens on first boot, we may be in edge
                    // tutorial or wizard while receiving a call.  But a call
                    // is more important than wizard so just bail out of those.
                    tutorial.finish();
                    wizard.hide();
                }

                greeter.notifyAppFocused(appId);
                launcher.hide();
            }
        }

        Loader {
            id: applicationsDisplayLoader
            objectName: "applicationsDisplayLoader"
            anchors.fill: parent

            // When we have a locked app, we only want to show that one app.
            // FIXME: do this in a less traumatic way.  We currently only allow
            // locked apps in phone mode (see FIXME in Lockscreen component in
            // this same file).  When that changes, we need to do something
            // nicer here.  But this code is currently just to prevent a
            // theoretical attack where user enters lockedApp mode, then makes
            // the screen larger (maybe connects to monitor) and tries to enter
            // tablet mode.
            property bool tabletMode: shell.sideStageEnabled && !greeter.hasLockedApp
            source: usageModeSettings.usageMode === "Windowed" ? "Stages/DesktopStage.qml"
                        : tabletMode ? "Stages/TabletStage.qml" : "Stages/PhoneStage.qml"

            Binding {
                target: applicationsDisplayLoader.item
                property: "objectName"
                value: "stage"
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "dragAreaWidth"
                value: shell.edgeSize
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "maximizedAppTopMargin"
                // Not just using panel.panelHeight as that changes depending on the focused app.
                value: panel.indicators.minimizedPanelHeight + units.dp(2) // dp(2) for orange line
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "interactive"
                value: tutorial.spreadEnabled && !greeter.shown && panel.indicators.fullyClosed && launcher.progress == 0 && !notifications.useModal
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "spreadEnabled"
                value: tutorial.spreadEnabled && !greeter.hasLockedApp
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "inverseProgress"
                value: launcher.progress
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "orientation"
                value: shell.orientation
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "background"
                value: shell.background
            }
        }
    }

    InputMethod {
        id: inputMethod
        objectName: "inputMethod"
        anchors { fill: parent; topMargin: panel.panelHeight }
        z: notifications.useModal || panel.indicators.shown || wizard.active ? overlay.z + 1 : overlay.z - 1
    }

    Connections {
        target: SurfaceManager
        onSurfaceCreated: {
            if (surface.type == MirSurfaceItem.InputMethod) {
                inputMethod.surface = surface;
            }
        }

        onSurfaceDestroyed: {
            if (inputMethod.surface == surface) {
                inputMethod.surface = null;
                surface.parent = null;
            }
            if (!surface.parent) {
                // there's no one displaying it. delete it right away
                surface.release();
            }
        }
    }
    Connections {
        target: SessionManager
        onSessionStopping: {
            if (!session.parentSession && !session.application) {
                // nothing is using it. delete it right away
                session.release();
            }
        }
    }

    Greeter {
        id: greeter
        objectName: "greeter"

        hides: [launcher, panel.indicators]
        tabletMode: shell.sideStageEnabled
        launcherOffset: launcher.progress
        forcedUnlock: tutorial.running
        background: shell.background

        anchors.fill: parent
        anchors.topMargin: panel.panelHeight

        // avoid overlapping with Launcher's edge drag area
        // FIXME: Fix TouchRegistry & friends and remove this workaround
        //        Issue involves launcher's DDA getting disabled on a long
        //        left-edge drag
        dragHandleLeftMargin: launcher.available ? launcher.dragAreaWidth + 1 : 0

        onSessionStarted: {
            launcher.hide();
        }

        onTease: {
            if (!tutorial.running) {
                launcher.tease();
            }
        }

        onEmergencyCall: startLockedApp("dialer-app")

        Timer {
            // See powerConnection for why this is useful
            id: showGreeterDelayed
            interval: 1
            onTriggered: {
                greeter.forceShow();
            }
        }

        Binding {
            target: ApplicationManager
            property: "suspended"
            value: greeter.shown
        }
    }

    Connections {
        id: callConnection
        target: callManager

        onHasCallsChanged: {
            if (greeter.locked && callManager.hasCalls && greeter.lockedApp !== "dialer-app") {
                // We just received an incoming call while locked.  The
                // indicator will have already launched dialer-app for us, but
                // there is a race between "hasCalls" changing and the dialer
                // starting up.  So in case we lose that race, we'll start/
                // focus the dialer ourselves here too.  Even if the indicator
                // didn't launch the dialer for some reason (or maybe a call
                // started via some other means), if an active call is
                // happening, we want to be in the dialer.
                startLockedApp("dialer-app")
            }
        }
    }

    Connections {
        id: powerConnection
        target: Powerd

        onStatusChanged: {
            if (Powerd.status === Powerd.Off && reason !== Powerd.Proximity &&
                    !callManager.hasCalls && !tutorial.running) {
                // We don't want to simply call greeter.showNow() here, because
                // that will take too long.  Qt will delay button event
                // handling until the greeter is done loading and may think the
                // user held down the power button the whole time, leading to a
                // power dialog being shown.  Instead, delay showing the
                // greeter until we've finished handling the event.  We could
                // make the greeter load asynchronously instead, but that
                // introduces a whole host of timing issues, especially with
                // its animations.  So this is simpler.
                showGreeterDelayed.start();
            }
        }
    }

    function showHome() {
        if (tutorial.running) {
            return
        }

        greeter.notifyAboutToFocusApp("unity8-dash");

        var animate = !LightDM.Greeter.active && !stages.shown
        dash.setCurrentScope(0, animate, false)
        ApplicationManager.requestFocusApplication("unity8-dash")
    }

    function showDash() {
        if (greeter.active) {
            greeter.notifyShowingDashFromDrag();
            launcher.fadeOut();
        }

        if (ApplicationManager.focusedApplicationId != "unity8-dash") {
            ApplicationManager.requestFocusApplication("unity8-dash")
            launcher.fadeOut();
        }
    }

    Item {
        id: overlay
        z: 10

        anchors.fill: parent

        Panel {
            id: panel
            objectName: "panel"
            anchors.fill: parent //because this draws indicator menus
            indicators {
                hides: [launcher]
                available: tutorial.panelEnabled && (!greeter.locked || AccountsService.enableIndicatorsWhileLocked) && !greeter.hasLockedApp
                contentEnabled: tutorial.panelContentEnabled
                width: parent.width > units.gu(60) ? units.gu(40) : parent.width

                minimizedPanelHeight: units.gu(3)
                expandedPanelHeight: units.gu(7)

                indicatorsModel: Indicators.IndicatorsModel {
                    Component.onCompleted: load(indicatorProfile);
                }
            }
            callHint {
                greeterShown: greeter.shown
            }

            property bool topmostApplicationIsFullscreen:
                ApplicationManager.focusedApplicationId &&
                    ApplicationManager.findApplication(ApplicationManager.focusedApplicationId).fullscreen

            fullscreenMode: (topmostApplicationIsFullscreen && !LightDM.Greeter.active && launcher.progress == 0)
                            || greeter.hasLockedApp
        }

        Launcher {
            id: launcher
            objectName: "launcher"

            readonly property bool dashSwipe: progress > 0

            anchors.top: parent.top
            anchors.topMargin: inverted ? 0 : panel.panelHeight
            anchors.bottom: parent.bottom
            width: parent.width
            dragAreaWidth: shell.edgeSize
            available: tutorial.launcherEnabled && (!greeter.locked || AccountsService.enableLauncherWhileLocked) && !greeter.hasLockedApp
            inverted: usageModeSettings.usageMode === "Staged"
            shadeBackground: !tutorial.running

            onShowDashHome: showHome()
            onDash: showDash()
            onDashSwipeChanged: {
                if (dashSwipe) {
                    dash.setCurrentScope(0, false, true)
                }
            }
            onLauncherApplicationSelected: {
                if (!tutorial.running) {
                    greeter.notifyAboutToFocusApp(appId);
                    shell.activateApplication(appId)
                }
            }
            onShownChanged: {
                if (shown) {
                    panel.indicators.hide()
                }
            }
        }

        Wizard {
            id: wizard
            anchors.fill: parent
            background: shell.background
        }

        Rectangle {
            id: modalNotificationBackground

            visible: notifications.useModal && (notifications.state == "narrow")
            color: "#000000"
            anchors.fill: parent
            opacity: 0.9

            MouseArea {
                anchors.fill: parent
            }
        }

        Notifications {
            id: notifications

            model: NotificationBackend.Model
            margin: units.gu(1)

            y: topmostIsFullscreen ? 0 : panel.panelHeight
            height: parent.height - (topmostIsFullscreen ? 0 : panel.panelHeight)

            states: [
                State {
                    name: "narrow"
                    when: overlay.width <= units.gu(60)
                    AnchorChanges {
                        target: notifications
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
                },
                State {
                    name: "wide"
                    when: overlay.width > units.gu(60)
                    AnchorChanges {
                        target: notifications
                        anchors.left: undefined
                        anchors.right: parent.right
                    }
                    PropertyChanges { target: notifications; width: units.gu(38) }
                }
            ]
        }
    }

    Dialogs {
        id: dialogs
        anchors.fill: parent
        z: overlay.z + 10
        onPowerOffClicked: {
            shutdownFadeOutRectangle.enabled = true;
            shutdownFadeOutRectangle.visible = true;
            shutdownFadeOut.start();
        }
    }

    Tutorial {
        id: tutorial
        objectName: "tutorial"
        active: AccountsService.demoEdges
        paused: LightDM.Greeter.active
        launcher: launcher
        panel: panel
        stages: stages
        overlay: overlay
        edgeSize: shell.edgeSize

        onFinished: {
            AccountsService.demoEdges = false;
            active = false; // for immediate response / if AS is having problems
        }
    }

    Connections {
        target: SessionBroadcast
        onShowHome: showHome()
    }

    Rectangle {
        id: shutdownFadeOutRectangle
        z: screenGrabber.z + 10
        enabled: false
        visible: false
        color: "black"
        anchors.fill: parent
        opacity: 0.0
        NumberAnimation on opacity {
            id: shutdownFadeOut
            from: 0.0
            to: 1.0
            onStopped: {
                if (shutdownFadeOutRectangle.enabled && shutdownFadeOutRectangle.visible) {
                    DBusUnitySessionService.Shutdown();
                }
            }
        }
    }

}
