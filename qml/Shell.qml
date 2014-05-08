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
import Powerd 0.1
import SessionBroadcast 0.1
import SessionManager 0.1
import "Dash"
import "Launcher"
import "Panel"
import "Components"
import "Notifications"
import Unity.Notifications 1.0 as NotificationBackend

BasicShell {
    id: shell

    readonly property real panelHeight: panel.panelHeight

    property bool dashShown: dash.shown

    property bool sideStageEnabled: shell.width >= units.gu(100)
    readonly property string focusedApplicationId: ApplicationManager.focusedApplicationId

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
    backgroundSource: backgroundSettings.pictureUri

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
            property bool fullyCovered: panel.indicators.fullyOpened && shell.width <= panel.indicatorsMenuWidth

            // Whether the user should see the topmost application surface (if there's one at all).
            readonly property bool applicationSurfaceShouldBeSeen: stages.shown && !stages.painting && !stages.overlayMode

            // NB! Application surfaces are stacked behind the shell one. So they can only be seen by the user
            // through the translucent parts of the shell surface.
            visible: !fullyCovered && !applicationSurfaceShouldBeSeen

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
                if (overlayMode || locked) {
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
                stages.show(true);
            }

            onFocusedApplicationIdChanged: {
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

        Binding {
            target: ApplicationManager
            property: "suspended"
            value: !SessionManager.active
        }

        Loader {
            id: applicationsDisplayLoader
            anchors.fill: parent

            source: shell.sideStageEnabled ? "Stages/StageWithSideStage.qml" : "Stages/PhoneStage.qml"

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
    }

    InputFilterArea {
        anchors.fill: parent
        blockInput: ApplicationManager.focusedApplicationId.length === 0 || launcher.shown
                    || panel.indicators.shown
    }

    Connections {
        id: powerConnection
        target: Powerd

        onDisplayPowerStateChange: {
            // We ignore any display-off signals when the proximity sensor
            // is active.  This usually indicates something like a phone call.
            if (status == Powerd.Off && (flags & Powerd.UseProximity) == 0) {
                SessionManager.lock();
            }

            // No reason to chew demo CPU when user isn't watching
            if (status == Powerd.Off) {
                edgeDemo.paused = true;
            } else if (status == Powerd.On) {
                edgeDemo.paused = false;
            }
        }
    }

    function showHome(fromLauncher) {
        var animate = fromLauncher && !stages.shown
        dash.setCurrentScope("clickscope", animate, false)
        stages.hide()
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
            fullscreenMode: focusedApplication && stages.fullscreen
            searchVisible: dash.shown && dash.searchable

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

            readonly property bool dashSwipe: progress > 0

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            dragAreaWidth: shell.edgeSize
            available: edgeDemo.launcherEnabled

            onShowDashHome: {
                if (edgeDemo.running)
                    return;

                showHome(true)
            }

            onDash: {
                if (stages.shown && !stages.overlayMode) {
                    if (!stages.locked) {
                        stages.hide();
                        launcher.hide();
                    }
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

            InputFilterArea {
                anchors.fill: parent
                blockInput: modalNotificationBackground.visible
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
        launcher: launcher
        dash: dash
        indicators: panel.indicators
        underlay: underlay
    }

    Connections {
        target: SessionBroadcast
        onShowHome: showHome(false)
    }
}
