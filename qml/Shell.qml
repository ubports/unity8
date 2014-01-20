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
import Ubuntu.Gestures 0.1
import Unity.Launcher 0.1
import LightDM 0.1 as LightDM
import Powerd 0.1
import SessionBroadcast 0.1
import "Dash"
import "Greeter"
import "Launcher"
import "Panel"
import "Hud"
import "Components"
import "Bottombar"
import "SideStage"
import "Notifications"
import Unity.Notifications 1.0 as NotificationBackend

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

    function activateApplication(appId) {
        if (ApplicationManager.findApplication(appId)) {
            print("Shell.qml: activating app", appId);
            ApplicationManager.activateApplication(appId);
        } else {
            print("starting app", appId);

            // FIXME:
//            var execFlags = sideStageEnabled ? ApplicationManager.NoFlag : ApplicationManager.ForceMainStage;
            var execFlags = ApplicationManager.ForceMainStage;

            ApplicationManager.startApplication(appId, execFlags);
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

    // This is a dummy image that is needed to determine if the picture url
    // in backgroundSettings points to a valid picture file.
    // We can't do this with the real background image because setting a
    // new source in onStatusChanged triggers a binding loop detection
    // inside Image, which causes it not to render even though a valid source
    // would be set. We don't mind about this image staying black and just
    // use it for verification to populate the source for the real
    // background image.
    Image {
        source: shell.background
        height: 0
        width: 0
        sourceSize.height: 0
        sourceSize.width: 0
        onStatusChanged: {
            if (status == Image.Error && source != shell.defaultBackground) {
                shell.background = defaultBackground
            }
        }
    }

    VolumeControl {
        id: volumeControl
    }

    Keys.onVolumeUpPressed: volumeControl.volumeUp()
    Keys.onVolumeDownPressed: volumeControl.volumeDown()

    Item {
        id: underlay
        objectName: "underlay"
        anchors.fill: parent

        // Whether the underlay is fully covered by opaque UI elements.
        property bool fullyCovered: panel.indicators.fullyOpened && shell.width <= panel.indicatorsMenuWidth

        readonly property bool applicationRunning: ApplicationManager.focusedApplicationId.length > 0
        onApplicationRunningChanged: print("***************+ application running", applicationRunning)

        // Whether the user should see the topmost application surface (if there's one at all).
        readonly property bool applicationSurfaceShouldBeSeen: applicationRunning && !stages.painting

        // NB! Application surfaces are stacked behind the shell one. So they can only be seen by the user
        // through the translucent parts of the shell surface.
        visible: !fullyCovered && !applicationSurfaceShouldBeSeen

        onVisibleChanged: print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh", visible, fullyCovered, applicationSurfaceShouldBeSeen,
                                applicationRunning, stages.fullyHidden, stages.painting)

        CrossFadeImage {
            id: backgroundImage
            objectName: "backgroundImage"

            anchors.fill: parent
            source: shell.background
            fillMode: Image.PreserveAspectCrop
        }

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: dash.disappearingAnimationProgress
        }

        Dash {
            id: dash
            objectName: "dash"

            available: !greeter.shown && !lockscreen.shown
            hides: [stages, launcher, panel.indicators]
            shown: disappearingAnimationProgress !== 1.0
            enabled: disappearingAnimationProgress === 0.0 && edgeDemo.dashEnabled

            anchors {
                fill: parent
                topMargin: panel.panelHeight
            }

            contentScale: 1.0 - 0.2 * disappearingAnimationProgress
            opacity: 1.0 - disappearingAnimationProgress
            property real disappearingAnimationProgress: {
                if (greeter.shown) {
                    return greeter.showProgress;
                } else {
                    return stagesOuterContainer.showProgress;
                }
            }

            // FIXME: only necessary because stagesOuterContainer.showProgress and
            // greeterRevealer.animatedProgress are not animated
            Behavior on disappearingAnimationProgress { SmoothedAnimation { velocity: 5 }}
        }
    }

    Item {
        id: stagesOuterContainer

        width: parent.width
        height: parent.height
        x: launcher.progress
        Behavior on x {SmoothedAnimation{velocity: 600}}

        property real showProgress: MathUtils.clamp(1 - (x + stages.x) / shell.width, 0, 1)

        Showable {
            id: stages
            objectName: "stages"

            x: width

            property bool fullyShown: shown && x == 0 && parent.x == 0
            property bool fullyHidden: !shown && x == width

            property bool painting: applicationsDisplayLoader.item ? applicationsDisplayLoader.item.painting : false

            available: !greeter.shown
            hides: [panel.indicators]
            shown: false
            opacity: 1.0
            showAnimation: StandardAnimation { property: "x"; duration: 350; to: 0; easing.type: Easing.OutCubic }
            hideAnimation: StandardAnimation { property: "x"; duration: 350; to: width; easing.type: Easing.OutCubic }

            width: parent.width
            height: parent.height

            property string lastFocusedAppId
            onShownChanged: {
                print("stages shown", shown)
                if (shown) {
                    if (!ApplicationManager.focusedApplicationId && lastFocusedAppId) {
                        ApplicationManager.focusApplication(lastFocusedAppId);
                    }
                } else {
                    lastFocusedAppId = ApplicationManager.focusedApplicationId;
                    ApplicationManager.unfocusCurrentApplication();
                }
            }

            Connections {
                target: ApplicationManager
                onFocusedApplicationIdChanged: {
                    if (ApplicationManager.focusedApplicationId.length > 0) {
                        print("should show stages")
                        stages.show();
                    } else {
                        stages.hide();
                    }
                }

                onApplicationAdded: {
                    stages.show();
                }
            }

            Loader {
                id: applicationsDisplayLoader
                anchors.fill: parent

//                source: "Stages/StageWithSideStage.qml"
                source: "Stages/PhoneStage.qml"

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
            }

            DragHandle {
                id: stagesDragHandle

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.left

                width: shell.edgeSize
                direction: Direction.Leftwards
                enabled: greeter.showProgress == 0 && edgeDemo.dashEnabled
                property bool haveApps: ApplicationManager.count > 0

                maxTotalDragDistance: haveApps ? parent.width : parent.width * 0.7
                // Make autocompletion impossible when !haveApps
                edgeDragEvaluator.minDragDistance: haveApps ? maxTotalDragDistance * 0.1 : Number.MAX_VALUE
            }
        }
    }

    Lockscreen {
        id: lockscreen
        objectName: "lockscreen"

        readonly property int backgroundTopMargin: -panel.panelHeight

        hides: [launcher, panel.indicators, hud]
        shown: false
        enabled: true
        showAnimation: StandardAnimation { property: "opacity"; to: 1 }
        hideAnimation: StandardAnimation { property: "opacity"; to: 0 }
        y: panel.panelHeight
        x: required ? 0 : - width
        width: parent.width
        height: parent.height - panel.panelHeight
        background: shell.background
        pinLength: 4

        onEntered: LightDM.Greeter.respond(passphrase);
        onCancel: greeter.show()

        Component.onCompleted: {
            if (LightDM.Users.count == 1) {
                LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole))
                greeter.selected(0)
            }
        }
    }

    Connections {
        target: LightDM.Greeter

        onShowPrompt: {
            if (LightDM.Users.count == 1) {
                // TODO: There's no better way for now to determine if its a PIN or a passphrase.
                if (text == "PIN") {
                    lockscreen.alphaNumeric = false
                } else {
                    lockscreen.alphaNumeric = true
                }
                lockscreen.placeholderText = i18n.tr("Please enter %1").arg(text);
                lockscreen.show();
            }
        }

        onAuthenticationComplete: {
            if (LightDM.Greeter.promptless) {
                return;
            }
            if (LightDM.Greeter.authenticated) {
                lockscreen.hide();
            } else {
                lockscreen.clear(true);
            }
        }
    }

    Greeter {
        id: greeter
        objectName: "greeter"

        available: true
        hides: [launcher, panel.indicators, hud]
        shown: true

        defaultBackground: shell.background

        y: panel.panelHeight
        width: parent.width
        height: parent.height - panel.panelHeight

        dragHandleWidth: shell.edgeSize

        property var previousMainApp: null
        property var previousSideApp: null

        onShownChanged: {
            if (shown) {
                lockscreen.reset();
                // If there is only one user, we start authenticating with that one here.
                // If there are more users, the Greeter will handle that
                if (LightDM.Users.count == 1) {
                    LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole));
                    greeter.selected(0);
                }
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

        onLeftTeaserPressedChanged: {
            if (leftTeaserPressed) {
                launcher.tease();
            }
        }
    }

    InputFilterArea {
        anchors.fill: parent
        blockInput: ApplicationManager.focusedApplicationId.length === 0 || greeter.shown || lockscreen.shown || launcher.shown
                    || panel.indicators.shown || hud.shown
    }

    Connections {
        id: powerConnection
        target: Powerd

        onDisplayPowerStateChange: {
            // We ignore any display-off signals when the proximity sensor
            // is active.  This usually indicates something like a phone call.
            if (status == Powerd.Off && (flags & Powerd.UseProximity) == 0) {
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
        var animate = !greeter.shown && !stages.shown
        greeter.hide()
        dash.setCurrentScope("home.scope", animate, false)
        stages.hide()
    }

    function hideIndicatorMenu(delay) {
        panel.hideIndicatorMenu(delay);
    }

    Item {
        id: overlay

        anchors.fill: parent

        Panel {
            id: panel
            anchors.fill: parent //because this draws indicator menus
            indicatorsMenuWidth: parent.width > units.gu(60) ? units.gu(40) : parent.width
            indicators {
                hides: [launcher]
                available: edgeDemo.panelEnabled
                contentEnabled: edgeDemo.panelContentEnabled
            }
            property string focusedAppId: ApplicationManager.focusedApplicationId
            property var focusedApplication: ApplicationManager.findApplication(focusedAppId)
            fullscreenMode: focusedApplication && focusedApplication.fullscreen && !greeter.shown && !lockscreen.shown
            searchVisible: !greeter.shown && !lockscreen.shown && dash.shown

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

        Hud {
            id: hud

            width: parent.width > units.gu(60) ? units.gu(40) : parent.width
            height: parent.height

            available: !greeter.shown && !panel.indicators.shown && !lockscreen.shown && edgeDemo.dashEnabled
            shown: false
            showAnimation: StandardAnimation { property: "y"; duration: hud.showableAnimationDuration; to: 0; easing.type: Easing.Linear }
            hideAnimation: StandardAnimation { property: "y"; duration: hud.showableAnimationDuration; to: hudRevealer.closedValue; easing.type: Easing.Linear }

            Connections {
                target: ApplicationManager
                onFocusedApplicationIdChanged: hud.hide()
            }
        }

        Revealer {
            id: hudRevealer

            enabled: hud.shown
            width: hud.width
            anchors.left: hud.left
            height: parent.height
            target: hud.revealerTarget
            closedValue: height
            openedValue: 0
            direction: Qt.RightToLeft
            orientation: Qt.Vertical
            handleSize: hud.handleHeight
            onCloseClicked: target.hide()
        }

        Bottombar {
            id: bottombar
            theHud: hud
            anchors.fill: parent
            enabled: hud.available
            applicationIsOnForeground: ApplicationManager.focusedApplicationId
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

            readonly property bool dashSwipe: progress > 0

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            dragAreaWidth: shell.edgeSize
            available: (!greeter.shown || greeter.narrowMode) && edgeDemo.launcherEnabled

            onShowDashHome: {
                if (edgeDemo.running)
                    return;

                showHome()
            }
            onDash: {
                if (stages.shown) {
                    stages.hide();
                    launcher.hide();
                }
            }
            onDashSwipeChanged: if (dashSwipe && stages.shown) dash.setCurrentScope("applications.scope", false, true)
            onLauncherApplicationSelected:{
                if (edgeDemo.running)
                    return;

                greeter.hide()
                shell.activateApplication(appId)
            }
            onShownChanged: {
                if (shown) {
                    panel.indicators.hide()
                    hud.hide()
                    bottombar.hide()
                }
            }
        }

        Notifications {
            id: notifications

            model: NotificationBackend.Model
            margin: units.gu(1)

            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
                topMargin: panel.panelHeight
            }
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
}
