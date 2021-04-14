/*
 * Copyright (C) 2015-2017 Canonical, Ltd.
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
import QtTest 1.0
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3 as ListItem
import Lomiri.Application 0.1
import Lomiri.SelfTest 0.1
import Utils 0.1
import WindowManager 1.0

import ".."
import "../../../qml/Stage"
import "../../../qml/Components"
import "../../../qml/Components/PanelState"

Rectangle {
    id: root
    color: "grey"
    width: units.gu(160*0.7)
    height: units.gu(100*0.7)

    property var greeter: { fullyShown: true }

    readonly property var topLevelSurfaceList: WorkspaceManager.activeWorkspace.windowModel

    ApplicationMenuDataLoader {
        id: appMenuData
    }

    Stage {
        id: stage
        anchors { fill: parent; rightMargin: units.gu(30) }
        dragAreaWidth: units.gu(2)
        allowInteractivity: true
        shellOrientation: Qt.LandscapeOrientation
        nativeWidth: width
        nativeHeight: height
        orientations: Orientations {
            native_: Qt.LandscapeOrientation
            primary: Qt.LandscapeOrientation
        }
        focus: true
        mode: "stagedWithSideStage"
        applicationManager: ApplicationManager
        topLevelSurfaceList: root.topLevelSurfaceList
        panelState: PanelState {}
        availableDesktopArea: availableDesktopAreaItem
        Item {
            id: availableDesktopAreaItem
            anchors.fill: parent
        }
    }

    Rectangle {
        id: controls
        color: "darkgrey"
        width: units.gu(30)
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        // don't let mouse clicks in the controls area disturb the Stage behind it
        MouseArea { anchors.fill: parent }

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)

            Button {
                text: testCase.sideStage ? testCase.sideStage.shown ? "Hide Side-stage" : "Show Side-stage" : ""
                enabled: testCase.sideStage
                activeFocusOnPress: false
                onClicked: {
                    if (testCase.sideStage.shown) testCase.sideStage.hide();
                    else testCase.sideStage.show();
                }
            }

            Button {
                text: "Drag app to side stage"
                activeFocusOnPress: false
                onClicked: {
                    testCase.dragToSideStage();
                }
            }

            Button {
                text: "Drag app to main stage"
                activeFocusOnPress: false
                onClicked: {
                    testCase.dragToMainStage();
                }
            }

            ApplicationCheckBox {
                id: webbrowserCheckBox
                appId: "morph-browser"
            }
            ApplicationCheckBox {
                id: galleryCheckBox
                appId: "gallery-app"
            }
            ApplicationCheckBox {
                id: dialerCheckBox
                appId: "dialer-app"
            }
            ApplicationCheckBox {
                id: facebookCheckBox
                appId: "facebook-webapp"
            }
        }
    }

    SignalSpy {
        id: stageSaver
        target: WindowStateStorage
        signalName: "stageSaved"
    }

    LomiriTestCase {
        id: testCase
        name: "TabletStage"
        when: windowShown

        property Item sideStage: stage ? findChild(stage, "sideStage") : null

        function init() {
            stageSaver.clear();

            tryCompare(topLevelSurfaceList, "count", 0);

            // wait for Stage to stabilize back into its initial state
            var appRepeater = findChild(stage, "appRepeater");
            tryCompare(appRepeater, "count", 0);

            sideStage.hideNow()
            tryCompare(sideStage, "x", stage.width)

        }

        function cleanup() {
            killApps();

            sideStage.hideNow();
            tryCompare(sideStage, "x", stage.width)
            waitForRendering(stage)

            WindowStateStorage.clear();
            wait(100)
        }

        function waitUntilAppSurfaceShowsUp(surfaceId) {
            var appWindow = findAppWindowForSurfaceId(surfaceId);
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function findAppWindowForSurfaceId(surfaceId) {
            tryVerify(function() {
                return findChild(stage, "appDelegate_" + surfaceId);
            }, 100, "Found app surface with ID " + surfaceId);
            var spreadDelegate = findChild(stage, "appDelegate_" + surfaceId);
            if (!spreadDelegate) {
                return null;
            }
            var appWindow = findChild(spreadDelegate, "appWindow");
            return appWindow;
        }

        function switchToSurface(targetSurfaceId) {
            waitForRendering(stage);
            performEdgeSwipeToShowAppSpread();

            waitUntilAppDelegateStopsMoving(targetSurfaceId);
            var targetAppWindow = findAppWindowForSurfaceId(targetSurfaceId);
            verify(targetAppWindow);
            tap(targetAppWindow, 10, 10);
            waitForRendering(stage);
        }

        function waitUntilAppDelegateStopsMoving(targetSurfaceId)
        {
            var targetAppDelegate = findChild(stage, "appDelegate_" + targetSurfaceId);
            verify(targetAppDelegate);
            var lastValue = undefined;
            do {
                lastValue = targetAppDelegate.animatedProgress;
                wait(300);
            } while (lastValue != targetAppDelegate.animatedProgress);
        }

        function performEdgeSwipeToShowAppSpread() {
            touchFlick(stage, stage.width - (stage.dragAreaWidth / 2), stage.height / 2, stage.x + 1, stage.height / 2);

            tryCompare(stage, "state", "spread");
        }

        function swipeSurfaceDownwards(surfaceId) {
            var appWindow = findAppWindowForSurfaceId(surfaceId);
            verify(appWindow);

            // Swipe from the left side of the surface as it's the one most likely
            // to not be covered by other surfaces when they're all being shown in the spread
            touchFlick(appWindow,
                    appWindow.width * 0.1, appWindow.height / 2,
                    appWindow.width * 0.1, appWindow.height * 1.5);
        }

        function dragToSideStage(surfaceId) {
            sideStage.showNow();

            var pos = stage.width - sideStage.width - (stage.width - sideStage.width) / 2;
            var end_pos = stage.width - sideStage.width / 2;

            multiTouchDragUntil([0,1,2], stage, pos, stage.height / 2, units.gu(3), 0,
                                function() {
                                    pos += units.gu(3);
                                    return sideStage.shown && !sideStage.showAnimation.running &&
                                           pos >= end_pos;
                                });
            if (surfaceId != null) {
                var targetAppDelegate = findChild(stage, "appDelegate_" + surfaceId);
                verify(targetAppDelegate);
                tryCompare(targetAppDelegate, "stage", ApplicationInfoInterface.SideStage);
            }
        }

        function dragToMainStage(surfaceId) {
            sideStage.showNow();

            var pos = stage.width - sideStage.width / 2;
            var end_pos = stage.width - sideStage.width - (stage.width - sideStage.width) / 2;

            multiTouchDragUntil([0,1,2],
                                stage,
                                pos,
                                stage.height / 2,
                                -units.gu(3),
                                0,
                                function() {
                                    pos -= units.gu(3);
                                    return pos <= end_pos;
                                });
            if (surfaceId != null) {
                var targetAppDelegate = findChild(stage, "appDelegate_" + surfaceId);
                verify(targetAppDelegate);
                tryCompare(targetAppDelegate, "stage", ApplicationInfoInterface.MainStage);
            }
        }

        // Launch one of the available apps in this test case
        // Return the topLevelSurfaceList's ID for the launched app
        // Valid values are: "morph", "gallery", "dialer", and "facebook"
        // "facebook" will be launched if no name is given
        function launchApp(appName) {
            var nextAppId = topLevelSurfaceList.nextId;
            switch (appName) {
                case "morph":
                    webbrowserCheckBox.checked = true;
                    break;
                case "gallery":
                    galleryCheckBox.checked = true;
                    break;
                case "dialer":
                    dialerCheckBox.checked = true;
                    break;
                case "facebook":
                default:
                    facebookCheckBox.checked = true;
                    break;
            }
            waitUntilAppSurfaceShowsUp(nextAppId);
            return nextAppId;
        }

        function test_tappingSwitchesFocusBetweenStages() {
            WindowStateStorage.saveStage(dialerCheckBox.appId, ApplicationInfoInterface.SideStage)

            var webbrowserSurfaceId = launchApp("morph");
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(webbrowserDelegate);
            compare(webbrowserDelegate.stage, ApplicationInfoInterface.MainStage);
            var webbrowserWindow = findAppWindowForSurfaceId(webbrowserSurfaceId);
            verify(webbrowserWindow);

            tryCompare(webbrowserWindow.surface, "activeFocus", true);

            var dialerSurfaceId = launchApp("dialer");
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerSurfaceId);

            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            var dialerDelegate = findChild(stage, "appDelegate_" + dialerSurfaceId);
            verify(dialerDelegate);
            compare(dialerDelegate.stage, ApplicationInfoInterface.SideStage);

            tryCompare(dialerDelegate.surface, "activeFocus", true);
            tryCompare(webbrowserWindow.surface, "activeFocus", false);

            // Tap on the main stage application and check if the focus
            // has been passed to it.

            tap(webbrowserWindow);

            tryCompare(dialerDelegate.surface, "activeFocus", false);
            tryCompare(webbrowserWindow.surface, "activeFocus", true);

            // Now tap on the side stage application and check if the focus
            // has been passed back to it.

            tap(dialerDelegate);

            tryCompare(dialerDelegate.surface, "activeFocus", true);
            tryCompare(webbrowserWindow.surface, "activeFocus", false);
        }

        function test_closeAppInSideStage() {
            WindowStateStorage.saveStage(dialerCheckBox.appId, ApplicationInfoInterface.SideStage)

            var dialerSurfaceId = launchApp("dialer");
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerSurfaceId);

            performEdgeSwipeToShowAppSpread();

            var appDelegate = findChild(stage, "appDelegate_" + dialerSurfaceId);
            var dragArea = findChild(appDelegate, "dragArea");
            verify(dragArea);
            compare(appDelegate.stage, ApplicationInfoInterface.SideStage);
            tryCompare(dragArea, "closeable", true);

            swipeSurfaceDownwards(dialerSurfaceId);

            // Check that dialer-app has been closed

            tryCompareFunction(function() {
                return findChild(stage, "appWindow_" + dialerCheckBox.appId);
            }, null);

            tryCompareFunction(function() {
                return ApplicationManager.findApplication(dialerCheckBox.appId);
            }, null);

            stage.closeSpread();
        }

        function test_suspendsAndResumesAppsInMainStage() {
            var webbrowserSurfaceId = launchApp("morph");

            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            var webbrowserDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            compare(webbrowserDelegate.stage, ApplicationInfoInterface.MainStage);

            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Running);

            var gallerySurfaceId = launchApp("gallery");
            galleryCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(gallerySurfaceId);

            var galleryApp = ApplicationManager.findApplication(galleryCheckBox.appId);
            var galleryDelegate = findChild(stage, "appDelegate_" + gallerySurfaceId);
            compare(galleryDelegate.stage, ApplicationInfoInterface.MainStage);

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Running);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);

            switchToSurface(webbrowserSurfaceId);

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Running);

            switchToSurface(gallerySurfaceId);

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Running);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);
        }

        function test_foregroundMainAndSideStageAppsAreKeptRunning() {
            WindowStateStorage.saveStage(facebookCheckBox.appId, ApplicationInfoInterface.SideStage)
            WindowStateStorage.saveStage(dialerCheckBox.appId, ApplicationInfoInterface.SideStage)

            var stagesPriv = findInvisibleChild(stage, "DesktopStagePrivate");
            verify(stagesPriv);

            // launch two main stage apps
            // gallery will be on foreground and webbrowser on background


            var webbrowserSurfaceId = launchApp("morph");

            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var webbrowserDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(webbrowserDelegate);
            compare(webbrowserDelegate.stage, ApplicationInfoInterface.MainStage);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);

            var gallerySurfaceId = launchApp("gallery");
            galleryCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(gallerySurfaceId);
            var galleryApp = ApplicationManager.findApplication(galleryCheckBox.appId);
            var galleryDelegate = findChild(stage, "appDelegate_" + gallerySurfaceId);
            compare(galleryDelegate.stage, ApplicationInfoInterface.MainStage);

            compare(stagesPriv.mainStageAppId, galleryCheckBox.appId);

            // then launch two side stage apps
            // facebook will be on foreground and dialer on background

            var dialerSurfaceId = launchApp("dialer");
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerSurfaceId);
            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            var dialerDelegate = findChild(stage, "appDelegate_" + dialerSurfaceId);
            compare(dialerDelegate.stage, ApplicationInfoInterface.SideStage);

            var facebookSurfaceId = launchApp("facebook");
            var facebookApp = ApplicationManager.findApplication(facebookCheckBox.appId);
            facebookCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(facebookSurfaceId);

            var facebookDelegate = findChild(stage, "appDelegate_" + facebookSurfaceId);
            compare(facebookDelegate.stage, ApplicationInfoInterface.SideStage);

            compare(stagesPriv.sideStageAppId, facebookCheckBox.appId);

            // Now check that the foreground apps are running and that the background ones
            // are suspended

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Running);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(facebookApp, "state", ApplicationInfoInterface.Running);
            tryCompare(dialerApp, "state", ApplicationInfoInterface.Suspended);

            switchToSurface(dialerSurfaceId);

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Running);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(facebookApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(dialerApp, "state", ApplicationInfoInterface.Running);

            switchToSurface(webbrowserSurfaceId);

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Running);
            tryCompare(facebookApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(dialerApp, "state", ApplicationInfoInterface.Running);
        }

        function test_foregroundAppsAreSuspendedWhenStageIsSuspended() {
            WindowStateStorage.saveStage(dialerCheckBox.appId, ApplicationInfoInterface.SideStage)

            var webbrowserSurfaceId = launchApp("morph");
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            var webbrowserDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            compare(webbrowserDelegate.stage, ApplicationInfoInterface.MainStage);

            var dialerSurfaceId = launchApp("dialer");
            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerSurfaceId);

            var dialerDelegate = findChild(stage, "appDelegate_" + dialerSurfaceId);
            compare(dialerDelegate.stage, ApplicationInfoInterface.SideStage);


            compare(webbrowserApp.requestedState, ApplicationInfoInterface.RequestedRunning);
            compare(dialerApp.requestedState, ApplicationInfoInterface.RequestedRunning);

            stage.suspended = true;

            tryCompare(webbrowserApp, "requestedState", ApplicationInfoInterface.RequestedSuspended);
            tryCompare(dialerApp, "requestedState", ApplicationInfoInterface.RequestedSuspended);

            stage.suspended = false;

            tryCompare(webbrowserApp, "requestedState", ApplicationInfoInterface.RequestedRunning);
            tryCompare(dialerApp, "requestedState", ApplicationInfoInterface.RequestedRunning);
        }

        function test_threeFingerTapOpensSideStage_data() {
            return [
                { tag: "1 finger", touchIds: [0], result: false },
                { tag: "2 finger", touchIds: [0, 1], result: false },
                { tag: "3 finger", touchIds: [0, 1, 2], result: true },
                { tag: "4 finger", touchIds: [0, 1, 2, 3], result: false },
            ];
        }

        function test_threeFingerTapOpensSideStage(data) {
            multiTouchTap(data.touchIds, stage, stage.width / 2, stage.height / 2);
            wait(200);
            tryCompare(sideStage, "shown", data.result);
        }


        function test_threeFingerTapClosesSideStage_data() {
            return [
                { tag: "1 finger", touchIds: [0], result: true },
                { tag: "2 finger", touchIds: [0, 1], result: true },
                { tag: "3 finger", touchIds: [0, 1, 2], result: false },
                { tag: "4 finger", touchIds: [0, 1, 2, 3], result: true },
            ];
        }

        function test_threeFingerTapClosesSideStage(data) {
            sideStage.showNow();

            multiTouchTap(data.touchIds, stage, stage.width / 2, stage.height / 2);
            wait(200);
            tryCompare(sideStage, "shown", data.result);
        }

        function test_threeFingerDragOpensSidestage() {
            multiTouchDragUntil([0,1,2], stage, stage.width / 4, stage.height / 4, units.gu(1), 0,
                                function() { return sideStage.shown; });
        }

        function test_applicationLoadsInDefaultStage_data() {
            return [
                { tag: "MainStage", appId: "morph-browser", mainStageAppId: "morph-browser", sideStageAppId: "" },
                { tag: "SideStage", appId: "dialer-app", mainStageAppId: "facebook-webapp", sideStageAppId: "dialer-app" },
            ];
        }

        function test_applicationLoadsInDefaultStage(data) {
            var stagesPriv = findInvisibleChild(stage, "DesktopStagePrivate");
            verify(stagesPriv);

            facebookCheckBox.checked = true;

            tryCompare(stagesPriv, "mainStageAppId", "facebook-webapp");
            tryCompare(stagesPriv, "sideStageAppId", "");

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication(data.appId);
            waitUntilAppSurfaceShowsUp(appSurfaceId);

            tryCompare(stagesPriv, "mainStageAppId", data.mainStageAppId);
            tryCompare(stagesPriv, "sideStageAppId", data.sideStageAppId);
        }

        function test_applicationLoadsInSavedStage_data() {
            return [
                { tag: "MainStage", stage: ApplicationInfoInterface.MainStage, mainStageAppId: "morph-browser", sideStageAppId: ""},
                { tag: "SideStage", stage: ApplicationInfoInterface.SideStage, mainStageAppId: "facebook-webapp", sideStageAppId: "morph-browser" },
            ];
        }

        function test_applicationLoadsInSavedStage(data) {
            WindowStateStorage.saveStage(webbrowserCheckBox.appId, data.stage)

            var stagesPriv = findInvisibleChild(stage, "DesktopStagePrivate");
            verify(stagesPriv);

            facebookCheckBox.checked = true;

            tryCompare(stagesPriv, "mainStageAppId", "facebook-webapp");
            tryCompare(stagesPriv, "sideStageAppId", "");

            var webbrowserSurfaceId = launchApp("morph");
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            tryCompare(stagesPriv, "mainStageAppId", data.mainStageAppId);
            tryCompare(stagesPriv, "sideStageAppId", data.sideStageAppId);
        }

        function test_applicationSavesLastStage_data() {
            return [
                { tag: "MainStage", fromStage: ApplicationInfoInterface.MainStage, toStage: ApplicationInfoInterface.SideStage },
                { tag: "SideStage", fromStage: ApplicationInfoInterface.SideStage, toStage: ApplicationInfoInterface.MainStage },
            ];
        }

        function test_applicationSavesLastStage(data) {
            WindowStateStorage.saveStage(webbrowserCheckBox.appId, data.fromStage);
            stageSaver.clear();

            var stagesPriv = findInvisibleChild(stage, "DesktopStagePrivate");
            verify(stagesPriv);

            facebookCheckBox.checked = true;

            tryCompare(stagesPriv, "mainStageAppId", "facebook-webapp");
            tryCompare(stagesPriv, "sideStageAppId", "");

            var webbrowserSurfaceId = launchApp("morph");
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            if (data.toStage === ApplicationInfoInterface.SideStage) {
                dragToSideStage(webbrowserSurfaceId);
            } else {
                dragToMainStage(webbrowserSurfaceId);
            }

            tryCompare(stageSaver, "count", 1);
            compare(stageSaver.signalArguments[0][0], "morph-browser")
            compare(stageSaver.signalArguments[0][1], data.toStage)
        }

        function test_loadSideStageByDraggingFromMainStage() {
            sideStage.showNow();
            var webbrowserSurfaceId = launchApp("morph")
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            waitForRendering(stage);
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);

            dragToSideStage(webbrowserSurfaceId);

            tryCompare(appDelegate, "stage", ApplicationInfoInterface.SideStage);
        }

        function test_unloadSideStageByDraggingFromSideStage() {
            sideStage.showNow();
            WindowStateStorage.saveStage(webbrowserCheckBox.appId, ApplicationInfoInterface.SideStage)
            // WindowStateStorage is async... Lets wait for it to be fully processed...
            tryCompareFunction(function() {
                return WindowStateStorage.getStage(webbrowserCheckBox.appId, ApplicationInfoInterface.MainStage) === ApplicationInfoInterface.SideStage
            }, true);
            var webbrowserSurfaceId = launchApp("morph");
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            waitForRendering(stage);
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.SideStage);

            dragToMainStage(webbrowserSurfaceId);

            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);
        }

        /*
            1- Suspended app gets killed behind the scenes, causing its surface to go zombie.
            2- Surface gets screenshotted and removed. Its slot in the topLevelSurfaceList remains,
               though (so ApplicationWindow can display the screenshot in its place).
            3- User taps on the screenshot of the long-gone surface.

            Expected outcome:
            Application gets relaunched. Its new surface will seamlessly replace the screenshot.
         */
        function test_selectSuspendedAppWithoutSurface() {
            launchApp("facebook");
            compare(topLevelSurfaceList.applicationAt(0).appId, "facebook-webapp");
            var facebookSurfaceId = topLevelSurfaceList.idAt(0);
            var facebookWindow = topLevelSurfaceList.windowAt(0);

            var webbrowserSurfaceId = topLevelSurfaceList.nextId;
            launchApp("morph");

            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);

            switchToSurface(facebookSurfaceId);

            tryCompare(topLevelSurfaceList, "focusedWindow", facebookWindow);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);

            compare(webbrowserApp.surfaceList.count, 1);

            // simulate the suspended app being killed by the out-of-memory daemon
            webbrowserApp.surfaceList.get(0).setLive(false);

            switchToSurface(webbrowserSurfaceId);

            // webbrowser should have been brought to front
            tryCompareFunction(function(){return topLevelSurfaceList.idAt(0);}, webbrowserSurfaceId);

            // and it should eventually get a new surface and get resumed
            tryCompareFunction(function(){return topLevelSurfaceList.surfaceAt(0) !== null;}, true);
            compare(topLevelSurfaceList.count, 2); // still two top-level items
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Running);
            compare(webbrowserApp.surfaceList.count, 1);
        }

        function test_draggingSurfaceKeepsSurfaceFocus() {
            var webbrowserSurfaceId = launchApp("morph");
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            compare(appDelegate.stage, ApplicationInfoInterface.MainStage);

            tryCompare(appDelegate.surface, "activeFocus", true);

            dragToSideStage(webbrowserSurfaceId);

            tryCompare(appDelegate.surface, "activeFocus", true);
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.SideStage);
        }

        function test_switchRestoreStageOnRotation() {
            WindowStateStorage.saveStage(webbrowserCheckBox.appId, ApplicationInfoInterface.SideStage)
            var webbrowserSurfaceId = launchApp("morph");
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            compare(appDelegate.stage, ApplicationInfoInterface.SideStage);

            dragToSideStage(webbrowserSurfaceId);

            // will be in sidestage now
            stage.shellOrientation = Qt.PortraitOrientation;
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);

            stage.shellOrientation = Qt.LandscapeOrientation;
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.SideStage);
        }

        function test_restoreSavedStageOnCloseReopen() {
            var webbrowserSurfaceId = launchApp("morph");
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);

            dragToSideStage(webbrowserSurfaceId);
            // will be in sidestage now
            stage.shellOrientation = Qt.PortraitOrientation;
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);

            webbrowserCheckBox.checked = false;
            tryCompare(ApplicationManager, "count", 0);

            // back to landscape
            stage.shellOrientation = Qt.LandscapeOrientation;

            webbrowserSurfaceId = launchApp("morph");
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            appDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.SideStage);
        }

        /*
            Regression test for https://bugs.launchpad.net/lomiri/+source/lomiri/+bug/1670361

            Clicks near the top window edge (but still inside the window boundaries) should go to
            the window (and not get eaten by some translucent decoration like in that bug).
         */
        function test_clickNearTopEdgeGoesToWindow() {
            var facebookSurfaceId = launchApp("facebook");
            var appDelegate = findChild(stage, "appDelegate_" + facebookSurfaceId);
            verify(appDelegate);

            var surfaceItem = findChild(appDelegate, "surfaceItem");
            verify(surfaceItem);

            compare(surfaceItem.mousePressCount, 0);
            compare(surfaceItem.mouseReleaseCount, 0);

            mouseClick(surfaceItem, 1, 1); // near top left

            tryCompare(surfaceItem, "mousePressCount", 1);
            tryCompare(surfaceItem, "mouseReleaseCount", 1);

            mouseClick(stage, appDelegate.width / 2, 1); // near top

            tryCompare(surfaceItem, "mousePressCount", 2);
            tryCompare(surfaceItem, "mouseReleaseCount", 2);

            mouseClick(stage, appDelegate.width - 1, 1); // near top right

            tryCompare(surfaceItem, "mousePressCount", 3);
            tryCompare(surfaceItem, "mouseReleaseCount", 3);
        }
    }
}
