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

        function isReady() {
            return AccountsService.demoEdgesCompleted.indexOf("left") == -1;
        }

        Component.onCompleted: if (tutorialLeft.isReady()) show()
        onFinished: AccountsService.markDemoEdgeCompleted("left")
    }

    TutorialTop {
        id: tutorialTop
        objectName: "tutorialTop"
        anchors.fill: parent
        panel: root.panel
        hides: [launcher, panel.indicators]

        function isReady() {
            return AccountsService.demoEdgesCompleted.indexOf("left") != -1 &&
                   AccountsService.demoEdgesCompleted.indexOf("top") == -1;
        }

        Timer {
            id: tutorialTopTimer
            interval: 60000
            onTriggered: if (tutorialTop.isReady()) tutorialTop.show()
        }

        Connections {
            target: AccountsService
            onDemoEdgesCompletedChanged: if (tutorialTop.isReady()) tutorialTopTimer.start()
        }

        Component.onCompleted: if (tutorialTop.isReady()) tutorialTopTimer.start()
        onFinished: AccountsService.markDemoEdgeCompleted("top")

        Connections {
            target: panel.indicators
            onFullyOpenedChanged: {
                if (panel.indicators.fullyOpened) {
                    AccountsService.markDemoEdgeCompleted("top");
                }
            }
        }
    }

    TutorialRight {
        id: tutorialRight
        objectName: "tutorialRight"
        anchors.fill: parent
        stage: root.stage
        hides: [launcher, panel.indicators]

        function isReady() {
            return AccountsService.demoEdgesCompleted.indexOf("left") != -1 &&
                   AccountsService.demoEdgesCompleted.indexOf("top") != -1 &&
                   AccountsService.demoEdgesCompleted.indexOf("right") == -1 &&
                   ApplicationManager.count >= 3;
        }

        Timer {
            id: tutorialRightTimer
            interval: 3000
            onTriggered: if (tutorialRight.isReady()) tutorialRight.show()
        }

        Connections {
            target: AccountsService
            onDemoEdgesCompletedChanged: if (tutorialRight.isReady()) tutorialRightTimer.start()
        }

        Connections {
            target: ApplicationManager
            onApplicationAdded: if (tutorialRight.isReady()) tutorialRight.show()
        }

        onFinished: AccountsService.markDemoEdgeCompleted("right")

        Connections {
            target: stage
            onDragProgressChanged: {
                if (stage.dragProgress >= 0.1) {
                    AccountsService.markDemoEdgeCompleted("right");
                }
            }
        }
    }

    TutorialBottom {
        id: tutorialBottom
        objectName: "tutorialBottom"
        anchors.fill: parent
        hides: [launcher, panel.indicators]

        function isReady() {
            return AccountsService.demoEdgesCompleted.indexOf("left") != -1 &&
                   AccountsService.demoEdgesCompleted.indexOf("top") != -1 &&
                   AccountsService.demoEdgesCompleted.indexOf("right") != -1 &&
                   AccountsService.demoEdgesCompleted.indexOf("bottom") == -1 &&
                   // focused app is an app known to have a bottom edge
                   (ApplicationManager.focusedApplicationId == "dialer-app" ||
                    ApplicationManager.focusedApplicationId == "webbrowser-app" ||
                    ApplicationManager.focusedApplicationId == "messaging-app" ||
                    ApplicationManager.focusedApplicationId == "camera-app" ||
                    ApplicationManager.focusedApplicationId == "clock-app");
        }

        Timer {
            id: tutorialBottomTimer
            interval: 3000
            onTriggered: if (tutorialBottom.isReady()) tutorialBottom.show()
        }

        Connections {
            target: AccountsService
            onDemoEdgesCompletedChanged: if (tutorialBottom.isReady()) tutorialBottomTimer.start()
        }

        Connections {
            target: ApplicationManager
            onFocusedApplicationIdChanged: if (tutorialBottom.isReady()) tutorialBottom.show()
        }

        onFinished: {
            AccountsService.markDemoEdgeCompleted("bottom");
            root.finish();
        }
    }
}
