/*
 * Copyright 2013 Canonical Ltd.
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
import QtTest 1.0
import ".."
import "../../../Components"
import Ubuntu.Application 0.1
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT
import "tst_Stage"

Rectangle {
    width: units.gu(70)
    height: stageRect.height

    // Even though we replace the ApplicationScreenshot instances in Stage
    // with our own fake ones, ApplicationScreenshot.qml still gives out a warning
    // if shell.importUbuntuApplicationAvailable is missing.
    // For we have this here for the sake of keeping a clean log output.
    Item {
        id: shell
        property bool importUbuntuApplicationAvailable: false
    }

    // A fake ApplicationManager implementation to be passed to Stage
    QtObject {
        id: fakeAppManager
        property ListModel mainStageApplications: ListModel {}
        property ListModel sideStageApplications: ListModel {}
        property var mainStageFocusedApplication

        property Component fakeAppWindowComponent: Component {
            Rectangle {
                width: stage.width
                height: stage.height
                property alias text : txt.text
                Text {id:txt}
            }
        }

        function activateApplication(desktopFile, argument) {
            var appWindow = fakeAppWindowComponent.createObject(fakeWindowContainer)
            var application = {
                'icon': "foo",
                'handle': desktopFile,
                'name': "Foo",
                'fullscreen': false,
                'desktopFile': desktopFile,
                'stage': ApplicationInfo.MainStage,
                'argument': 0,
                'color': desktopFile,
                'window': appWindow
            };
            appWindow.color = application.color
            appWindow.text = desktopFile + " actual";

            mainStageApplications.append(application)
            updateZOrderOfWindows(mainStageApplications)

            return application
        }

        function focusApplication(application) {
            mainStageFocusedApplication = application
        }

        function getApplicationFromDesktopFile(desktopFile, stageType) {
            var sideStage = (stage == ApplicationInfo.SideStage);
            var applications = sideStage ? sideStageApplications
                                         : mainStageApplications;

            for (var i = 0; i < applications.count; i++ ) {
                var application = applications.get(i);
                if (application.desktopFile === desktopFile) {
                    return application;
                }
            }
            return null;
        }

        function moveRunningApplicationStackPosition(from, to, stage) {
            var sideStage = (stage == ApplicationInfo.SideStage);
            var applications = sideStage ? sideStageApplications
                                         : mainStageApplications;

            if (from !== to && applications.count > 0 && from >= 0 && to >= 0) {
                applications.move(from, to, 1);
            }

            updateZOrderOfWindows(applications)
        }

        function updateZOrderOfWindows(applications) {
            var nextZ = 100
            for (var i = 0; i < applications.count; i++ ) {
                var application = applications.get(i);
                application.window.z = nextZ--;
            }
        }

        function deacticateApplication(desktopFile) {
            for (var i = 0; i < mainStageApplications.count; i++ ) {
                var application = mainStageApplications.get(i)
                if (application.desktopFile === desktopFile) {
                    focusApplication(null)
                    application.window.destroy();
                    mainStageApplications.remove(i)
                    updateZOrderOfWindows(mainStageApplications)
                    return;
                }
            }
        }
    }

    Rectangle {
        id: stageRect
        x:0
        y:0
        width: childrenRect.width
        height: childrenRect.height

        color: "grey"

        // This is where the fake windows are held.
        // They stay behind the stage, so that the stage's screenshots are shown
        // on top of them
        // On a real usage scenario, the current application's surface is composited behind
        // the shell's surface (where Stage lives). fakeWindowContainer simulates this stacking
        Item {
            id: fakeWindowContainer
            anchors.fill: parent
        }


        // A black rectangle behind the stage so that the window switch animations
        // look good, just like in Stage's real usage.
        Rectangle {
            anchors.fill: parent
            color: "black"
            visible: stage.usingScreenshots
        }

        Stage {
            id: stage
            y: 0
            shouldUseScreenshots: false
            applicationManager: fakeAppManager
            rightEdgeDraggingAreaWidth: units.gu(2)
            fullyShown: true
            newApplicationScreenshot: FakeApplicationScreenshot {
                    id: newAppScreenshot
                    parent: stage
                    width: stage.width
                    height: stage.height - stage.y}
            oldApplicationScreenshot: FakeApplicationScreenshot {
                    id: oldAppScreenshot
                    parent: stage
                    width: stage.width
                    height: stage.height - stage.y}
        }
    }

    Rectangle {
        id: controlsRect
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: stageRect.right
        anchors.right: parent.right
        color: "lightgrey"

        Column {
            id: controls
            spacing: units.gu(1)
            AppControl {id: redControl; desktopFile:"red"}
            AppControl {id: greenControl; desktopFile:"green"}
            AppControl {id: blueControl; desktopFile:"blue"}
        }
    }

    UT.UnityTestCase {
        name: "Stage"
        when: windowShown

        /* If you press Stage's right edge it should show the hint that it's possible to
           switch to the next running application. This means (graphically) sliding the
           next application window from Stage's right edge for a small part of its width */
        function test_pressingRightEdgeShowsHint() {
            redControl.checked = true

            tryCompare(stage, "usingScreenshots", true) // wait for the animation to start
            tryCompare(stage, "usingScreenshots", false) // and then for it to end
            compare(fakeAppManager.mainStageFocusedApplication.desktopFile, "red")
            compare(fakeAppManager.mainStageApplications.get(0).desktopFile, "red")

            greenControl.checked = true

            tryCompare(stage, "usingScreenshots", true) // wait for the animation to start
            tryCompare(stage, "usingScreenshots", false) // and then for it to end
            compare(fakeAppManager.mainStageFocusedApplication.desktopFile, "green")
            compare(fakeAppManager.mainStageApplications.get(0).desktopFile, "green")

            var draggingAreaCenterX = stage.width - (stage.rightEdgeDraggingAreaWidth / 2)
            var draggingAreaCenterY = stage.height / 2
            touchPress(stage, draggingAreaCenterX, draggingAreaCenterY)

            // wait for the animation to start
            tryCompare(stage, "usingScreenshots", true)

            // "red" should be the new/next application being shown
            compare(newAppScreenshot.application.desktopFile, "red")
            tryCompareFunction(isShowingABitOfNewApp, true);

            // "green" should be the current application being shown
            compare(oldAppScreenshot.application.desktopFile, "green")
            tryCompareFunction(isCurrentAppFadingOut, true);

            touchRelease(stage, draggingAreaCenterX, draggingAreaCenterY)
        }

        function isShowingABitOfNewApp() {
            // it should come from the right and take less than half of the screen
            // but at least 5% of it
            return newAppScreenshot.x > stage.width/2
                && newAppScreenshot.x < stage.width*(95/100)
                && newAppScreenshot.y === 0
                && newAppScreenshot.visible
        }

        function isCurrentAppFadingOut() {
            // it should get a bit translucent and smaller
            return oldAppScreenshot.opacity < 0.99
                && oldAppScreenshot.opacity >= 0.1
                && oldAppScreenshot.scale < 0.99
                && oldAppScreenshot.scale >= 0.1
                && oldAppScreenshot.visible
        }

        function init() {
            redControl.checked = false;
            greenControl.checked = false;
            blueControl.checked = false;
            // give some room for animations to start
            wait(50)
            // wait until animations end, if any
            tryCompare(stage, "usingScreenshots", false)
        }

        /* If you flick from the right edge of the stage leftwards it should cause an
           application switch.  */
        function test_dragFromRightEdgeToSwitchApplication() {
            redControl.checked = true

            tryCompare(stage, "usingScreenshots", true) // wait for the animation to start
            tryCompare(stage, "usingScreenshots", false) // and then for it to end
            compare(fakeAppManager.mainStageFocusedApplication.desktopFile, "red")
            compare(fakeAppManager.mainStageApplications.get(0).desktopFile, "red")

            greenControl.checked = true

            tryCompare(stage, "usingScreenshots", true) // wait for the animation to start
            tryCompare(stage, "usingScreenshots", false) // and then for it to end
            compare(fakeAppManager.mainStageFocusedApplication.desktopFile, "green")
            compare(fakeAppManager.mainStageApplications.get(0).desktopFile, "green")

            var touchX = stage.width - (stage.rightEdgeDraggingAreaWidth / 2)
            var touchY = stage.height / 2
            touchFlick(stage, touchX, touchY,
                       touchX - units.gu(5), touchY)

            // wait until animations end, if any
            tryCompare(stage, "usingScreenshots", false)

            // "red" should be the new topmost, focused, application
            compare(fakeAppManager.mainStageFocusedApplication.desktopFile, "red")
            compare(fakeAppManager.mainStageApplications.get(0).desktopFile, "red")
        }

        /* When an application is launched, it needs a background before it's drawn on screen
           so that the user does not see the previous running app while the new one is launching.
           When switching between applications, backgrounds are unnecessary, 'cause the
           applications are in front of them. */
        function test_background() {
            redControl.checked = true
            tryCompare(stage, "usingScreenshots", true) // wait for the animation to start

            compare(newAppScreenshot.withBackground, true, "starting app screenshot does not have background enabled")

            tryCompare(stage, "usingScreenshots", false) // wait for the animation to finish

            greenControl.checked = true
            tryCompare(stage, "usingScreenshots", true) // wait for the animation to start
            tryCompare(stage, "usingScreenshots", false) // and finish

            var draggingAreaCenterX = stage.width - (stage.rightEdgeDraggingAreaWidth / 2)
            var draggingAreaCenterY = stage.height / 2
            touchPress(stage, draggingAreaCenterX, draggingAreaCenterY)

            // wait for the animation to start
            tryCompare(stage, "usingScreenshots", true)

            compare(newAppScreenshot.withBackground, false, "switched app does have background enabled")

            tryCompareFunction(isShowingABitOfNewApp, true); // wait for the hint animation to finish
            touchRelease(stage, draggingAreaCenterX, draggingAreaCenterY)
        }
    }
}
