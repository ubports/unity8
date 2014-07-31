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
import Ubuntu.Components.Popups 0.1
import Ubuntu.Gestures 0.1
import Ubuntu.SystemImage 0.1
import Unity.Launcher 0.1
import LightDM 0.1 as LightDM
import Powerd 0.1
import SessionBroadcast 0.1
import "Dash"
import "Greeter"
import "Launcher"
import "Panel"
import "Components"
import "Notifications"
import Unity.Notifications 1.0 as NotificationBackend
import Unity.Session 0.1

FocusScope {
    id: shell

    // this is only here to select the width / height of the window if not running fullscreen
    property bool tablet: false
    width: tablet ? units.gu(160) : applicationArguments.hasGeometry() ? applicationArguments.width() : units.gu(40)
    height: tablet ? units.gu(100) : applicationArguments.hasGeometry() ? applicationArguments.height() : units.gu(71)

    property real edgeSize: units.gu(2)
    property url defaultBackground: Qt.resolvedUrl(shell.width >= units.gu(60) ? "graphics/tablet_background.jpg" : "graphics/phone_background.jpg")
    property url background
    readonly property real panelHeight: panel.panelHeight

    property bool dashShown: dash.shown

    property bool sideStageEnabled: shell.width >= units.gu(100)
    readonly property string focusedApplicationId: ApplicationManager.focusedApplicationId

    property int maxFailedLogins: -1 // disabled by default for now, will enable via settings in future

    function activateApplication(appId) {
        if (ApplicationManager.findApplication(appId)) {
            ApplicationManager.requestFocusApplication(appId);
            stages.show(true);
            if (stages.locked && ApplicationManager.focusedApplicationId == appId) {
                applicationsDisplayLoader.item.select(appId);
            }
        } else {
            var execFlags = shell.sideStageEnabled ? ApplicationManager.NoFlag : ApplicationManager.ForceMainStage;
            ApplicationManager.startApplication(appId, execFlags);
            stages.show(false);
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

    Keys.onVolumeUpPressed: volumeControl.volumeUp()
    Keys.onVolumeDownPressed: volumeControl.volumeDown()

    Item {
        id: underlayClipper
        anchors.fill: parent
        anchors.rightMargin: stages.overlayWidth
        clip: stages.overlayMode && !stages.painting

        InputFilterArea {
            anchors.fill: parent
            blockInput: parent.clip
        }

        Item {
            id: underlay
            objectName: "underlay"
            anchors.fill: parent
            anchors.rightMargin: -parent.anchors.rightMargin

            // Whether the underlay is fully covered by opaque UI elements.
            property bool fullyCovered: panel.indicators.fullyOpened && shell.width <= panel.indicators.width

            // Whether the user should see the topmost application surface (if there's one at all).
            readonly property bool applicationSurfaceShouldBeSeen: stages.shown && !stages.painting && !stages.overlayMode

            // NB! Application surfaces are stacked behind the shell one. So they can only be seen by the user
            // through the translucent parts of the shell surface.
            visible: !fullyCovered && !applicationSurfaceShouldBeSeen

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: dash.disappearingAnimationProgress
            }

            Image {
                anchors.fill: dash
                source: shell.width > shell.height ? "Dash/graphics/paper_landscape.png" : "Dash/graphics/paper_portrait.png"
                fillMode: Image.PreserveAspectCrop
                horizontalAlignment: Image.AlignRight
                verticalAlignment: Image.AlignTop
            }

            Dash {
                id: dash
                objectName: "dash"

                available: !LightDM.Greeter.active
                hides: [stages, launcher, panel.indicators]
                shown: disappearingAnimationProgress !== 1.0 && greeterWrapper.showProgress !== 1.0
                enabled: disappearingAnimationProgress === 0.0 && greeterWrapper.showProgress === 0.0 && edgeDemo.dashEnabled

                anchors {
                    fill: parent
                    topMargin: panel.panelHeight
                }

                contentScale: 1.0 - 0.2 * disappearingAnimationProgress
                opacity: 1.0 - disappearingAnimationProgress
                property real disappearingAnimationProgress: {
                    if (stages.overlayMode) {
                        return 0;
                    } else {
                        return stages.showProgress
                    }
                }

                // FIXME: only necessary because stages.showProgress is not animated
                Behavior on disappearingAnimationProgress { SmoothedAnimation { velocity: 5 }}
            }
        }
    }

    EdgeDragArea {
        id: stagesDragHandle
        direction: Direction.Leftwards

        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: shell.edgeSize

        property real progress: stages.width

        onTouchXChanged: {
            if (status == DirectionalDragArea.Recognized) {
                if (ApplicationManager.count == 0) {
                    progress = Math.max(stages.width - stagesDragHandle.width + touchX, stages.width * .3)
                } else {
                    progress = stages.width - stagesDragHandle.width + touchX
                }
            }
        }

        onDraggingChanged: {
            if (!dragging) {
                if (ApplicationManager.count > 0 && progress < stages.width - units.gu(10)) {
                    stages.show(true)
                }
                stagesDragHandle.progress = stages.width;
            }
        }
    }

    Item {
        id: stages
        objectName: "stages"
        width: parent.width
        height: parent.height

        x: {
            if (shown) {
                if (overlayMode || locked || greeter.fakeActiveForApp !== "") {
                    return 0;
                }
                return launcher.progress
            } else {
                return stagesDragHandle.progress
            }
        }

        Behavior on x { SmoothedAnimation { velocity: 600; duration: UbuntuAnimation.FastDuration } }

        property bool shown: false

        property real showProgress: overlayMode ? 0 : MathUtils.clamp(1 - x / shell.width, 0, 1)

        property bool fullyShown: x == 0
        property bool fullyHidden: x == width

        property bool painting: applicationsDisplayLoader.item ? applicationsDisplayLoader.item.painting : false
        property bool fullscreen: applicationsDisplayLoader.item ? applicationsDisplayLoader.item.fullscreen : false
        property bool overlayMode: applicationsDisplayLoader.item ? applicationsDisplayLoader.item.overlayMode : false
        property int overlayWidth: applicationsDisplayLoader.item ? applicationsDisplayLoader.item.overlayWidth : false
        property bool locked: applicationsDisplayLoader.item ? applicationsDisplayLoader.item.locked : false

        function show(focusApp) {
            shown = true;
            panel.indicators.hide();
            edgeDemo.stopDemo();
            greeter.hide();
            if (!ApplicationManager.focusedApplicationId && ApplicationManager.count > 0 && focusApp) {
                ApplicationManager.focusApplication(ApplicationManager.get(0).appId);
            }
        }

        function hide() {
            shown = false;
            if (ApplicationManager.focusedApplicationId) {
                ApplicationManager.unfocusCurrentApplication();
            }
        }

        Connections {
            target: ApplicationManager

            onFocusRequested: {
                if (greeter.fakeActiveForApp !== "" && greeter.fakeActiveForApp !== appId) {
                    lockscreen.show();
                }
                greeter.hide();
                stages.show(true);
            }

            onFocusedApplicationIdChanged: {
                if (greeter.fakeActiveForApp !== "" && greeter.fakeActiveForApp !== ApplicationManager.focusedApplicationId) {
                    lockscreen.show();
                }
                if (ApplicationManager.focusedApplicationId.length > 0) {
                    stages.show(false);
                } else {
                    if (!stages.overlayMode) {
                        stages.hide();
                    }
                }
            }

            onApplicationAdded: {
                stages.show(false);
            }

            onApplicationRemoved: {
                if (ApplicationManager.focusedApplicationId.length == 0) {
                    stages.hide();
                }
            }
        }

        property bool dialogShown: false

        Component {
            id: logoutDialog
            Dialog {
                id: dialogueLogout
                title: "Logout"
                text: "Are you sure that you want to logout?"
                Button {
                    text: "Cancel"
                    onClicked: {
                        PopupUtils.close(dialogueLogout);
                        stages.dialogShown = false;
                    }
                }
                Button {
                    text: "Yes"
                    onClicked: {
                        DBusUnitySessionService.Logout();
                        PopupUtils.close(dialogueLogout);
                        stages.dialogShown = false;
                    }
                }
            }
        }

        Component {
            id: shutdownDialog
            Dialog {
                id: dialogueShutdown
                title: "Shutdown"
                text: "Are you sure that you want to shutdown?"
                Button {
                    text: "Cancel"
                    onClicked: {
                        PopupUtils.close(dialogueShutdown);
                        stages.dialogShown = false;
                    }
                }
                Button {
                    text: "Yes"
                    onClicked: {
                        dBusUnitySessionServiceConnection.closeAllApps();
                        DBusUnitySessionService.Shutdown();
                        PopupUtils.close(dialogueShutdown);
                        stages.dialogShown = false;
                    }
                }
            }
        }

        Component {
            id: rebootDialog
            Dialog {
                id: dialogueReboot
                title: "Reboot"
                text: "Are you sure that you want to reboot?"
                Button {
                    text: "Cancel"
                    onClicked: {
                        PopupUtils.close(dialogueReboot)
                        stages.dialogShown = false;
                    }
                }
                Button {
                    text: "Yes"
                    onClicked: {
                        dBusUnitySessionServiceConnection.closeAllApps();
                        DBusUnitySessionService.Reboot();
                        PopupUtils.close(dialogueReboot);
                        stages.dialogShown = false;
                    }
                }
            }
        }

        Component {
            id: powerDialog
            Dialog {
                id: dialoguePower
                title: "Power"
                text: i18n.tr("Are you sure you would like to turn power off?")
                Button {
                    text: i18n.tr("Power off")
                    onClicked: {
                        dBusUnitySessionServiceConnection.closeAllApps();
                        PopupUtils.close(dialoguePower);
                        stages.dialogShown = false;
                        shutdownFadeOutRectangle.enabled = true;
                        shutdownFadeOutRectangle.visible = true;
                        shutdownFadeOut.start();
                    }
                }
                Button {
                    text: i18n.tr("Restart")
                    onClicked: {
                        dBusUnitySessionServiceConnection.closeAllApps();
                        DBusUnitySessionService.Reboot();
                        PopupUtils.close(dialoguePower);
                        stages.dialogShown = false;
                    }
                }
                Button {
                    text: i18n.tr("Cancel")
                    onClicked: {
                        PopupUtils.close(dialoguePower);
                        stages.dialogShown = false;
                    }
                }
            }
        }

        function showPowerDialog() {
            if (!stages.dialogShown) {
                stages.dialogShown = true;
                PopupUtils.open(powerDialog);
            }
        }

        Connections {
            id: dBusUnitySessionServiceConnection
            objectName: "dBusUnitySessionServiceConnection"
            target: DBusUnitySessionService

            function closeAllApps() {
                while (true) {
                    var app = ApplicationManager.get(0);
                    if (app === null) {
                        break;
                    }
                    ApplicationManager.stopApplication(app.appId);
                }
            }

            onLogoutRequested: {
                // Display a dialog to ask the user to confirm.
                if (!stages.dialogShown) {
                    stages.dialogShown = true;
                    PopupUtils.open(logoutDialog);
                }
            }

            onShutdownRequested: {
                // Display a dialog to ask the user to confirm.
                if (!stages.dialogShown) {
                    stages.dialogShown = true;
                    PopupUtils.open(shutdownDialog);
                }
            }

            onRebootRequested: {
                // Display a dialog to ask the user to confirm.
                if (!stages.dialogShown) {
                    stages.dialogShown = true;
                    PopupUtils.open(rebootDialog);
                }
            }

            onLogoutReady: {
                closeAllApps();
                Qt.quit();
            }
        }

        Loader {
            id: applicationsDisplayLoader
            anchors.fill: parent

            source: shell.sideStageEnabled ? "Stages/StageWithSideStage.qml" : "Stages/PhoneStage.qml"

            Binding {
                target: applicationsDisplayLoader.item
                property: "objectName"
                value: "stage"
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "moving"
                value: !stages.fullyShown
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "shown"
                value: stages.shown
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "dragAreaWidth"
                value: shell.edgeSize
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "spreadEnabled"
                value: greeter.fakeActiveForApp === "" // to support emergency dialer hack
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
        x: required ? 0 : - width
        width: parent.width
        height: parent.height - panel.panelHeight
        background: shell.background
        alphaNumeric: AccountsService.passwordDisplayHint === AccountsService.Keyboard
        minPinLength: 4
        maxPinLength: 4

        onEntered: LightDM.Greeter.respond(passphrase);
        onCancel: greeter.show()
        onEmergencyCall: {
            greeter.fakeActiveForApp = "dialer-app"
            shell.activateApplication("dialer-app")
            lockscreen.hide()
        }

        onShownChanged: if (shown) greeter.fakeActiveForApp = ""

        Component.onCompleted: {
            if (greeter.narrowMode) {
                LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole))
            }
        }
    }

    Component {
        id: factoryResetWarningDialog
        FactoryResetWarningDialog {
            objectName: "factoryResetWarningDialog"
            alphaNumeric: lockscreen.alphaNumeric
        }
    }

    Connections {
        target: LightDM.Greeter

        onShowGreeter: greeter.show()

        onShowPrompt: {
            if (greeter.narrowMode) {
                lockscreen.placeholderText = i18n.tr("Please enter %1").arg(text.toLowerCase());
                lockscreen.show();
            }
        }

        onPromptlessChanged: {
            if (LightDM.Greeter.promptless) {
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
                lockscreen.hide();
                greeter.login();
            } else {
                AccountsService.failedLogins++
                if (maxFailedLogins >= 2) { // require at least a warning
                    if (AccountsService.failedLogins === maxFailedLogins - 1) {
                        PopupUtils.open(factoryResetWarningDialog)
                    } else if (AccountsService.failedLogins >= maxFailedLogins) {
                        SystemImage.factoryReset() // Ouch!
                    }
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

        readonly property real showProgress: MathUtils.clamp((1 - x/width) + greeter.showProgress - 1, 0, 1)
        onShowProgressChanged: if (LightDM.Greeter.promptless && showProgress === 0) greeter.login()

        Greeter {
            id: greeter
            objectName: "greeter"

            signal sessionStarted() // helpful for tests

            property string fakeActiveForApp: ""

            available: true
            hides: [launcher, panel.indicators]
            shown: true

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
                    if (!LightDM.Greeter.promptless) {
                        lockscreen.reset();
                        lockscreen.show();
                    }
                    greeter.fakeActiveForApp = "";
                    greeter.forceActiveFocus();
                }
            }

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

    InputFilterArea {
        anchors.fill: parent
        blockInput: ApplicationManager.focusedApplicationId.length === 0 || greeter.shown || lockscreen.shown || launcher.shown
                    || panel.indicators.shown
    }

    Connections {
        id: powerConnection
        target: Powerd

        onDisplayPowerStateChange: {
            // We ignore any display-off signals when the proximity sensor
            // is active.  This usually indicates something like a phone call.
            if (status == Powerd.Off && reason != Powerd.Proximity) {
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
            if (!LightDM.Greeter.promptless) {
                lockscreen.show()
            }
            greeter.hide()
        }

        var animate = !LightDM.Greeter.active && !stages.shown
        dash.setCurrentScope("clickscope", animate, false)
        stages.hide()
    }

    function showDash() {
        if (LightDM.Greeter.active && !LightDM.Greeter.promptless) {
            return;
        }

        if (stages.shown && !stages.overlayMode && !stages.locked) {
            stages.hide();
            launcher.fadeOut();
        } else {
            launcher.switchToNextState("visible");
        }

        if (greeter.shown) {
            greeter.hideRight();
            launcher.fadeOut();
        }
    }

    Item {
        id: overlay

        anchors.fill: parent

        Panel {
            id: panel
            objectName: "panel"
            anchors.fill: parent //because this draws indicator menus
            indicators {
                hides: [launcher]
                available: edgeDemo.panelEnabled && greeter.fakeActiveForApp === ""
                contentEnabled: edgeDemo.panelContentEnabled
                width: parent.width > units.gu(60) ? units.gu(40) : parent.width
                panelHeight: units.gu(3)
            }
            property string focusedAppId: ApplicationManager.focusedApplicationId
            property var focusedApplication: ApplicationManager.findApplication(focusedAppId)
            fullscreenMode: (focusedApplication && stages.fullscreen && !LightDM.Greeter.active) || greeter.fakeActiveForApp !== ""

            InputFilterArea {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: (panel.fullscreenMode) ? shell.edgeSize : panel.panelHeight
                blockInput: true
            }
        }

        InputFilterArea {
            blockInput: launcher.shown
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: launcher.width
        }

        Launcher {
            id: launcher
            objectName: "launcher"

            readonly property bool dashSwipe: progress > 0

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            dragAreaWidth: shell.edgeSize
            available: edgeDemo.launcherEnabled && greeter.fakeActiveForApp === ""

            onShowDashHome: showHome()
            onDash: showDash()
            onDashSwipeChanged: if (dashSwipe && stages.shown) dash.setCurrentScope("clickscope", false, true)
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

            InputFilterArea {
                anchors.fill: parent
                blockInput: modalNotificationBackground.visible
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

            InputFilterArea {
                anchors { left: parent.left; right: parent.right }
                height: parent.contentHeight
                blockInput: height > 0
            }
        }
    }

    focus: true
    onFocusChanged: if (!focus) forceActiveFocus();

    InputFilterArea {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: shell.edgeSize
        blockInput: true
    }

    InputFilterArea {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: shell.edgeSize
        blockInput: true
    }

    Binding {
        target: i18n
        property: "domain"
        value: "unity8"
    }

    OSKController {
        anchors.topMargin: panel.panelHeight
        anchors.fill: parent // as needs to know the geometry of the shell
    }

    //FIXME: This should be handled in the input stack, keyboard shouldnt propagate
    MouseArea {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: ApplicationManager.keyboardVisible ? ApplicationManager.keyboardHeight : 0

        enabled: ApplicationManager.keyboardVisible
    }

    Label {
        anchors.centerIn: parent
        visible: ApplicationManager.fake ? ApplicationManager.fake : false
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
        greeter: greeter
        launcher: launcher
        dash: dash
        indicators: panel.indicators
        underlay: underlay
    }

    Connections {
        target: SessionBroadcast
        onShowHome: showHome()
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_PowerOff || event.key == Qt.Key_PowerDown) {
            if (!powerKeyTimer.running) {
                powerKeyTimer.start();
            }
            event.accepted = true;
        }
    }

    Keys.onReleased: {
        if (event.key == Qt.Key_PowerOff || event.key == Qt.Key_PowerDown) {
            powerKeyTimer.stop();
            event.accepted = true;
        }
    }

    Timer {
        id: powerKeyTimer
        interval: 2000
        repeat: false
        triggeredOnStart: false

        onTriggered: {
            stages.showPowerDialog();
        }
    }

    Rectangle {
        id: shutdownFadeOutRectangle
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
