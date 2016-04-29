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
    property bool paused: true // default to true so that we won't start until top level is all ready
    property bool delayed: true // same
    property var lastInputTimestamp

    readonly property bool launcherEnabled: !running
                                            || tutorialLeftLoader.shown
                                            || tutorialLeftLongLoader.shown
    readonly property bool launcherLongSwipeEnabled: tutorialLeftLongLoader.shown
                                                     || tutorialLeftLongLoader.skipped
    readonly property bool spreadEnabled: !running || tutorialRightLoader.shown
    readonly property bool panelEnabled: !running || tutorialTopLoader.shown
    readonly property bool running: tutorialLeftLoader.shown
                                    || tutorialLeftLongLoader.shown
                                    || tutorialTopLoader.shown
                                    || tutorialRightLoader.shown

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

        function haveShown(tutorialId) {
            return AccountsService.demoEdgesCompleted.indexOf(tutorialId) != -1;
        }

        property bool endPointsFinished: tutorialRightLoader.skipped
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

            isReady: !tutorialLeftLoader.skipped && !paused && !delayed

            InactivityTimer {
                id: tutorialLeftTimer
                objectName: "tutorialLeftTimer"
                interval: 20000
                lastInputTimestamp: root.lastInputTimestamp
                page: parent
            }

            onIsReadyChanged: if (isReady && !shown) tutorialLeftTimer.start()
            onFinished: AccountsService.markDemoEdgeCompleted("left")
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
            isReady: tutorialLeftLoader.skipped && !skipped && !paused && !delayed

            InactivityTimer {
                id: tutorialTopTimer
                objectName: "tutorialTopTimer"
                interval: 60000
                lastInputTimestamp: root.lastInputTimestamp
                page: parent
            }

            onIsReadyChanged: if (isReady && !shown) tutorialTopTimer.start()
            onFinished: AccountsService.markDemoEdgeCompleted("top")
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
            isReady: tutorialTopLoader.skipped && !skipped && !paused && !delayed &&
                     ApplicationManager.focusedApplicationId != "unity8-dash"

            InactivityTimer {
                id: tutorialLeftLongTimer
                objectName: "tutorialLeftLongTimer"
                interval: 5000
                lastInputTimestamp: root.lastInputTimestamp
                page: parent
            }

            onIsReadyChanged: if (isReady && !shown) tutorialLeftLongTimer.start()
            onFinished: AccountsService.markDemoEdgeCompleted("left-long")
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
            isReady: tutorialTopLoader.skipped && !skipped && !paused && !delayed &&
                     ApplicationManager.count >= 4

            InactivityTimer {
                id: tutorialRightTimer
                objectName: "tutorialRightTimer"
                interval: 10000
                lastInputTimestamp: root.lastInputTimestamp
                page: parent
            }

            onIsReadyChanged: if (isReady && !shown) tutorialRightTimer.start()
            onFinished: AccountsService.markDemoEdgeCompleted("right")
        }
    }
}
