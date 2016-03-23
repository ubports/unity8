/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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
import AccountsService 0.1
import Unity.Application 0.1

Item {
    id: root

    property Item launcher
    property Item panel
    property Item stage
    property string usageScenario
    property bool paused
    property bool keyboardVisible
    property var lastInputTimestamp

    readonly property bool launcherEnabled: !running
                                            || tutorialLeftLoader.shown
                                            || tutorialLeftLongLoader.shown
    readonly property bool spreadEnabled: !running || tutorialRightLoader.shown
    readonly property bool panelEnabled: !running || tutorialTopLoader.shown
    readonly property bool running: tutorialLeftLoader.shown
                                    || tutorialTopLoader.shown
                                    || tutorialRightLoader.shown
                                    || tutorialBottomLoader.shown

    signal finished()

    function finish() {
        finished();
    }

    ////

    QtObject {
        id: d

        // We allow "" because it is briefly empty on startup, and we don't
        // want to improperly skip any mobile tutorials.
        property bool mobileScenario: root.usageScenario === "" ||
                                      root.usageScenario === "phone" ||
                                      root.usageScenario === "tablet"

        property var focusedApp: ApplicationManager.focusedApplicationId
                                 ? ApplicationManager.findApplication(ApplicationManager.focusedApplicationId)
                                 : null

        function haveShown(tutorialId) {
            return AccountsService.demoEdgesCompleted.indexOf(tutorialId) != -1;
        }

        property bool endPointsFinished: tutorialRightLoader.skipped &&
                                         tutorialBottomLoader.skipped
        onEndPointsFinishedChanged: if (endPointsFinished) root.finish()
    }

    Loader {
        id: tutorialLeftLoader
        objectName: "tutorialLeftLoader"
        anchors.fill: parent

        readonly property bool skipped: !d.mobileScenario || d.haveShown("left")
        readonly property bool shown: item && item.shown
        active: !skipped || (item && item.visible)
        onSkippedChanged: if (skipped && shown) item.hide()

        sourceComponent: TutorialLeft {
            id: tutorialLeft
            objectName: "tutorialLeft"
            anchors.fill: parent
            launcher: root.launcher
            hides: [launcher, panel.indicators]
            paused: root.paused

            isReady: !tutorialLeftLoader.skipped && !paused && !keyboardVisible &&
                     !tutorialBottomLoader.shown && !tutorialBottomLoader.mightShow

            // Use an idle timer here, because when constructed, all our isReady variables will be false.
            // Qml needs a moment to copy their values from Tutorial.qml.  So we idle it and recheck.
            Timer {
                id: tutorialLeftTimer
                interval: 0
                onTriggered: if (tutorialLeft.isReady && !tutorialLeft.shown) tutorialLeft.show()
            }

            onIsReadyChanged: if (isReady && !shown) tutorialLeftTimer.start()
            onFinished: AccountsService.markDemoEdgeCompleted("left")
        }
    }

    Loader {
        id: tutorialLeftLongLoader
        objectName: "tutorialLeftLongLoader"
        anchors.fill: parent

        readonly property bool skipped: !d.mobileScenario || d.haveShown("left-long")
        readonly property bool shown: item && item.shown
        active: !skipped || (item && item.visible)
        onSkippedChanged: if (skipped && shown) item.hide()

        sourceComponent: TutorialLeftLong {
            id: tutorialLeftLong
            objectName: "tutorialLeftLong"
            anchors.fill: parent
            launcher: root.launcher
            hides: [launcher, panel.indicators]
            paused: root.paused

            skipped: tutorialLeftLongLoader.skipped
            isReady: tutorialLeftLoader.skipped && !skipped && !paused && !keyboardVisible &&
                     !tutorialBottomLoader.shown && !tutorialBottomLoader.mightShow

            Timer {
                id: tutorialLeftLongTimer
                objectName: "tutorialLeftLongTimer"
                interval: 5000
                onTriggered: {
                    if (parent.isReady) {
                        if (!parent.shown) {
                            parent.show();
                        }
                    } else if (!parent.skipped) {
                        restart();
                    }
                }
            }

            onIsReadyChanged: if (isReady && !shown) tutorialLeftLongTimer.start()
            onFinished: AccountsService.markDemoEdgeCompleted("left-long")
        }
    }

    Loader {
        id: tutorialTopLoader
        objectName: "tutorialTopLoader"
        anchors.fill: parent

        readonly property bool skipped: !d.mobileScenario || d.haveShown("top")
        readonly property bool shown: item && item.shown
        active: !skipped || (item && item.visible)
        onSkippedChanged: if (skipped && shown) item.hide()

        sourceComponent: TutorialTop {
            id: tutorialTop
            objectName: "tutorialTop"
            anchors.fill: parent
            panel: root.panel
            hides: [launcher, panel.indicators]
            paused: root.paused

            skipped: tutorialTopLoader.skipped
            isReady: tutorialLeftLongLoader.skipped && !skipped && !paused && !keyboardVisible &&
                     !tutorialBottomLoader.shown && !tutorialBottomLoader.mightShow

            // We fire 30s after left edge tutorial, with at least 3s of inactivity

            InactivityTimer {
                id: tutorialTopInactivityTimer
                lastInputTimestamp: root.lastInputTimestamp
                page: parent
            }

            Timer {
                id: tutorialTopTimer
                objectName: "tutorialTopTimer"
                interval: 27000
                onTriggered: tutorialTopInactivityTimer.start()
            }

            onIsReadyChanged: if (isReady && !shown) tutorialTopTimer.start()
            onFinished: AccountsService.markDemoEdgeCompleted("top")
        }
    }

    Loader {
        id: tutorialRightLoader
        objectName: "tutorialRightLoader"
        anchors.fill: parent

        readonly property bool skipped: d.haveShown("right")
        readonly property bool shown: item && item.shown
        active: !skipped || (item && item.visible)
        onSkippedChanged: if (skipped && shown) item.hide()

        sourceComponent: TutorialRight {
            id: tutorialRight
            objectName: "tutorialRight"
            anchors.fill: parent
            stage: root.stage
            usageScenario: root.usageScenario
            hides: [launcher, panel.indicators]
            paused: root.paused

            skipped: tutorialRightLoader.skipped
            isReady: tutorialTopLoader.skipped && !skipped && !paused && !keyboardVisible &&
                     !tutorialBottomLoader.shown && !tutorialBottomLoader.mightShow &&
                     ApplicationManager.count >= 3

            InactivityTimer {
                id: tutorialRightInactivityTimer
                objectName: "tutorialRightInactivityTimer"
                lastInputTimestamp: root.lastInputTimestamp
                page: parent
            }

            Connections {
                target: d
                onFocusedAppChanged: {
                    if (tutorialRight.isReady && !tutorialRight.shown && d.focusedApp
                            && d.focusedApp.state === ApplicationInfoInterface.Starting) {
                        tutorialRight.show();
                    }
                }
            }

            onIsReadyChanged: if (isReady && !shown) tutorialRightInactivityTimer.start()
            onFinished: AccountsService.markDemoEdgeCompleted("right")
        }
    }

    Loader {
        id: tutorialBottomLoader
        objectName: "tutorialBottomLoader"
        anchors.fill: parent

        // See TutorialBottom.qml for an explanation of why we only support
        // certain apps.
        readonly property var supportedApps: ["address-book-app",
                                              "com.ubuntu.calculator_calculator",
                                              "dialer-app",
                                              "messaging-app"]
        readonly property bool skipped: {
            if (!d.mobileScenario) {
                return true;
            }
            for (var i = 0; i < supportedApps.length; i++) {
                if (!d.haveShown("bottom-" + supportedApps[i])) {
                    return false;
                }
            }
            return true;
        }
        readonly property bool shown: item && item.shown
        readonly property bool haveShownFocusedApp: d.focusedApp &&
                                                    d.haveShown("bottom-" + d.focusedApp.appId)
        readonly property bool mightShow: !skipped && d.focusedApp &&
                                          supportedApps.indexOf(d.focusedApp.appId) !== -1 &&
                                          !haveShownFocusedApp
        active: !skipped || (item && item.visible)
        onHaveShownFocusedAppChanged: if (haveShownFocusedApp && shown) hide()
        onSkippedChanged: if (skipped && shown) item.hide()

        sourceComponent: TutorialBottom {
            id: tutorialBottom
            objectName: "tutorialBottom"
            anchors.fill: parent
            hides: [launcher, panel.indicators]
            paused: root.paused
            usageScenario: root.usageScenario
            stage: root.stage
            application: d.focusedApp

            skipped: tutorialBottomLoader.skipped
            isReady: !tutorialBottomLoader.skipped && !paused && !keyboardVisible &&
                     !tutorialLeftLoader.shown && !tutorialLeftLongLoader.shown &&
                     !tutorialTopLoader.shown && !tutorialRightLoader.shown &&
                     tutorialBottomLoader.mightShow &&
                     d.focusedApp.state === ApplicationInfoInterface.Running

            onIsReadyChanged: if (isReady && !shown) show()
            onFinished: AccountsService.markDemoEdgeCompleted("bottom-" + d.focusedApp.appId)
        }
    }
}
