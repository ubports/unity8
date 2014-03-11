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
import Unity.Application 0.1
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1

/*
  Responsible for application switching.

  Drag from the right edge to switch to the next application.
  While being dragged, this component will show an animation for the user to
  visualize that he's changing the stacking of applications (next/new app comes from
  right edge and current/old app fades out).
 */
Showable {
    id: stage

    width: units.gu(40)
    height: units.gu(71)

    property int type: ApplicationInfo.MainStage
    property var applicationManager
    readonly property var applications:
        type == ApplicationInfo.MainStage ? applicationManager.mainStageApplications
                                            : applicationManager.sideStageApplications
    property bool fullyShown: false
    property bool fullyHidden: true
    readonly property var focusedApplication:
        type == ApplicationInfo.MainStage ? applicationManager.mainStageFocusedApplication
                                            : applicationManager.sideStageFocusedApplication
    property bool shouldUseScreenshots: true

    /* Will be true whenever application screenshots are being shown.
       i.e. during application window transitions */
    readonly property bool usingScreenshots: {
        if (newApplicationScreenshot.application != null && oldApplicationScreenshot.application != null) {
            return newApplicationScreenshot.ready && oldApplicationScreenshot.ready;
        } else {
            return newApplicationScreenshot.ready || oldApplicationScreenshot.ready;
        }
    }

    property bool rightEdgeEnabled: true
    property bool switchingFromFullscreenToFullscreen: false

    property alias rightEdgeDraggingAreaWidth: rightEdgeDraggingArea.width

    // Y coordinate for non-fullscreen applications
    property int normalApplicationY: 0

    function activateApplication(desktopFile, addDelay) {
        var application = applicationManager.getApplicationFromDesktopFile(desktopFile, stage.type);
        if (application == null) {
            return;
        } else if (application == stage.focusedApplication) {
            stage.show();
            return;
        }

        showStartingApplicationAnimation.prepare(application);
        if (!stage.fullyShown) {
            // if launching this app reveals the stage, make new application screenshot visible
            newApplicationScreenshot.visible = true;
            stage.show();
        } else {
            showStartingApplicationAnimation.start();
        }

        if (addDelay) {
            stage.__startingApplicationDesktopFile = desktopFile;
        }
    }

    Connections {
        target: applicationManager
        onFocusRequested: activateApplication(appId)
    }

    /* Keep a reference to the focused application so that we can safely
       unfocus it when the stage is not fully shown and refocus it when the stage
       is fully shown again.
    */
    property var focusedApplicationWhenUsingScreenshots
    onShouldUseScreenshotsChanged: {
        if (showStartingApplicationAnimation.running || switchToApplicationAnimation.running) {
            return;
        }

        if (shouldUseScreenshots) {
            stage.__focusApplicationUsingScreenshots(stage.focusedApplication);
        } else {
            if (stage.focusedApplicationWhenUsingScreenshots) {
                stage.__focusActualApplication(stage.focusedApplicationWhenUsingScreenshots);
            }
        }
    }


    property Item newApplicationScreenshot: ApplicationScreenshot {
                                               parent: stage
                                               width: stage.width
                                               height: stage.height - y
                                           }
    property Item oldApplicationScreenshot: ApplicationScreenshot {
                                               parent: stage
                                               width: stage.width
                                               height: stage.height - y
                                           }

    function __getApplicationIndex(application) {
        if (!application)
            return -1
        for (var i = 0; i < stage.applications.count; i++ ) {
            if (stage.applications.get(i).desktopFile == application.desktopFile) {
                return i
            }
        }
        return -1
    }


    property string __startingApplicationDesktopFile

    Timer {
        id: delayedHideScreenshots
        interval: 500 // on Galaxy Nexus, Telephony app is slowest application to draw a frame so needs this delay
        onTriggered: {
            __hideScreenshots();
        }
    }

    Timer {
        id: hideScreenshotsAfterBriefDelay
        // Since Mir & Qt have independent event loops, Mir often applies a focus request a frame later than when Qt
        // asks for it. To work around, delay removing the screenshots a touch so Mir has definitely shown the app.
        interval: 10
        onTriggered: stage.__hideScreenshots();
    }

    function __hideScreenshots() {
        newApplicationScreenshot.clearApplication();
        oldApplicationScreenshot.clearApplication();
        newApplicationScreenshot.visible = false;
        oldApplicationScreenshot.visible = false;
    }

    function __focusApplication(application) {
        if (!application) return
        if (shouldUseScreenshots) {
            stage.__focusApplicationUsingScreenshots(application);
        } else {
            stage.__focusActualApplication(application);
        }
    }


    function __focusActualApplication(application) {
        if (application == null) {
            return;
        }

        if (stage.focusedApplication == application) {
            /* FIXME: this case is reached when showing the sidestage, we
               need to refocus the side stage app in order to show it.
               FIXME: this case is reached when doing a right edge swipe
               while in the dash to bring back the stage.
               FIXME: this case is reached when showStartingApplicationAnimation
               finishes after the newly started application has been focused
               automatically by the ApplicationManager.
            */
            if (stage.type == ApplicationInfo.SideStage) {
                applicationManager.focusApplication(application);
            }
            if (!delayedHideScreenshots.running) {
                hideScreenshotsAfterBriefDelay.start();
            }
        } else {
            /* FIXME: calling ApplicationManager::focusApplication does not focus
               the application immediately nor show the application's surface
               immediately. Delay hiding the screenshots until it has done so.
            */
            delayedHideScreenshots.stop();
            applicationManager.focusApplication(application);
        }
        stage.focusedApplicationWhenUsingScreenshots = null;
    }

    function __focusApplicationUsingScreenshots(application) {
        delayedHideScreenshots.stop();
        if (application == null) {
            return;
        }

        if (newApplicationScreenshot.application != null) {
            stage.focusedApplicationWhenUsingScreenshots = application;
            return;
        }

        newApplicationScreenshot.setApplication(application);
        newApplicationScreenshot.scheduleUpdate();
        newApplicationScreenshot.opacity = 1.0;
        newApplicationScreenshot.x = 0.0;
        newApplicationScreenshot.y = __getApplicationY(application);
        newApplicationScreenshot.scale = 1.0;
        newApplicationScreenshot.visible = true;
        stage.focusedApplicationWhenUsingScreenshots = application;
        stage.switchingFromFullscreenToFullscreen = false;
    }

    function __getApplicationY(application) {
        return Qt.binding( function(){
            return (application && application.fullscreen
                    && application.stage !== ApplicationInfo.SideStage)
                        ? 0 : normalApplicationY;
        } )
    }

    /* FIXME: should hide the screenshots when the focused application's surface
       is visible. There is no API in QtUbuntu to support that yet.
    */
    Connections {
        target: stage
        onFocusedApplicationChanged: {
            if (stage.focusedApplication != null) {
                /* Move application to the beginning of the list of running applications */
                var index = stage.__getApplicationIndex(stage.focusedApplication);
                applicationManager.moveRunningApplicationStackPosition(index, 0, stage.type);

                var startingApplication = applicationManager.getApplicationFromDesktopFile(
                        stage.__startingApplicationDesktopFile, stage.type);

                if (stage.focusedApplication == startingApplication) {
                    stage.__startingApplicationDesktopFile = "";

                    /* Screenshots might still be in use at this point and their
                       use can be stopped before delayedHideScreenshots is complete.
                       Prepare for that case by setting appropriately
                       stage.focusedApplicationWhenUsingScreenshots.
                    */
                    stage.focusedApplicationWhenUsingScreenshots = stage.focusedApplication;

                    /* FIXME: should hide the screenshots when the focused application's window
                       is visible. There is no API in qtubuntu to support that yet. Therefore
                       we delay their hiding to avoid a state where neither the screenshot nor
                       the application's window is visible.
                    */
                    delayedHideScreenshots.start();
                } else {
                    stage.focusedApplicationWhenUsingScreenshots = null;
                    hideScreenshotsAfterBriefDelay.start();
                }
            }
        }
    }

    Connections {
        target: stage.applications
        onCountChanged: { __discardObsoleteScreenshots(); }
        ignoreUnknownSignals: true
    }
    onFullyHiddenChanged: { __discardObsoleteScreenshots(); }
    function __discardObsoleteScreenshots() {
        if (stage.fullyHidden && stage.applications && stage.applications.count == 0) {
            stage.focusedApplicationWhenUsingScreenshots = undefined;
            stage.__hideScreenshots();
        }
    }


    SequentialAnimation {
        id: showStartingApplicationAnimation

        function prepare(newApplication) {
            var oldApplication = stage.focusedApplication;
            newApplicationScreenshot.setApplication(newApplication);
            newApplicationScreenshot.updateFromCache();
            oldApplicationScreenshot.setApplication(oldApplication);
            oldApplicationScreenshot.scheduleUpdate();
            newApplicationScreenshot.withBackground = true; // FIXME: should be withBackground = newApplication.state == Application.Starting
            newApplicationScreenshot.y = __getApplicationY(newApplication);
            oldApplicationScreenshot.y = __getApplicationY(oldApplication);
            stage.focusedApplicationWhenUsingScreenshots = newApplication;
            stage.switchingFromFullscreenToFullscreen = false;
        }

        PropertyAction {target: newApplicationScreenshot; property: "visible"; value: false}
        PropertyAction {target: oldApplicationScreenshot; property: "visible"; value: false}
        PropertyAction {target: newApplicationScreenshot; property: "z"; value: 0}
        PropertyAction {target: oldApplicationScreenshot; property: "z"; value: 1}
        PropertyAction {target: newApplicationScreenshot; property: "scale"; value: 0.8}
        PropertyAction {target: oldApplicationScreenshot; property: "scale"; value: 1.0}
        PropertyAction {target: newApplicationScreenshot; property: "opacity"; value: 0.0}
        PropertyAction {target: oldApplicationScreenshot; property: "opacity"; value: 1.0}
        PropertyAction {target: newApplicationScreenshot; property: "x"; value: 0.0}
        PropertyAction {target: oldApplicationScreenshot; property: "x"; value: 0.0}

        ParallelAnimation {
            PropertyAction {target: newApplicationScreenshot; property: "visible"; value: true}
            NumberAnimation {
                target: newApplicationScreenshot
                property: "scale"
                duration: 500
                easing.type: Easing.OutQuad
                to: 1.0
            }
            NumberAnimation {
                target: newApplicationScreenshot
                property: "opacity"
                duration: 500
                easing.type: Easing.OutQuad
                to: 1.0
            }

            PropertyAction {target: oldApplicationScreenshot; property: "visible"; value: true}

            NumberAnimation {
                target: oldApplicationScreenshot
                property: "x"
                duration: 400
                easing.type: Easing.OutQuad
                to: stage.width
            }
        }

        ScriptAction {
            script: {
                // FIXME: only here to support case where application does
                // not exist yet but is about to
                if (stage.focusedApplicationWhenUsingScreenshots) {
                    stage.__focusApplication(stage.focusedApplicationWhenUsingScreenshots);
                }
            }
        }
    }


    SequentialAnimation {
        id: switchToApplicationAnimation

        function prepare(newApplication) {
            var oldApplication = stage.focusedApplication;
            newApplicationScreenshot.setApplication(newApplication);
            newApplicationScreenshot.updateFromCache();
            oldApplicationScreenshot.setApplication(oldApplication);
            oldApplicationScreenshot.scheduleUpdate();
            newApplicationScreenshot.withBackground = false;
            newApplicationScreenshot.y = __getApplicationY(newApplication);
            oldApplicationScreenshot.y = __getApplicationY(oldApplication);
            stage.focusedApplicationWhenUsingScreenshots = newApplication;
            stage.switchingFromFullscreenToFullscreen = newApplication && newApplication.fullscreen;
        }

        PropertyAction {target: newApplicationScreenshot; property: "visible"; value: false}
        PropertyAction {target: oldApplicationScreenshot; property: "visible"; value: false}
        PropertyAction {target: newApplicationScreenshot; property: "z"; value: 1}
        PropertyAction {target: oldApplicationScreenshot; property: "z"; value: 0}
        PropertyAction {target: newApplicationScreenshot; property: "scale"; value: 1.0}
        PropertyAction {target: oldApplicationScreenshot; property: "scale"; value: 1.0}
        PropertyAction {target: newApplicationScreenshot; property: "opacity"; value: 1.0}
        PropertyAction {target: oldApplicationScreenshot; property: "opacity"; value: 1.0}
        PropertyAction {target: newApplicationScreenshot; property: "x"; value: stage.width}
        PropertyAction {target: oldApplicationScreenshot; property: "x"; value: 0.0}
        PropertyAction {target: newApplicationScreenshot; property: "visible"; value: true}
        PropertyAction {target: oldApplicationScreenshot; property: "visible"; value: true}

        ParallelAnimation {
            NumberAnimation {
                target: oldApplicationScreenshot
                property: "scale"
                duration: 500
                easing.type: Easing.OutQuad
                to: 0.8
            }
            NumberAnimation {
                target: oldApplicationScreenshot
                property: "opacity"
                duration: 500
                easing.type: Easing.OutQuad
                to: 0.0
            }

            NumberAnimation {
                target: newApplicationScreenshot
                property: "x"
                duration: 500
                easing.type: Easing.OutQuad
                to: 0
            }
        }

        ScriptAction {
            script: {
                // move previously focused application to the end of the list of running applications
                var oldApplication = oldApplicationScreenshot.application;
                if (oldApplication != null) {
                    var oldApplicationIndex = stage.__getApplicationIndex(oldApplicationScreenshot.application);
                    applicationManager.moveRunningApplicationStackPosition(
                            oldApplicationIndex, stage.applications.count - 1, stage.type);
                }

                stage.__focusApplication(stage.focusedApplicationWhenUsingScreenshots);
            }
        }
    }


    function __dragValueToProgress(dragValue, startValue, applicationsCount) {
        if (applicationsCount == 0) {
            return 0;
        } else if (applicationsCount == 1) {
            // prevent the current app from moving more than 1/4 of the screen
            var elasticValue = __elastic(dragValue, startValue/4);
            return elasticValue / startValue;
        } else {
            return dragValue / startValue;
        }
    }

    function __elastic(x, limit) {
        return limit * ( 1 - Math.pow( ( limit - 1 ) / limit, x ) )
    }

    property real __startValue: stage.width

    AnimationControllerWithSignals {
        id: switchToApplicationAnimationController

        onAnimationCompletedAtBeginning: {
            animation = null;
            stage.__focusApplication(oldApplicationScreenshot.application);
        }
    }

    EdgeDragEvaluator {
        id: dragEvaluator
        trackedPosition: rightEdgeDraggingArea.touchX
        direction: rightEdgeDraggingArea.direction
        maxDragDistance: stage.width
    }

    EdgeDragArea {
        id: rightEdgeDraggingArea

        enabled: {
            if (status == DirectionalDragArea.WaitingForTouch) {
                return switchToApplicationAnimationController.completed
                        && stage.applications.count > 0 && stage.rightEdgeEnabled
                        && !delayedHideScreenshots.running
            } else {
                return true
            }
        }
        width: units.gu(2)
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        direction: Direction.Leftwards

        onDistanceChanged: {
            if (status !== DirectionalDragArea.Recognized)
                return

            var targetProgress = __dragValueToProgress(-distance, __startValue,
                                                       stage.applications.count)
            var delta = targetProgress - switchToApplicationAnimationController.progress

            // When the gesture finally gets recognized, the finger will likely be
            // reasonably far from the edge. If we made the progress immediately
            // follow the finger position it would be visually unpleasant as there
            // would be a jump to meet the finger's current position.
            //
            // The trick is not to go all the way (1.0) as it would cause the
            // aforementioned jump.
            switchToApplicationAnimationController.progress += 0.4 * delta
        }

        property int lastStatus: -1

        onStatusChanged: {
            if (status == DirectionalDragArea.Undecided) {
                onUndecided();
            } else if (status == DirectionalDragArea.WaitingForTouch) {
                if (lastStatus == DirectionalDragArea.Undecided) {
                    // got rejected
                    switchToApplicationAnimationController.completeToBeginningWithSignal();
                } else {
                    onGestureEnded();
                }
            }
            lastStatus = status;
        }

        function onUndecided() {
            dragEvaluator.reset();

            var nextApplication = null;
            if (stage.applications.count > 1) {
                nextApplication = stage.applications.get(1);
            }
            switchToApplicationAnimationController.progress = 0
            switchToApplicationAnimation.prepare(nextApplication);
            switchToApplicationAnimationController.animation = switchToApplicationAnimation;

        }

        function onGestureEnded() {
            if (stage.applications.count > 1 && dragEvaluator.shouldAutoComplete()) {
                switchToApplicationAnimationController.completeToEndWithSignal();
            } else {
                switchToApplicationAnimationController.completeToBeginningWithSignal();
            }
        }
    }


    // FIXME: very bad hack to detect when an application was closed or crashed
    property var __previouslyFocusedApplication
    Connections {
        target: stage
        onFocusedApplicationChanged: {
            if (stage.focusedApplication == null
                && __getApplicationIndex(stage.__previouslyFocusedApplication) == -1) {
                stage.__onFocusedApplicationClosed();
            }
            stage.__previouslyFocusedApplication = stage.focusedApplication;
        }
    }

    function __onFocusedApplicationClosed() {
        if (!stage.shown) {
            return;
        }

        if (stage.applications.count > 0) {
            // Do not change the focused application from within onFocusedApplicationChanged.
            // This causes binding loop warnings besides being a bad practice in general
            // (setting a property from within its "changed" signal handling)
            // Hence the timer.
            focusTopmostAppTimer.start();
        } else {
            stage.hide();
        }
    }

    Timer {
        id: focusTopmostAppTimer
        interval: 1; repeat: false
        onTriggered: {
            if (stage.applications.count > 0) {
                stage.__focusApplication(stage.applications.get(0));
            }
        }
    }

}
