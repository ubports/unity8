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
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Unity.Application 0.1
import Unity.Test 0.1
import Utils 0.1
import WindowManager 1.0

import ".."
import "../../../qml/Stage"
import "../../../qml/Components"

Rectangle {
    id: root
    color: "grey"
    width: units.gu(160*0.7)
    height: units.gu(100*0.7)

    property var greeter: { fullyShown: true }

    SurfaceManager { id: sMgr }
    ApplicationMenuDataLoader {
        id: appMenuData
        surfaceManager: sMgr
    }

    Stage {
        id: stage
        anchors { fill: parent; rightMargin: units.gu(30) }
        dragAreaWidth: units.gu(2)
        interactive: true
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
        topLevelSurfaceList: TopLevelWindowModel {
            id: topLevelSurfaceList
            applicationManager: ApplicationManager
            surfaceManager: sMgr
        }
        availableDesktopArea: availableDesktopAreaItem
        Item {
            id: availableDesktopAreaItem
            anchors.fill: parent
        }
        Component.onCompleted: {
            ApplicationManager.startApplication("unity8-dash");
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

            EdgeBarrierControls {
                id: edgeBarrierControls
                text: "Drag here to pull out spread"
                backgroundColor: "blue"
                onDragged: { stage.pushRightEdge(amount); }
                Component.onCompleted: {
                    edgeBarrierControls.target = testCase.findChild(stage, "edgeBarrierController");
                }
            }

            Button {
                text: testCase.sideStage ? testCase.sideStage.shown ? "Hide Side-stage" : "Show Side-stage" : ""
                enabled: testCase.sideStage
                activeFocusOnPress: false
                onClicked: {
                    if (testCase.sideStage.shown) testCase.sideStage.hide();
                    else testCase.sideStage.show();
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

    UnityTestCase {
        id: testCase
        name: "TabletStage"
        when: windowShown

        readonly property alias topSurfaceList: stage.topLevelSurfaceList
        property Item sideStage: stage ? findChild(stage, "sideStage") : null

        function init() {
            stageSaver.clear();

            ApplicationManager.startApplication("unity8-dash");
            tryCompare(topSurfaceList, "count", 1);
            compare(topSurfaceList.applicationAt(0).appId, "unity8-dash");

            // this is very strange, but sometimes the test starts without
            // Stage components having finished loading themselves
            var appWindow = null
            while (!appWindow) {
                appWindow = findAppWindowForSurfaceId(topSurfaceList.idAt(0));
                if (!appWindow) {
                    console.log("didn't find unity8-dash appWindow in Stage. Trying again...");
                    wait(50);
                }
            }

            // wait for Stage to stabilize back into its initial state
            var appRepeater = findChild(stage, "appRepeater");
            tryCompare(appRepeater, "count", 1);
            tryCompare(appRepeater.itemAt(0), "x", 0);

            waitUntilAppSurfaceShowsUp(topSurfaceList.idAt(0));
            sideStage.hideNow()
            tryCompare(sideStage, "x", stage.width)
        }

        function cleanup() {
            ApplicationManager.requestFocusApplication("unity8-dash");
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");
            tryCompare(stage, "state", "stagedWithSideStage");
            waitForRendering(stage);

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
            var spreadDelegate = findChild(stage, "appDelegate_" + surfaceId);
            if (!spreadDelegate) {
                return null;
            }
            var appWindow = findChild(spreadDelegate, "appWindow");
            return appWindow;
        }

        function switchToSurface(targetSurfaceId) {
            performEdgeSwipeToShowAppSpread();

            waitUntilAppDelegateStopsMoving(targetSurfaceId);
            var targetAppWindow = findAppWindowForSurfaceId(targetSurfaceId);
            verify(targetAppWindow);
            tap(targetAppWindow, 10, 10);
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

        function swipeSurfaceUpwards(surfaceId) {
            var appWindow = findAppWindowForSurfaceId(surfaceId);
            verify(appWindow);

            // Swipe from the left side of the surface as it's the one most likely
            // to not be covered by other surfaces when they're all being shown in the spread
            touchFlick(appWindow,
                    appWindow.width * 0.1, appWindow.height / 2,
                    appWindow.width * 0.1, -appWindow.height / 2);
        }

        function dragToSideStage(surfaceId) {
            sideStage.showNow();
            var targetAppDelegate = findChild(stage, "appDelegate_" + surfaceId);

            var pos = stage.width - sideStage.width - (stage.width - sideStage.width) / 2;
            var end_pos = stage.width - sideStage.width / 2;

            multiTouchDragUntil([0,1,2], stage, pos, stage.height / 2, units.gu(3), 0,
                                function() {
                                    pos += units.gu(3);
                                    return sideStage.shown && !sideStage.showAnimation.running &&
                                           pos >= end_pos;
                                });
            tryCompare(targetAppDelegate, "stage", ApplicationInfoInterface.SideStage);
        }

        function dragToMainStage(surfaceId) {
            sideStage.showNow();
            var targetAppDelegate = findChild(stage, "appDelegate_" + surfaceId);
            verify(targetAppDelegate);

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
            tryCompare(targetAppDelegate, "stage", ApplicationInfoInterface.MainStage);
        }

        function test_tappingSwitchesFocusBetweenStages() {
            WindowStateStorage.saveStage(dialerCheckBox.appId, ApplicationInfoInterface.SideStage)

            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(webbrowserDelegate);
            compare(webbrowserDelegate.stage, ApplicationInfoInterface.MainStage);
            var webbrowserWindow = findAppWindowForSurfaceId(webbrowserSurfaceId);
            verify(webbrowserWindow);

            tryCompare(webbrowserWindow.surface, "activeFocus", true);

            var dialerSurfaceId = topSurfaceList.nextId;
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

            var dialerSurfaceId = topSurfaceList.nextId;
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerSurfaceId);

            performEdgeSwipeToShowAppSpread();

            var appDelegate = findChild(stage, "appDelegate_" + dialerSurfaceId);
            var dragArea = findChild(appDelegate, "dragArea");
            verify(dragArea);
            compare(appDelegate.stage, ApplicationInfoInterface.SideStage);
            tryCompare(dragArea, "closeable", true);

            swipeSurfaceUpwards(dialerSurfaceId);

            // Check that dialer-app has been closed

            tryCompareFunction(function() {
                return findChild(stage, "appWindow_" + dialerCheckBox.appId);
            }, null);

            tryCompareFunction(function() {
                return ApplicationManager.findApplication(dialerCheckBox.appId);
            }, null);
        }

        function test_suspendsAndResumesAppsInMainStage() {
            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            var webbrowserDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            compare(webbrowserDelegate.stage, ApplicationInfoInterface.MainStage);

            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Running);

            var gallerySurfaceId = topSurfaceList.nextId;
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

            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(webbrowserDelegate);
            compare(webbrowserDelegate.stage, ApplicationInfoInterface.MainStage);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);

            var gallerySurfaceId = topSurfaceList.nextId;
            galleryCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(gallerySurfaceId);
            var galleryApp = ApplicationManager.findApplication(galleryCheckBox.appId);
            var galleryDelegate = findChild(stage, "appDelegate_" + gallerySurfaceId);
            compare(galleryDelegate.stage, ApplicationInfoInterface.MainStage);

            compare(stagesPriv.mainStageAppId, galleryCheckBox.appId);

            // then launch two side stage apps
            // facebook will be on foreground and dialer on background

            var dialerSurfaceId = topSurfaceList.nextId;
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerSurfaceId);
            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            var dialerDelegate = findChild(stage, "appDelegate_" + dialerSurfaceId);
            compare(dialerDelegate.stage, ApplicationInfoInterface.SideStage);

            var facebookSurfaceId = topSurfaceList.nextId;
            facebookCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(facebookSurfaceId);
            var facebookApp = ApplicationManager.findApplication(facebookCheckBox.appId);
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

            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            var webbrowserDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            compare(webbrowserDelegate.stage, ApplicationInfoInterface.MainStage);

            var dialerSurfaceId = topSurfaceList.nextId;
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerSurfaceId);
            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
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
                { tag: "SideStage", appId: "dialer-app", mainStageAppId: "unity8-dash", sideStageAppId: "dialer-app" },
            ];
        }

        function test_applicationLoadsInDefaultStage(data) {
            var stagesPriv = findInvisibleChild(stage, "DesktopStagePrivate");
            verify(stagesPriv);

            tryCompare(stagesPriv, "mainStageAppId", "unity8-dash");
            tryCompare(stagesPriv, "sideStageAppId", "");

            var appSurfaceId = topSurfaceList.nextId;
            var app = ApplicationManager.startApplication(data.appId);
            waitUntilAppSurfaceShowsUp(appSurfaceId);

            tryCompare(stagesPriv, "mainStageAppId", data.mainStageAppId);
            tryCompare(stagesPriv, "sideStageAppId", data.sideStageAppId);
        }

        function test_applicationLoadsInSavedStage_data() {
            return [
                { tag: "MainStage", stage: ApplicationInfoInterface.MainStage, mainStageAppId: "morph-browser", sideStageAppId: ""},
                { tag: "SideStage", stage: ApplicationInfoInterface.SideStage, mainStageAppId: "unity8-dash", sideStageAppId: "morph-browser" },
            ];
        }

        function test_applicationLoadsInSavedStage(data) {
            WindowStateStorage.saveStage(webbrowserCheckBox.appId, data.stage)

            var stagesPriv = findInvisibleChild(stage, "DesktopStagePrivate");
            verify(stagesPriv);

            tryCompare(stagesPriv, "mainStageAppId", "unity8-dash");
            tryCompare(stagesPriv, "sideStageAppId", "");

            var webbrowserSurfaceId = topSurfaceList.nextId;
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

            tryCompare(stagesPriv, "mainStageAppId", "unity8-dash");
            tryCompare(stagesPriv, "sideStageAppId", "");

            var webbrowserSurfaceId = topSurfaceList.nextId;
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
            print("sidestage now shown. launching browser")
            var webbrowserSurfaceId = topSurfaceList.nextId;
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
            var webbrowserSurfaceId = topSurfaceList.nextId;
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
            2- Surface gets screenshotted and removed. Its slot in the topSurfaceList remains,
               though (so ApplicationWindow can display the screenshot in its place).
            3- User taps on the screenshot of the long-gone surface.

            Expected outcome:
            Application gets relaunched. Its new surface will seamlessly replace the screenshot.
         */
        function test_selectSuspendedAppWithoutSurface() {
            compare(topSurfaceList.applicationAt(0).appId, "unity8-dash");
            var dashSurfaceId = topSurfaceList.idAt(0);
            var dashWindow = topSurfaceList.windowAt(0);

            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);

            switchToSurface(dashSurfaceId);

            tryCompare(topLevelSurfaceList, "focusedWindow", dashWindow);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);

            compare(webbrowserApp.surfaceList.count, 1);

            // simulate the suspended app being killed by the out-of-memory daemon
            webbrowserApp.surfaceList.get(0).setLive(false);

            // wait until the surface is gone
            tryCompare(webbrowserApp.surfaceList, "count", 0);
            compare(topSurfaceList.surfaceAt(topSurfaceList.indexForId(webbrowserSurfaceId)), null);

            switchToSurface(webbrowserSurfaceId);

            // webbrowser should have been brought to front
            tryCompareFunction(function(){return topSurfaceList.idAt(0);}, webbrowserSurfaceId);

            // and it should eventually get a new surface and get resumed
            tryCompareFunction(function(){return topSurfaceList.surfaceAt(0) !== null;}, true);
            compare(topSurfaceList.count, 2); // still two top-level items
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Running);
            compare(webbrowserApp.surfaceList.count, 1);
        }

        function test_draggingSurfaceKeepsSurfaceFocus() {
            var webbrowserSurfaceId = topSurfaceList.nextId;
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

        function test_dashDoesNotDragToSidestage() {
            sideStage.showNow();
            compare(topSurfaceList.applicationAt(0).appId, "unity8-dash");
            var dashSurfaceId = topSurfaceList.idAt(0);

            var appDelegate = findChild(stage, "appDelegate_" + dashSurfaceId);
            verify(appDelegate);
            compare(appDelegate.stage, ApplicationInfoInterface.MainStage);

            var pos = stage.width - sideStage.width - (stage.width - sideStage.width) / 2;
            var end_pos = stage.width - sideStage.width / 2;

            multiTouchDragUntil([0,1,2], stage, pos, stage.height / 2, units.gu(3), 0,
                                function() {
                                    pos += units.gu(3);
                                    return sideStage.shown && !sideStage.showAnimation.running &&
                                           pos >= end_pos;
                                });

            waitForRendering(stage);
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);
        }

        function test_switchRestoreStageOnRotation() {
            WindowStateStorage.saveStage(webbrowserCheckBox.appId, ApplicationInfoInterface.SideStage)
            var webbrowserSurfaceId = topSurfaceList.nextId;
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
            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);

            dragToSideStage(webbrowserSurfaceId);
            // will be in sidestage now
            stage.shellOrientation = Qt.PortraitOrientation;
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);

            webbrowserCheckBox.checked = false;
            tryCompare(ApplicationManager, "count", 1);

            // back to landscape
            stage.shellOrientation = Qt.LandscapeOrientation;

            webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            appDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.SideStage);
        }

        /*
            Regression test for https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1670361

            Clicks near the top window edge (but still inside the window boundaries) should go to
            the window (and not get eaten by some translucent decoration like in that bug).
         */
        function test_clickNearTopEdgeGoesToWindow() {
            compare(topLevelSurfaceList.count, 1); // assume unity8-dash is already there

            var appDelegate = findChild(stage, "appDelegate_" + topLevelSurfaceList.idAt(0));
            verify(appDelegate);

            var surfaceItem = findChild(appDelegate, "surfaceItem");
            verify(surfaceItem);

            compare(surfaceItem.mousePressCount, 0);
            compare(surfaceItem.mouseReleaseCount, 0);

            mouseClick(appDelegate, 1, 1); // near top left

            compare(surfaceItem.mousePressCount, 1);
            compare(surfaceItem.mouseReleaseCount, 1);

            mouseClick(appDelegate, appDelegate.width / 2, 1); // near top

            compare(surfaceItem.mousePressCount, 2);
            compare(surfaceItem.mouseReleaseCount, 2);

            mouseClick(appDelegate, appDelegate.width - 1, 1); // near top right

            compare(surfaceItem.mousePressCount, 3);
            compare(surfaceItem.mouseReleaseCount, 3);
        }
    }
}
