/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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
import AccountsService 0.1
import GSettings 1.0
import LightDM 0.1 as LightDM
import Ubuntu.Components 1.1
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
import Unity.Connectivity 0.1
import Unity.Indicators 0.1
import Unity.Notifications 1.0
import Unity.Test 0.1 as UT
import Powerd 0.1

import "../../qml"

Item {
    id: root
    width: units.gu(60)
    height: units.gu(71)

    Component.onCompleted: {
        // must set the mock mode before loading the Shell
        LightDM.Greeter.mockMode = "single";
        LightDM.Users.mockMode = "single";
        shellLoader.active = true;
    }

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

    Row {
        anchors.fill: parent
        Loader {
            id: shellLoader
            focus: true

            active: false
            property bool itemDestroyed: false
            sourceComponent: Component {
                Shell {
                    property string indicatorProfile: "phone"

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
                        activeFocusOnPress: false
                        onClicked: {
                            if (shellLoader.status !== Loader.Ready)
                                return;

                            var greeter = testCase.findChild(shellLoader.item, "greeter");
                            if (!greeter.shown) {
                                LightDM.Greeter.showGreeter();
                            }
                        }
                    }
                }
            }
        }
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

        onActionInvoked: {
            if(actionId == "ok_id") {
                mockNotificationsModel.clear()
            }
        }
    }

    SignalSpy {
        id: launcherShowDashHomeSpy
        signalName: "showDashHome"
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

    SignalSpy {
        id: notificationActionSpy
        target: mockNotificationsModel
        signalName: "actionInvoked"
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
            tryCompare(shell, "enabled", true); // enabled by greeter when ready
            shell.indicatorProfile = "phone";

            swipeAwayGreeter();

            sessionSpy.target = findChild(shell, "greeter")
            dashCommunicatorSpy.target = findInvisibleChild(shell, "dashCommunicator");

            var launcher = findChild(shell, "launcher");
            launcherShowDashHomeSpy.target = launcher;
        }

        function cleanup() {
            tryCompare(shell, "enabled", true); // make sure greeter didn't leave us in disabled state
            launcherShowDashHomeSpy.target = null;

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
            LightDM.Greeter.authenticate(""); // reset greeter

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

        function test_snapDecisionDismissalReturnsFocus() {
            var notifications = findChild(shell, "notificationList");
            var app = ApplicationManager.startApplication("camera-app");
            var stage = findChild(shell, "stage")
            // Open an application and focus
            waitUntilApplicationWindowIsFullyVisible(app);
            ApplicationManager.focusApplication(app);
            tryCompare(app.session.surface, "activeFocus", true);

            notifications.model = mockNotificationsModel;

            // FIXME: Hack: UnitySortFilterProxyModelQML doesn't work with QML ListModels which we use
            // for mocking here (RoleType can't be found in the QML model). As we only need to show
            // one SnapDecision lets just disable the filtering and make appear any notification as a
            // SnapDecision.
            var snapDecisionProxyModel = findInvisibleChild(shell, "snapDecisionProxyModel");
            snapDecisionProxyModel.filterRegExp = RegExp("");

            // Pop-up a notification
            addSnapDecisionNotification();
            waitForRendering(shell);

            // Make sure the notification really opened
            var notification = findChild(notifications, "notification" + (mockNotificationsModel.count - 1));
            verify(notification !== undefined && notification != null, "notification wasn't found");
            tryCompare(notification, "height", notification.implicitHeight)
            waitForRendering(notification);

            // Make sure activeFocus went away from the app window
            tryCompare(app.session.surface, "activeFocus", false);
            tryCompare(stage, "interactive", false);

            // Clicking the button should dismiss the notification and return focus
            var buttonAccept = findChild(notification, "notify_button0");
            mouseClick(buttonAccept);

            // Make sure we're back to normal
            tryCompare(app.session.surface, "activeFocus", true);
            compare(stage.interactive, true, "Stages not interactive again after modal notification has closed");
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

        function test_leftEdgeDrag(data) {
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
        }

        function test_suspend() {
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
            tryCompare(greeter, "shown", false);

            // Now try again after ending call
            callManager.foregroundCall = null;
            Powerd.status = Powerd.On;
            Powerd.status = Powerd.Off;
            tryCompare(greeter, "fullyShown", true);

            tryCompare(ApplicationManager, "suspended", true);
            compare(mainApp.state, ApplicationInfoInterface.Suspended);

            // And wake up
            Powerd.status = Powerd.On;
            tryCompare(greeter, "fullyShown", true);

            // Swipe away greeter to focus app
            swipeAwayGreeter();
            tryCompare(ApplicationManager, "suspended", false);
            compare(mainApp.state, ApplicationInfoInterface.Running);
            tryCompare(ApplicationManager, "focusedApplicationId", mainAppId);
        }

        function swipeAwayGreeter() {
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "fullyShown", true);

            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;
            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY);

            // wait until the animation has finished
            tryCompare(greeter, "shown", false);
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
        function test_minimizingAppTakesToDashApps() {
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
            compare(dashCommunicatorSpy.signalArguments[0][0], 0);
        }

        function test_showInputMethod() {
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
        }

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

        function test_surfaceLosesActiveFocusWhilePanelIsOpen() {
            var app = ApplicationManager.startApplication("dialer-app");
            waitUntilAppWindowIsFullyLoaded(app);

            tryCompare(app.session.surface, "activeFocus", true);

            // Drag the indicators panel half-open
            var touchX = shell.width / 2;
            var indicators = findChild(shell, "indicators");
            touchFlick(indicators,
                    touchX /* fromX */, indicators.minimizedPanelHeight * 0.5 /* fromY */,
                    touchX /* toX */, shell.height * 0.5 /* toY */,
                    true /* beginTouch */, false /* endTouch */);
            verify(indicators.partiallyOpened);

            tryCompare(app.session.surface, "activeFocus", false);

            // And finish getting it open
            touchFlick(indicators,
                    touchX /* fromX */, shell.height * 0.5 /* fromY */,
                    touchX /* toX */, shell.height * 0.9 /* toY */,
                    false /* beginTouch */, true /* endTouch */);
            tryCompare(indicators, "fullyOpened", true);

            tryCompare(app.session.surface, "activeFocus", false);

            dragToCloseIndicatorsPanel();

            tryCompare(app.session.surface, "activeFocus", true);
        }

        function test_launchedAppHasActiveFocus() {
            var dialerApp = ApplicationManager.startApplication("dialer-app");
            verify(dialerApp);
            waitUntilAppSurfaceShowsUp("dialer-app")

            verify(dialerApp.session.surface);

            tryCompare(dialerApp.session.surface, "activeFocus", true);
        }

        // Wait for the whole UI to settle down
        function waitForUIToSettle() {
            var launcher = findChild(shell, "launcherPanel")
            tryCompareFunction(function() {return launcher.x === 0 || launcher.x === -launcher.width;}, true);
            if (launcher.x === 0) {
                mouseClick(shell)
            }
            tryCompare(launcher, "x", -launcher.width)

            waitForRendering(shell)
        }

        function waitUntilAppSurfaceShowsUp(appId) {
            var appWindow = findChild(shell, "appWindow_" + appId);
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function dragToCloseIndicatorsPanel() {
            var indicators = findChild(shell, "indicators");

            var touchStartX = shell.width / 2;
            var touchStartY = shell.height - (indicators.minimizedPanelHeight * 0.5);
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

            // pick the first icon, the one at the top.
            var appIcon = findChild(launcherPanel, "launcherDelegate0")
            tap(appIcon, appIcon.width / 2, appIcon.height / 2);
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

        function test_greeterDoesNotChangeIndicatorProfile() {
            var panel = findChild(shell, "panel");
            tryCompare(panel.indicators.indicatorsModel, "profile", shell.indicatorProfile);

            LightDM.Greeter.showGreeter();
            tryCompare(panel.indicators.indicatorsModel, "profile", shell.indicatorProfile);

            LightDM.Greeter.hideGreeter();
            tryCompare(panel.indicators.indicatorsModel, "profile", shell.indicatorProfile);
        }

        function test_shellProfileChangesReachIndicators() {
            var panel = findChild(shell, "panel");

            shell.indicatorProfile = "test1";
            for (var i = 0; i < panel.indicators.indicatorsModel.count; ++i) {
                var properties = panel.indicators.indicatorsModel.data(i, IndicatorsModelRole.IndicatorProperties);
                verify(properties["menuObjectPath"].substr(-5), "test1");
            }

            shell.indicatorProfile = "test2";
            for (var i = 0; i < panel.indicators.indicatorsModel.count; ++i) {
                var properties = panel.indicators.indicatorsModel.data(i, IndicatorsModelRole.IndicatorProperties);
                verify(properties["menuObjectPath"].substr(-5), "test2");
            }
        }

        function test_focusRequestedHidesGreeter() {
            var greeter = findChild(shell, "greeter");

            var app = ApplicationManager.startApplication("dialer-app");
            // wait until the app is fully loaded (ie, real surface replaces splash screen)
            tryCompareFunction(function() { return app.session !== null && app.session.surface !== null }, true);

            // Minimize the application we just launched
            swipeFromLeftEdge(units.gu(26) + 1);

            waitUntilDashIsFocused();

            LightDM.Greeter.showGreeter();
            tryCompare(greeter, "fullyShown", true);

            // The main point of this test
            ApplicationManager.requestFocusApplication("dialer-app");
            tryCompare(greeter, "shown", false);
            waitForRendering(greeter);
        }

        function test_focusRequestedHidesIndicators() {
            var indicators = findChild(shell, "indicators");

            showIndicators();

            var oldCount = ApplicationManager.count;
            ApplicationManager.startApplication("camera-app");
            tryCompare(ApplicationManager, "count", oldCount + 1);

            tryCompare(indicators, "fullyClosed", true);
        }

        function test_showAndHideGreeterDBusCalls() {
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "shown", false)
            waitForRendering(greeter);
            LightDM.Greeter.showGreeter()
            waitForRendering(greeter)
            tryCompare(greeter, "fullyShown", true)
            LightDM.Greeter.hideGreeter()
            tryCompare(greeter, "shown", false)
        }

        function test_login() {
            var greeter = findChild(shell, "greeter")
            waitForRendering(greeter)
            LightDM.Greeter.showGreeter();
            tryCompare(greeter, "fullyShown", true)

            sessionSpy.clear();
            swipeAwayGreeter()
            tryCompare(sessionSpy, "count", 1)
        }

        function test_fullscreen() {
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
        }

        function test_leftEdgeDragFullscreen() {
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
        }

        function test_unlockedProperties() {
            // Confirm that various properties have the correct values when unlocked
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "locked", false);

            var launcher = findChild(shell, "launcher")
            tryCompare(launcher, "available", true)

            var indicators = findChild(shell, "indicators")
            tryCompare(indicators, "available", true)
        }

        function test_unlockAllModemsOnBoot() {
            tryCompare(unlockAllModemsSpy, "count", 1)
        }

        function test_leftEdgeDragOnGreeter_data() {
            return [
                {tag: "short swipe", targetX: shell.width / 3, unlocked: false},
                {tag: "long swipe", targetX: shell.width / 3 * 2, unlocked: true}
            ]
        }

        function test_leftEdgeDragOnGreeter(data) {
            var greeter = findChild(shell, "greeter");
            LightDM.Greeter.showGreeter();
            tryCompare(greeter, "fullyShown", true);

            var touchStartX = 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, data.targetX, touchStartY);

            if (data.unlocked) {
                tryCompare(greeter, "shown", false);
            } else {
                tryCompare(greeter, "fullyShown", true);
            }
        }

        function test_tapOnRightEdgeReachesApplicationSurface() {
            var topmostSpreadDelegate = findChild(shell, "appDelegate0");
            var topmostSurface = findChild(topmostSpreadDelegate, "surfaceContainer").surface;
            var rightEdgeDragArea = findChild(shell, "spreadDragArea");

            topmostSurface.touchPressCount = 0;
            topmostSurface.touchReleaseCount = 0;

            var tapPoint = rightEdgeDragArea.mapToItem(shell, rightEdgeDragArea.width / 2,
                    rightEdgeDragArea.height / 2);

            tap(shell, tapPoint.x, tapPoint.y);

            tryCompare(topmostSurface, "touchPressCount", 1);
            tryCompare(topmostSurface, "touchReleaseCount", 1);
        }

        /*
            Perform a right edge drag over an application surface and check
            that no touch event was sent to it (ie, they were all consumed
            by the right-edge drag area)
         */
        function test_rightEdgeDragDoesNotReachApplicationSurface() {
            var topmostSpreadDelegate = findChild(shell, "appDelegate0");
            var topmostSurface = findChild(topmostSpreadDelegate, "surfaceContainer").surface;
            var rightEdgeDragArea = findChild(shell, "spreadDragArea");

            topmostSurface.touchPressCount = 0;
            topmostSurface.touchReleaseCount = 0;

            var gestureStartPoint = rightEdgeDragArea.mapToItem(shell, rightEdgeDragArea.width / 2,
                    rightEdgeDragArea.height / 2);

            touchFlick(shell,
                    gestureStartPoint.x /* fromX */, gestureStartPoint.y /* fromY */,
                    units.gu(1) /* toX */, gestureStartPoint.y /* toY */);

            tryCompare(topmostSurface, "touchPressCount", 0);
            tryCompare(topmostSurface, "touchReleaseCount", 0);
        }

        function waitUntilFocusedApplicationIsShowingItsSurface()
        {
            var spreadDelegate = findChild(shell, "appDelegate0");
            var appState = findInvisibleChild(spreadDelegate, "applicationWindowStateGroup");
            tryCompare(appState, "state", "surface");
            var transitions = appState.transitions;
            for (var i = 0; i < transitions.length; ++i) {
                var transition = transitions[i];
                tryCompare(transition, "running", false, 2000);
            }
        }

        function swipeFromRightEdgeToShowAppSpread()
        {
            // perform a right-edge drag to show the spread
            var touchStartX = shell.width - (shell.edgeSize / 2)
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, units.gu(1) /* endX */, touchStartY /* endY */);

            // check if it's indeed showing the spread
            var stage = findChild(shell, "stage");
            var spreadView = findChild(stage, "spreadView");
            tryCompare(spreadView, "phase", 2);
        }

        function test_tapUbuntuIconInLauncherOverAppSpread() {

            waitUntilFocusedApplicationIsShowingItsSurface();

            swipeFromRightEdgeToShowAppSpread();

            var launcher = findChild(shell, "launcher");

            // ensure the launcher dimissal timer never gets triggered during the test run
            var dismissTimer = findInvisibleChild(launcher, "dismissTimer");
            dismissTimer.interval = 60 * 60 * 1000;

            dragLauncherIntoView();

            // Emulate a tap with a finger, where the touch position drifts during the tap.
            // This is to test the touch ownership changes. The tap is happening on the button
            // area but then drifting into the left edge drag area. This test makes sure
            // the touch ownership stays with the button and doesn't move over to the
            // left edge drag area.
            {
                var buttonShowDashHome = findChild(launcher, "buttonShowDashHome");
                var startPos = buttonShowDashHome.mapToItem(shell,
                        buttonShowDashHome.width * 0.8,
                        buttonShowDashHome.height * 0.2);
                var endPos = buttonShowDashHome.mapToItem(shell,
                        buttonShowDashHome.width * 0.2,
                        buttonShowDashHome.height * 0.8);
                touchFlick(shell, startPos.x, startPos.y, endPos.x, endPos.y);
            }

            compare(launcherShowDashHomeSpy.count, 1);

            // check that the stage has left spread mode.
            {
                var stage = findChild(shell, "stage");
                var spreadView = findChild(stage, "spreadView");
                tryCompare(spreadView, "phase", 0);
            }

            // check that the launcher got dismissed
            var launcherPanel = findChild(shell, "launcherPanel");
            tryCompare(launcherPanel, "x", -launcherPanel.width);
        }

        function test_background_data() {
            return [
                {tag: "color", accounts: Qt.resolvedUrl("data:image/svg+xml,<svg><rect width='100%' height='100%' fill='#dd4814'/></svg>"), gsettings: "", output: Qt.resolvedUrl("data:image/svg+xml,<svg><rect width='100%' height='100%' fill='#dd4814'/></svg>")},
                {tag: "empty", accounts: "", gsettings: "", output: shell.defaultBackground},
                {tag: "as-specified", accounts: Qt.resolvedUrl("../data/unity/backgrounds/blue.png"), gsettings: "", output: Qt.resolvedUrl("../data/unity/backgrounds/blue.png")},
                {tag: "gs-specified", accounts: "", gsettings: Qt.resolvedUrl("../data/unity/backgrounds/red.png"), output: Qt.resolvedUrl("../data/unity/backgrounds/red.png")},
                {tag: "both-specified", accounts: Qt.resolvedUrl("../data/unity/backgrounds/blue.png"), gsettings: Qt.resolvedUrl("../data/unity/backgrounds/red.png"), output: Qt.resolvedUrl("../data/unity/backgrounds/blue.png")},
                {tag: "invalid-as", accounts: Qt.resolvedUrl("../data/unity/backgrounds/nope.png"), gsettings: Qt.resolvedUrl("../data/unity/backgrounds/red.png"), output: Qt.resolvedUrl("../data/unity/backgrounds/red.png")},
                {tag: "invalid-both", accounts: Qt.resolvedUrl("../data/unity/backgrounds/nope.png"), gsettings: Qt.resolvedUrl("../data/unity/backgrounds/stillnope.png"), output: shell.defaultBackground},
            ]
        }
        function test_background(data) {
            AccountsService.backgroundFile = data.accounts;
            var backgroundSettings = findInvisibleChild(shell, "backgroundSettings");
            backgroundSettings.pictureUri = data.gsettings;
            tryCompare(shell, "background", data.output);
        }
    }
}
