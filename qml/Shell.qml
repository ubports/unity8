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
import AccountsService 0.1
import GSettings 1.0
import Unity.Application 0.1
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Gestures 0.1
import Ubuntu.SystemImage 0.1
import Unity.Connectivity 0.1
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
import Unity.Notifications 1.0 as NotificationBackend
import Unity.Session 0.1
import Unity.DashCommunicator 0.1

Item {
    id: shell

    // this is only here to select the width / height of the window if not running fullscreen
    property bool tablet: false
    width: tablet ? units.gu(160) : applicationArguments.hasGeometry() ? applicationArguments.width() : units.gu(40)
    height: tablet ? units.gu(100) : applicationArguments.hasGeometry() ? applicationArguments.height() : units.gu(71)

    property real edgeSize: units.gu(2)
    property url defaultBackground: Qt.resolvedUrl(shell.width >= units.gu(60) ? "graphics/tablet_background.jpg" : "graphics/phone_background.jpg")
    property url background
    readonly property real panelHeight: panel.panelHeight

    readonly property bool locked: LightDM.Greeter.active && !LightDM.Greeter.authenticated

    property bool sideStageEnabled: shell.width >= units.gu(100)
    readonly property string focusedApplicationId: ApplicationManager.focusedApplicationId

    property int maxFailedLogins: -1 // disabled by default for now, will enable via settings in future
    property int failedLoginsDelayAttempts: 7 // number of failed logins
    property int failedLoginsDelaySeconds: 5 * 60 // seconds of forced waiting

    function activateApplication(appId) {
        if (ApplicationManager.findApplication(appId)) {
            ApplicationManager.requestFocusApplication(appId);
        } else {
            var execFlags = shell.sideStageEnabled ? ApplicationManager.NoFlag : ApplicationManager.ForceMainStage;
            ApplicationManager.startApplication(appId, execFlags);
        }
    }

    function setFakeActiveForApp(app) {
        if (shell.locked) {
            greeter.fakeActiveForApp = app
            lockscreen.hide()
        }
    }

    Binding {
        target: LauncherModel
        property: "applicationManager"
        value: ApplicationManager
    }

    Component.onCompleted: {
        Theme.name = "Ubuntu.Components.Themes.SuruGradient"
    }

    GSettings {
        id: backgroundSettings
        schema.id: "org.gnome.desktop.background"
    }
    property url gSettingsPicture: backgroundSettings.pictureUri != undefined && backgroundSettings.pictureUri.length > 0 ? backgroundSettings.pictureUri : shell.defaultBackground
    onGSettingsPictureChanged: {
        shell.background = gSettingsPicture
    }

    VolumeControl {
        id: volumeControl
    }

    DashCommunicator {
        id: dash
        objectName: "dashCommunicator"
    }

    WindowKeysFilter {
        // Handle but do not filter out volume keys
        Keys.onVolumeUpPressed: { volumeControl.volumeUp(); event.accepted = false; }
        Keys.onVolumeDownPressed: { volumeControl.volumeDown(); event.accepted = false; }

        Keys.onPressed: {
            if (event.key == Qt.Key_PowerOff || event.key == Qt.Key_PowerDown) {
                dialogs.onPowerKeyPressed();
                event.accepted = true;
            } else {
                event.accepted = false;
            }
        }

        Keys.onReleased: {
            if (event.key == Qt.Key_PowerOff || event.key == Qt.Key_PowerDown) {
                dialogs.onPowerKeyReleased();
                event.accepted = true;
            } else {
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
                if (appId === "dialer-app") {
                    // Always let the dialer-app through.  Either user asked
                    // for an emergency call or accepted an incoming call.
                    setFakeActiveForApp(appId)
                } else if (greeter.fakeActiveForApp !== "" && greeter.fakeActiveForApp !== appId) {
                    lockscreen.show();
                }
                greeter.hide();
            }

            onFocusedApplicationIdChanged: {
                if (greeter.fakeActiveForApp !== "" && greeter.fakeActiveForApp !== ApplicationManager.focusedApplicationId) {
                    lockscreen.show();
                }
                panel.indicators.hide();
            }

            onApplicationAdded: {
                if (greeter.shown && appId != "unity8-dash") {
                    greeter.hide();
                }
                if (appId === "dialer-app") {
                    // Always let the dialer-app through.  Either user asked
                    // for an emergency call or accepted an incoming call.
                    setFakeActiveForApp(appId)
                }
            }
        }

        Loader {
            id: applicationsDisplayLoader
            anchors.fill: parent

            source: shell.sideStageEnabled ? "Stages/TabletStage.qml" : "Stages/PhoneStage.qml"

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
                value: panel.indicators.panelHeight
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "interactive"
                value: edgeDemo.stagesEnabled && !greeter.shown && !lockscreen.shown && panel.indicators.fullyClosed && launcher.progress == 0
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "spreadEnabled"
                value: edgeDemo.stagesEnabled && greeter.fakeActiveForApp === "" // to support emergency dialer hack
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "inverseProgress"
                value: launcher.progress
            }
        }
    }

    InputMethod {
        id: inputMethod
        objectName: "inputMethod"
        anchors { fill: parent; topMargin: panel.panelHeight }
        z: notifications.useModal || panel.indicators.shown ? overlay.z + 1 : overlay.z - 1
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

    Lockscreen {
        id: lockscreen
        objectName: "lockscreen"

        readonly property int backgroundTopMargin: -panel.panelHeight

        hides: [launcher, panel.indicators]
        shown: false
        enabled: true
        showAnimation: StandardAnimation { property: "opacity"; to: 1 }
        hideAnimation: StandardAnimation { property: "opacity"; to: 0 }
        y: panel.panelHeight
        visible: required
        width: parent.width
        height: parent.height - panel.panelHeight
        background: shell.background
        alphaNumeric: AccountsService.passwordDisplayHint === AccountsService.Keyboard
        minPinLength: 4
        maxPinLength: 4

        onEntered: LightDM.Greeter.respond(passphrase);
        onCancel: greeter.show()
        onEmergencyCall: shell.activateApplication("dialer-app") // will automatically enter fake-active mode

        onShownChanged: if (shown) greeter.fakeActiveForApp = ""

        Component.onCompleted: {
            if (greeter.narrowMode) {
                LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole))
            }
        }
    }

    Connections {
        target: LightDM.Greeter

        onShowGreeter: greeter.show()
        onHideGreeter: greeter.login()

        onShowPrompt: {
            if (greeter.narrowMode) {
                if (isDefaultPrompt) {
                    if (lockscreen.alphaNumeric) {
                        lockscreen.infoText = i18n.tr("Enter your passphrase")
                        lockscreen.errorText = i18n.tr("Sorry, incorrect passphrase")
                    } else {
                        lockscreen.infoText = i18n.tr("Enter your passcode")
                        lockscreen.errorText = i18n.tr("Sorry, incorrect passcode")
                    }
                } else {
                    lockscreen.infoText = i18n.tr("Enter your %1").arg(text.toLowerCase())
                    lockscreen.errorText = i18n.tr("Sorry, incorrect %1").arg(text.toLowerCase())
                }

                lockscreen.show();
            }
        }

        onPromptlessChanged: {
            if (LightDM.Greeter.promptless && LightDM.Greeter.authenticated) {
                lockscreen.hide()
            } else {
                lockscreen.reset();
                lockscreen.show();
            }
        }

        onAuthenticationComplete: {
            if (LightDM.Greeter.authenticated) {
                AccountsService.failedLogins = 0
            }
            // Else only penalize user for a failed login if they actually were
            // prompted for a password.  We do this below after the promptless
            // early exit.

            if (LightDM.Greeter.promptless) {
                return;
            }

            if (LightDM.Greeter.authenticated) {
                greeter.login();
            } else {
                AccountsService.failedLogins++
                if (maxFailedLogins >= 2) { // require at least a warning
                    if (AccountsService.failedLogins === maxFailedLogins - 1) {
                        var title = lockscreen.alphaNumeric ?
                                    i18n.tr("Sorry, incorrect passphrase.") :
                                    i18n.tr("Sorry, incorrect passcode.")
                        var text = i18n.tr("This will be your last attempt.") + " " +
                                   (lockscreen.alphaNumeric ?
                                    i18n.tr("If passphrase is entered incorrectly, your phone will conduct a factory reset and all personal data will be deleted.") :
                                    i18n.tr("If passcode is entered incorrectly, your phone will conduct a factory reset and all personal data will be deleted."))
                        lockscreen.showInfoPopup(title, text)
                    } else if (AccountsService.failedLogins >= maxFailedLogins) {
                        SystemImage.factoryReset() // Ouch!
                    }
                }
                if (failedLoginsDelayAttempts > 0 && AccountsService.failedLogins % failedLoginsDelayAttempts == 0) {
                    lockscreen.forceDelay(failedLoginsDelaySeconds * 1000)
                }

                lockscreen.clear(true);
                if (greeter.narrowMode) {
                    LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole))
                }
            }
        }
    }

    Binding {
        target: LightDM.Greeter
        property: "active"
        value: greeter.shown || lockscreen.shown || greeter.fakeActiveForApp != ""
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: greeterWrapper.showProgress * 0.8
    }

    Item {
        // Just a tiny wrapper to adjust greeter's x without messing with its own dragging
        id: greeterWrapper
        x: launcher.progress
        y: panel.panelHeight
        width: parent.width
        height: parent.height - panel.panelHeight

        Behavior on x {
            enabled: !launcher.dashSwipe
            StandardAnimation {}
        }

        property bool fullyShown: showProgress === 1.0
        onFullyShownChanged: {
            // Wait until the greeter is completely covering lockscreen before resetting it.
            if (fullyShown && !LightDM.Greeter.authenticated) {
                lockscreen.reset();
                lockscreen.show();
            }
        }

        readonly property real showProgress: MathUtils.clamp((1 - x/width) + greeter.showProgress - 1, 0, 1)
        onShowProgressChanged: if (LightDM.Greeter.authenticated && showProgress === 0) greeter.login()

        Greeter {
            id: greeter
            objectName: "greeter"

            signal sessionStarted() // helpful for tests

            property string fakeActiveForApp: ""

            available: true
            hides: [launcher, panel.indicators]
            shown: true
            loadContent: required || lockscreen.required // keeps content in memory for quick show()

            defaultBackground: shell.background

            width: parent.width
            height: parent.height

            dragHandleWidth: shell.edgeSize

            function login() {
                enabled = false;
                if (LightDM.Greeter.startSessionSync()) {
                    sessionStarted();
                    greeter.hide();
                    lockscreen.hide();
                    launcher.hide();
                }
                enabled = true;
            }

            onShownChanged: {
                if (shown) {
                    if (greeter.narrowMode) {
                        LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole));
                    }
                    greeter.fakeActiveForApp = "";
                    greeter.forceActiveFocus();
                }
            }

            /* TODO re-enable when the corresponding changes in the service land (LP: #1361074)
            Component.onCompleted: {
                Connectivity.unlockAllModems()
            } */

            onUnlocked: greeter.hide()
            onSelected: {
                // Update launcher items for new user
                var user = LightDM.Users.data(uid, LightDM.UserRoles.NameRole);
                AccountsService.user = user;
                LauncherModel.setUser(user);
            }

            onTease: launcher.tease()

            Binding {
                target: ApplicationManager
                property: "suspended"
                value: greeter.shown && greeterWrapper.showProgress == 1
            }
        }
    }

    Connections {
        id: powerConnection
        target: Powerd

        onDisplayPowerStateChange: {
            // We ignore any display-off signals when the proximity sensor
            // is active.  This usually indicates something like a phone call.
            if (status == Powerd.Off && reason != Powerd.Proximity && !edgeDemo.running) {
                greeter.showNow();
            }

            // No reason to chew demo CPU when user isn't watching
            if (status == Powerd.Off) {
                edgeDemo.paused = true;
            } else if (status == Powerd.On) {
                edgeDemo.paused = false;
            }
        }
    }

    function showHome() {
        if (edgeDemo.running) {
            return
        }

        if (LightDM.Greeter.active) {
            if (!LightDM.Greeter.authenticated) {
                lockscreen.show()
            }
            greeter.hide()
        }

        var animate = !LightDM.Greeter.active && !stages.shown
        dash.setCurrentScope("clickscope", animate, false)
        ApplicationManager.requestFocusApplication("unity8-dash")
    }

    function showDash() {
        if (shell.locked) {
            return;
        }
        if (greeter.shown) {
            greeter.hideRight();
            launcher.fadeOut();
        }

        ApplicationManager.requestFocusApplication("unity8-dash")
        launcher.fadeOut();
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
                available: edgeDemo.panelEnabled && (!shell.locked || AccountsService.enableIndicatorsWhileLocked) && greeter.fakeActiveForApp === ""
                contentEnabled: edgeDemo.panelContentEnabled
                width: parent.width > units.gu(60) ? units.gu(40) : parent.width
                panelHeight: units.gu(3)
            }

            property bool topmostApplicationIsFullscreen:
                ApplicationManager.focusedApplicationId &&
                    ApplicationManager.findApplication(ApplicationManager.focusedApplicationId).fullscreen

            fullscreenMode: (topmostApplicationIsFullscreen && !LightDM.Greeter.active && launcher.progress == 0)
                            || greeter.fakeActiveForApp !== ""
        }

        Launcher {
            id: launcher
            objectName: "launcher"

            readonly property bool dashSwipe: progress > 0

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            dragAreaWidth: shell.edgeSize
            available: edgeDemo.launcherEnabled && (!shell.locked || AccountsService.enableLauncherWhileLocked) && greeter.fakeActiveForApp === ""

            onShowDashHome: showHome()
            onDash: {
                if (ApplicationManager.focusedApplicationId != "unity8-dash") {
                    showDash()
                }
            }
            onDashSwipeChanged: {
                if (dashSwipe && ApplicationManager.focusedApplicationId !== "unity8-dash") {
                    dash.setCurrentScope("clickscope", false, true)
                }
            }
            onLauncherApplicationSelected: {
                if (greeter.fakeActiveForApp !== "") {
                    lockscreen.show()
                }
                if (!edgeDemo.running)
                    shell.activateApplication(appId)
            }
            onShownChanged: {
                if (shown) {
                    panel.indicators.hide()
                }
            }
        }

        Rectangle {
            id: modalNotificationBackground

            visible: notifications.useModal && !greeter.shown && (notifications.state == "narrow")
            color: "#000000"
            anchors.fill: parent
            opacity: 0.5

            MouseArea {
                anchors.fill: parent
            }
        }

        Notifications {
            id: notifications

            model: NotificationBackend.Model
            margin: units.gu(1)

            y: panel.panelHeight
            width: parent.width
            height: parent.height - panel.panelHeight

            states: [
                State {
                    name: "narrow"
                    when: overlay.width <= units.gu(60)
                    AnchorChanges { target: notifications; anchors.left: parent.left }
                },
                State {
                    name: "wide"
                    when: overlay.width > units.gu(60)
                    AnchorChanges { target: notifications; anchors.left: undefined }
                    PropertyChanges { target: notifications; width: units.gu(38) }
                }
            ]
        }
    }

    Binding {
        target: i18n
        property: "domain"
        value: "unity8"
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

    Label {
        id: alphaDisclaimerLabel
        anchors.centerIn: parent
        visible: ApplicationManager.fake ? ApplicationManager.fake : false
        z: dialogs.z + 10
        text: "EARLY ALPHA\nNOT READY FOR USE"
        color: "lightgrey"
        opacity: 0.2
        font.weight: Font.Black
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.Fit
        rotation: -45
        scale: Math.min(parent.width, parent.height) / width
    }

    EdgeDemo {
        id: edgeDemo
        z: alphaDisclaimerLabel.z + 10
        greeter: greeter
        launcher: launcher
        indicators: panel.indicators
        stages: stages
    }

    Connections {
        target: SessionBroadcast
        onShowHome: showHome()
    }

    Rectangle {
        id: shutdownFadeOutRectangle
        z: edgeDemo.z + 10
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
