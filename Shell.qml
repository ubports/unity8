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
import GSettings 1.0
import Ubuntu.Application 0.1
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1
import LightDM 0.1 as LightDM
import Powerd 0.1
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
    width: tablet ? units.gu(160) : applicationArguments.hasGeometry() ? applicationArguments.width() : units.gu(40)
    height: tablet ? units.gu(100) : applicationArguments.hasGeometry() ? applicationArguments.height() : units.gu(71)

    property real edgeSize: units.gu(2)
    property url defaultBackground: shell.width >= units.gu(60) ? "graphics/tablet_background.jpg" : "graphics/phone_background.jpg"
    property url background: backgroundSettings.pictureUri
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
        Theme.name = "Ubuntu.Components.Themes.SuruGradient"

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

    GSettings {
        id: backgroundSettings
        schema.id: "org.gnome.desktop.background"
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

        // Whether the user should see the topmost application surface (if there's one at all).
        property bool applicationSurfaceShouldBeSeen:
                (mainStage.applications && mainStage.applications.count > 0)
                && (!stages.fullyHidden && !mainStage.usingScreenshots)

        // NB! Application surfaces are stacked behing the shell one. So they can only be seen by the user
        // through the translucent parts of the shell surface.
        visible: !fullyCovered && !applicationSurfaceShouldBeSeen

        CrossFadeImage {
            id: backgroundImage
            objectName: "backgroundImage"
            source: shell.background
            anchors.fill: parent
            onStatusChanged: {
                if (status == Image.Error) {
                    backgroundSettings.pictureUri = shell.defaultBackground
                }
            }
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

        property real showProgress:
            MathLocal.clamp(1 - (x + stages.x) / shell.width, 0, 1)

        Showable {
            id: stages
            objectName: "stages"

            x: width

            property bool fullyShown: shown && x == 0 && parent.x == 0
            property bool fullyHidden: !shown && x == width
            available: !greeter.shown
            hides: [launcher, panel.indicators]
            shown: false
            opacity: 1.0
            showAnimation: StandardAnimation { property: "x"; duration: 350; to: 0; easing.type: Easing.OutCubic }
            hideAnimation: StandardAnimation { property: "x"; duration: 350; to: width; easing.type: Easing.OutCubic }

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
                fullyHidden: stages.fullyHidden
                shouldUseScreenshots: !fullyShown
                rightEdgeEnabled: !sideStage.enabled

                applicationManager: shell.applicationManager
                rightEdgeDraggingAreaWidth: shell.edgeSize
                normalApplicationY: shell.panelHeight

                shown: true
                function show() {
                    stages.show();
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

            DragHandle {
                id: stagesDragHandle

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.left

                width: shell.edgeSize
                direction: Direction.Leftwards
                property bool haveApps: mainStage.applications.count > 0 || sideStage.applications.count > 0

                maxTotalDragDistance: haveApps ? parent.width : parent.width * 0.7
                // Make autocompletion impossible when !haveApps
                edgeDragEvaluator.minDragDistance: haveApps ? maxTotalDragDistance * 0.1 : Number.MAX_VALUE
            }
        }
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

        y: panel.panelHeight
        width: parent.width
        height: parent.height - panel.panelHeight

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
            var bgPath = greeter.model.data(uid, LightDM.UserRoles.BackgroundPathRole)
            shell.background = bgPath ? bgPath : defaultBackground
        }

        onLeftTeaserPressedChanged: {
            if (leftTeaserPressed) {
                launcher.tease();
            }
        }
    }

    InputFilterArea {
        anchors.fill: parent
        blockInput: greeter.shown || lockscreen.shown
    }

    Connections {
        id: powerConnection
        target: Powerd

        property var previousMainApp: null
        property var previousSideApp: null

        function setFocused(focused) {
            if (!focused) {
                // FIXME: *FocusedApplication are not updated when unfocused, hence the need to check whether
                // the stage was actually shown
                if (mainStage.fullyShown) powerConnection.previousMainApp = applicationManager.mainStageFocusedApplication;
                if (sideStage.fullyShown) powerConnection.previousSideApp = applicationManager.sideStageFocusedApplication;
                applicationManager.unfocusCurrentApplication();
            } else {
                if (powerConnection.previousMainApp) {
                    applicationManager.focusApplication(powerConnection.previousMainApp);
                    powerConnection.previousMainApp = null;
                }
                if (powerConnection.previousSideApp) {
                    applicationManager.focusApplication(powerConnection.previousSideApp);
                    powerConnection.previousSideApp = null;
                }
            }
        }

        onPowerStateChange: {
            if (state == 0) { // suspend
                powerConnection.setFocused(false);
                greeter.show();
            } else if (state == 1) { // active
                powerConnection.setFocused(true);
            }
        }
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
            available: !greeter.shown || greeter.narrowMode
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

    Label {
        anchors.fill: parent
        visible: applicationManager.fake
        text: "EARLY ALPHA\nNOT READY FOR USE"
        color: "lightgrey"
        opacity: 0.2
        font.weight: Font.Black
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.Fit
        font.pixelSize: height/2
        rotation: -45
    }
}
