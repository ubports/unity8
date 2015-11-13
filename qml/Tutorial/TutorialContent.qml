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

    TutorialLeft {
        id: tutorialLeft
        objectName: "tutorialLeft"
        anchors.fill: parent
        launcher: root.launcher
        hides: [launcher, panel.indicators]
        paused: root.paused

        readonly property bool skipped: (root.usageScenario !== "phone"
                                         && root.usageScenario !== "tablet")
                                        || AccountsService.demoEdgesCompleted.indexOf("left") != -1
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

        readonly property bool skipped: (root.usageScenario !== "phone"
                                         && root.usageScenario !== "tablet")
                                        || AccountsService.demoEdgesCompleted.indexOf("top") != -1
        isReady: tutorialLeft.skipped && !skipped && !paused && !keyboardVisible && !tutorialBottom.shown

        Timer {
            id: tutorialTopTimer
            objectName: "tutorialTopTimer"
            interval: 30000
            onTriggered: if (tutorialTop.isReady && !tutorialTop.shown) tutorialTop.show()
        }

        Connections {
            target: AccountsService
            onDemoEdgesCompletedChanged: if (tutorialTop.isReady && !tutorialTop.shown) tutorialTopTimer.start()
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
        isReady: tutorialTop.skipped && !skipped && !paused && !keyboardVisible && !tutorialBottom.shown &&
                 ApplicationManager.count >= 3

        Timer {
            id: tutorialRightTimer
            objectName: "tutorialRightTimer"
            interval: 3000
            onTriggered: if (tutorialRight.isReady && !tutorialRight.shown) tutorialRight.show()
        }

        Connections {
            target: ApplicationManager
            onApplicationAdded: if (tutorialRight.isReady && !tutorialRight.shown) tutorialRight.show()
        }

        onSkippedChanged: if (skipped && shown) hide()
        onIsReadyChanged: if (isReady && !shown) tutorialRightTimer.start()
        onFinished: AccountsService.markDemoEdgeCompleted("right")
    }

    TutorialBottom {
        id: tutorialBottom
        objectName: "tutorialBottom"
        anchors.fill: parent
        hides: [launcher, panel.indicators]
        paused: root.paused

        readonly property bool skipped: (root.usageScenario !== "phone"
                                         && root.usageScenario !== "tablet")
                                        || AccountsService.demoEdgesCompleted.indexOf("bottom") != -1
        isReady: !skipped && !paused && !keyboardVisible && !tutorialTop.shown && !tutorialRight.shown &&
                 // focused app is an app known to have a bottom edge
                 (ApplicationManager.focusedApplicationId == "dialer-app" ||
                  ApplicationManager.focusedApplicationId == "messaging-app" ||
                  ApplicationManager.focusedApplicationId == "address-book-app" ||
                  ApplicationManager.focusedApplicationId == "ubuntu-calculator-app" ||
                  ApplicationManager.focusedApplicationId == "ubuntu-clock-app") &&
                 (stage.mainApp && stage.mainApp.state === ApplicationInfoInterface.Running)

        onSkippedChanged: if (skipped && shown) hide()
        onIsReadyChanged: if (isReady && !shown) show()
        onFinished: {
            AccountsService.markDemoEdgeCompleted("bottom");
            root.finish();
        }
    }
}
