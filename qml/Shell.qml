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
import Mir.Application 0.1
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
import "Components"
import "Notifications"
import "Stages"
import Unity.Notifications 1.0 as NotificationBackend

FocusScope {
    id: shell

    property int orientationAngle
    property real edgeSize: units.gu(2)
    property url defaultBackground: Qt.resolvedUrl(shell.width >= units.gu(60) ? "graphics/tablet_background.jpg" : "graphics/phone_background.jpg")
    property url background
    readonly property real panelHeight: panel.panelHeight

    property bool dashShown: dash.shown

    property bool sideStageEnabled: shell.width >= units.gu(100)

    function activateApplication(appId) {
        if (ApplicationManager.findApplication(appId)) {
            ApplicationManager.requestFocusApplication(appId);
        } else {
            var execFlags = shell.sideStageEnabled ? ApplicationManager.NoFlag : ApplicationManager.ForceMainStage;
            ApplicationManager.startApplication(appId, execFlags);
            stages.show();
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
        id: underlay
        objectName: "underlay"
        anchors.fill: parent

        // Whether the underlay is fully covered by opaque UI elements.
        property bool fullyCovered: panel.indicators.fullyOpened && shell.width <= panel.indicatorsMenuWidth

        // NB! Application surfaces are stacked behind the shell one. So they can only be seen by the user
        // through the translucent parts of the shell surface.
        visible: !fullyCovered

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

            orientationAngle: shell.orientationAngle

            available: !greeter.shown && !lockscreen.shown
            hides: [stages, launcher, panel.indicators]
            shown: disappearingAnimationProgress !== 1.0 && greeterWrapper.showProgress !== 1.0
            enabled: disappearingAnimationProgress === 0.0 && greeterWrapper.showProgress === 0.0 && edgeDemo.dashEnabled

            anchors {
                fill: parent
                topMargin: panel.panelHeight
            }

            contentScale: 1.0 - 0.2 * disappearingAnimationProgress
            opacity: 1.0 - disappearingAnimationProgress
            property real disappearingAnimationProgress: stages.showProgress

            // FIXME: only necessary because stages.showProgress is not animated
            Behavior on disappearingAnimationProgress { SmoothedAnimation { velocity: 5 }}
        }
    }

    EdgeDragArea {
        id: stagesDragArea
        direction: Direction.Leftwards

        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: shell.edgeSize

        property real progress: stages.width

        onTouchXChanged: {
            if (status == DirectionalDragArea.Recognized) {
                if (stages.empty) {
                    progress = Math.max(stages.width - stagesDragArea.width + touchX, stages.width * .3);
                } else {
                    progress = stages.width - stagesDragArea.width + touchX;
                }
            }
        }

        onDraggingChanged: {
            if (!dragging) {
                if (!stages.empty && progress < stages.width - units.gu(10)) {
                    stages.show();
                }
                stagesDragArea.progress = Qt.binding(function () { return stages.width; });
            }
        }
    }

    Rectangle {
        id: stages
        objectName: "stages"
        width: parent.width
        height: parent.height
        color: "khaki"

        visible: !fullyHidden

        x: shown ? launcher.progress : stagesDragArea.progress
        //Behavior on x { SmoothedAnimation { velocity: 600; duration: UbuntuAnimation.FastDuration } }

        property bool shown: false
        onShownChanged: {
            if (!shown && ApplicationManager.focusedApplicationId) {
                ApplicationManager.updateScreenshot(ApplicationManager.focusedApplicationId);
                ApplicationManager.unfocusCurrentApplication();
            }
        }

        // Avoid a silent "divide by zero -> NaN" situation during init as shell.width will be
        // zero. That breaks the property binding and the function won't be reevaluated once
        // shell.width is set, with the NaN result staying there for good.
        property real showProgress: shell.width ? MathUtils.clamp(1 - x / shell.width, 0, 1) : 0

        property bool fullyShown: x == 0
        property bool fullyHidden: x == width

        property bool empty: SurfaceManager.count == 0
        onEmptyChanged: {
            if (empty) {
                hide();
            }
        }

        function show() {
            shown = true;
        }

        function hide() {
            shown = false;
        }

        Connections {
            target: ApplicationManager
            onFocusRequested: { stages.show(); }
        }

        Loader {
            id: applicationsDisplayLoader
            anchors.fill: parent

            source: shell.sideStageEnabled ? "Stages/StageWithSideStage.qml" : "Stages/PhoneStage.qml"

            Binding {
                target: applicationsDisplayLoader.item
                property: "surfaces"
                value: SurfaceManager
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "dragAreaWidth"
                value: shell.edgeSize
            }
            Binding {
                target: applicationsDisplayLoader.item
                property: "orientationAngleOfSurfaces"
                value: shell.orientationAngle
            }
        }
    }

    InputMethod {
        id: inputMethod
    }

    Connections {
        target: SurfaceManager
        onSurfaceCreated: {
            if (surface.type == MirSurfaceItem.InputMethod) {
                inputMethod.surface = surface;
            } else {
                stages.show();
            }
        }

        onSurfaceDestroyed: {
            var orphan = !surface.parent;
            if (inputMethod.surface == surface) {
                inputMethod.removeSurface(surface);
            }
            if (orphan) {
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

        Behavior on x {SmoothedAnimation{velocity: 600}}

        readonly property real showProgress: MathUtils.clamp((1 - x/width) + greeter.showProgress - 1, 0, 1)

        Greeter {
            id: greeter
            objectName: "greeter"

            available: true
            hides: [launcher, panel.indicators]
            shown: true

            defaultBackground: shell.background

            width: parent.width
            height: parent.height

            dragHandleWidth: shell.edgeSize

            onShownChanged: {
                if (shown) {
                    lockscreen.reset();
                    // If there is only one user, we start authenticating with that one here.
                    // If there are more users, the Greeter will handle that
                    if (LightDM.Users.count == 1) {
                        LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole));
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
        dash.setCurrentScope("clickscope", animate, false)
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
            //fullscreenMode: focusedApplication && stages.fullscreen && !greeter.shown && !lockscreen.shown
            fullscreenMode: focusedApplication && !greeter.shown && !lockscreen.shown
            searchVisible: !greeter.shown && !lockscreen.shown && dash.shown && dash.searchable
        }

        Launcher {
            id: launcher

            readonly property bool dashSwipe: progress > 0

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            dragAreaWidth: shell.edgeSize
            available: edgeDemo.launcherEnabled

            onShowDashHome: {
                if (edgeDemo.running)
                    return;

                showHome()
            }
            onDash: {
                if (!stages.locked) {
                    stages.hide();
                    launcher.hide();
                }
                if (greeter.shown) {
                    greeter.hideRight();
                    launcher.hide();
                }
            }
            onDashSwipeChanged: if (dashSwipe && stages.shown) dash.setCurrentScope("clickscope", false, true)
            onLauncherApplicationSelected: {
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
        }
    }

    focus: true
    onFocusChanged: if (!focus) forceActiveFocus();

    Binding {
        target: i18n
        property: "domain"
        value: "unity8"
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
