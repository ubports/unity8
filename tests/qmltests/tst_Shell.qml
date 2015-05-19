/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
import Unity.Connectivity 0.1
import Unity.Indicators 0.1
import Unity.Notifications 1.0
import Unity.Test 0.1
import Powerd 0.1
import Wizard 0.1 as Wizard

import "../../qml"

Rectangle {
    id: root
    color: "grey"
    width: units.gu(100) + controls.width
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

    Item {
        anchors.left: root.left
        anchors.right: controls.left
        anchors.top: root.top
        anchors.bottom: root.bottom
        Loader {
            id: shellLoader
            focus: true

            anchors.centerIn: parent

            state: "phone"
            states: [
                State {
                    name: "phone"
                    PropertyChanges {
                        target: shellLoader
                        width: units.gu(40)
                        height: units.gu(71)
                    }
                },
                State {
                    name: "tablet"
                    PropertyChanges {
                        target: shellLoader
                        width: units.gu(100)
                        height: units.gu(71)
                    }
                }
            ]

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
    }

    Rectangle {
        id: controls
        color: "darkgrey"
        width: units.gu(30)
        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.right: root.right

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
            ListItem.ItemSelector {
                anchors { left: parent.left; right: parent.right }
                activeFocusOnPress: false
                text: "LightDM mock mode"
                model: ["single", "single-passphrase", "single-pin", "full"]
                onSelectedIndexChanged: {
                    shellLoader.active = false;
                    LightDM.Greeter.mockMode = model[selectedIndex];
                    LightDM.Users.mockMode = model[selectedIndex];
                    shellLoader.active = true;
                }
            }
            ListItem.ItemSelector {
                anchors { left: parent.left; right: parent.right }
                activeFocusOnPress: false
                text: "Size"
                model: ["phone", "tablet"]
                onSelectedIndexChanged: {
                    shellLoader.active = false;
                    shellLoader.state = model[selectedIndex];
                    shellLoader.active = true;
                }
                MouseTouchEmulationCheckbox { color: "white" }
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

    UnityTestCase {
        id: testCase
        name: "Shell"
        when: windowShown

        property Item shell: shellLoader.status === Loader.Ready ? shellLoader.item : null

        function init() {
            if (shellLoader.active) {
                // happens for the very first test function as shell
                // is loaded by default
                tearDown();
            }

        }

        function cleanup() {
            tryCompare(shell, "enabled", true); // make sure greeter didn't leave us in disabled state
            tearDown();
        }

        function loadShell(formFactor) {
            shellLoader.state = formFactor;
            shellLoader.active = true;
            tryCompare(shellLoader, "status", Loader.Ready);
            removeTimeConstraintsFromDirectionalDragAreas(shellLoader.item);
            tryCompare(shell, "enabled", true); // enabled by greeter when ready

            sessionSpy.target = findChild(shell, "greeter")
            dashCommunicatorSpy.target = findInvisibleChild(shell, "dashCommunicator");

            var launcher = findChild(shell, "launcher");
            launcherShowDashHomeSpy.target = launcher;

            waitForGreeterToStabilize();
        }

        function waitForGreeterToStabilize() {
            var greeter = findChild(shell, "greeter");
            verify(greeter);

            var loginList = findChild(greeter, "loginList");
            // Only present in WideView
            if (loginList) {
                var userList = findChild(loginList, "userList");
                verify(userList);
                tryCompare(userList, "movingInternally", false);
            }
        }

        function tearDown() {
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

            setLightDMMockMode("single"); // back to the default value

            AccountsService.demoEdges = false;
            Wizard.System.wizardEnabled = false;

            // kill all (fake) running apps
            killApps(ApplicationManager);

            unlockAllModemsSpy.clear()
            LightDM.Greeter.authenticate(""); // reset greeter

            sessionSpy.clear();
        }

        function killApps() {
            while (ApplicationManager.count > 1) {
                var appIndex = ApplicationManager.get(0).appId == "unity8-dash" ? 1 : 0
                ApplicationManager.stopApplication(ApplicationManager.get(appIndex).appId);
            }
            compare(ApplicationManager.count, 1)
        }

        function test_snapDecisionDismissalReturnsFocus() {
            loadShell("phone");
            swipeAwayGreeter();
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

        function test_phoneLeftEdgeDrag_data() {
            return [
                {tag: "without launcher",
                 revealLauncher: false, swipeLength: units.gu(30), appHides: true, focusedApp: "dialer-app",
                 launcherHides: true, greeterShown: false},

                {tag: "with launcher",
                 revealLauncher: true, swipeLength: units.gu(30), appHides: true, focusedApp: "dialer-app",
                 launcherHides: true, greeterShown: false},

                {tag: "small swipe",
                 revealLauncher: false, swipeLength: units.gu(25), appHides: false, focusedApp: "dialer-app",
                 launcherHides: false, greeterShown: false},

                {tag: "long swipe",
                 revealLauncher: false, swipeLength: units.gu(30), appHides: true, focusedApp: "dialer-app",
                 launcherHides: true, greeterShown: false},

                {tag: "small swipe with greeter",
                 revealLauncher: false, swipeLength: units.gu(25), appHides: false, focusedApp: "dialer-app",
                 launcherHides: false, greeterShown: true},

                {tag: "long swipe with greeter",
                 revealLauncher: false, swipeLength: units.gu(30), appHides: true, focusedApp: "dialer-app",
                 launcherHides: true, greeterShown: true},

                {tag: "swipe over dash",
                 revealLauncher: false, swipeLength: units.gu(30), appHides: true, focusedApp: "unity8-dash",
                 launcherHides: false, greeterShown: false},
            ];
        }

        function test_phoneLeftEdgeDrag(data) {
            loadShell("phone");
            swipeAwayGreeter();
            dragLauncherIntoView();
            tapOnAppIconInLauncher();
            waitUntilApplicationWindowIsFullyVisible();
            ApplicationManager.focusApplication(data.focusedApp)
            waitUntilApplicationWindowIsFullyVisible();

            var greeter = findChild(shell, "greeter");
            if (data.greeterShown) {
                showGreeter();
            }

            if (data.revealLauncher) {
                dragLauncherIntoView();
            }

            swipeFromLeftEdge(data.swipeLength);
            if (data.appHides) {
                waitUntilDashIsFocused();
                tryCompare(greeter, "shown", false);
            } else {
                waitUntilApplicationWindowIsFullyVisible();
                compare(greeter.fullyShown, data.greeterShown);
            }

            var launcher = findChild(shell, "launcherPanel");
            tryCompare(launcher, "x", data.launcherHides ? -launcher.width : 0)

            // Make sure the helper for sliding out the launcher wasn't touched. We want to fade it out here.
            var animateTimer = findInvisibleChild(shell, "animateTimer");
            compare(animateTimer.nextState, "visible");
        }

        function test_tabletLeftEdgeDrag_data() {
            return [
                {tag: "without password", user: "no-password", loggedIn: true, demo: false},
                {tag: "with password", user: "has-password", loggedIn: false, demo: false},
                {tag: "with demo", user: "has-password", loggedIn: true, demo: true},
            ]
        }

        function test_tabletLeftEdgeDrag(data) {
            setLightDMMockMode("full");
            loadShell("tablet");

            selectUser(data.user)

            AccountsService.demoEdges = data.demo
            var tutorial = findChild(shell, "tutorial");
            tryCompare(tutorial, "running", data.demo);

            swipeFromLeftEdge(shell.width * 0.75)
            wait(500) // to give time to handle dash() signal from Launcher
            confirmLoggedIn(data.loggedIn)
        }

        function test_suspend() {
            loadShell("phone");
            swipeAwayGreeter();
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

            // greeter unloads its internal components when hidden
            // and reloads them when shown. Thus we have to do this
            // again before interacting with it otherwise any
            // DirectionalDragAreas in there won't be easily fooled by
            // fake swipes.
            removeTimeConstraintsFromDirectionalDragAreas(greeter);
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

        function selectUserAtIndex(i) {
            // We could be anywhere in list; find target index to know which direction
            var greeter = findChild(shell, "greeter")
            var userlist = findChild(greeter, "userList")
            if (userlist.currentIndex == i)
                keyClick(Qt.Key_Escape) // Reset state if we're not moving
            while (userlist.currentIndex != i) {
                var next = userlist.currentIndex + 1
                if (userlist.currentIndex > i) {
                    next = userlist.currentIndex - 1
                }
                tap(findChild(greeter, "username"+next));
                tryCompare(userlist, "currentIndex", next)
                tryCompare(userlist, "movingInternally", false)
            }
            tryCompare(shell, "enabled", true); // wait for PAM to settle
        }

        function selectUser(name) {
            // Find index of user with the right name
            for (var i = 0; i < LightDM.Users.count; i++) {
                if (LightDM.Users.data(i, LightDM.UserRoles.NameRole) == name) {
                    break
                }
            }
            if (i == LightDM.Users.count) {
                fail("Didn't find name")
                return -1
            }
            selectUserAtIndex(i)
            return i
        }

        function clickPasswordInput(isButton) {
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "fullyShown", true);

            var passwordMouseArea = findChild(shell, "passwordMouseArea")
            tryCompare(passwordMouseArea, "enabled", isButton)

            var passwordInput = findChild(shell, "passwordInput")
            mouseClick(passwordInput)
        }

        function confirmLoggedIn(loggedIn) {
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "shown", loggedIn ? false : true);
            verify(loggedIn ? sessionSpy.count > 0 : sessionSpy.count === 0);
        }

        function setLightDMMockMode(mode) {
            LightDM.Greeter.mockMode = mode;
            LightDM.Users.mockMode = mode;
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
            loadShell("phone");
            swipeAwayGreeter();
            dragLauncherIntoView();

            // Launch an app from the launcher
            tapOnAppIconInLauncher();

            waitUntilApplicationWindowIsFullyVisible();

            verify(ApplicationManager.focusedApplicationId !== "unity8-dash")

            dashCommunicatorSpy.clear();
            // Minimize the application we just launched
            swipeFromLeftEdge(shell.width * 0.75);

            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");

            compare(dashCommunicatorSpy.count, 1);
            compare(dashCommunicatorSpy.signalArguments[0][0], 0);
        }

        function test_showInputMethod() {
            loadShell("phone");
            swipeAwayGreeter();
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
            loadShell("phone");
            swipeAwayGreeter();
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

        function test_launchedAppHasActiveFocus_data() {
            return [
                {tag:"phone", formFactor:"phone"},
                {tag:"tablet", formFactor:"tablet"},
            ];
        }

        function test_launchedAppHasActiveFocus(data) {
            loadShell(data.formFactor);
            swipeAwayGreeter();

            var dialerApp = ApplicationManager.startApplication("webbrowser-app");
            verify(dialerApp);
            waitUntilAppSurfaceShowsUp("webbrowser-app")

            verify(dialerApp.session.surface);

            tryCompare(dialerApp.session.surface, "activeFocus", true);
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
            var launcher = findChild(shell, "launcher");
            var launcherPanel = findChild(launcher, "launcherPanel");
            verify(launcherPanel.x = - launcherPanel.width);

            var touchStartX = 2;
            var touchStartY = shell.height / 2;
            touchFlick(shell, touchStartX, touchStartY, launcherPanel.width + units.gu(1), touchStartY);

            tryCompare(launcherPanel, "x", 0);
            tryCompare(launcher, "state", "visible");
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
            touchFlick(shell,
                    touchStartX              , touchStartY,
                    touchStartX + swipeLength, touchStartY);
        }

        function itemIsOnScreen(item) {
            var itemRectInShell = item.mapToItem(shell, 0, 0, item.width, item.height);

            return itemRectInShell.x >= 0
                && itemRectInShell.y >= 0
                && itemRectInShell.x + itemRectInShell.width <= shell.width
                && itemRectInShell.y + itemRectInShell.height <= shell.height;
        }

        function showGreeter() {
            var greeter = findChild(shell, "greeter");
            LightDM.Greeter.showGreeter();
            waitForRendering(greeter);
            tryCompare(greeter, "fullyShown", true);

            // greeter unloads its internal components when hidden
            // and reloads them when shown. Thus we have to do this
            // again before interacting with it otherwise any
            // DirectionalDragAreas in there won't be easily fooled by
            // fake swipes.
            removeTimeConstraintsFromDirectionalDragAreas(greeter);
        }

        function test_greeterDoesNotChangeIndicatorProfile() {
            loadShell("phone");
            swipeAwayGreeter();
            var panel = findChild(shell, "panel");
            tryCompare(panel.indicators.indicatorsModel, "profile", shell.indicatorProfile);

            showGreeter();
            tryCompare(panel.indicators.indicatorsModel, "profile", shell.indicatorProfile);

            LightDM.Greeter.hideGreeter();
            tryCompare(panel.indicators.indicatorsModel, "profile", shell.indicatorProfile);
        }

        function test_shellProfileChangesReachIndicators() {
            loadShell("phone");
            swipeAwayGreeter();
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
            loadShell("phone");
            swipeAwayGreeter();
            var greeter = findChild(shell, "greeter");

            var app = ApplicationManager.startApplication("dialer-app");
            // wait until the app is fully loaded (ie, real surface replaces splash screen)
            tryCompareFunction(function() { return app.session !== null && app.session.surface !== null }, true);

            // Minimize the application we just launched
            swipeFromLeftEdge(shell.width * 0.75);

            waitUntilDashIsFocused();

            showGreeter();

            // The main point of this test
            ApplicationManager.requestFocusApplication("dialer-app");
            tryCompare(greeter, "shown", false);
            waitForRendering(greeter);
        }

        function test_focusRequestedHidesIndicators() {
            loadShell("phone");
            swipeAwayGreeter();
            var indicators = findChild(shell, "indicators");

            showIndicators();

            var oldCount = ApplicationManager.count;
            ApplicationManager.startApplication("camera-app");
            tryCompare(ApplicationManager, "count", oldCount + 1);

            tryCompare(indicators, "fullyClosed", true);
        }

        function test_showAndHideGreeterDBusCalls() {
            loadShell("phone");
            swipeAwayGreeter();
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "shown", false)
            waitForRendering(greeter);
            LightDM.Greeter.showGreeter()
            waitForRendering(greeter)
            tryCompare(greeter, "fullyShown", true)
            LightDM.Greeter.hideGreeter()
            tryCompare(greeter, "shown", false)
        }

        function test_greeterLoginsAutomaticallyWhenNoPasswordSet() {
            loadShell("phone");
            swipeAwayGreeter();

            sessionSpy.clear();
            verify(sessionSpy.valid);

            showGreeter();

            tryCompare(sessionSpy, "count", 1);
        }

        function test_fullscreen() {
            loadShell("phone");
            swipeAwayGreeter();
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
            loadShell("phone");
            swipeAwayGreeter();
            var panel = findChild(shell, "panel");
            tryCompare(panel, "fullscreenMode", false)

            ApplicationManager.startApplication("camera-app");
            tryCompare(panel, "fullscreenMode", true)

            var touchStartX = 2;
            var touchStartY = shell.height / 2;

            touchFlick(shell, touchStartX, touchStartY, units.gu(2), touchStartY, true, false);

            compare(panel.fullscreenMode, true);

            touchFlick(shell, units.gu(2), touchStartY, shell.width * 0.5, touchStartY, false, false);

            tryCompare(panel, "fullscreenMode", false);

            touchRelease(shell);
        }

        function test_unlockedProperties() {
            loadShell("phone");
            swipeAwayGreeter();
            // Confirm that various properties have the correct values when unlocked
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "locked", false);

            var launcher = findChild(shell, "launcher")
            tryCompare(launcher, "available", true)

            var indicators = findChild(shell, "indicators")
            tryCompare(indicators, "available", true)
        }

        function test_unlockAllModemsOnBoot() {
            loadShell("phone");
            swipeAwayGreeter();
            tryCompare(unlockAllModemsSpy, "count", 1)
        }

        function test_unlockAllModemsAfterWizard() {
            Wizard.System.wizardEnabled = true;
            loadShell("phone");

            var wizard = findChild(shell, "wizard");
            compare(wizard.active, true);
            compare(Wizard.System.wizardEnabled, true);
            compare(unlockAllModemsSpy.count, 0);

            wizard.hide();
            tryCompare(wizard, "active", false);
            compare(Wizard.System.wizardEnabled, false);
            compare(unlockAllModemsSpy.count, 1);
        }

        function test_wizardEarlyExit() {
            Wizard.System.wizardEnabled = true;
            AccountsService.demoEdges = true;
            loadShell("phone");

            var wizard = findChild(shell, "wizard");
            var tutorial = findChild(shell, "tutorial");
            tryCompare(wizard, "active", true);
            tryCompare(tutorial, "running", true);
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");

            // Make sure we stay running when nothing focused (can happen for
            // a moment when we restart the dash after switching language)
            ApplicationManager.stopApplication("unity8-dash");
            tryCompare(ApplicationManager, "focusedApplicationId", "");
            compare(wizard.shown, true);
            compare(tutorial.running, true);

            // And make sure we stay running when dash focused again
            ApplicationManager.startApplication("unity8-dash");
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");
            compare(wizard.shown, true);
            compare(tutorial.running, true);

            // And make sure we stop when something else is focused
            ApplicationManager.startApplication("gallery-app");
            tryCompare(ApplicationManager, "focusedApplicationId", "gallery-app");
            compare(wizard.shown, false);
            compare(tutorial.running, false);
            tryCompare(AccountsService, "demoEdges", false);
            tryCompare(Wizard.System, "wizardEnabled", false);

            var tutorialLeft = findChild(tutorial, "tutorialLeft");
            compare(tutorialLeft, null); // should be destroyed with tutorial
        }

        function test_tapOnRightEdgeReachesApplicationSurface() {
            loadShell("phone");
            swipeAwayGreeter();
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
            loadShell("phone");
            swipeAwayGreeter();
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
            loadShell("phone");
            swipeAwayGreeter();

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
                        buttonShowDashHome.width * 0.2,
                        buttonShowDashHome.height * 0.8);
                var endPos = buttonShowDashHome.mapToItem(shell,
                        buttonShowDashHome.width * 0.8,
                        buttonShowDashHome.height * 0.2);
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
                {tag: "empty", accounts: "", gsettings: "", output: "defaultBackground"},
                {tag: "as-specified", accounts: Qt.resolvedUrl("../data/unity/backgrounds/blue.png"), gsettings: "", output: Qt.resolvedUrl("../data/unity/backgrounds/blue.png")},
                {tag: "gs-specified", accounts: "", gsettings: Qt.resolvedUrl("../data/unity/backgrounds/red.png"), output: Qt.resolvedUrl("../data/unity/backgrounds/red.png")},
                {tag: "both-specified", accounts: Qt.resolvedUrl("../data/unity/backgrounds/blue.png"), gsettings: Qt.resolvedUrl("../data/unity/backgrounds/red.png"), output: Qt.resolvedUrl("../data/unity/backgrounds/blue.png")},
                {tag: "invalid-as", accounts: Qt.resolvedUrl("../data/unity/backgrounds/nope.png"), gsettings: Qt.resolvedUrl("../data/unity/backgrounds/red.png"), output: Qt.resolvedUrl("../data/unity/backgrounds/red.png")},
                {tag: "invalid-both", accounts: Qt.resolvedUrl("../data/unity/backgrounds/nope.png"), gsettings: Qt.resolvedUrl("../data/unity/backgrounds/stillnope.png"), output: "defaultBackground"},
            ]
        }
        function test_background(data) {
            loadShell("phone");
            swipeAwayGreeter();
            AccountsService.backgroundFile = data.accounts;
            var backgroundSettings = findInvisibleChild(shell, "backgroundSettings");
            backgroundSettings.pictureUri = data.gsettings;

            if (data.output === "defaultBackground") {
                tryCompare(shell, "background", shell.defaultBackground);
            } else {
                tryCompare(shell, "background", data.output);
            }
        }

        function test_tabletLogin_data() {
            return [
                {tag: "auth error", user: "auth-error", loggedIn: false, password: ""},
                {tag: "with password", user: "has-password", loggedIn: true, password: "password"},
                {tag: "without password", user: "no-password", loggedIn: true, password: ""},
            ]
        }

        function test_tabletLogin(data) {
            setLightDMMockMode("full");
            loadShell("tablet");

            selectUser(data.user);

            clickPasswordInput(data.password === "" /* isButton */);

            if (data.password !== "") {
                typeString(data.password);
                keyClick(Qt.Key_Enter);
            }

            confirmLoggedIn(data.loggedIn);
        }

        function test_appLaunchDuringGreeter_data() {
            return [
                {tag: "auth error", user: "auth-error", loggedIn: false, passwordFocus: false},
                {tag: "without password", user: "no-password", loggedIn: true, passwordFocus: false},
                {tag: "with password", user: "has-password", loggedIn: false, passwordFocus: true},
            ]
        }

        function test_appLaunchDuringGreeter(data) {
            setLightDMMockMode("full");
            loadShell("tablet");

            selectUser(data.user)

            var greeter = findChild(shell, "greeter")
            var app = ApplicationManager.startApplication("dialer-app")

            confirmLoggedIn(data.loggedIn)

            if (data.passwordFocus) {
                var passwordInput = findChild(greeter, "passwordInput")
                tryCompare(passwordInput, "focus", true)
            }
        }
    }
}
