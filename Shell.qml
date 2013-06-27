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
import Ubuntu.Application 0.1
import Ubuntu.Components 0.1
import LightDM 0.1 as LightDM
import "Dash"
import "Greeter"
import "Launcher"
import "Panel"
import "Hud"
import "Components"
import "Components/Math.js" as MathLocal
import "Bottombar"
import "SideStage"
import "Notifications"
import Unity.Notifications 1.0 as NotificationBackend

FocusScope {
    id: shell

    // this is only here to select the width / height of the window if not running fullscreen
    property bool tablet: false
    width: tablet ? units.gu(160) : units.gu(40)
    height: tablet ? units.gu(100) : units.gu(71)

    property real edgeSize: units.gu(2)
    property url default_background: shell.width >= units.gu(60) ? "graphics/tablet_background.jpg" : "graphics/phone_background.jpg"
    property url background: default_background
    readonly property real panelHeight: panel.panelHeight

    property bool dashShown: dash.shown
    property bool stageScreenshotsReady: {
        if (sideStage.shown) {
            if (mainStage.applications.count > 0) {
                return mainStage.usingScreenshots && sideStage.usingScreenshots;
            } else {
                return sideStage.usingScreenshots;
            }
        } else {
            return mainStage.usingScreenshots;
        }
    }

    property ListModel searchHistory: SearchHistoryModel {}

    property var applicationManager: ApplicationManagerWrapper {}

    Component.onCompleted: {
        applicationManager.sideStageEnabled = Qt.binding(function() { return sideStage.enabled })

        // FIXME: if application focused before shell starts, shell draws on top of it only.
        // We should detect already running applications on shell start and bring them to the front.
        applicationManager.unfocusCurrentApplication();
    }

    readonly property bool fullscreenMode: {
        if (greeter.shown || lockscreen.shown) {
            return false;
        } else if (mainStage.usingScreenshots) { // Window Manager animating so want to re-evaluate fullscreen mode
            return mainStage.switchingFromFullscreenToFullscreen;
        } else if (applicationManager.mainStageFocusedApplication) {
            return applicationManager.mainStageFocusedApplication.fullscreen;
        } else {
            return false;
        }
    }

    Connections {
        target: applicationManager
        ignoreUnknownSignals: true
        onFocusRequested: {
            // TODO: this should be protected to only unlock for certain applications / certain usecases
            // potentially only in connection with a notification
            greeter.hide();
            shell.activateApplication(desktopFile);
        }
    }

    function activateApplication(desktopFile, argument) {
        if (applicationManager) {
            // For newly started applications, as it takes them time to draw their first frame
            // we add a delay before we hide the animation screenshots to compensate.
            var addDelay = !applicationManager.getApplicationFromDesktopFile(desktopFile);

            var application;
            application = applicationManager.activateApplication(desktopFile, argument);
            if (application == null) {
                return;
            }
            if (application.stage == ApplicationInfo.MainStage || !sideStage.enabled) {
                mainStage.activateApplication(desktopFile, addDelay);
            } else {
                sideStage.activateApplication(desktopFile, addDelay);
            }
            stages.show();
        }
    }

    VolumeControl {
        id: volumeControl
    }

    Keys.onVolumeUpPressed: volumeControl.volumeUp()
    Keys.onVolumeDownPressed: volumeControl.volumeDown()

    Keys.onReleased: {
        if (event.key == Qt.Key_PowerOff) {
            greeter.show()
        }
    }

    Item {
        id: underlay
        anchors.fill: parent
        visible: !(panel.indicators.fullyOpened && shell.width <= panel.indicatorsMenuWidth)
                 && (stages.fullyHidden
                     || (stages.fullyShown && mainStage.usingScreenshots)
                     || !stages.fullyShown && (mainStage.usingScreenshots || (sideStage.shown && sideStage.usingScreenshots)))

        Image {
            id: backgroundImage
            source: shell.background
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            anchors.fill: parent
        }

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: dash.disappearingAnimationProgress
        }

        Dash {
            id: dash

            available: !greeter.shown && !lockscreen.shown
            hides: [stages, launcher, panel.indicators]
            shown: disappearingAnimationProgress !== 1.0
            enabled: disappearingAnimationProgress === 0.0
            // FIXME: unfocus all applications when going back to the dash
            onEnabledChanged: {
                if (enabled) {
                    shell.applicationManager.unfocusCurrentApplication()
                }
            }

            anchors {
                fill: parent
                topMargin: panel.panelHeight
            }

            contentScale: 1.0 - 0.2 * disappearingAnimationProgress
            opacity: 1.0 - disappearingAnimationProgress
            property real disappearingAnimationProgress: ((greeter.shown) ? greeterRevealer.animatedProgress : stagesRevealer.animatedProgress)
            // FIXME: only necessary because stagesRevealer.animatedProgress and
            // greeterRevealer.animatedProgress are not animated
            Behavior on disappearingAnimationProgress { SmoothedAnimation { velocity: 5 }}
        }
    }


    Item {

        width: parent.width
        height: parent.height
        x: launcher.progress
        Behavior on x {SmoothedAnimation{velocity: 600}}


        Showable {
            id: stages

            property bool fullyShown: shown && stages[stagesRevealer.boundProperty] == stagesRevealer.openedValue
                                      && parent.x == 0

            property bool fullyHidden: !shown && stages[stagesRevealer.boundProperty] == stagesRevealer.closedValue
            available: !greeter.shown
            hides: [launcher, panel.indicators]
            shown: false
            opacity: 1.0
            showAnimation: StandardAnimation { property: "x"; duration: 350; to: stagesRevealer.openedValue; easing.type: Easing.OutCubic }
            hideAnimation: StandardAnimation { property: "x"; duration: 350; to: stagesRevealer.closedValue; easing.type: Easing.OutCubic }

            width: parent.width
            height: parent.height

            // close the stages when no focused application remains
            Connections {
                target: shell.applicationManager
                onMainStageFocusedApplicationChanged: stages.closeIfNoApplications()
                onSideStageFocusedApplicationChanged: stages.closeIfNoApplications()
                ignoreUnknownSignals: true
            }

            function closeIfNoApplications() {
                if (!shell.applicationManager.mainStageFocusedApplication
                 && !shell.applicationManager.sideStageFocusedApplication
                 && shell.applicationManager.mainStageApplications.count == 0
                 && shell.applicationManager.sideStageApplications.count == 0) {
                    stages.hide();
                }
            }

            // show the stages when an application gets the focus
            Connections {
                target: shell.applicationManager
                onMainStageFocusedApplicationChanged: {
                    if (shell.applicationManager.mainStageFocusedApplication) {
                        mainStage.show();
                        stages.show();
                    }
                }
                onSideStageFocusedApplicationChanged: {
                    if (shell.applicationManager.sideStageFocusedApplication) {
                        sideStage.show();
                        stages.show();
                    }
                }
                ignoreUnknownSignals: true
            }


            Stage {
                id: mainStage

                anchors.fill: parent
                fullyShown: stages.fullyShown
                shouldUseScreenshots: !fullyShown
                rightEdgeEnabled: !sideStage.enabled

                applicationManager: shell.applicationManager
                rightEdgeDraggingAreaWidth: shell.edgeSize
                normalApplicationY: shell.panelHeight

                shown: true
                function show() {
                    stages.show();
                }
                function showWithoutAnimation() {
                    stages.showWithoutAnimation();
                }
                function hide() {
                }

                // FIXME: workaround the fact that focusing a main stage application
                // raises its surface on top of all other surfaces including the ones
                // that belong to side stage applications.
                onFocusedApplicationChanged: {
                    if (focusedApplication && sideStage.focusedApplication && sideStage.fullyShown) {
                        shell.applicationManager.focusApplication(sideStage.focusedApplication);
                    }
                }
            }

            SideStage {
                id: sideStage

                applicationManager: shell.applicationManager
                rightEdgeDraggingAreaWidth: shell.edgeSize
                normalApplicationY: shell.panelHeight

                onShownChanged: {
                    if (!shown && mainStage.applications.count == 0) {
                        stages.hide();
                    }
                }
                // FIXME: when hiding the side stage, refocus the main stage
                // application so that it goes in front of the side stage
                // application and hides it
                onFullyShownChanged: {
                    if (!fullyShown && stages.fullyShown && sideStage.focusedApplication != null) {
                        shell.applicationManager.focusApplication(mainStage.focusedApplication);
                    }
                }

                enabled: shell.width >= units.gu(60)
                visible: enabled
                fullyShown: stages.fullyShown && shown
                            && sideStage[sideStageRevealer.boundProperty] == sideStageRevealer.openedValue
                shouldUseScreenshots: !fullyShown || mainStage.usingScreenshots || sideStageRevealer.pressed

                available: !greeter.shown && !lockscreen.shown && enabled
                hides: [launcher, panel.indicators]
                shown: false
                showAnimation: StandardAnimation { property: "x"; duration: 350; to: sideStageRevealer.openedValue; easing.type: Easing.OutQuint }
                hideAnimation: StandardAnimation { property: "x"; duration: 350; to: sideStageRevealer.closedValue; easing.type: Easing.OutQuint }

                width: units.gu(40)
                height: stages.height
                handleExpanded: sideStageRevealer.pressed
            }

            Revealer {
                id: sideStageRevealer

                enabled: mainStage.applications.count > 0 && sideStage.applications.count > 0
                         && sideStage.available
                direction: Qt.RightToLeft
                openedValue: parent.width - sideStage.width
                hintDisplacement: units.gu(3)
                /* The size of the sidestage handle needs to be bigger than the
                   typical size used for edge detection otherwise it is really
                   hard to grab.
                */
                handleSize: sideStage.shown ? units.gu(4) : shell.edgeSize
                closedValue: parent.width + sideStage.handleSizeCollapsed
                target: sideStage
                x: parent.width - width
                width: sideStage.width + handleSize * 0.7
                height: sideStage.height
                orientation: Qt.Horizontal
            }
        }
    }


    Revealer {
        id: stagesRevealer

        property real animatedProgress: MathLocal.clamp((-dragPosition - launcher.progress) / closedValue, 0, 1)
        enabled: mainStage.applications.count > 0 || sideStage.applications.count > 0
        direction: Qt.RightToLeft
        openedValue: 0
        hintDisplacement: units.gu(3)
        handleSize: shell.edgeSize
        closedValue: width
        target: stages
        width: stages.width
        height: stages.height
        orientation: Qt.Horizontal
    }

    Lockscreen {
        id: lockscreen
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

        onUnlocked: lockscreen.hide()
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
    }

    Greeter {
        id: greeter

        available: true
        hides: [launcher, panel.indicators, hud]
        shown: true
        showAnimation: StandardAnimation { property: "x"; to: greeterRevealer.openedValue }
        hideAnimation: StandardAnimation { property: "x"; to: greeterRevealer.closedValue }
        y: panel.panelHeight
        width: parent.width
        height: parent.height - panel.panelHeight

        property var previousMainApp: null
        property var previousSideApp: null

        onShownChanged: {
            if (shown) {
                lockscreen.reset();
                // If there is only one user, we start authenticating with that one here.
                // If there are more users, the Greeter will handle that
                if (LightDM.Users.count == 1) {
                    LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole));
                }
                greeter.forceActiveFocus();
                // FIXME: *FocusedApplication are not updated when unfocused, hence the need to check whether
                // the stage was actually shown
                if (mainStage.fullyShown) greeter.previousMainApp = applicationManager.mainStageFocusedApplication;
                if (sideStage.fullyShown) greeter.previousSideApp = applicationManager.sideStageFocusedApplication;
                applicationManager.unfocusCurrentApplication();
            } else {
                if (greeter.previousMainApp) {
                    applicationManager.focusApplication(greeter.previousMainApp);
                    greeter.previousMainApp = null;
                }
                if (greeter.previousSideApp) {
                    applicationManager.focusApplication(greeter.previousSideApp);
                    greeter.previousSideApp = null;
                }
            }
        }

        onUnlocked: greeter.hide()
        onSelected: {
            var bgPath = greeter.model.data(uid, LightDM.UserRoles.BackgroundPathRole)
            shell.background = bgPath ? bgPath : default_background
        }
    }

    InputFilterArea {
        anchors.fill: parent
        blockInput: greeter.shown || lockscreen.shown
    }

    Revealer {
        id: greeterRevealer

        property real animatedProgress: MathLocal.clamp(-dragPosition / closedValue, 0, 1)
        target: greeter
        width: greeter.width
        height: greeter.height
        handleSize: shell.edgeSize
        orientation: Qt.Horizontal
        visible: greeter.shown
        enabled: !greeter.locked
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
            }
            fullscreenMode: shell.fullscreenMode
            searchVisible: !greeter.shown && !lockscreen.shown

            InputFilterArea {
                anchors.fill: parent
                blockInput: panel.indicators.shown
            }
        }

        Hud {
            id: hud

            width: parent.width > units.gu(60) ? units.gu(40) : parent.width
            height: parent.height

            available: !greeter.shown && !panel.indicators.shown && !lockscreen.shown
            shown: false
            showAnimation: StandardAnimation { property: "y"; duration: hud.showableAnimationDuration; to: 0; easing.type: Easing.Linear }
            hideAnimation: StandardAnimation { property: "y"; duration: hud.showableAnimationDuration; to: hudRevealer.closedValue; easing.type: Easing.Linear }

            Connections {
                target: shell.applicationManager
                onMainStageFocusedApplicationChanged: hud.hide()
                onSideStageFocusedApplicationChanged: hud.hide()
            }

            InputFilterArea {
                anchors.fill: parent
                blockInput: hud.shown
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
            theHud: hud
            anchors.fill: parent
            enabled: !panel.indicators.shown
            applicationIsOnForeground: applicationManager.mainStageFocusedApplication
                                    || applicationManager.sideStageFocusedApplication
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

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            dragAreaWidth: shell.edgeSize
            available: !greeter.locked
            teasing: available && greeter.leftTeaserPressed
            onDashItemSelected: {
                greeter.hide()
                // Animate if moving between application and dash
                if (!stages.shown) {
                    dash.setCurrentScope("home.scope", true, false)
                } else {
                    dash.setCurrentScope("home.scope", false, false)
                }
                stages.hide();
            }
            onDash: {
                if (stages.shown) {
                    dash.setCurrentScope("applications.scope", true, false)
                    stages.hide();
                    launcher.hide();
                }
            }
            onLauncherApplicationSelected:{
                greeter.hide()
                shell.activateApplication(desktopFile)
            }
            onShownChanged: {
                if (shown) {
                    panel.indicators.hide()
                    hud.hide()
                }
            }
        }

        Notifications {
            id: notifications

            model: NotificationBackend.Model
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
                topMargin: panel.panelHeight + units.gu(1)
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

    //FIXME: This should be handled in the input stack, keyboard shouldnt propagate
    MouseArea {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: shell.applicationManager ? shell.applicationManager.keyboardHeight : 0

        enabled: shell.applicationManager && shell.applicationManager.keyboardVisible
    }
}
