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
import "../../../qml/Stages"
import Ubuntu.Components 1.3
import Unity.Application 0.1
import WindowManager 0.1

Item {
    id: root
    width: units.gu(70)
    height: units.gu(70)

    property var greeter: { fullyShown: true }

    PhoneStage {
        id: phoneStage
        anchors { fill: parent; rightMargin: units.gu(30) }
        focus: true
        dragAreaWidth: units.gu(2)
        maximizedAppTopMargin: units.gu(3)
        interactive: true
        shellOrientation: Qt.PortraitOrientation
        orientations: Orientations {}
        applicationManager: ApplicationManager
        topLevelSurfaceList: TopLevelSurfaceList {
            id: topLevelSurfaceList
            applicationsModel: ApplicationManager
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
                    onDragged: { phoneStage.pushRightEdge(amount); }
                    Component.onCompleted: {
                        edgeBarrierControls.target = testCase.findChild(phoneStage, "edgeBarrierController");
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

        function findAppWindowForSurfaceId(surfaceId) {
            var delegateObjectName = "spreadDelegate_" + surfaceId;
            var spreadDelegate = findChild(phoneStage, delegateObjectName);
            if (!spreadDelegate) {
                console.warn("Failed to find " + delegateObjectName + " in phoneStage ("+phoneStage+")");
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
                var appSurfaceId = topLevelSurfaceList.nextId;
                var app = ApplicationManager.startApplication(ApplicationManager.availableApplications[ApplicationManager.count])
                tryCompare(app, "state", ApplicationInfoInterface.Running)
                var spreadView = findChild(phoneStage, "spreadView");
                tryCompare(spreadView, "contentX", -spreadView.shift);
                waitUntilAppSurfaceShowsUp(appSurfaceId);
                waitForRendering(phoneStage)
            }
        }

        function performEdgeSwipeToShowAppSpread() {
            var spreadView = findChild(phoneStage, "spreadView");

            // Keep it inside the PhoneStage otherwise the controls on the right side will
            // capture the press thus the "- 2"  on startX.
            var startX = phoneStage.width - 2;
            var startY = phoneStage.height / 2;
            var endY = startY;
            var endX = phoneStage.width / 2;

            touchFlick(phoneStage, startX, startY, endX, endY,
                       true /* beginTouch */, true /* endTouch */, units.gu(10), 50);

            tryCompare(spreadView, "phase", 2);
            tryCompare(spreadView, "flicking", false);
            tryCompare(spreadView, "moving", false);
            waitForRendering(phoneStage);
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
            var targetAppDelegate = findChild(phoneStage, "spreadDelegate_" + targetSurfaceId);
            verify(targetAppDelegate);
            var lastValue = undefined;
            do {
                lastValue = targetAppDelegate.animatedProgress;
                wait(300);
            } while (lastValue != targetAppDelegate.animatedProgress);
        }

        function test_shortFlick() {
            addApps(2)
            var startX = phoneStage.width - units.gu(1);
            var startY = phoneStage.height / 2;
            var endX = startX - units.gu(4);
            var endY = startY;

            var activeApp = ApplicationManager.get(0);
            var inactiveApp = ApplicationManager.get(1);

            touchFlick(phoneStage, startX, startY, endX, endY,
                       true /* beginTouch */, true /* endTouch */, units.gu(10), 50);

            tryCompare(ApplicationManager, "focusedApplicationId", inactiveApp.appId)

            touchFlick(phoneStage, startX, startY, endX, endY,
                       true /* beginTouch */, true /* endTouch */, units.gu(10), 50);

            tryCompare(ApplicationManager, "focusedApplicationId", activeApp.appId)
        }

        function test_enterSpread_data() {
            return [
                {tag: "<position1 (linear movement)", positionMarker: "positionMarker1", linear: true, offset: 0, endPhase: 0, targetPhase: 0, newFocusedIndex: 1 },
                {tag: "<position1 (non-linear movement)", positionMarker: "positionMarker1", linear: false, offset: 0, endPhase: 0, targetPhase: 0, newFocusedIndex: 0 },
                {tag: ">position1", positionMarker: "positionMarker1", linear: true, offset: +5, endPhase: 0, targetPhase: 0, newFocusedIndex: 1 },
                {tag: "<position2 (linear)", positionMarker: "positionMarker2", linear: true, offset: 0, endPhase: 0, targetPhase: 0, newFocusedIndex: 1 },
                {tag: "<position2 (non-linear)", positionMarker: "positionMarker2", linear: false, offset: 0, endPhase: 0, targetPhase: 0, newFocusedIndex: 1 },
                {tag: ">position2", positionMarker: "positionMarker2", linear: true, offset: +5, endPhase: 1, targetPhase: 0, newFocusedIndex: 1 },
                {tag: "<position3", positionMarker: "positionMarker3", linear: true, offset: 0, endPhase: 1, targetPhase: 0, newFocusedIndex: 1 },
                {tag: ">position3", positionMarker: "positionMarker3", linear: true, offset: +5, endPhase: 1, targetPhase: 2, newFocusedIndex: 2 },
            ];
        }

        function test_enterSpread(data) {
            addApps(5)

            var spreadView = findChild(phoneStage, "spreadView");

            // Keep it inside the PhoneStage otherwise the controls on the right side will
            // capture the press thus the "- 2"  on startX.
            var startX = phoneStage.width - 2;
            var startY = phoneStage.height / 2;
            var endY = startY;
            var endX = spreadView.width - (spreadView.width * spreadView[data.positionMarker]) - data.offset
                - phoneStage.dragAreaWidth;

            var oldFocusedApp = ApplicationManager.get(0);
            var newFocusedApp = ApplicationManager.get(data.newFocusedIndex);

            touchFlick(phoneStage, startX, startY, endX, endY,
                       true /* beginTouch */, false /* endTouch */, units.gu(10), 50);

            tryCompare(spreadView, "phase", data.endPhase)

            if (!data.linear) {
                touchFlick(phoneStage, endX, endY, endX + units.gu(.5), endY,
                           false /* beginTouch */, false /* endTouch */, units.gu(10), 50);
                touchFlick(phoneStage, endY + units.gu(.5), endY, endX, endY,
                           false /* beginTouch */, false /* endTouch */, units.gu(10), 50);
            }

            touchRelease(phoneStage, endX, endY);

            tryCompare(spreadView, "phase", data.targetPhase)

            if (data.targetPhase == 2) {
                var app2 = findChild(spreadView, "spreadDelegate_" + topLevelSurfaceList.idAt(2));
                tryCompare(app2, "swipeToCloseEnabled", true);
                mouseClick(app2, units.gu(1), units.gu(1));
            }

            tryCompare(ApplicationManager, "focusedApplicationId", newFocusedApp.appId);
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

            var spreadView = findChild(phoneStage, "spreadView");

            performEdgeSwipeToShowAppSpread();

            tryCompare(spreadView, "phase", 2);

            var tile = findChild(spreadView, "spreadDelegate_" + topLevelSurfaceList.idAt(data.index));
            var appId = ApplicationManager.get(data.index).appId;

            if (tile.mapToItem(spreadView, 0, 0).x > spreadView.width) {
                // Item is not visible... Need to flick the spread
                var startX = phoneStage.width - units.gu(1);
                var startY = phoneStage.height / 2;
                var endY = startY;
                var endX = units.gu(2);
                touchFlick(phoneStage, startX, startY, endX, endY, true, true, units.gu(10), 50)
                tryCompare(spreadView, "flicking", false);
                tryCompare(spreadView, "moving", false);
//                waitForRendering(phoneStage);
            }

            console.log("clicking app", data.index, "(", appId, ")")
            tryCompare(tile, "swipeToCloseEnabled", true);
            mouseClick(spreadView, tile.mapToItem(spreadView, 0, 0).x + units.gu(1), spreadView.height / 2)
            tryCompare(ApplicationManager, "focusedApplicationId", appId);
            tryCompare(spreadView, "phase", 0);
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

            var spreadView = findChild(phoneStage, "spreadView");
            var selectedApp = ApplicationManager.get(data.index);

            performEdgeSwipeToShowAppSpread();

            phoneStage.select(selectedApp.appId);

            tryCompare(spreadView, "contentX", -spreadView.shift);

            compare(ApplicationManager.focusedApplicationId, selectedApp.appId);
        }

        function test_backgroundClickCancelsSpread() {
            addApps(3);

            var focusedAppId = ApplicationManager.focusedApplicationId;

            performEdgeSwipeToShowAppSpread();

            mouseClick(phoneStage, units.gu(1), units.gu(1));

            // Make sure the spread is in the idle position
            var spreadView = findChild(phoneStage, "spreadView");
            tryCompare(spreadView, "contentX", -spreadView.shift);

            // Make sure the same app is still focused
            compare(focusedAppId, ApplicationManager.focusedApplicationId);
        }

        function init() {
            // wait until unity8-dash is up and running.
            // it's started automatically by ApplicationManager mock implementation
            tryCompare(ApplicationManager, "count", 1);
            var dashApp = ApplicationManager.findApplication("unity8-dash");
            verify(dashApp);
            tryCompare(dashApp, "state", ApplicationInfoInterface.Running);
        }

        function cleanup() {
            killApps();

            phoneStage.shellOrientationAngle = 0;
            phoneStage.select(ApplicationManager.get(0).appId);

            // wait for PhoneStage to stabilize back into its initial state
            var spreadView = findChild(phoneStage, "spreadView");
            while (spreadView.phase !== 0 || spreadView.contentX !== -spreadView.shift || spreadView.selectedIndex != -1) {
                wait(50);
            }
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

        function test_cantCloseWhileSnapping() {
            addApps(2);

            performEdgeSwipeToShowAppSpread();

            var spreadView = findChild(phoneStage, "spreadView");
            var selectedApp = ApplicationManager.get(2);

            performEdgeSwipeToShowAppSpread();

            var app0 = findChild(spreadView, "spreadDelegate_" + topLevelSurfaceList.idAt(0));
            var app1 = findChild(spreadView, "spreadDelegate_" + topLevelSurfaceList.idAt(1));
            var app2 = findChild(spreadView, "spreadDelegate_" + topLevelSurfaceList.idAt(2));

            var dragArea0 = findChild(app0, "dragArea");
            var dragArea1 = findChild(app1, "dragArea");
            var dragArea2 = findChild(app2, "dragArea");

            compare(dragArea0.enabled, true);
            compare(dragArea1.enabled, true);
            compare(dragArea2.enabled, true);

            phoneStage.select(selectedApp.appId);

            // Make sure all drag areas are disabled instantly. Don't use tryCompare here!
            compare(dragArea0.enabled, false);
            compare(dragArea1.enabled, false);
            compare(dragArea2.enabled, false);

            tryCompare(spreadView, "contentX", -spreadView.shift)
        }

        function test_cantAccessPhoneStageWhileRightEdgeGesture() {
            var spreadView = findChild(phoneStage, "spreadView");
            var eventEaterArea = findChild(phoneStage, "eventEaterArea")

            var startX = phoneStage.width - 2;
            var startY = phoneStage.height / 2;
            var endY = startY;
            var endX = phoneStage.width / 2;

            touchFlick(phoneStage, startX, startY, endX, endY,
                       true /* beginTouch */, false /* endTouch */, units.gu(10), 50);

            compare(eventEaterArea.enabled, true);

            touchRelease(phoneStage, endX, endY);

            compare(eventEaterArea.enabled, false);
        }

        function test_leftEdge_data() {
            return [
                { tag: "normal", inSpread: false, leftEdgeDragWidth: units.gu(5), shouldMoveApp: true },
                { tag: "inSpread", inSpread: true, leftEdgeDragWidth: units.gu(5), shouldMoveApp: false }
            ]
        }

        function test_leftEdge(data) {
            addApps(2);

            if (data.inSpread) {
                performEdgeSwipeToShowAppSpread();
            }

            var focusedDelegate = findChild(phoneStage, "spreadDelegate_" + topLevelSurfaceList.idAt(0));
            phoneStage.inverseProgress = data.leftEdgeDragWidth;

            tryCompare(focusedDelegate, "x", data.shouldMoveApp ? data.leftEdgeDragWidth : 0);

            phoneStage.inverseProgress = 0;

            tryCompare(focusedDelegate, "x", 0);
        }

        function test_focusedAppIsTheOnlyRunningApp() {
            addApps(2);

            var delegateA = findChild(phoneStage, "spreadDelegate_" + topLevelSurfaceList.idAt(0));
            verify(delegateA);
            var delegateB = findChild(phoneStage, "spreadDelegate_" + topLevelSurfaceList.idAt(1));
            verify(delegateB);

            // A is focused and running, B is unfocused and suspended
            compare(delegateA.focus, true);
            compare(delegateA.application.requestedState, ApplicationInfoInterface.RequestedRunning);
            compare(delegateB.focus, false);
            compare(delegateB.application.requestedState, ApplicationInfoInterface.RequestedSuspended);

            // Switch foreground/focused appp from A to B
            performEdgeSwipeToShowAppSpread();
            phoneStage.select(delegateB.application.appId);

            // Now it's the other way round
            // A is unfocused and suspended, B is focused and running
            tryCompare(delegateA, "focus", false);
            tryCompare(delegateA.application, "requestedState", ApplicationInfoInterface.RequestedSuspended);
            tryCompare(delegateB, "focus", true);
            tryCompare(delegateB.application, "requestedState", ApplicationInfoInterface.RequestedRunning);
        }

        function test_dashRemainsRunningIfStageIsToldSo() {
            addApps(1);

            var delegateDash = findChild(phoneStage, "spreadDelegate_" + topLevelSurfaceList.idAt(1));
            verify(delegateDash);
            compare(delegateDash.application.appId, "unity8-dash");

            var delegateOther = findChild(phoneStage, "spreadDelegate_" + topLevelSurfaceList.idAt(0));
            verify(delegateOther);

            performEdgeSwipeToShowAppSpread();
            phoneStage.select("unity8-dash");

            tryCompare(delegateDash, "focus", true);
            tryCompare(delegateDash.application, "requestedState", ApplicationInfoInterface.RequestedRunning);
            compare(delegateOther.focus, false);
            compare(delegateOther.application.requestedState, ApplicationInfoInterface.RequestedSuspended);

            performEdgeSwipeToShowAppSpread();
            phoneStage.select(delegateOther.application.appId);

            // The other app gets focused and running but dash is kept running despite being unfocused
            tryCompare(delegateDash, "focus", false);
            tryCompare(delegateDash.application, "requestedState", ApplicationInfoInterface.RequestedRunning);
            compare(delegateOther.focus, true);
            compare(delegateOther.application.requestedState, ApplicationInfoInterface.RequestedRunning);
        }

        function test_foregroundAppIsSuspendedWhenStageIsSuspended() {
            addApps(1);

            var delegate = findChild(phoneStage, "spreadDelegate_" + topLevelSurfaceList.idAt(0));
            verify(delegate);

            compare(delegate.focus, true);
            compare(delegate.application.requestedState, ApplicationInfoInterface.RequestedRunning);

            phoneStage.suspended = true;

            tryCompare(delegate.application, "requestedState", ApplicationInfoInterface.RequestedSuspended);

            phoneStage.suspended = false;

            tryCompare(delegate.application, "requestedState", ApplicationInfoInterface.RequestedRunning);
        }

        function test_mouseEdgePush() {
            var spreadView = findChild(phoneStage, "spreadView")
            addApps(1);
            mouseMove(phoneStage, phoneStage.width -  1, units.gu(10));
            for (var i = 0; i < units.gu(10); i++) {
                phoneStage.pushRightEdge(1);
            }
            tryCompare(spreadView, "phase", 2);
        }

        function test_closeSurfaceOfMultiSurfaceApp() {
            var surface1Id = topLevelSurfaceList.nextId;
            var webbrowserApp  = ApplicationManager.startApplication("webbrowser-app");
            waitUntilAppSurfaceShowsUp(surface1Id);

            var surface2Id = topLevelSurfaceList.nextId;
            verify(surface1Id !== surface2Id); // sanity checking
            webbrowserApp.createSurface();
            waitUntilAppSurfaceShowsUp(surface2Id);

            performEdgeSwipeToShowAppSpread();

            var appDelegate = findChild(phoneStage, "spreadDelegate_" + surface1Id);
            verify(appDelegate);
            tryCompare(appDelegate, "swipeToCloseEnabled", true);

            compare(webbrowserApp.surfaceList.count, 2);
            compare(webbrowserApp.state, ApplicationInfoInterface.Running);

            swipeSurfaceUpwards(surface1Id);

            // Surface must eventually be gone
            tryCompareFunction(function() { return topLevelSurfaceList.indexForId(surface1Id); }, -1);
            tryCompare(webbrowserApp.surfaceList, "count", 1);
            compare(webbrowserApp.state, ApplicationInfoInterface.Running);
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
            var dashSurface = topLevelSurfaceList.surfaceAt(0);

            var webbrowserSurfaceId = topLevelSurfaceList.nextId;
            var webbrowserApp  = ApplicationManager.startApplication("webbrowser-app");
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            switchToSurface(dashSurfaceId);

            tryCompare(MirFocusController, "focusedSurface", dashSurface);
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
            var dashSurface = topLevelSurfaceList.surfaceAt(0);

            var webbrowserSurfaceId = topLevelSurfaceList.nextId;
            var webbrowserApp  = ApplicationManager.startApplication("webbrowser-app");
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            switchToSurface(dashSurfaceId);

            tryCompare(MirFocusController, "focusedSurface", dashSurface);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);

            compare(webbrowserApp.surfaceList.count, 1);

            // simulate the suspended app being killed by the out-of-memory daemon
            webbrowserApp.surfaceList.get(0).setLive(false);

            // wait until the surface is gone
            tryCompare(webbrowserApp.surfaceList, "count", 0);
            compare(topLevelSurfaceList.surfaceAt(topLevelSurfaceList.indexForId(webbrowserSurfaceId)), null);

            performEdgeSwipeToShowAppSpread();

            {
                var appDelegate = findChild(phoneStage, "spreadDelegate_" + webbrowserSurfaceId);
                verify(appDelegate);
                tryCompare(appDelegate, "swipeToCloseEnabled", true);
            }

            swipeSurfaceUpwards(webbrowserSurfaceId);

            // webbrowser entry is nowhere to be seen
            tryCompareFunction(function(){return topLevelSurfaceList.indexForId(webbrowserSurfaceId);}, -1);

            // nor is its app
            compare(ApplicationManager.findApplication("webbrowser-app"), null);

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
            var webbrowserApp  = ApplicationManager.startApplication("webbrowser-app");
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            compare(topLevelSurfaceList.idAt(0), webbrowserSurfaceId);
            compare(webbrowserApp.focused, true);
        }
    }
}
