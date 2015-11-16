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

    readonly property bool launcherEnabled: !running || tutorialLeft.shown
    readonly property bool spreadEnabled: !running || tutorialRight.shown
    readonly property bool panelEnabled: !running || tutorialTop.shown
    readonly property bool running: tutorialLeft.shown
                                    || tutorialTop.shown
                                    || tutorialRight.shown
                                    || tutorialBottom.shown

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

        property bool endPointsFinished: tutorialRight.skipped && tutorialBottom.skipped
        onEndPointsFinishedChanged: if (endPointsFinished) root.finish()
    }

    TutorialLeft {
        id: tutorialLeft
        objectName: "tutorialLeft"
        anchors.fill: parent
        launcher: root.launcher
        hides: [launcher, panel.indicators]
        paused: root.paused

        readonly property bool skipped: !d.mobileScenario ||
                                        AccountsService.demoEdgesCompleted.indexOf("left") != -1
        isReady: !skipped && !paused && !keyboardVisible

        onSkippedChanged: if (skipped && shown) hide()
        onIsReadyChanged: if (isReady && !shown) show()
        onFinished: AccountsService.markDemoEdgeCompleted("left")
    }

    TutorialTop {
        id: tutorialTop
        objectName: "tutorialTop"
        anchors.fill: parent
        panel: root.panel
        hides: [launcher, panel.indicators]
        paused: root.paused

        readonly property bool skipped: !d.mobileScenario ||
                                        AccountsService.demoEdgesCompleted.indexOf("top") != -1
        isReady: tutorialLeft.skipped && !skipped && !paused && !keyboardVisible &&
                 !tutorialBottom.shown && !tutorialBottom.mightShow

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

        onSkippedChanged: if (skipped && shown) hide()
        onIsReadyChanged: if (isReady && !shown) tutorialTopTimer.start()
        onFinished: AccountsService.markDemoEdgeCompleted("top")
    }

    TutorialRight {
        id: tutorialRight
        objectName: "tutorialRight"
        anchors.fill: parent
        stage: root.stage
        usageScenario: root.usageScenario
        hides: [launcher, panel.indicators]
        paused: root.paused

        readonly property bool skipped: AccountsService.demoEdgesCompleted.indexOf("right") != -1
        isReady: tutorialTop.skipped && !skipped && !paused && !keyboardVisible &&
                 !tutorialBottom.shown && !tutorialBottom.mightShow &&
                 ApplicationManager.count >= 3

        InactivityTimer {
            id: tutorialRightInactivityTimer
            lastInputTimestamp: root.lastInputTimestamp
            page: parent
        }

        Connections {
            target: stage
            onMainAppChanged: {
                if (tutorialRight.isReady && !tutorialRight.shown && stage.mainApp
                        && stage.mainApp.state === ApplicationInfoInterface.Starting) {
                    tutorialRight.show();
                }
            }
        }

        onSkippedChanged: if (skipped && shown) hide()
        onIsReadyChanged: if (isReady && !shown) tutorialRightInactivityTimer.start()
        onFinished: AccountsService.markDemoEdgeCompleted("right")
    }

    TutorialBottom {
        id: tutorialBottom
        objectName: "tutorialBottom"
        anchors.fill: parent
        hides: [launcher, panel.indicators]
        paused: root.paused

        readonly property bool skipped: !d.mobileScenario ||
                                        AccountsService.demoEdgesCompleted.indexOf("bottom") != -1
        readonly property bool mightShow: !skipped && stage.mainApp && canShowForApp(stage.mainApp.appId)
        isReady: !skipped && !paused && !keyboardVisible &&
                 !tutorialTop.shown && !tutorialRight.shown &&
                 mightShow && stage.mainApp.state === ApplicationInfoInterface.Running

        onSkippedChanged: if (skipped && shown) hide()
        onIsReadyChanged: if (isReady && !shown) show()
        onFinished: AccountsService.markDemoEdgeCompleted("bottom")
    }
}
