/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import WindowManager 0.1

import ".."
import "../../../qml/Stages"
import "../../../qml/Components"

Rectangle {
    id: root
    color: "grey"
    width:  tabletStageLoader.width + controls.width
    height: tabletStageLoader.height

    property var greeter: { fullyShown: true }

    TopLevelSurfaceList {
        id: topSurfaceList
        applicationsModel: ApplicationManager
    }

    Loader {
        id: tabletStageLoader

        x: ((root.width - controls.width) - width) / 2
        y: (root.height - height) / 2
        width: units.gu(160*0.7)
        height: units.gu(100*0.7)

        focus: true

        property bool itemDestroyed: false
        sourceComponent: Component {
            TabletStage {
                anchors.fill: parent
                Component.onDestruction: {
                    tabletStageLoader.itemDestroyed = true;
                }
                dragAreaWidth: units.gu(2)
                maximizedAppTopMargin: units.gu(3)
                interactive: true
                shellOrientation: Qt.LandscapeOrientation
                nativeWidth: width
                nativeHeight: height
                orientations: Orientations {
                    native_: Qt.LandscapeOrientation
                    primary: Qt.LandscapeOrientation
                }
                focus: true
                applicationManager: ApplicationManager
                topLevelSurfaceList: topSurfaceList
            }
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

        // don't let mouse clicks in the controls area disturb the TabletStage behind it
        MouseArea { anchors.fill: parent }

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)

            EdgeBarrierControls {
                id: edgeBarrierControls
                text: "Drag here to pull out spread"
                backgroundColor: "blue"
                onDragged: { tabletStageLoader.item.pushRightEdge(amount); }
                Component.onCompleted: {
                    edgeBarrierControls.target = testCase.findChild(tabletStageLoader, "edgeBarrierController");
                }
            }

            Button {
                text: testCase.sideStage ? testCase.sideStage.shown ? "Hide Side-stage" : "Show Side-stage" : ""
                enabled: testCase.sideStage
                onClicked: {
                    if (testCase.sideStage.shown) testCase.sideStage.hide();
                    else testCase.sideStage.show();
                }
            }

            ApplicationCheckBox {
                id: webbrowserCheckBox
                appId: "webbrowser-app"
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

        property Item tabletStage: tabletStageLoader.status === Loader.Ready ? tabletStageLoader.item : null
        property Item sideStage: tabletStage ? findChild(tabletStage, "sideStage") : null

        function init() {
            stageSaver.clear();
            tabletStageLoader.active = true;
            tryCompare(tabletStageLoader, "status", Loader.Ready);

            tryCompare(topSurfaceList, "count", 1);
            compare(topSurfaceList.applicationAt(0).appId, "unity8-dash");

            // this is very strange, but sometimes the test starts without
            // TabletStage components having finished loading themselves
            var appWindow = null
            while (!appWindow) {
                appWindow = findAppWindowForSurfaceId(topSurfaceList.idAt(0));
                if (!appWindow) {
                    console.log("didn't find unity8-dash appWindow in " + tabletStage + ". Trying again...");
                    wait(50);
                }
            }

            waitUntilAppSurfaceShowsUp(topSurfaceList.idAt(0));
            sideStage.hideNow()
        }

        function cleanup() {
            tabletStageLoader.itemDestroyed = false;
            tabletStageLoader.active = false;

            tryCompare(tabletStageLoader, "status", Loader.Null);
            tryCompare(tabletStageLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(tabletStageLoader, "itemDestroyed", true);

            killApps();
            WindowStateStorage.clear();
        }

        function waitUntilAppSurfaceShowsUp(surfaceId) {
            var appWindow = findAppWindowForSurfaceId(surfaceId);
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function findAppWindowForSurfaceId(surfaceId) {
            var spreadDelegate = findChild(tabletStage, "spreadDelegate_" + surfaceId);
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
            var targetAppDelegate = findChild(tabletStage, "spreadDelegate_" + targetSurfaceId);
            verify(targetAppDelegate);
            var lastValue = undefined;
            do {
                lastValue = targetAppDelegate.animatedProgress;
                wait(300);
            } while (lastValue != targetAppDelegate.animatedProgress);
        }

        function performEdgeSwipeToShowAppSpread() {
            touchFlick(tabletStage,
                tabletStage.width - (tabletStage.dragAreaWidth / 2), tabletStage.height / 2,
                tabletStage.x + 1, tabletStage.height / 2);

            var spreadView = findChild(tabletStage, "spreadView");
            verify(spreadView);
            tryCompare(spreadView, "phase", 2);
            tryCompare(spreadView, "flicking", false);
            tryCompare(spreadView, "moving", false);
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
            var targetAppDelegate = findChild(tabletStage, "spreadDelegate_" + surfaceId);

            var pos = tabletStage.width - sideStage.width - (tabletStage.width - sideStage.width) / 2;
            var end_pos = tabletStage.width - sideStage.width / 2;

            multiTouchDragUntil([0,1,2],
                                tabletStage,
                                pos,
                                tabletStage.height / 2,
                                units.gu(3),
                                0,
                                function() {
                                    pos += units.gu(3);
                                    return sideStage.shown && !sideStage.showAnimation.running &&
                                           pos >= end_pos;
                                });
            tryCompare(targetAppDelegate, "stage", ApplicationInfoInterface.SideStage);
        }

        function dragToMainStage(surfaceId) {
            sideStage.showNow();
            var targetAppDelegate = findChild(tabletStage, "spreadDelegate_" + surfaceId);
            verify(targetAppDelegate);

            var pos = tabletStage.width - sideStage.width / 2;
            var end_pos = tabletStage.width - sideStage.width - (tabletStage.width - sideStage.width) / 2;

            multiTouchDragUntil([0,1,2],
                                tabletStage,
                                pos,
                                tabletStage.height / 2,
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
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            compare(webbrowserApp.stage, ApplicationInfoInterface.MainStage);
            var webbrowserWindow = findAppWindowForSurfaceId(webbrowserSurfaceId);
            verify(webbrowserWindow);

            tryCompare(webbrowserWindow.surface, "activeFocus", true);

            var dialerSurfaceId = topSurfaceList.nextId;
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerSurfaceId);

            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            var dialerDelegate = findChild(tabletStage, "spreadDelegate_" + dialerSurfaceId);
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

            var appDelegate = findChild(tabletStage, "spreadDelegate_" + dialerSurfaceId);
            verify(appDelegate);
            compare(appDelegate.stage, ApplicationInfoInterface.SideStage);
            tryCompare(appDelegate, "swipeToCloseEnabled", true);

            swipeSurfaceUpwards(dialerSurfaceId);

            // Check that dialer-app has been closed

            tryCompareFunction(function() {
                return findChild(tabletStage, "appWindow_" + dialerCheckBox.appId);
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
            var webbrowserDelegate = findChild(tabletStage, "spreadDelegate_" + webbrowserSurfaceId);
            compare(webbrowserDelegate.stage, ApplicationInfoInterface.MainStage);

            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Running);

            var gallerySurfaceId = topSurfaceList.nextId;
            galleryCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(gallerySurfaceId);
            var galleryApp = ApplicationManager.findApplication(galleryCheckBox.appId);
            var galleryDelegate = findChild(tabletStage, "spreadDelegate_" + gallerySurfaceId);
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

            var stagesPriv = findInvisibleChild(tabletStage, "stagesPriv");
            verify(stagesPriv);

            // launch two main stage apps
            // gallery will be on foreground and webbrowser on background

            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            compare(webbrowserApp.stage, ApplicationInfoInterface.MainStage);

            var gallerySurfaceId = topSurfaceList.nextId;
            galleryCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(gallerySurfaceId);
            var galleryApp = ApplicationManager.findApplication(galleryCheckBox.appId);
            var galleryDelegate = findChild(tabletStage, "spreadDelegate_" + gallerySurfaceId);
            compare(galleryDelegate.stage, ApplicationInfoInterface.MainStage);

            compare(stagesPriv.mainStageAppId, galleryCheckBox.appId);

            // then launch two side stage apps
            // facebook will be on foreground and dialer on background

            var dialerSurfaceId = topSurfaceList.nextId;
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerSurfaceId);
            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            var dialerDelegate = findChild(tabletStage, "spreadDelegate_" + dialerSurfaceId);
            compare(dialerDelegate.stage, ApplicationInfoInterface.SideStage);

            var facebookSurfaceId = topSurfaceList.nextId;
            facebookCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(facebookSurfaceId);
            var facebookApp = ApplicationManager.findApplication(facebookCheckBox.appId);
            var facebookDelegate = findChild(tabletStage, "spreadDelegate_" + facebookSurfaceId);
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
            var webbrowserDelegate = findChild(tabletStage, "spreadDelegate_" + webbrowserSurfaceId);
            compare(webbrowserDelegate.stage, ApplicationInfoInterface.MainStage);

            var dialerSurfaceId = topSurfaceList.nextId;
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerSurfaceId);
            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            var dialerDelegate = findChild(tabletStage, "spreadDelegate_" + dialerSurfaceId);
            compare(dialerDelegate.stage, ApplicationInfoInterface.SideStage);


            compare(webbrowserApp.requestedState, ApplicationInfoInterface.RequestedRunning);
            compare(dialerApp.requestedState, ApplicationInfoInterface.RequestedRunning);

            tabletStage.suspended = true;

            tryCompare(webbrowserApp, "requestedState", ApplicationInfoInterface.RequestedSuspended);
            tryCompare(dialerApp, "requestedState", ApplicationInfoInterface.RequestedSuspended);

            tabletStage.suspended = false;

            tryCompare(webbrowserApp, "requestedState", ApplicationInfoInterface.RequestedRunning);
            tryCompare(dialerApp, "requestedState", ApplicationInfoInterface.RequestedRunning);
        }

        function test_mouseEdgePush() {
            var spreadView = findChild(tabletStageLoader, "spreadView")
            mouseMove(tabletStageLoader, tabletStageLoader.width -  1, units.gu(10));
            for (var i = 0; i < units.gu(10); i++) {
                tabletStageLoader.item.pushRightEdge(1);
            }
            tryCompare(spreadView, "phase", 2);
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
            multiTouchTap(data.touchIds, tabletStage, tabletStage.width / 2, tabletStage.height / 2);
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

            multiTouchTap(data.touchIds, tabletStage, tabletStage.width / 2, tabletStage.height / 2);
            wait(200);
            tryCompare(sideStage, "shown", data.result);
        }

        function test_threeFingerDragOpensSidestage() {
            multiTouchDragUntil([0,1,2],
                                tabletStage,
                                tabletStage.width / 4,
                                tabletStage.height / 4,
                                units.gu(1),
                                0,
                                function() { return sideStage.shown; });
        }

        function test_applicationLoadsInDefaultStage_data() {
            return [
                { tag: "MainStage", appId: "webbrowser-app", mainStageAppId: "webbrowser-app", sideStageAppId: "" },
                { tag: "SideStage", appId: "dialer-app", mainStageAppId: "unity8-dash", sideStageAppId: "dialer-app" },
            ];
        }

        function test_applicationLoadsInDefaultStage(data) {
            var stagesPriv = findInvisibleChild(tabletStage, "stagesPriv");
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
                { tag: "MainStage", stage: ApplicationInfoInterface.MainStage, mainStageAppId: "webbrowser-app", sideStageAppId: ""},
                { tag: "SideStage", stage: ApplicationInfoInterface.SideStage, mainStageAppId: "unity8-dash", sideStageAppId: "webbrowser-app" },
            ];
        }

        function test_applicationLoadsInSavedStage(data) {
            WindowStateStorage.saveStage(webbrowserCheckBox.appId, data.stage)

            var stagesPriv = findInvisibleChild(tabletStage, "stagesPriv");
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

            var stagesPriv = findInvisibleChild(tabletStage, "stagesPriv");
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
            compare(stageSaver.signalArguments[0][0], "webbrowser-app")
            compare(stageSaver.signalArguments[0][1], data.toStage)
        }

        function test_loadSideStageByDraggingFromMainStage() {
            sideStage.showNow();
            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(tabletStage, "spreadDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            compare(appDelegate.stage, ApplicationInfoInterface.MainStage);

            dragToSideStage(webbrowserSurfaceId);

            var spreadView = findChild(tabletStageLoader, "spreadView")
            tryCompare(spreadView, "surfaceDragging", false);
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.SideStage);
        }

        function test_unloadSideStageByDraggingFromStageStage() {
            sideStage.showNow();
            WindowStateStorage.saveStage(webbrowserCheckBox.appId, ApplicationInfoInterface.SideStage)
            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(tabletStage, "spreadDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            compare(appDelegate.stage, ApplicationInfoInterface.SideStage);

            dragToMainStage(webbrowserSurfaceId);

            var spreadView = findChild(tabletStageLoader, "spreadView")
            tryCompare(spreadView, "surfaceDragging", false);
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);
        }

        function test_closeSurfaceOfMultiSurfaceApp() {
            var surface1Id = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(surface1Id);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);

            var surface2Id = topSurfaceList.nextId;
            verify(surface1Id !== surface2Id); // sanity checking
            webbrowserCheckBox.createSurface();
            waitUntilAppSurfaceShowsUp(surface2Id);

            performEdgeSwipeToShowAppSpread();

            var appDelegate = findChild(tabletStage, "spreadDelegate_" + surface1Id);
            verify(appDelegate);
            tryCompare(appDelegate, "swipeToCloseEnabled", true);

            compare(webbrowserApp.surfaceList.count, 2);
            compare(webbrowserApp.state, ApplicationInfoInterface.Running);

            swipeSurfaceUpwards(surface1Id);

            // Surface must eventually be gone
            tryCompareFunction(function() { return topSurfaceList.indexForId(surface1Id); }, -1);
            tryCompare(webbrowserApp.surfaceList, "count", 1);
            compare(webbrowserApp.state, ApplicationInfoInterface.Running);
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
            var dashSurface = topSurfaceList.surfaceAt(0);

            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);

            switchToSurface(dashSurfaceId);

            tryCompare(MirFocusController, "focusedSurface", dashSurface);
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

        /*
            1 - user suspends an application (ie, focus a surface from a different application)
            2 - That suspended application gets killed, causing its surface to go zombie
            3 - user goes to spread and closes that zombie surface. Actually, by that time
                Tablet shell will be displaying a screenshot of it instead, so there's no
                MirSurface whatsoever backing it up.
         */
        function test_closeZombieSurface()
        {
            compare(topSurfaceList.applicationAt(0).appId, "unity8-dash");
            var dashSurfaceId = topSurfaceList.idAt(0);
            var dashSurface = topSurfaceList.surfaceAt(0);

            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);

            switchToSurface(dashSurfaceId);

            tryCompare(MirFocusController, "focusedSurface", dashSurface);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);

            compare(webbrowserApp.surfaceList.count, 1);

            // simulate the suspended app being killed by the out-of-memory daemon
            webbrowserApp.surfaceList.get(0).setLive(false);

            // wait until the surface is gone
            tryCompare(webbrowserApp.surfaceList, "count", 0);
            compare(topSurfaceList.surfaceAt(topSurfaceList.indexForId(webbrowserSurfaceId)), null);

            performEdgeSwipeToShowAppSpread();

            {
                var appDelegate = findChild(tabletStage, "spreadDelegate_" + webbrowserSurfaceId);
                verify(appDelegate);
                tryCompare(appDelegate, "swipeToCloseEnabled", true);
            }

            swipeSurfaceUpwards(webbrowserSurfaceId);

            // webbrowser entry is nowhere to be seen
            tryCompareFunction(function(){return topSurfaceList.indexForId(webbrowserSurfaceId);}, -1);

            // nor is its app
            compare(ApplicationManager.findApplication(webbrowserCheckBox.appId), null);

            // only unity8-dash surface is left
            compare(topSurfaceList.count, 1);
        }

        function test_draggingSurfaceKeepsSurfaceFocus() {
            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(tabletStage, "spreadDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            compare(appDelegate.stage, ApplicationInfoInterface.MainStage);

            tryCompare(appDelegate.surface, "activeFocus", true);

            dragToSideStage(webbrowserSurfaceId);

            var spreadView = findChild(tabletStageLoader, "spreadView")
            tryCompare(spreadView, "surfaceDragging", false);
            tryCompare(appDelegate.surface, "activeFocus", true);
        }

        function test_dashDoesNotDragToSidestage() {
            sideStage.showNow();
            compare(topSurfaceList.applicationAt(0).appId, "unity8-dash");
            var dashSurfaceId = topSurfaceList.idAt(0);

            var appDelegate = findChild(tabletStage, "spreadDelegate_" + dashSurfaceId);
            verify(appDelegate);
            compare(appDelegate.stage, ApplicationInfoInterface.MainStage);

            var pos = tabletStage.width - sideStage.width - (tabletStage.width - sideStage.width) / 2;
            var end_pos = tabletStage.width - sideStage.width / 2;

            multiTouchDragUntil([0,1,2],
                                tabletStage,
                                pos,
                                tabletStage.height / 2,
                                units.gu(3),
                                0,
                                function() {
                                    pos += units.gu(3);
                                    return sideStage.shown && !sideStage.showAnimation.running &&
                                           pos >= end_pos;
                                });

            var spreadView = findChild(tabletStageLoader, "spreadView")
            tryCompare(spreadView, "surfaceDragging", false);
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);
        }

        function test_switchStageOnRotation() {
            WindowStateStorage.saveStage(webbrowserCheckBox.appId, ApplicationInfoInterface.SideStage)
            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(tabletStage, "spreadDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            compare(appDelegate.stage, ApplicationInfoInterface.SideStage);

            tabletStage.shellOrientation = Qt.PortraitOrientation;
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);
        }

        function test_restoreOriginalStageOnRotation() {
            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(tabletStage, "spreadDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);

            dragToSideStage(webbrowserSurfaceId);

            // will be in sidestage now
            tabletStage.shellOrientation = Qt.PortraitOrientation;
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);

            tabletStage.shellOrientation = Qt.LandscapeOrientation;
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.SideStage);
        }

        function test_restoreSavedStageOnCloseReopen() {
            var webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            var appDelegate = findChild(tabletStage, "spreadDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);

            dragToSideStage(webbrowserSurfaceId);
            // will be in sidestage now
            tabletStage.shellOrientation = Qt.PortraitOrientation;
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.MainStage);

            webbrowserCheckBox.checked = false;
            tryCompare(ApplicationManager, "count", 1);

            // back to landscape
            tabletStage.shellOrientation = Qt.LandscapeOrientation;

            webbrowserSurfaceId = topSurfaceList.nextId;
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            appDelegate = findChild(tabletStage, "spreadDelegate_" + webbrowserSurfaceId);
            verify(appDelegate);
            tryCompare(appDelegate, "stage", ApplicationInfoInterface.SideStage);
        }


    }
}
