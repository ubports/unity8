/*
 * Copyright 2014-2016 Canonical Ltd.
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
import Unity.Test 0.1 as UT
import ".."
import "../../../qml/Components"
import "../../../qml/Stage"
import Ubuntu.Components 1.3
import Unity.Application 0.1
import WindowManager 1.0

Item {
    id: root
    width: units.gu(70)
    height: units.gu(70)

    property var greeter: { fullyShown: true }

    SurfaceManager { id: sMgr }
    ApplicationMenuDataLoader {
        id: appMenuData
        surfaceManager: sMgr
    }

    Stage {
        id: stage
        anchors { fill: parent; rightMargin: units.gu(30) }
        focus: true
        dragAreaWidth: units.gu(2)
        interactive: true
        shellOrientation: Qt.PortraitOrientation
        orientations: Orientations {}
        applicationManager: ApplicationManager
        mode: "staged"
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

    Flickable {
        contentHeight: controlRect.height

        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.right: root.right
        width: units.gu(30)
        Rectangle {
            id: controlRect
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height + units.gu(2)
            color: "darkGrey"
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
                Repeater {
                    model: ApplicationManager.availableApplications
                    ApplicationCheckBox { appId: modelData }
                }
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "PhoneStage"
        when: windowShown

        function init() {
            // wait until unity8-dash is up and running.
            ApplicationManager.startApplication("unity8-dash");
            tryCompare(ApplicationManager, "count", 1);
            var dashApp = ApplicationManager.findApplication("unity8-dash");
            verify(dashApp);
            tryCompare(dashApp, "state", ApplicationInfoInterface.Running);

            // wait for Stage to stabilize back into its initial state
            var appRepeater = findChild(stage, "appRepeater");
            tryCompare(appRepeater, "count", 1);
            tryCompare(appRepeater.itemAt(0), "x", 0);
        }

        function cleanup() {
            ApplicationManager.requestFocusApplication("unity8-dash");
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");
            tryCompare(stage, "state", "staged");
            waitForRendering(stage);

            killApps();

            stage.shellOrientationAngle = 0;

            waitForRendering(stage)
        }

        function findAppWindowForSurfaceId(surfaceId) {
            var delegateObjectName = "appDelegate_" + surfaceId;
            var spreadDelegate = findChild(stage, delegateObjectName);
            if (!spreadDelegate) {
                console.warn("Failed to find " + delegateObjectName + " in stage");
                return null;
            }
            var appWindow = findChild(spreadDelegate, "appWindow");
            return appWindow;
        }

        // Waits until ApplicationWindow has moved from showing a splash screen to displaying
        // the application surface.
        function waitUntilAppSurfaceShowsUp(surfaceId) {
            var appWindow = findAppWindowForSurfaceId(surfaceId);
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function addApps(count) {
            if (count == undefined) count = 1;
            for (var i = 0; i < count; i++) {
                var startingAppId = ApplicationManager.availableApplications[ApplicationManager.count];
                var appSurfaceId = topLevelSurfaceList.nextId;
                var app = ApplicationManager.startApplication(startingAppId)
                tryCompare(app, "state", ApplicationInfoInterface.Running)
                waitUntilAppSurfaceShowsUp(appSurfaceId);
                waitForRendering(stage)
                tryCompare(ApplicationManager, "focusedApplicationId", startingAppId)
            }
        }

        function performEdgeSwipeToShowAppSpread() {
            // Keep it inside the Stage otherwise the controls on the right side will
            // capture the press thus the "- 2"  on startX.
            var startX = stage.width - 2;
            var startY = stage.height / 2;
            var endY = startY;
            var endX = stage.width / 2;

            touchFlick(stage, startX, startY, endX, endY,
                       true /* beginTouch */, true /* endTouch */, units.gu(10), 50);

            tryCompare(stage, "state", "spread");
            // Make sure all the transitions have finished
            var appRepeater = findChild(stage, "appRepeater");
            for (var i = 0; i < appRepeater.count; i++) {
                waitUntilTransitionsEnd(appRepeater.itemAt(i));
            }
            waitForRendering(stage);
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

        function switchToSurface(targetSurfaceId) {
            performEdgeSwipeToShowAppSpread();

            waitUntilAppDelegateStopsMoving(targetSurfaceId);

            // TODO: won't work if there are many items in the spread. in this case
            // you might have to drag the list to the right or left a bit to better
            // expose the target surface. Improve this code if needed.
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

        function test_enterSpread_data() {
            return [
                {tag: "<breakPoint (trigger)", progress: .2, cancel: false, endState: "staged", newFocusedIndex: 1 },
                {tag: "<breakPoint (cancel)", progress: .2, cancel: true, endState: "staged", newFocusedIndex: 0 },
                {tag: ">breakPoint (trigger)", progress: .5, cancel: false, endState: "spread", newFocusedIndex: 0 },
                {tag: ">breakPoint (cancel)", progress: .8, cancel: true, endState: "staged", newFocusedIndex: 0 },
            ];
        }

        function test_enterSpread(data) {
            addApps(5)

            // Keep it inside the Stage otherwise the controls on the right side will
            // capture the press thus the "- 2"  on startX.
            var startX = stage.width - 2;
            var startY = stage.height / 2;
            var endY = startY;
            var endX = stage.width - (stage.width * data.progress) - stage.dragAreaWidth;

            var oldFocusedApp = ApplicationManager.get(0);
            var newFocusedApp = ApplicationManager.get(data.newFocusedIndex);

            touchFlick(stage, startX, startY, endX, endY,
                       true /* beginTouch */, false /* endTouch */, units.gu(10), 50);

            if (data.cancel) {
                touchFlick(stage, endX, endY, endX + units.gu(5), endY,
                           false /* beginTouch */, true /* endTouch */, units.gu(10), 50);
            } else {
                touchRelease(stage, endX, endY);            }

            tryCompare(stage, "state", data.endState);
            tryCompare(ApplicationManager, "focusedApplicationId", data.endState == "spread" ? oldFocusedApp.appId : newFocusedApp.appId);
        }

        function test_selectAppFromSpread_data() {
            var appsToTest = 6;
            var apps = new Array();
            for (var i = 0; i < appsToTest; i++) {
                var item = new Object();
                item.tag = "App " + i;
                item.index = i;
                item.total = appsToTest;
                apps.push(item)
            }
            return apps;
        }

        function test_selectAppFromSpread(data) {
            addApps(data.total)

            performEdgeSwipeToShowAppSpread();

            var tile = findChild(stage, "appDelegate_" + topLevelSurfaceList.idAt(data.index));
            var appId = ApplicationManager.get(data.index).appId;

            if (tile.mapToItem(stage, 0, 0).x > stage.width - units.gu(3)) {
                // Item is not visible... Need to flick the spread
                var startX = stage.width - units.gu(1);
                var startY = stage.height / 2;
                var endY = startY;
                var endX = units.gu(2);
                touchFlick(stage, startX, startY, endX, endY, true, true, units.gu(10), 50)
            }

            console.log("clicking app", data.index, "(", appId, ")")
            var dragArea = findChild(tile, "dragArea");
            tryCompare(dragArea, "closeable", true);
            mouseClick(stage, tile.mapToItem(stage, 0, 0).x + units.gu(1), stage.height / 2)
            tryCompare(ApplicationManager, "focusedApplicationId", appId);
            tryCompare(stage, "state", "staged");
        }

        function test_select_data() {
            return [
                { tag: "0", index: 0 },
                { tag: "2", index: 2 },
                { tag: "4", index: 4 },
            ]
        }

        function test_select(data) {
            addApps(5);

            var selectedApp = ApplicationManager.get(data.index);
            var appRepeater = findChild(stage, "appRepeater");
            var selectedAppDeleage = appRepeater.itemAt(data.index);

            performEdgeSwipeToShowAppSpread();

            print("tapping", selectedAppDeleage.appId, selectedAppDeleage.visible)
            if (selectedAppDeleage.x > stage.width - units.gu(5)) {
                touchFlick(stage, stage.width - units.gu(2), stage.height / 2, units.gu(2), stage.height / 2, true, true, units.gu(2), 10)
            }

            tap(selectedAppDeleage, 1, 1);

            tryCompare(stage, "state", "staged");

            tryCompare(ApplicationManager, "focusedApplicationId", selectedApp.appId);
        }

        function test_backgroundClickCancelsSpread() {
            addApps(3);

            var focusedAppId = ApplicationManager.focusedApplicationId;

            performEdgeSwipeToShowAppSpread();
            tryCompare(stage, "state", "spread");

            mouseClick(stage, units.gu(1), units.gu(1));

            tryCompare(stage, "state", "staged");

            // Make sure the same app is still focused
            tryCompare(ApplicationManager, "focusedApplicationId", focusedAppId);
        }

        function test_focusNewTopMostAppAfterFocusedOneClosesItself() {
            addApps(2);

            var secondApp = ApplicationManager.get(0);
            tryCompare(secondApp, "requestedState", ApplicationInfoInterface.RequestedRunning);
            tryCompare(secondApp, "focused", true);

            var firstApp = ApplicationManager.get(1);
            tryCompare(firstApp, "requestedState", ApplicationInfoInterface.RequestedSuspended);
            tryCompare(firstApp, "focused", false);

            ApplicationManager.stopApplication(secondApp.appId);

            tryCompare(firstApp, "requestedState", ApplicationInfoInterface.RequestedRunning);
            tryCompare(firstApp, "focused", true);
        }

        function test_focusedAppIsTheOnlyRunningApp() {
            addApps(2);

            var delegateA = findChild(stage, "appDelegate_" + topLevelSurfaceList.idAt(0));
            verify(delegateA);
            var delegateB = findChild(stage, "appDelegate_" + topLevelSurfaceList.idAt(1));
            verify(delegateB);

            // A is focused and running, B is unfocused and suspended
            compare(delegateA.focus, true);
            compare(delegateA.application.requestedState, ApplicationInfoInterface.RequestedRunning);
            compare(delegateB.focus, false);
            compare(delegateB.application.requestedState, ApplicationInfoInterface.RequestedSuspended);

            // Switch foreground/focused appp from A to B
            performEdgeSwipeToShowAppSpread();
            tap(delegateB, 1, 1);

            // Now it's the other way round
            // A is unfocused and suspended, B is focused and running
            tryCompare(delegateA, "focus", false);
            tryCompare(delegateA.application, "requestedState", ApplicationInfoInterface.RequestedSuspended);
            tryCompare(delegateB, "focus", true);
            tryCompare(delegateB.application, "requestedState", ApplicationInfoInterface.RequestedRunning);
        }

        function test_dashRemainsRunningIfStageIsToldSo() {
            addApps(1);

            var delegateDash = findChild(stage, "appDelegate_" + topLevelSurfaceList.idAt(1));
            verify(delegateDash);
            compare(delegateDash.application.appId, "unity8-dash");

            var delegateOther = findChild(stage, "appDelegate_" + topLevelSurfaceList.idAt(0));
            verify(delegateOther);

            performEdgeSwipeToShowAppSpread();
            tap(delegateDash, 1, 1);

            tryCompare(delegateDash, "focus", true);
            tryCompare(delegateDash.application, "requestedState", ApplicationInfoInterface.RequestedRunning);
            compare(delegateOther.focus, false);
            compare(delegateOther.application.requestedState, ApplicationInfoInterface.RequestedSuspended);

            performEdgeSwipeToShowAppSpread();
            tap(delegateOther, 1, 1);
            // The other app gets focused and running but dash is kept running despite being unfocused
            tryCompare(delegateOther, "focus", true);
            tryCompare(delegateOther.application, "requestedState", ApplicationInfoInterface.RequestedRunning);
            tryCompare(delegateDash, "focus", false);
            tryCompare(delegateDash.application, "requestedState", ApplicationInfoInterface.RequestedRunning);
        }

        function test_foregroundAppIsSuspendedWhenStageIsSuspended() {
            addApps(1);

            var delegate = findChild(stage, "appDelegate_" + topLevelSurfaceList.idAt(0));
            verify(delegate);

            compare(delegate.focus, true);
            compare(delegate.application.requestedState, ApplicationInfoInterface.RequestedRunning);

            stage.suspended = true;

            tryCompare(delegate.application, "requestedState", ApplicationInfoInterface.RequestedSuspended);

            stage.suspended = false;

            tryCompare(delegate.application, "requestedState", ApplicationInfoInterface.RequestedRunning);
        }

        function test_mouseEdgePush() {
            addApps(1);
            // When progress goes to 1 it should switch to spread, but stay there even if progress goes back
            stage.rightEdgePushProgress = 1;
            compare(stage.state, "spread");
            stage.rightEdgePushProgress = 0;
            compare(stage.state, "spread");
        }

        function test_closeSurfaceOfMultiSurfaceApp() {
            var surface1Id = topLevelSurfaceList.nextId;
            var webbrowserApp  = ApplicationManager.startApplication("morph-browser");
            waitUntilAppSurfaceShowsUp(surface1Id);

            var surface2Id = topLevelSurfaceList.nextId;
            verify(surface1Id !== surface2Id); // sanity checking
            webbrowserApp.createSurface();
            waitUntilAppSurfaceShowsUp(surface2Id);

            performEdgeSwipeToShowAppSpread();

            var appDelegate = findChild(stage, "appDelegate_" + surface1Id);
            var dragArea = findChild(appDelegate, "dragArea")
            verify(dragArea);
            tryCompare(dragArea, "closeable", true);

            compare(webbrowserApp.surfaceList.count, 2);

            swipeSurfaceUpwards(surface1Id);

            // Surface must eventually be gone
            tryCompareFunction(function() { return topLevelSurfaceList.indexForId(surface1Id); }, -1);
            tryCompare(webbrowserApp.surfaceList, "count", 1);
        }

        function test_swipeToClose_data() {
            return [
                { tag: "closeable", closeable: true },
                { tag: "not closeable", closeable: false }
            ]
        }

        function test_swipeToClose(data) {
            var surface1Id = topLevelSurfaceList.nextId;
            var webbrowserApp  = ApplicationManager.startApplication("morph-browser");
            waitUntilAppSurfaceShowsUp(surface1Id);

            performEdgeSwipeToShowAppSpread();

            var appDelegate = findChild(stage, "appDelegate_" + surface1Id);
            var dragArea = findChild(appDelegate, "dragArea")
            verify(dragArea);
            dragArea.closeable = data.closeable;

            var oldCount = ApplicationManager.count;

            swipeSurfaceUpwards(surface1Id);

            tryCompare(ApplicationManager, "count", data.closeable ? oldCount - 1 : oldCount);
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
            compare(topLevelSurfaceList.applicationAt(0).appId, "unity8-dash");
            var dashSurfaceId = topLevelSurfaceList.idAt(0);
            var dashWindow = topLevelSurfaceList.windowAt(0);

            var webbrowserSurfaceId = topLevelSurfaceList.nextId;
            var webbrowserApp  = ApplicationManager.startApplication("morph-browser");
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            switchToSurface(dashSurfaceId);

            tryCompare(topLevelSurfaceList, "focusedWindow", dashWindow);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);

            compare(webbrowserApp.surfaceList.count, 1);

            // simulate the suspended app being killed by the out-of-memory daemon
            webbrowserApp.surfaceList.get(0).setLive(false);

            // wait until the surface is gone
            tryCompare(webbrowserApp.surfaceList, "count", 0);

            compare(topLevelSurfaceList.surfaceAt(topLevelSurfaceList.indexForId(webbrowserSurfaceId)), null);

            switchToSurface(webbrowserSurfaceId);

            // webbrowser should have been brought to front
            tryCompareFunction(function(){return topLevelSurfaceList.idAt(0);}, webbrowserSurfaceId);

            // and it should eventually get a new surface and get resumed
            tryCompareFunction(function(){return topLevelSurfaceList.surfaceAt(0) !== null;}, true);
            compare(topLevelSurfaceList.count, 2); // still two top-level items
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
            compare(topLevelSurfaceList.applicationAt(0).appId, "unity8-dash");
            var dashSurfaceId = topLevelSurfaceList.idAt(0);
            var dashWindow = topLevelSurfaceList.windowAt(0);

            var webbrowserSurfaceId = topLevelSurfaceList.nextId;
            var webbrowserApp  = ApplicationManager.startApplication("morph-browser");
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            switchToSurface(dashSurfaceId);

            tryCompare(topLevelSurfaceList, "focusedWindow", dashWindow);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);

            compare(webbrowserApp.surfaceList.count, 1);

            // simulate the suspended app being killed by the out-of-memory daemon
            webbrowserApp.surfaceList.get(0).setLive(false);

            // wait until the surface is gone
            tryCompare(webbrowserApp.surfaceList, "count", 0);
            compare(topLevelSurfaceList.surfaceAt(topLevelSurfaceList.indexForId(webbrowserSurfaceId)), null);

            performEdgeSwipeToShowAppSpread();

            var appDelegate = findChild(stage, "appDelegate_" + webbrowserSurfaceId);
            var dragArea = findChild(appDelegate, "dragArea");
            verify(dragArea);
            tryCompare(dragArea, "closeable", true);

            swipeSurfaceUpwards(webbrowserSurfaceId);

            // webbrowser entry is nowhere to be seen
            tryCompareFunction(function(){return topLevelSurfaceList.indexForId(webbrowserSurfaceId);}, -1);

            // nor is its app
            compare(ApplicationManager.findApplication("morph-browser"), null);

            // only unity8-dash surface is left
            compare(topLevelSurfaceList.count, 1);
        }


        /*
            Check that when an application starts while the spread is open, the
            spread closes and that new app is brought to front (gets focused).
         */
        function test_launchAppWithSpreadOpen()
        {
            performEdgeSwipeToShowAppSpread();

            var webbrowserSurfaceId = topLevelSurfaceList.nextId;
            var webbrowserApp  = ApplicationManager.startApplication("morph-browser");
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            compare(topLevelSurfaceList.idAt(0), webbrowserSurfaceId);
            compare(webbrowserApp.focused, true);
        }
    }
}
