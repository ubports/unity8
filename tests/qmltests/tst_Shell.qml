/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *   Daniel d'Andrada <daniel.dandrada@canonical.com>
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
import GSettings 1.0
import LightDM 0.1 as LightDM
import Ubuntu.Components 1.1
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
import Unity.Connectivity 0.1
import Unity.Notifications 1.0
import Unity.Test 0.1 as UT
import Powerd 0.1

import "../../qml"

Row {
    id: root
    spacing: 0

    QtObject {
        id: applicationArguments

        function hasGeometry() {
            return false;
        }

        function width() {
            return 0;
        }

        function height() {
            return 0;
        }
    }

    Loader {
        id: shellLoader

        // Copied from Shell.qml
        property bool tablet: false
        width: tablet ? units.gu(160)
                      : applicationArguments.hasGeometry() ? applicationArguments.width()
                                                           : units.gu(40)
        height: tablet ? units.gu(100)
                       : applicationArguments.hasGeometry() ? applicationArguments.height()
                                                            : units.gu(71)

        property bool itemDestroyed: false
        sourceComponent: Component {
            Shell {
                Component.onDestruction: {
                    shellLoader.itemDestroyed = true;
                }
            }
        }
    }

    Rectangle {
        color: "white"
        width: units.gu(30)
        height: shellLoader.height

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)
            Row {
                anchors { left: parent.left; right: parent.right }
                Button {
                    text: "Show Greeter"
                    onClicked: {
                        if (shellLoader.status !== Loader.Ready)
                            return;

                        var greeter = testCase.findChild(shellLoader.item, "greeter");
                        if (!greeter.shown) {
                            greeter.show();
                        }
                    }
                }
            }
        }
    }

    SignalSpy {
        id: sessionSpy
        signalName: "sessionStarted"
    }

    SignalSpy {
        id: dashCommunicatorSpy
        signalName: "setCurrentScopeCalled"
    }

    SignalSpy {
        id: unlockAllModemsSpy
        target: Connectivity
        signalName: "unlockingAllModems"
    }

    Telephony.CallEntry {
        id: phoneCall
        phoneNumber: "+447812221111"
    }

    UT.UnityTestCase {
        id: testCase
        name: "Shell"
        when: windowShown

        property Item shell: shellLoader.status === Loader.Ready ? shellLoader.item : null

        function init() {
            swipeAwayGreeter();

            sessionSpy.target = findChild(shell, "greeter")
            dashCommunicatorSpy.target = findInvisibleChild(shell, "dashCommunicator");
        }

        function cleanup() {
            shellLoader.itemDestroyed = false;

            shellLoader.active = false;

            tryCompare(shellLoader, "status", Loader.Null);
            tryCompare(shellLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // item might still be alive. So if we set Loader.active back to true
            // again right now we will get the very same Shell instance back. So no reload
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(shellLoader, "itemDestroyed", true);

            // kill all (fake) running apps
            killApps(ApplicationManager);

            unlockAllModemsSpy.clear()

            // reload our test subject to get it in a fresh state once again
            shellLoader.active = true;

            tryCompare(shellLoader, "status", Loader.Ready);
            removeTimeConstraintsFromDirectionalDragAreas(shellLoader.item);
        }

        function killApps() {
            while (ApplicationManager.count > 1) {
                var appIndex = ApplicationManager.get(0).appId == "unity8-dash" ? 1 : 0
                ApplicationManager.stopApplication(ApplicationManager.get(appIndex).appId);
            }
            compare(ApplicationManager.count, 1)
        }

        Component {
            id: mockNotification

            QtObject {
                function invokeAction(actionId) {
                    mockNotificationsModel.actionInvoked(actionId)
                }
            }
        }

        ListModel {
            id: mockNotificationsModel

            signal actionInvoked(string actionId)

            function getRaw(id) {
                return mockNotification.createObject(mockNotificationsModel)
            }
        }

        SignalSpy {
            id: notificationActionSpy

            target: mockNotificationsModel
            signalName: "actionInvoked"
        }

        function test_snapDecisionDismissalReturnsFocus() {
            var notifications = findChild(shell, "notificationList");
            var app = ApplicationManager.startApplication("camera-app");

            // Open an application and focus
            waitUntilApplicationWindowIsFullyVisible(app);
            ApplicationManager.focusApplication(app);
            compare(app.session.surface.activeFocus, true, "Focused application didn't have activeFocus");

            // Pop-up a notification
            addSnapDecisionNotification();
            notifications.model = mockNotificationsModel;

            var notification = findChild(notifications, "notification" + (mockNotificationsModel.count - 1));
            verify(notification !== undefined, "notification wasn't found");

            var buttonRow = findChild(notification, "buttonRow");
            verify(buttonRow !== undefined, "notification buttonRow wasn't found");

            var buttonAccept = findChild(buttonRow, "notify_button0");
            verify(buttonAccept !== undefined, "notification accept button wasn't found");

            // Pressing the button should give focus to the notification
            mousePress(buttonAccept, 0, 0);
            compare(app.session.surface.activeFocus, false, "Notification didn't take active focus");
            mouseRelease(buttonAccept);

            // Clicking the button should dismiss the notification and return focus
            mouseClick(buttonAccept, buttonAccept.width / 2, buttonAccept.height / 2);
            //compare(app.session.surface.activeFocus, true, "App didn't take active focus after snap notification was dismissed");
        }

        function addSnapDecisionNotification() {
		    var n = {
		        type: Notification.SnapDecision,
		        hints: {"x-canonical-private-affirmative-tint": "true"},
		        summary: "Tom Ato",
		        body: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
		        icon: "../graphics/avatars/funky.png",
		        secondaryIcon: "../graphics/applicationIcons/facebook.png",
		        actions: [{ id: "ok_id", label: "Ok"},
		                  { id: "cancel_id", label: "Cancel"},
		                  { id: "notreally_id", label: "Not really"},
		                  { id: "noway_id", label: "messages:No way"},
		                  { id: "nada_id", label: "messages:Nada"}]
		    }

        	mockNotificationsModel.append(n)
    	}

        function test_leftEdgeDrag_data() {
            return [
                {tag: "without launcher", revealLauncher: false, swipeLength: units.gu(27), appHides: true, focusedApp: "dialer-app", launcherHides: true},
                {tag: "with launcher", revealLauncher: true, swipeLength: units.gu(27), appHides: true, focusedApp: "dialer-app", launcherHides: true},
                {tag: "small swipe", revealLauncher: false, swipeLength: units.gu(25), appHides: false, focusedApp: "dialer-app", launcherHides: false},
                {tag: "long swipe", revealLauncher: false, swipeLength: units.gu(27), appHides: true, focusedApp: "dialer-app", launcherHides: true},
                {tag: "long swipe", revealLauncher: false, swipeLength: units.gu(27), appHides: true, focusedApp: "unity8-dash", launcherHides: false}
            ];
        }

        /*function test_leftEdgeDrag(data) {
            dragLauncherIntoView();
            tapOnAppIconInLauncher();
            waitUntilApplicationWindowIsFullyVisible();
            ApplicationManager.focusApplication(data.focusedApp)
            waitUntilApplicationWindowIsFullyVisible();

            if (data.revealLauncher) {
                dragLauncherIntoView();
            }

            swipeFromLeftEdge(data.swipeLength);
            if (data.appHides) {
                waitUntilDashIsFocused();
            } else {
                waitUntilApplicationWindowIsFullyVisible();
            }

            var launcher = findChild(shell, "launcherPanel");
            tryCompare(launcher, "x", data.launcherHides ? -launcher.width : 0)

            // Make sure the helper for sliding out the launcher wasn't touched. We want to fade it out here.
            var animateTimer = findInvisibleChild(shell, "animateTimer");
            compare(animateTimer.nextState, "visible");
        }*/

        /*function test_suspend() {
            var greeter = findChild(shell, "greeter");

            // Launch an app from the launcher
            dragLauncherIntoView();
            tapOnAppIconInLauncher();
            waitUntilApplicationWindowIsFullyVisible();

            var mainAppId = ApplicationManager.focusedApplicationId;
            verify(mainAppId != "");
            var mainApp = ApplicationManager.findApplication(mainAppId);
            verify(mainApp);
            tryCompare(mainApp, "state", ApplicationInfoInterface.Running);

            // Suspend while call is active...
            callManager.foregroundCall = phoneCall;
            Powerd.status = Powerd.Off;
            tryCompare(greeter, "showProgress", 0);

            // Now try again after ending call
            callManager.foregroundCall = null;
            Powerd.status = Powerd.On;
            Powerd.status = Powerd.Off;
            tryCompare(greeter, "showProgress", 1);

            tryCompare(ApplicationManager, "suspended", true);
            compare(mainApp.state, ApplicationInfoInterface.Suspended);

            // And wake up
            Powerd.status = Powerd.On;
            tryCompare(greeter, "showProgress", 1);

            // Swipe away greeter to focus app
            swipeAwayGreeter();
            tryCompare(ApplicationManager, "suspended", false);
            compare(mainApp.state, ApplicationInfoInterface.Running);
            tryCompare(ApplicationManager, "focusedApplicationId", mainAppId);
        }*/

        function swipeAwayGreeter() {
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "showProgress", 1);

            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;
            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY);

            // wait until the animation has finished
            tryCompare(greeter, "showProgress", 0);
            waitForRendering(greeter);
        }

        /*
          Regression test for bug https://bugs.launchpad.net/touch-preview-images/+bug/1193419

          When the user minimizes an application (left-edge swipe) he should always end up in the
          "Applications" scope view.

          Steps:
          - reveal launcher and launch an app that covers the dash
          - perform long left edge swipe to go minimize the app and go back to the dash.
          - verify the setCurrentScope() D-Bus call to the dash has been called for the correct scope id.
         */
        /*function test_minimizingAppTakesToDashApps() {
            dragLauncherIntoView();

            // Launch an app from the launcher
            tapOnAppIconInLauncher();

            waitUntilApplicationWindowIsFullyVisible();

            verify(ApplicationManager.focusedApplicationId !== "unity8-dash")

            dashCommunicatorSpy.clear();
            // Minimize the application we just launched
            swipeFromLeftEdge(units.gu(27));

            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");

            compare(dashCommunicatorSpy.count, 1);
            compare(dashCommunicatorSpy.signalArguments[0][0], "clickscope");
        }*/

        /*function test_showInputMethod() {
            var item = findChild(shell, "inputMethod");
            var surface = SurfaceManager.inputMethodSurface();

            surface.setState(MirSurfaceItem.Minimized);
            tryCompare(item, "visible", false);

            surface.setState(MirSurfaceItem.Restored);
            tryCompare(item, "visible", true);

            surface.setState(MirSurfaceItem.Minimized);
            tryCompare(item, "visible", false);

            surface.setState(MirSurfaceItem.Maximized);
            tryCompare(item, "visible", true);

            surface.setState(MirSurfaceItem.Minimized);
            tryCompare(item, "visible", false);
        }*/

        // wait until any transition animation has finished
        function waitUntilTransitionsEnd(stateGroup) {
            var transitions = stateGroup.transitions;
            for (var i = 0; i < transitions.length; ++i) {
                var transition = transitions[i];
                tryCompare(transition, "running", false, 2000);
            }
        }

        // Wait until the ApplicationWindow for the given Application object is fully loaded
        // (ie, the real surface has replaced the splash screen)
        function waitUntilAppWindowIsFullyLoaded(app) {
            var appWindow = findChild(shell, "appWindow_" + app.appId);
            var appWindowStateGroup = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            tryCompareFunction(function() { return appWindowStateGroup.state === "surface" }, true);
            waitUntilTransitionsEnd(appWindowStateGroup);
        }

        function test_surfaceLosesFocusWhilePanelIsOpen() {
            var app = ApplicationManager.startApplication("dialer-app");
            waitUntilAppWindowIsFullyLoaded(app);

            tryCompare(app.session.surface, "focus", true);

            // Drag the indicators panel half-open
            var touchX = shell.width / 2;
            var indicators = findChild(shell, "indicators");
            touchFlick(indicators,
                    touchX /* fromX */, indicators.panelHeight * 0.5 /* fromY */,
                    touchX /* toX */, shell.height * 0.5 /* toY */,
                    true /* beginTouch */, false /* endTouch */);
            verify(indicators.partiallyOpened);

            tryCompare(app.session.surface, "focus", false);

            // And finish getting it open
            touchFlick(indicators,
                    touchX /* fromX */, shell.height * 0.5 /* fromY */,
                    touchX /* toX */, shell.height * 0.9 /* toY */,
                    false /* beginTouch */, true /* endTouch */);
            tryCompare(indicators, "fullyOpened", true);

            tryCompare(app.session.surface, "focus", false);

            dragToCloseIndicatorsPanel();

            tryCompare(app.session.surface, "focus", true);
        }

        // Wait for the whole UI to settle down
        function waitForUIToSettle() {
            var launcher = findChild(shell, "launcherPanel")
            tryCompareFunction(function() {return launcher.x === 0 || launcher.x === -launcher.width;}, true);
            if (launcher.x === 0) {
                mouseClick(shell, shell.width / 2, shell.height / 2)
            }
            tryCompare(launcher, "x", -launcher.width)

            waitForRendering(shell)
        }

        function dragToCloseIndicatorsPanel() {
            var indicators = findChild(shell, "indicators");

            var touchStartX = shell.width / 2;
            var touchStartY = shell.height - (indicators.panelHeight * 0.5);
            touchFlick(shell,
                    touchStartX, touchStartY,
                    touchStartX, shell.height * 0.1);

            tryCompare(indicators, "fullyClosed", true);
        }

        function dragLauncherIntoView() {
            var launcherPanel = findChild(shell, "launcherPanel");
            verify(launcherPanel.x = - launcherPanel.width);

            var touchStartX = 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, launcherPanel.width + units.gu(1), touchStartY);

            tryCompare(launcherPanel, "x", 0);
        }

        function tapOnAppIconInLauncher() {
            var launcherPanel = findChild(shell, "launcherPanel");

            // pick the first icon, the one at the bottom.
            var appIcon = findChild(launcherPanel, "launcherDelegate0")

            // Swipe upwards over the launcher to ensure that this icon
            // at the bottom is not folded and faded away.
            var touchStartX = launcherPanel.width / 2;
            var touchStartY = launcherPanel.height / 2;
            touchFlick(launcherPanel, touchStartX, touchStartY, touchStartX, 0);
            tryCompare(launcherPanel, "moving", false);

            // NB tapping (i.e., using touch events) doesn't activate the icon... go figure...
            mouseClick(appIcon, appIcon.width / 2, appIcon.height / 2);
        }

        function showIndicators() {
            var indicators = findChild(shell, "indicators");
            indicators.show();
            tryCompare(indicators, "fullyOpened", true);
        }

        function hideIndicators() {
            var indicators = findChild(shell, "indicators");
            if (indicators.fullyOpened) {
                indicators.hide();
            }
        }

        function waitUntilApplicationWindowIsFullyVisible() {
            var appDelegate = findChild(shell, "appDelegate0")
            var surfaceContainer = findChild(appDelegate, "surfaceContainer");
            tryCompareFunction(function() { return surfaceContainer.surface !== null; }, true);
        }

        function waitUntilDashIsFocused() {
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");
        }

        function swipeFromLeftEdge(swipeLength) {
            var touchStartX = 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, swipeLength, touchStartY);
        }

        function itemIsOnScreen(item) {
            var itemRectInShell = item.mapToItem(shell, 0, 0, item.width, item.height);

            return itemRectInShell.x >= 0
                && itemRectInShell.y >= 0
                && itemRectInShell.x + itemRectInShell.width <= shell.width
                && itemRectInShell.y + itemRectInShell.height <= shell.height;
        }

        /*function test_focusRequestedHidesGreeter() {
            var greeter = findChild(shell, "greeter");

            var app = ApplicationManager.startApplication("dialer-app");
            // wait until the app is fully loaded (ie, real surface replaces splash screen)
            tryCompareFunction(function() { return app.session !== null && app.session.surface !== null }, true);

            // Minimize the application we just launched
            swipeFromLeftEdge(units.gu(26) + 1);

            waitUntilDashIsFocused();

            greeter.show();
            tryCompare(greeter, "showProgress", 1);

            // The main point of this test
            ApplicationManager.requestFocusApplication("dialer-app");
            tryCompare(greeter, "showProgress", 0);
            waitForRendering(greeter);
        }*/

        /*function test_focusRequestedHidesIndicators() {
            var indicators = findChild(shell, "indicators");

            showIndicators();

            var oldCount = ApplicationManager.count;
            ApplicationManager.startApplication("camera-app");
            tryCompare(ApplicationManager, "count", oldCount + 1);

            tryCompare(indicators, "fullyClosed", true);
        }*/

        /*function test_showAndHideGreeterDBusCalls() {
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "showProgress", 0)
            waitForRendering(greeter);
            LightDM.Greeter.showGreeter()
            tryCompare(greeter, "showProgress", 1)
            LightDM.Greeter.hideGreeter()
            tryCompare(greeter, "showProgress", 0)
        }*/

        /*function test_login() {
            sessionSpy.clear()

            var greeter = findChild(shell, "greeter")
            waitForRendering(greeter)
            greeter.show()
            tryCompare(greeter, "showProgress", 1)

            tryCompare(sessionSpy, "count", 0)
            swipeAwayGreeter()
            tryCompare(sessionSpy, "count", 1)
        }*/

        /*function test_fullscreen() {
            var panel = findChild(shell, "panel");
            compare(panel.fullscreenMode, false);
            ApplicationManager.startApplication("camera-app");
            tryCompare(panel, "fullscreenMode", true);
            ApplicationManager.startApplication("dialer-app");
            tryCompare(panel, "fullscreenMode", false);
            ApplicationManager.requestFocusApplication("camera-app");
            tryCompare(panel, "fullscreenMode", true);
            ApplicationManager.requestFocusApplication("dialer-app");
            tryCompare(panel, "fullscreenMode", false);
        }*/

        /*function test_leftEdgeDragFullscreen() {
            var panel = findChild(shell, "panel");
            tryCompare(panel, "fullscreenMode", false)

            ApplicationManager.startApplication("camera-app");
            tryCompare(panel, "fullscreenMode", true)

            var touchStartX = 2;
            var touchStartY = shell.height / 2;

            touchFlick(shell, touchStartX, touchStartY, units.gu(2), touchStartY, true, false);

            compare(panel.fullscreenMode, true);

            touchFlick(shell, units.gu(2), touchStartY, units.gu(10), touchStartY, false, false);

            tryCompare(panel, "fullscreenMode", false);

            touchRelease(shell);
        }*/

        /*function test_unlockedProperties() {
            // Confirm that various properties have the correct values when unlocked
            tryCompare(shell, "locked", false)

            var launcher = findChild(shell, "launcher")
            tryCompare(launcher, "available", true)

            var indicators = findChild(shell, "indicators")
            tryCompare(indicators, "available", true)
        }*/

        /*function test_unlockAllModemsOnBoot() {
            // TODO reenable when service ready (LP: #1361074)
            expectFail("", "Unlock on boot temporarily disabled");
            tryCompare(unlockAllModemsSpy, "count", 1)
        }*/

        /*function test_leftEdgeDragOnGreeter_data() {
            return [
                {tag: "short swipe", targetX: shell.width / 3, unlocked: false},
                {tag: "long swipe", targetX: shell.width / 3 * 2, unlocked: true}
            ]
        }*/

        /*function test_leftEdgeDragOnGreeter(data) {
            var greeter = findChild(shell, "greeter");
            greeter.show();
            tryCompare(greeter, "showProgress", 1);

            var touchStartX = 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, data.targetX, touchStartY);

            tryCompare(greeter, "showProgress", data.unlocked ? 0 : 1);
        }*/
    }
}
