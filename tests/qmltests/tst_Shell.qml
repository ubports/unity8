/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import AccountsService 0.1
import GSettings 1.0
import LightDM.IntegratedLightDM 0.1 as LightDM
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
import Unity.Connectivity 0.1
import Unity.Indicators 0.1
import Unity.Notifications 1.0
import Unity.Launcher 0.1
import Unity.Test 0.1
import Powerd 0.1
import Wizard 0.1 as Wizard
import Utils 0.1

import "../../qml"
import "../../qml/Components"
import "../../qml/Components/PanelState"
import "Stages"

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

    Item {
        id: shellContainer
        anchors.left: root.left
        anchors.right: controls.left
        anchors.top: root.top
        anchors.bottom: root.bottom
        Loader {
            id: shellLoader
            focus: true

            anchors.centerIn: parent

            property int shellOrientation: Qt.PortraitOrientation
            property int nativeOrientation: Qt.PortraitOrientation
            property int primaryOrientation: Qt.PortraitOrientation
            property string mode: "full-greeter"

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
                        shellOrientation: Qt.LandscapeOrientation
                        nativeOrientation: Qt.LandscapeOrientation
                        primaryOrientation: Qt.LandscapeOrientation
                    }
                },
                State {
                    name: "desktop"
                    PropertyChanges {
                        target: shellLoader
                        width: shellContainer.width
                        height: shellContainer.height
                    }
                    PropertyChanges {
                        target: mouseEmulation
                        checked: false
                    }
                }
            ]

            active: false
            property bool itemDestroyed: false
            sourceComponent: Component {
                Shell {
                    id: __shell
                    usageScenario: usageScenarioSelector.model[usageScenarioSelector.selectedIndex]
                    nativeWidth: width
                    nativeHeight: height
                    orientation: shellLoader.shellOrientation
                    orientations: Orientations {
                        native_: shellLoader.nativeOrientation
                        primary: shellLoader.primaryOrientation
                    }
                    mode: shellLoader.mode
                    Component.onDestruction: {
                        shellLoader.itemDestroyed = true;
                    }
                }
            }
        }
    }

    Flickable {
        id: controls
        contentHeight: controlRect.height

        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.right: root.right
        width: units.gu(30)

        Rectangle {
            id: controlRect
            anchors { left: parent.left; right: parent.right }
            color: "darkgrey"
            height: childrenRect.height + units.gu(2)

            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                spacing: units.gu(1)

                Flow {
                    spacing: units.gu(1)
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
                    Button {
                        text: "Hide Greeter"
                        activeFocusOnPress: false
                        onClicked: {
                            if (shellLoader.status !== Loader.Ready)
                                return;

                            var greeter = testCase.findChild(shellLoader.item, "greeter");
                            if (greeter.shown) {
                                greeter.hide()
                            }
                        }
                    }
                    Button {
                        text: callManager.foregroundCall ? "Hide Call" : "Show Call"
                        activeFocusOnPress: false
                        onClicked: {
                            if (shellLoader.status !== Loader.Ready)
                                return;

                            callManager.foregroundCall = callManager.foregroundCall ? null : phoneCall;
                        }
                    }
                }
                Button {
                    text: "Show Launcher"
                    activeFocusOnPress: false
                    onClicked: {
                        if (shellLoader.status !== Loader.Ready)
                            return;

                        var launcher = testCase.findChild(shellLoader.item, "launcher");
                        launcher.state = "visible";
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
                    model: ["phone", "tablet", "desktop"]
                    onSelectedIndexChanged: {
                        shellLoader.active = false;
                        shellLoader.state = model[selectedIndex];
                        shellLoader.active = true;
                    }
                }
                ListItem.ItemSelector {
                    id: usageScenarioSelector
                    anchors { left: parent.left; right: parent.right }
                    activeFocusOnPress: false
                    text: "Usage scenario"
                    model: ["phone", "tablet", "desktop"]
                }
                MouseTouchEmulationCheckbox {
                    id: mouseEmulation
                    checked: true
                }
                ListItem.ItemSelector {
                    id: ctrlModifier
                    anchors { left: parent.left; right: parent.right }
                    activeFocusOnPress: false
                    text: "Ctrl key as"
                    model: ["Ctrl", "Alt", "Super"]
                    onSelectedIndexChanged: {
                        var keyMapper = testCase.findChild(shellContainer, "physicalKeysMapper");
                        keyMapper.controlInsteadOfAlt = selectedIndex == 1;
                        keyMapper.controlInsteadOfSuper = selectedIndex == 2;
                    }
                }

                Row {
                    anchors { left: parent.left; right: parent.right }
                    CheckBox {
                        id: autohideLauncherCheckbox
                        onCheckedChanged:  {
                            GSettingsController.setAutohideLauncher(checked)
                        }
                    }
                    Label {
                        text: "Autohide launcher"
                    }
                }

                Label { text: "Applications"; font.bold: true }

                Button {
                    text: "Start all apps"
                    width: parent.width
                    onClicked: {
                        for (var i = 0; i < ApplicationManager.availableApplications.length; i++) {
                            var appId = ApplicationManager.availableApplications[i];
                            ApplicationManager.startApplication(appId)
                        }
                    }
                }

                Repeater {
                    id: appRepeater
                    model: ApplicationManager.availableApplications
                    ApplicationCheckBox {
                        appId: modelData
                    }
                }

                Label { text: "Focused Application"; font.bold: true }

                Row {
                    CheckBox {
                        id: fullscreeAppCheck

                        onTriggered: {
                            if (!MirFocusController.focusedSurface) return;
                            if (MirFocusController.focusedSurface.state == Mir.FullscreenState) {
                                MirFocusController.focusedSurface.state = Mir.RestoredState;
                            } else {
                                MirFocusController.focusedSurface.state = Mir.FullscreenState;
                            }
                        }

                        Binding {
                            target: fullscreeAppCheck
                            when: MirFocusController.focusedSurface
                            property: "checked"
                            value: {
                                if (!MirFocusController.focusedSurface) return false;
                                return MirFocusController.focusedSurface.state === Mir.FullscreenState
                            }
                        }
                    }
                    Label {
                        text: "Fullscreen"
                    }
                }

                Row {
                    CheckBox {
                        id: chromeAppCheck

                        onTriggered: {
                            if (!MirFocusController.focusedSurface) return;
                            if (MirFocusController.focusedSurface.shellChrome == Mir.LowChrome) {
                                MirFocusController.focusedSurface.setShellChrome(Mir.NormalChrome);
                            } else {
                                MirFocusController.focusedSurface.setShellChrome(Mir.LowChrome);
                            }
                        }

                        Binding {
                            target: chromeAppCheck
                            when: MirFocusController.focusedSurface !== null
                            property: "checked"
                            value: {
                                if (!MirFocusController.focusedSurface) return false;
                                MirFocusController.focusedSurface.shellChrome === Mir.LowChrome
                            }
                        }
                    }
                    Label {
                        text: "Low Chrome"
                    }
                }

                Label {
                    text: "Fingerprint"
                }
                Row {
                    Button {
                        text: "Success"
                        onClicked: {
                            var biometryd = testCase.findInvisibleChild(shellContainer, "biometryd");
                            var uid = 0;
                            for (var i = 0; i < LightDM.Users.count; i++) {
                                if (LightDM.Users.data(i, LightDM.UserRoles.NameRole) == AccountsService.user) {
                                    uid = LightDM.Users.data(i, LightDM.UserRoles.UidRole);
                                    break;
                                }
                            }
                            biometryd.operation.mockSuccess(uid);
                        }
                    }

                    Button {
                        text: "Failure"
                        onClicked: {
                            var biometryd = testCase.findInvisibleChild(shellContainer, "biometryd");
                            biometryd.operation.mockFailure("error");
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

    Item {
        id: fakeDismissTimer
        property bool running: false
        signal triggered

        function stop() {
            running = false;
        }

        function restart() {
            running = true;
        }
    }

    UnityTestCase {
        id: testCase
        name: "Shell"
        when: windowShown

        property Item shell: shellLoader.status === Loader.Ready ? shellLoader.item : null
        property QtObject topLevelSurfaceList: null

        function init() {
            if (shellLoader.active) {
                // happens for the very first test function as shell
                // is loaded by default
                tearDown();
            }

        }

        function cleanup() {
            waitForRendering(shell);
            mouseEmulation.checked = true;
            tryCompare(shell, "enabled", true); // make sure greeter didn't leave us in disabled state
            tearDown();
            WindowStateStorage.clear();
        }

        function loadShell(formFactor) {
            shellLoader.state = formFactor;
            shellLoader.active = true;
            tryCompare(shellLoader, "status", Loader.Ready);
            removeTimeConstraintsFromSwipeAreas(shellLoader.item);
            tryCompare(shell, "enabled", true); // enabled by greeter when ready

            sessionSpy.target = findChild(shell, "greeter")
            dashCommunicatorSpy.target = findInvisibleChild(shell, "dashCommunicator");

            var launcher = findChild(shell, "launcher");
            launcherShowDashHomeSpy.target = launcher;

            var panel = findChild(launcher, "launcherPanel");
            verify(!!panel);

            panel.dismissTimer = fakeDismissTimer;

            waitForGreeterToStabilize();

            topLevelSurfaceList = findInvisibleChild(shell, "topLevelSurfaceList");
            verify(topLevelSurfaceList);
        }

        function loadDesktopShellWithApps() {
            loadShell("desktop");
            waitForRendering(shell)
            shell.usageScenario = "desktop"
            waitForRendering(shell)
            var app1 = ApplicationManager.startApplication("dialer-app")
            var app2 = ApplicationManager.startApplication("webbrowser-app")
            var app3 = ApplicationManager.startApplication("camera-app")
            var app4 = ApplicationManager.startApplication("facebook-webapp")
            var app5 = ApplicationManager.startApplication("camera-app")
            var app6 = ApplicationManager.startApplication("gallery-app")
            var app7 = ApplicationManager.startApplication("calendar-app")
            for (var i = 0; i < topLevelSurfaceList.count; ++i) {
                waitUntilAppWindowIsFullyLoaded(topLevelSurfaceList.idAt(i));
            }
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
            AccountsService.demoEdgesCompleted = [];
            Wizard.System.wizardEnabled = false;
            shellLoader.mode = "full-greeter";

            // kill all (fake) running apps
            killApps();

            unlockAllModemsSpy.clear()
            LightDM.Greeter.authenticate(""); // reset greeter

            sessionSpy.clear();

            GSettingsController.setLifecycleExemptAppids([]);

            // there should be only unity8-dash window over there
            tryCompare(ApplicationManager, "count", 1);
            compare(ApplicationManager.get(0).appId, "unity8-dash");
        }

        function test_snapDecisionDismissalReturnsFocus() {
            loadShell("phone");
            swipeAwayGreeter();
            var notifications = findChild(shell, "notificationList");
            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("camera-app");
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);
            var stage = findChild(shell, "stage")

            var appSurface = app.surfaceList.get(0);
            verify(appSurface);

            tryCompare(appSurface, "activeFocus", true);

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
            tryCompare(appSurface, "activeFocus", false);
            tryCompare(stage, "interactive", false);

            // Clicking the button should dismiss the notification and return focus
            var buttonAccept = findChild(notification, "notify_button0");
            mouseClick(buttonAccept);

            // Make sure we're back to normal
            tryCompare(appSurface, "activeFocus", true);
            compare(stage.interactive, true, "Stages not interactive again after modal notification has closed");
        }

        function addSnapDecisionNotification() {
            var n = {
                type: Notification.SnapDecision,
                hints: {"x-canonical-private-affirmative-tint": "true"},
                summary: "Tom Ato",
                body: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
                icon: "../../tests/graphics/avatars/funky.png",
                secondaryIcon: "../../tests/graphics/applicationIcons/facebook.png",
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
            var appSurfaceId = topLevelSurfaceList.nextId;
            tapOnAppIconInLauncher();
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

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
                compare(greeter.fullyShown, data.greeterShown);
            }

            var launcher = findChild(shell, "launcherPanel");
            tryCompare(launcher, "x", data.launcherHides ? -launcher.width : 0)

            //FIXME: This check fails. Don't understand the rationale behind it.
            /*
            // Make sure the helper for sliding out the launcher wasn't touched. We want to fade it out here.
            var animateTimer = findInvisibleChild(shell, "animateTimer");
            compare(animateTimer.nextState, "visible");
            */
        }

        function test_tabletLeftEdgeDrag_data() {
            return [
                {tag: "without password", user: "no-password", loggedIn: true},
                {tag: "with password", user: "has-password", loggedIn: false},
            ]
        }

        function test_tabletLeftEdgeDrag(data) {
            setLightDMMockMode("full");
            loadShell("tablet");

            selectUser(data.user)

            swipeFromLeftEdge(shell.width * 0.75)
            wait(500) // to give time to handle dash() signal from Launcher
            confirmLoggedIn(data.loggedIn)
        }

        function test_longLeftEdgeSwipeTakesToAppsAndResetSearchString() {
            loadShell("phone");
            swipeAwayGreeter();
            dragLauncherIntoView();
            dashCommunicatorSpy.clear();

            var appSurfaceId = topLevelSurfaceList.nextId;
            tapOnAppIconInLauncher();
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            tryCompareFunction(function() { return ApplicationManager.focusedApplicationId !== "unity8-dash"; }, true);

            //Long left swipe
            swipeFromLeftEdge(units.gu(30));

            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");

            compare(dashCommunicatorSpy.count, 1);
        }

        function test_ClickUbuntuIconInLauncherTakesToAppsAndResetSearchString() {
            loadShell("phone");
            swipeAwayGreeter();
            dragLauncherIntoView();
            dashCommunicatorSpy.clear();

            var launcher = findChild(shell, "launcher");
            var dashIcon = findChild(launcher, "dashItem");
            verify(dashIcon != undefined);
            mouseClick(dashIcon);

            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");

            compare(dashCommunicatorSpy.count, 1);
        }

        function test_suspend() {
            loadShell("phone");
            swipeAwayGreeter();
            var greeter = findChild(shell, "greeter");

            // Launch an app from the launcher
            dragLauncherIntoView();
            var appSurfaceId = topLevelSurfaceList.nextId;
            tapOnAppIconInLauncher();
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            var mainAppId = ApplicationManager.focusedApplicationId;
            verify(mainAppId != "");
            var mainApp = ApplicationManager.findApplication(mainAppId);
            verify(mainApp);
            tryCompare(mainApp, "requestedState", ApplicationInfoInterface.RequestedRunning);

            // Display off while call is active...
            callManager.foregroundCall = phoneCall;
            Powerd.setStatus(Powerd.Off, Powerd.Unknown);
            tryCompare(greeter, "shown", false);

            // Now try again after ending call
            callManager.foregroundCall = null;
            Powerd.setStatus(Powerd.On, Powerd.Unknown);
            Powerd.setStatus(Powerd.Off, Powerd.Unknown);
            tryCompare(greeter, "fullyShown", true);

            compare(mainApp.requestedState, ApplicationInfoInterface.RequestedSuspended);

            // And wake up
            Powerd.setStatus(Powerd.On, Powerd.Unknown);
            tryCompare(greeter, "fullyShown", true);

            // Swipe away greeter to focus app

            // greeter unloads its internal components when hidden
            // and reloads them when shown. Thus we have to do this
            // again before interacting with it otherwise any
            // SwipeAreas in there won't be easily fooled by
            // fake swipes.
            removeTimeConstraintsFromSwipeAreas(greeter);
            swipeAwayGreeter();

            compare(mainApp.requestedState, ApplicationInfoInterface.RequestedRunning);
            tryCompare(ApplicationManager, "focusedApplicationId", mainAppId);
        }

        function swipeAwayGreeter() {
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "fullyShown", true);
            waitForGreeterToStabilize();
            removeTimeConstraintsFromSwipeAreas(greeter);

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

            var passwordInput = findChild(shell, "passwordInput");

            var promptButton = findChild(passwordInput, "promptButton");
            tryCompare(promptButton, "visible", isButton);

            var promptField = findChild(passwordInput, "promptField");
            tryCompare(promptField, "visible", !isButton);

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
            var appSurfaceId = topLevelSurfaceList.nextId;
            tapOnAppIconInLauncher();
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

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
            var surface = SurfaceManager.inputMethodSurface;

            surface.setState(Mir.MinimizedState);
            tryCompare(item, "visible", false);

            surface.setState(Mir.RestoredState);
            tryCompare(item, "visible", true);

            surface.setState(Mir.MinimizedState);
            tryCompare(item, "visible", false);

            surface.setState(Mir.MaximizedState);
            tryCompare(item, "visible", true);

            surface.setState(Mir.MinimizedState);
            tryCompare(item, "visible", false);
        }

        function findAppWindowForSurfaceId(surfaceId) {
            // for PhoneStage and TabletStage
            var delegate = findChild(shell, "spreadDelegate_" + surfaceId);
            if (!delegate) {
                // for DesktopStage
                delegate = findChild(shell, "appDelegate_" + surfaceId);
            }
            verify(delegate);
            var appWindow = findChild(delegate, "appWindow");
            return appWindow;
        }

        // Wait until the ApplicationWindow for the given Application object is fully loaded
        // (ie, the real surface has replaced the splash screen)
        function waitUntilAppWindowIsFullyLoaded(surfaceId) {
            var appWindow = findAppWindowForSurfaceId(surfaceId);
            var appWindowStateGroup = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            tryCompareFunction(function() { return appWindowStateGroup.state === "surface" }, true);
            waitUntilTransitionsEnd(appWindowStateGroup);
        }

        function test_surfaceLosesActiveFocusWhilePanelIsOpen() {
            loadShell("phone");
            swipeAwayGreeter();
            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("dialer-app");
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);
            var appSurface = app.surfaceList.get(0);
            verify(appSurface);

            tryCompare(appSurface, "activeFocus", true);

            // Drag the indicators panel half-open
            var touchX = shell.width / 2;
            var indicators = findChild(shell, "indicators");
            touchFlick(indicators,
                    touchX /* fromX */, indicators.minimizedPanelHeight * 0.5 /* fromY */,
                    touchX /* toX */, shell.height * 0.5 /* toY */,
                    true /* beginTouch */, false /* endTouch */);
            verify(indicators.partiallyOpened);

            tryCompare(appSurface, "activeFocus", false);

            // And finish getting it open
            touchFlick(indicators,
                    touchX /* fromX */, shell.height * 0.5 /* fromY */,
                    touchX /* toX */, shell.height * 0.9 /* toY */,
                    false /* beginTouch */, true /* endTouch */);
            tryCompare(indicators, "fullyOpened", true);

            tryCompare(appSurface, "activeFocus", false);

            dragToCloseIndicatorsPanel();

            tryCompare(appSurface, "activeFocus", true);
        }

        function test_launchedAppHasActiveFocus_data() {
            return [
                {tag: "phone", formFactor: "phone", usageScenario: "phone"},
                {tag: "tablet", formFactor: "tablet", usageScenario: "tablet"},
                {tag: "desktop", formFactor: "tablet", usageScenario: "desktop"}
            ]
        }

        function test_launchedAppHasActiveFocus(data) {
            loadShell(data.formFactor);
            shell.usageScenario = data.usageScenario;
            swipeAwayGreeter();

            var webAppSurfaceId = topLevelSurfaceList.nextId;
            var webApp = ApplicationManager.startApplication("webbrowser-app");
            verify(webApp);
            waitUntilAppWindowIsFullyLoaded(webAppSurfaceId);

            var webAppSurface = webApp.surfaceList.get(topLevelSurfaceList.indexForId(webAppSurfaceId));
            verify(webAppSurface);

            tryCompare(webAppSurface, "activeFocus", true);
        }

        function test_launchedAppKeepsActiveFocusOnUsageModeChange() {
            loadShell("tablet");
            swipeAwayGreeter();

            var webAppSurfaceId = topLevelSurfaceList.nextId;
            var webApp = ApplicationManager.startApplication("webbrowser-app");
            verify(webApp);
            waitUntilAppWindowIsFullyLoaded(webAppSurfaceId);

            var webAppSurface = webApp.surfaceList.get(topLevelSurfaceList.indexForId(webAppSurfaceId));
            verify(webAppSurface);

            tryCompare(webAppSurface, "activeFocus", true);

            shell.usageScenario = "desktop";

            // check that the desktop stage and window have been loaded
            waitUntilAppWindowIsFullyLoaded(webAppSurfaceId);

            tryCompare(webAppSurface, "activeFocus", true);

            shell.usageScenario = "tablet";

            // check that the tablet stage and app surface delegate have been loaded
            waitUntilAppWindowIsFullyLoaded(webAppSurfaceId);

            tryCompare(webAppSurface, "activeFocus", true);
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
            waitForRendering(launcher);
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
            // SwipeAreas in there won't be easily fooled by
            // fake swipes.
            removeTimeConstraintsFromSwipeAreas(greeter);
        }

        function revealLauncherByEdgePushWithMouse() {
            var launcher = findChild(shell, "launcher");
            verify(launcher);

            // Place the mouse against the window/screen edge and push beyond the barrier threshold
            mouseMove(shell, 0, shell.height / 2);
            launcher.pushEdge(EdgeBarrierSettings.pushThreshold * 1.1);

            var panel = findChild(launcher, "launcherPanel");
            verify(panel);

            // wait until it gets fully extended
            tryCompare(panel, "x", 0);
            tryCompare(launcher, "state", "visibleTemporary");
        }

        function test_focusRequestedHidesGreeter() {
            loadShell("phone");
            swipeAwayGreeter();
            var greeter = findChild(shell, "greeter");

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("dialer-app");
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

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

            var greeter = findChild(shell, "greeter");
            verify(!greeter.locked);
            compare(sessionSpy.count, 0);

            swipeAwayGreeter();
            compare(sessionSpy.count, 1);
        }

        function test_fullscreen() {
            loadShell("phone");
            swipeAwayGreeter();
            var panel = findChild(shell, "panel");
            compare(panel.fullscreenMode, false);
            var cameraSurfaceId = topLevelSurfaceList.nextId;
            var cameraApp = ApplicationManager.startApplication("camera-app");
            waitUntilAppWindowIsFullyLoaded(cameraSurfaceId);
            tryCompare(panel, "fullscreenMode", true);
            var dialerSurfaceId = topLevelSurfaceList.nextId;
            var dialerApp = ApplicationManager.startApplication("dialer-app");
            waitUntilAppWindowIsFullyLoaded(dialerSurfaceId);
            tryCompare(panel, "fullscreenMode", false);
            ApplicationManager.requestFocusApplication(cameraApp.appId);
            tryCompare(panel, "fullscreenMode", true);
            ApplicationManager.requestFocusApplication(dialerApp.appId);
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
            loadShell("phone");

            var wizard = findChild(shell, "wizard");
            tryCompare(wizard, "active", true);
            tryCompareFunction(function() { return topLevelSurfaceList.applicationAt(0).appId; }, "unity8-dash");

            // Make sure we stay running when there's no top level window (can happen for
            // a moment when we restart the dash after switching language)
            var dashApplication = ApplicationManager.findApplication("unity8-dash");
            ApplicationManager.stopApplication(dashApplication.appId);
            // wait until all zombie surfaces are gone. As MirSurfaceItems hold references over them.
            // They won't be gone until those surface items are destroyed.
            tryCompareFunction(function() { return dashApplication.surfaceList.count }, 0);

            tryCompare(topLevelSurfaceList, "count", 0);
            compare(wizard.shown, true);

            // And make sure we stay running when dash comes back again
            var dashSurfaceId = topLevelSurfaceList.nextId;
            ApplicationManager.startApplication(dashApplication.appId);
            waitUntilAppWindowIsFullyLoaded(dashSurfaceId);
            compare(wizard.shown, true);

            // And make sure we stop when some other surface shows app
            var gallerySurfaceId = topLevelSurfaceList.nextId;
            var galleryApp = ApplicationManager.startApplication("gallery-app");
            waitUntilAppWindowIsFullyLoaded(gallerySurfaceId);
            tryCompareFunction(function() { return topLevelSurfaceList.applicationAt(0).appId; }, "gallery-app");
            compare(wizard.shown, false);
            tryCompare(Wizard.System, "wizardEnabled", false);
        }

        function test_tutorialPausedDuringGreeter() {
            loadShell("phone");

            var tutorial = findChild(shell, "tutorial");

            AccountsService.demoEdges = true;
            tryCompare(tutorial, "paused", true);

            swipeAwayGreeter();
            tryCompare(tutorial, "paused", false);
        }

        function test_tapOnRightEdgeReachesApplicationSurface() {
            loadShell("phone");
            swipeAwayGreeter();
            var topmostSpreadDelegate = findChild(shell, "spreadDelegate_" + topLevelSurfaceList.idAt(0));
            verify(topmostSpreadDelegate);

            waitUntilFocusedApplicationIsShowingItsSurface();

            var topmostSurfaceItem = findChild(topmostSpreadDelegate, "surfaceItem");
            verify(topmostSurfaceItem);

            var rightEdgeDragArea = findChild(shell, "spreadDragArea");
            topmostSurfaceItem.touchPressCount = 0;
            topmostSurfaceItem.touchReleaseCount = 0;

            var tapPoint = rightEdgeDragArea.mapToItem(shell, rightEdgeDragArea.width / 2,
                    rightEdgeDragArea.height / 2);

            tap(shell, tapPoint.x, tapPoint.y);

            tryCompare(topmostSurfaceItem, "touchPressCount", 1);
            tryCompare(topmostSurfaceItem, "touchReleaseCount", 1);
        }

        /*
            Perform a right edge drag over an application surface and check
            that no touch event was sent to it (ie, they were all consumed
            by the right-edge drag area)
         */
        function test_rightEdgeDragDoesNotReachApplicationSurface() {
            loadShell("phone");
            swipeAwayGreeter();
            var topmostSpreadDelegate = findChild(shell, "spreadDelegate_" + topLevelSurfaceList.idAt(0));
            var topmostSurfaceItem = findChild(topmostSpreadDelegate, "surfaceItem");
            var rightEdgeDragArea = findChild(shell, "spreadDragArea");

            topmostSurfaceItem.touchPressCount = 0;
            topmostSurfaceItem.touchReleaseCount = 0;

            var gestureStartPoint = rightEdgeDragArea.mapToItem(shell, rightEdgeDragArea.width / 2,
                    rightEdgeDragArea.height / 2);

            touchFlick(shell,
                    gestureStartPoint.x /* fromX */, gestureStartPoint.y /* fromY */,
                    units.gu(1) /* toX */, gestureStartPoint.y /* toY */);

            tryCompare(topmostSurfaceItem, "touchPressCount", 0);
            tryCompare(topmostSurfaceItem, "touchReleaseCount", 0);
        }

        function waitUntilFocusedApplicationIsShowingItsSurface()
        {
            var spreadDelegate = findChild(shell, "spreadDelegate_" + topLevelSurfaceList.idAt(0));
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
            launcherShowDashHomeSpy.clear();

            loadShell("phone");
            swipeAwayGreeter();

            waitUntilFocusedApplicationIsShowingItsSurface();

            swipeFromRightEdgeToShowAppSpread();

            var launcher = findChild(shell, "launcher");

            dragLauncherIntoView();

            // Emulate a tap with a finger, where the touch position drifts during the tap.
            // This is to test the touch ownership changes. The tap is happening on the button
            // area but then drifting into the left edge drag area. This test makes sure
            // the touch ownership stays with the button and doesn't move over to the
            // left edge drag area.
            {
                var buttonShowDashHome = findChild(launcher, "buttonShowDashHome");
                touchFlick(buttonShowDashHome,
                    buttonShowDashHome.width * 0.2,  /* startPos.x */
                    buttonShowDashHome.height * 0.8, /* startPos.y */
                    buttonShowDashHome.width * 0.8,  /* endPos.x */
                    buttonShowDashHome.height * 0.2  /* endPos.y */);
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

        function test_physicalHomeKeyPressDoesNothingWithActiveGreeter() {
            loadShell("phone");

            var windowInputMonitor = findInvisibleChild(shell, "windowInputMonitor");
            var coverPage = findChild(shell, "coverPage");

            windowInputMonitor.homeKeyActivated();
            verify(coverPage.shown);
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

        function test_stageLoader_data() {
            return [
                {tag: "phone", source: "Stages/PhoneStage.qml", formFactor: "phone", usageScenario: "phone"},
                {tag: "tablet", source: "Stages/TabletStage.qml", formFactor: "tablet", usageScenario: "tablet"},
                {tag: "desktop", source: "Stages/DesktopStage.qml", formFactor: "tablet", usageScenario: "desktop"}
            ]
        }

        function test_stageLoader(data) {
            loadShell(data.formFactor);
            shell.usageScenario = data.usageScenario;
            var stageLoader = findChild(shell, "applicationsDisplayLoader");
            verify(String(stageLoader.source).indexOf(data.source) >= 0);
        }

        function test_launcherInverted_data() {
            return [
                {tag: "phone", formFactor: "phone", usageScenario: "phone", launcherInverted: true},
                {tag: "tablet", formFactor: "tablet", usageScenario: "tablet", launcherInverted: true},
                {tag: "desktop", formFactor: "tablet", usageScenario: "desktop", launcherInverted: false}
            ]
        }

        function test_launcherInverted(data) {
            loadShell(data.formFactor);
            shell.usageScenario = data.usageScenario;

            var launcher = findChild(shell, "launcher");
            compare(launcher.inverted, data.launcherInverted);
        }

        function test_unfocusedAppsGetSuspendedAfterEnteringStagedMode() {
            loadShell("tablet");
            shell.usageScenario = "desktop";

            var webBrowserSurfaceId = topLevelSurfaceList.nextId;
            var webBrowserApp = ApplicationManager.startApplication("webbrowser-app");
            waitUntilAppWindowIsFullyLoaded(webBrowserSurfaceId);

            var gallerySurfaceId = topLevelSurfaceList.nextId;
            var galleryApp = ApplicationManager.startApplication("gallery-app");
            waitUntilAppWindowIsFullyLoaded(gallerySurfaceId);

            ApplicationManager.requestFocusApplication("unity8-dash");
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");

            compare(webBrowserApp.requestedState, ApplicationInfoInterface.RequestedRunning);
            compare(galleryApp.requestedState, ApplicationInfoInterface.RequestedRunning);

            shell.usageScenario = "tablet";

            tryCompare(webBrowserApp, "requestedState", ApplicationInfoInterface.RequestedSuspended);
            tryCompare(galleryApp, "requestedState", ApplicationInfoInterface.RequestedSuspended);
        }

        function test_unfocusedAppsAreResumedWhenEnteringWindowedMode() {
            loadShell("tablet");
            shell.usageScenario = "tablet";

            var webBrowserSurfaceId = topLevelSurfaceList.nextId;
            var webBrowserApp = ApplicationManager.startApplication("webbrowser-app");
            waitUntilAppWindowIsFullyLoaded(webBrowserSurfaceId);

            var gallerySurfaceId = topLevelSurfaceList.nextId;
            var galleryApp = ApplicationManager.startApplication("gallery-app");
            waitUntilAppWindowIsFullyLoaded(gallerySurfaceId);

            ApplicationManager.requestFocusApplication("unity8-dash");
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");

            compare(webBrowserApp.requestedState, ApplicationInfoInterface.RequestedSuspended);
            compare(galleryApp.requestedState, ApplicationInfoInterface.RequestedSuspended);

            shell.usageScenario = "desktop";

            tryCompare(webBrowserApp, "requestedState", ApplicationInfoInterface.RequestedRunning);
            tryCompare(galleryApp, "requestedState", ApplicationInfoInterface.RequestedRunning);
        }

        function test_altTabSwitchesFocus_data() {
            return [
                { tag: "windowed", shellType: "desktop" },
                { tag: "staged", shellType: "phone" },
                { tag: "sidestaged", shellType: "tablet" }
            ];
        }

        function test_altTabSwitchesFocus(data) {
            loadShell(data.shellType);
            shell.usageScenario = data.shellType;
            waitForRendering(root)

            var desktopStage = findChild(shell, "stage");
            verify(desktopStage != null)

            var app1SurfaceId = topLevelSurfaceList.nextId;
            var app1 = ApplicationManager.startApplication("dialer-app")
            waitUntilAppWindowIsFullyLoaded(app1SurfaceId);

            var app2SurfaceId = topLevelSurfaceList.nextId;
            var app2 = ApplicationManager.startApplication("webbrowser-app")
            waitUntilAppWindowIsFullyLoaded(app2SurfaceId);
            var app2Surface = app2.surfaceList.get(0);
            verify(app2Surface);

            var app3SurfaceId = topLevelSurfaceList.nextId;
            var app3 = ApplicationManager.startApplication("camera-app")
            waitUntilAppWindowIsFullyLoaded(app3SurfaceId);
            var app3Surface = app3.surfaceList.get(0);
            verify(app3Surface);

            // Do a quick alt-tab and see if focus changes
            tryCompare(app3Surface, "activeFocus", true)
            keyClick(Qt.Key_Tab, Qt.AltModifier)
            tryCompare(app2Surface, "activeFocus", true)

            // Press Alt+Tab
            keyPress(Qt.Key_Alt);
            keyClick(Qt.Key_Tab);
            keyRelease(Qt.Key_Alt)

            // Focus should have switched back now
            tryCompare(app3Surface, "activeFocus", true)
        }

        function test_altTabWrapAround() {
            loadDesktopShellWithApps();

            var desktopStage = findChild(shell, "stage");
            verify(desktopStage !== null)

            var desktopSpread = findChild(shell, "spread");
            verify(desktopSpread !== null)

            var spreadContainer = findInvisibleChild(shell, "spreadContainer")
            verify(spreadContainer !== null)

            var spreadRepeater = findInvisibleChild(shell, "spreadRepeater")
            verify(spreadRepeater !== null)

            // remember the focused appId
            var focused = ApplicationManager.get(ApplicationManager.findApplication(ApplicationManager.focusedApplicationId));

            tryCompare(desktopSpread, "state", "")

            // Just press Alt, make sure the spread comes up
            keyPress(Qt.Key_Alt);
            keyClick(Qt.Key_Tab);
            tryCompare(desktopSpread, "state", "altTab")
            tryCompare(spreadRepeater, "highlightedIndex", 1)
            waitForRendering(shell)

            // Now press and hold Tab, make sure the highlight moves all the way but stops at the last one
            // We can't simulate a pressed key with keyPress() currently, so let's inject the events
            // at API level. Jump for 10 times, verify that it's still at the last one and didn't wrap around.
            for (var i = 0; i < 10; i++) {
                desktopSpread.selectNext(true); // true == isAutoRepeat
                wait(0); // Trigger the event loop to make sure all the things happen
            }
            tryCompare(spreadRepeater, "highlightedIndex", 6)

            // Now release it once, and verify that it does wrap around with an additional Tab press
            keyRelease(Qt.Key_Tab);
            keyClick(Qt.Key_Tab);
            tryCompare(spreadRepeater, "highlightedIndex", 0)

            // Release control, check if spread disappears
            keyRelease(Qt.Key_Alt)
            tryCompare(desktopSpread, "state", "")

            // Make sure that after wrapping around once, we have the same one focused as at the beginning
            var focusedAppSurface = focused.surfaceList.get(0);
            verify(focusedAppSurface);
            tryCompare(focusedAppSurface, "activeFocus", true)
        }

        function test_altBackTabNavigation() {
            loadDesktopShellWithApps();

            var spreadRepeater = findInvisibleChild(shell, "spreadRepeater");
            verify(spreadRepeater !== null);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);
            tryCompare(spreadRepeater, "highlightedIndex", 1);

            keyClick(Qt.Key_Tab);
            tryCompare(spreadRepeater, "highlightedIndex", 2);

            keyClick(Qt.Key_Tab);
            tryCompare(spreadRepeater, "highlightedIndex", 3);

            keyClick(Qt.Key_Tab);
            tryCompare(spreadRepeater, "highlightedIndex", 4);

            keyClick(Qt.Key_Backtab);
            tryCompare(spreadRepeater, "highlightedIndex", 3);

            keyClick(Qt.Key_Backtab);
            tryCompare(spreadRepeater, "highlightedIndex", 2);

            keyClick(Qt.Key_Backtab);
            tryCompare(spreadRepeater, "highlightedIndex", 1);

            keyRelease(Qt.Key_Alt);
        }

        function otest_highlightFollowsMouse() {
            loadDesktopShellWithApps()

            var spreadRepeater = findInvisibleChild(shell, "spreadRepeater");
            verify(spreadRepeater !== null);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);

            tryCompare(spreadRepeater, "highlightedIndex", 1);

            var x = 0;
            var y = shell.height * .75;
            mouseMove(shell, x, y)

            for (var i = 0; i < 7; i++) {
                while (spreadRepeater.highlightedIndex != i && x <= 4000) {
                    x+=10;
                    mouseMove(shell, x, y)
                    wait(0); // spin the loop so bindings get evaluated
                }
            }

            verify(y < 4000);

            keyRelease(Qt.Key_Alt);
        }

        function test_closeFromSpread() {
            loadDesktopShellWithApps()

            var spreadRepeater = findInvisibleChild(shell, "spreadRepeater");
            verify(spreadRepeater !== null);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);

            var surfaceId = topLevelSurfaceList.idAt(2);
            var spreadDelegate2 = spreadRepeater.itemAt(2);
            var closeMouseArea = findChild(spreadDelegate2, "closeMouseArea");

            // Move the mosue over tile 2 and verify the close button becomes visible
            var x = 0;
            var y = shell.height * .5;
            mouseMove(shell, x, y)
            while (spreadRepeater.highlightedIndex !== 2 && x <= 4000) {
                x+=10;
                mouseMove(shell, x, y)
                wait(0); // spin the loop so bindings get evaluated
            }
            tryCompare(closeMouseArea, "enabled", true)

            var countBeforeClickingCloseButton = topLevelSurfaceList.count;
            verify(topLevelSurfaceList.indexForId(surfaceId) === 2);

            // Close the app using the close button
            mouseClick(closeMouseArea, closeMouseArea.width / 2, closeMouseArea.height / 2)

            tryCompare(topLevelSurfaceList, "count", countBeforeClickingCloseButton - 1);
            verify(topLevelSurfaceList.indexForId(surfaceId) === -1);

            keyRelease(Qt.Key_Alt);
        }

        function test_selectFromSpreadWithMouse_data() {
            return [
                {tag: "click on tileInfo", tileInfo: true },
                {tag: "click on surface", tileInfo: false },
            ]
        }

        function test_selectFromSpreadWithMouse(data) {
            loadDesktopShellWithApps()

            var stage = findChild(shell, "stage");
            var spread = findChild(stage, "spread");
            waitForRendering(spread)

            var spreadRepeater = findInvisibleChild(shell, "spreadRepeater");
            verify(spreadRepeater !== null);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);

            var surface = topLevelSurfaceList.surfaceAt(2);
            var spreadDelegate2 = spreadRepeater.itemAt(2);
            var clippedSpreadDelegate = findChild(spreadDelegate2, "clippedSpreadDelegate");

            tryCompare(spread, "state", "altTab");

            // Move the mouse over tile 2 and verify the highlight becomes visible
            var x = 0;
            var y = shell.height * (data.tileInfo ? .95 : 0.5)
            mouseMove(shell, x, y)
            while (spreadRepeater.highlightedIndex !== 2 && x <= 4000) {
                x+=10;
                mouseMove(shell, x, y)
                wait(0); // spin the loop so bindings get evaluated
            }
            tryCompare(clippedSpreadDelegate, "highlightShown", true);

            // Click the tile
            mouseClick(clippedSpreadDelegate, clippedSpreadDelegate.width / 2, clippedSpreadDelegate.height / 2)

            // Verify that we left the spread and app2 is the focused one now
            tryCompare(stage, "state", "");
            tryCompare(surface, "focused", true);

            keyRelease(Qt.Key_Alt);
        }

        function test_progressiveAutoScrolling() {
            loadDesktopShellWithApps()

            var appRepeater = findInvisibleChild(shell, "appRepeater");
            verify(appRepeater !== null);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);

            var spreadFlickable = findChild(shell, "spreadFlickable")

            compare(spreadFlickable.contentX, 0);

            // Move the mouse to the right and make sure it scrolls the Flickable
            var x = 0;
            var y = shell.height * .5
            mouseMove(shell, x, y)
            while (x <= shell.width) {
                x+=10;
                mouseMove(shell, x, y)
                wait(0); // spin the loop so bindings get evaluated
            }
            tryCompare(spreadFlickable, "contentX", spreadFlickable.contentWidth - spreadFlickable.width);

            // And turn around
            while (x > 0) {
                x-=10;
                mouseMove(shell, x, y)
                wait(0); // spin the loop so bindings get evaluated
            }
            tryCompare(spreadFlickable, "contentX", 0);

            keyRelease(Qt.Key_Alt);
        }

        // This makes sure the hoverMouseArea is set to invisible AND disabled
        // when not needed. Otherwise it'll eat mouse hover events for the rest of the shell/apps
        function test_hoverMouseAreaDisabledAndInvisible() {
            loadDesktopShellWithApps()

            var hoverMouseArea = findChild(shell, "hoverMouseArea");
            tryCompare(hoverMouseArea, "enabled", false)
            tryCompare(hoverMouseArea, "visible", false)

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);

            tryCompare(hoverMouseArea, "enabled", true)
            tryCompare(hoverMouseArea, "visible", true)

            keyRelease(Qt.Key_Alt)

            tryCompare(hoverMouseArea, "enabled", false)
            tryCompare(hoverMouseArea, "visible", false)
        }

        function test_workspacePreviewsHighlightedApp() {
            loadDesktopShellWithApps()

            var targetZ = topLevelSurfaceList.count + 1;

            var spreadRepeater = findInvisibleChild(shell, "spreadRepeater");
            verify(spreadRepeater !== null);

            var appRepeater = findInvisibleChild(shell, "appRepeater");
            verify(appRepeater !== null);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);

            tryCompare(spreadRepeater, "highlightedIndex", 1);
            tryCompare(appRepeater.itemAt(1), "z", targetZ)

            var x = 0;
            var y = shell.height * .75;
            mouseMove(shell, x, y)

            for (var i = 0; i < 7; i++) {
                while (spreadRepeater.highlightedIndex != i && x <= 4000) {
                    tryCompare(appRepeater.itemAt(spreadRepeater.highlightedIndex), "z", targetZ)
                    x+=10;
                    mouseMove(shell, x, y)
                    wait(0); // spin the loop so bindings get evaluated
                }
            }

            verify(y < 4000);

            keyRelease(Qt.Key_Alt);
        }

        function test_focusAppFromLauncherExitsSpread_data() {
            return [
                {tag: "autohide launcher", launcherLocked: false },
                {tag: "locked launcher", launcherLocked: true }
            ]
        }

        function test_focusAppFromLauncherExitsSpread(data) {
            loadDesktopShellWithApps()
            var launcher = findChild(shell, "launcher");
            var desktopSpread = findChild(shell, "spread");
            var bfb = findChild(launcher, "buttonShowDashHome");

            GSettingsController.setAutohideLauncher(!data.launcherLocked);
            waitForRendering(shell);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);

            tryCompare(desktopSpread, "state", "altTab")

            if (!data.launcherLocked) {
                revealLauncherByEdgePushWithMouse();
                tryCompare(launcher, "x", 0);
                mouseMove(bfb, bfb.width / 2, bfb.height / 2)
                waitForRendering(shell)
            }

            mouseClick(bfb, bfb.width / 2, bfb.height / 2)
            if (!data.launcherLocked) {
                tryCompare(launcher, "state", "")
            }
            tryCompare(desktopSpread, "state", "")

            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash")

            keyRelease(Qt.Key_Alt);
        }

        // regression test for http://pad.lv/1443319
        function test_closeMaximizedAndRestart() {
            loadDesktopShellWithApps();

            var appRepeater = findChild(shell, "appRepeater")
            var application = topLevelSurfaceList.applicationAt(0);
            var surfaceId = topLevelSurfaceList.idAt(0);
            var appDelegate = appRepeater.itemAt(0);
            var maximizeButton = findChild(appDelegate, "maximizeWindowButton");

            tryCompare(appDelegate, "state", "normal");
            tryCompare(PanelState, "buttonsVisible", false)

            mouseClick(maximizeButton, maximizeButton.width / 2, maximizeButton.height / 2);
            tryCompare(appDelegate, "state", "maximized");
            tryCompare(PanelState, "buttonsVisible", true)

            ApplicationManager.stopApplication(application.appId);
            tryCompare(PanelState, "buttonsVisible", false)

            // wait until all zombie surfaces are gone. As MirSurfaceItems hold references over them.
            // They won't be gone until those surface items are destroyed.
            tryCompareFunction(function() { return application.surfaceList.count }, 0);

            ApplicationManager.startApplication(application.appId);
            tryCompare(PanelState, "buttonsVisible", true)
        }

        function test_newAppHasValidGeometry() {
            loadDesktopShellWithApps();
            var appRepeater = findChild(shell, "appRepeater");
            var appDelegate = appRepeater.itemAt(0);

            var resizeArea = findChild(appDelegate, "windowResizeArea");
            var priv = findInvisibleChild(resizeArea, "priv");

            // Make sure windows are at 0,0 or greater and they have a size that's > 0
            compare(priv.normalX >= 0, true)
            compare(priv.normalY >= 0, true)
            compare(priv.normalWidth > 0, true)
            compare(priv.normalHeight > 0, true)
        }

        // bug http://pad.lv/1431566
        function test_switchToStagedHidesPanelButtons() {
            loadDesktopShellWithApps();
            var appRepeater = findChild(shell, "appRepeater")
            var appDelegate = appRepeater.itemAt(0);
            var panelButtons = findChild(shell, "panelWindowControlButtons")

            tryCompare(appDelegate, "state", "normal");
            tryCompare(panelButtons, "visible", false);

            appDelegate.maximize(false);

            shell.usageScenario = "phone";
            waitForRendering(shell);
            tryCompare(panelButtons, "visible", false);
        }

        function test_lockingGreeterHidesPanelButtons() {
            loadDesktopShellWithApps();
            var appRepeater = findChild(shell, "appRepeater")
            var appDelegate = appRepeater.itemAt(0);
            var panelButtons = findChild(shell, "panelWindowControlButtons")

            tryCompare(appDelegate, "state", "normal");
            tryCompare(panelButtons, "visible", false);

            appDelegate.maximize(false);

            LightDM.Greeter.showGreeter();
            waitForRendering(shell);
            tryCompare(panelButtons, "visible", false);
        }

        function test_cantMoveWindowUnderPanel() {
            loadDesktopShellWithApps();
            var appRepeater = findChild(shell, "appRepeater")
            var appDelegate = appRepeater.itemAt(0);

            mousePress(appDelegate, appDelegate.width / 2, units.gu(1))
            mouseMove(appDelegate, appDelegate.width / 2, -units.gu(100))

            compare(appDelegate.y >= PanelState.panelHeight, true);
        }

        function test_cantResizeWindowUnderPanel() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("dialer-app")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            var appContainer = findChild(shell, "appContainer");
            verify(appContainer);
            var appDelegate = findChild(appContainer, "appDelegate_" + appSurfaceId);
            verify(appDelegate);
            var decoration = findChild(appDelegate, "appWindowDecoration");
            verify(decoration);

            // move it away from launcher and panel
            appDelegate.x = units.gu(10)
            appDelegate.y = units.gu(10)

            // drag-resize the area up
            mousePress(decoration, decoration.width/2, -units.gu(1));
            mouseMove(decoration, decoration.width/2, -units.gu(100));

            // verify we don't go past the panel
            compare(appDelegate.y >= PanelState.panelHeight, true);
        }

        function test_restoreWindowStateFixesIfUnderPanel() {
            loadDesktopShellWithApps();
            var appRepeater = findChild(shell, "appRepeater")
            var application = topLevelSurfaceList.applicationAt(0);
            var appDelegate = appRepeater.itemAt(0);

            // Move it under the panel programmatically (might happen later with an alt+drag)
            appDelegate.y = -units.gu(10)

            ApplicationManager.stopApplication(application.appId);
            // wait until all zombie surfaces are gone. As MirSurfaceItems hold references over them.
            // They won't be gone until those surface items are destroyed.
            tryCompareFunction(function() { return application.surfaceList.count }, 0);

            ApplicationManager.startApplication(application.appId);
            waitForRendering(shell)

            // Make sure the newly started one is at index 0 again
            tryCompareFunction(function () { return topLevelSurfaceList.applicationAt(0).appId; }, application.appId);

            appDelegate = appRepeater.itemAt(0);
            compare(appDelegate.y >= PanelState.panelHeight, true);
        }

        function test_lifecyclePolicyForNonTouchApp_data() {
            return [
                {tag: "phone", formFactor: "phone", usageScenario: "phone"},
                {tag: "tablet", formFactor: "tablet", usageScenario: "tablet"}
            ]
        }

        function test_lifecyclePolicyForNonTouchApp(data) {
            loadShell(data.formFactor);
            shell.usageScenario = data.usageScenario;

            // Add two main stage apps, the second in order to suspend the first.
            // LibreOffice has isTouchApp set to false by our mocks.
            var app1SurfaceId = topLevelSurfaceList.nextId;
            var app1 = ApplicationManager.startApplication("libreoffice");
            waitUntilAppWindowIsFullyLoaded(app1SurfaceId);
            var app2SurfaceId = topLevelSurfaceList.nextId;
            var app2 = ApplicationManager.startApplication("gallery-app");
            waitUntilAppWindowIsFullyLoaded(app2SurfaceId);

            // Sanity checking
            compare(app1.stage, ApplicationInfoInterface.MainStage);
            compare(app2.stage, ApplicationInfoInterface.MainStage);
            verify(!app1.isTouchApp);

            var app1Surface = app1.surfaceList.get(0);
            verify(app1Surface);

            verify(!app1Surface.activeFocus);

            // Make sure app1 is exempt with a requested suspend
            verify(app1.exemptFromLifecycle);
            compare(app1.requestedState, ApplicationInfoInterface.RequestedSuspended);
        }

        function test_lifecyclePolicyExemption_data() {
            return [
                {tag: "phone", formFactor: "phone", usageScenario: "phone"},
                {tag: "tablet", formFactor: "tablet", usageScenario: "tablet"}
            ]
        }

        function test_lifecyclePolicyExemption(data) {
            loadShell(data.formFactor);
            shell.usageScenario = data.usageScenario;

            GSettingsController.setLifecycleExemptAppids(["webbrowser-app"]);

            // Add two main stage apps, the second in order to suspend the first
            var app1SurfaceId = topLevelSurfaceList.nextId;
            var app1 = ApplicationManager.startApplication("webbrowser-app");
            waitUntilAppWindowIsFullyLoaded(app1SurfaceId);
            var app2SurfaceId = topLevelSurfaceList.nextId;
            var app2 = ApplicationManager.startApplication("gallery-app");
            waitUntilAppWindowIsFullyLoaded(app2SurfaceId);

            // Sanity checking
            compare(app1.stage, ApplicationInfoInterface.MainStage);
            compare(app2.stage, ApplicationInfoInterface.MainStage);

            var app1Surface = app1.surfaceList.get(0);
            verify(app1Surface);

            verify(!app1Surface.activeFocus);

            // Make sure app1 is exempt with a requested suspend
            verify(app1.exemptFromLifecycle);
            compare(app1.requestedState, ApplicationInfoInterface.RequestedSuspended);
        }

        function test_switchToStagedForcesLegacyAppClosing_data() {
            return [
                {tag: "forceClose", replug: false },
                {tag: "replug", replug: true }
            ];
        }

        function test_switchToStagedForcesLegacyAppClosing(data) {
            loadShell("desktop")
            shell.usageScenario = "desktop"
            waitForRendering(shell);

            ApplicationManager.startApplication("camera-app")

            shell.usageScenario = "phone"
            waitForRendering(shell);

            // No legacy app running yet... Popup must *not* show.
            var popup = findChild(root, "modeSwitchWarningDialog");
            compare(popup, null);

            shell.usageScenario = "desktop"
            waitForRendering(shell);

            // Now start a legacy app
            ApplicationManager.startApplication("libreoffice")

            shell.usageScenario = "phone"
            waitForRendering(shell);

            // The popup must appear now
            popup = findChild(root, "modeSwitchWarningDialog");
            compare(popup !== null, true);

            if (data.replug) {
                shell.usageScenario = "desktop"
                waitForRendering(shell);

            } else {
                var forceCloseButton = findChild(popup, "forceCloseButton");
                mouseClick(forceCloseButton, forceCloseButton.width / 2, forceCloseButton.height / 2);
                waitForRendering(root);
            }

            // Popup must be gone now
            popup = findChild(root, "modeSwitchWarningDialog");
            tryCompareFunction(function() { return popup === null}, true);

            if (data.replug) {
                // Libreoffice must still be running
                compare(ApplicationManager.findApplication("libreoffice") !== null, true);
            } else {
                // Libreoffice must be gone now (or soon at least)
                tryCompareFunction(function() { return ApplicationManager.findApplication("libreoffice") === null}, true);
            }
        }

        function test_superTabToCycleLauncher_data() {
            return [
                {tag: "autohide launcher", launcherLocked: false},
                {tag: "locked launcher", launcherLocked: true}
            ]
        }

        function test_superTabToCycleLauncher(data) {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            GSettingsController.setAutohideLauncher(!data.launcherLocked);
            waitForRendering(shell);

            var launcher = findChild(shell, "launcher");
            var launcherPanel = findChild(launcher, "launcherPanel");
            var firstAppInLauncher = LauncherModel.get(0).appId;

            compare(launcher.state, data.launcherLocked ? "visible": "");
            compare(launcherPanel.highlightIndex, -2);
            compare(ApplicationManager.focusedApplicationId, "unity8-dash");

            // Use Super + Tab Tab to cycle to the first entry in the launcher
            wait(1000);
            keyPress(Qt.Key_Super_L, Qt.MetaModifier);
            keyClick(Qt.Key_Tab);
            tryCompare(launcher, "state", "visible");
            tryCompare(launcherPanel, "highlightIndex", -1);
            keyClick(Qt.Key_Tab);
            tryCompare(launcherPanel, "highlightIndex", 0);
            keyRelease(Qt.Key_Super_L, Qt.MetaModifier);
            tryCompare(launcher, "state", data.launcherLocked ? "visible" : "");
            tryCompare(launcherPanel, "highlightIndex", -2);
            tryCompare(ApplicationManager, "focusedApplicationId", firstAppInLauncher);

            // Now go back to the dash
            keyPress(Qt.Key_Super_L, Qt.MetaModifier);
            keyClick(Qt.Key_Tab);
            tryCompare(launcher, "state", "visible");
            tryCompare(launcherPanel, "highlightIndex", -1);
            keyRelease(Qt.Key_Super_L, Qt.MetaModifier);
            tryCompare(launcher, "state", data.launcherLocked ? "visible" : "");
            tryCompare(launcherPanel, "highlightIndex", -2);
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");
        }

        function test_longpressSuperOpensLauncherAndShortcutsOverlay() {
            loadShell("desktop");
            var launcher = findChild(shell, "launcher");
            var shortcutHint = findChild(findChild(launcher, "launcherDelegate0"), "shortcutHint")
            var shortcutsOverlay = findChild(shell, "shortcutsOverlay");

            compare(launcher.state, "");
            keyPress(Qt.Key_Super_L, Qt.MetaModifier);
            waitForRendering(shortcutsOverlay);
            tryCompare(launcher, "state", "visible");
            tryCompare(shortcutHint, "visible", true);
            if (shortcutsOverlay.enabled) {
                tryCompare(shortcutsOverlay, "visible", true, 10000);
            }

            keyRelease(Qt.Key_Super_L, Qt.MetaModifier);
            tryCompare(launcher, "state", "");
            tryCompare(shortcutHint, "visible", false);
            if (shortcutsOverlay.enabled) {
                tryCompare(shortcutsOverlay, "visible", false);
            }
        }

        function test_metaNumberLaunchesFromLauncher_data() {
            return [
                {tag: "Meta+1", key: Qt.Key_1, index: 0},
                {tag: "Meta+2", key: Qt.Key_2, index: 1},
                {tag: "Meta+4", key: Qt.Key_5, index: 4},
                {tag: "Meta+0", key: Qt.Key_0, index: 9},
            ]
        }

        function test_metaNumberLaunchesFromLauncher(data) {
            loadShell("desktop");
            var launcher = findChild(shell, "launcher");
            var appId = LauncherModel.get(data.index).appId;
            waitForRendering(shell);

            keyClick(data.key, Qt.MetaModifier);
            tryCompare(ApplicationManager, "focusedApplicationId", appId);
        }

        function test_altF1OpensLauncherForKeyboardNavigation() {
            loadShell("desktop");
            waitForRendering(shell);
            var launcher = findChild(shell, "launcher");

            keyClick(Qt.Key_F1, Qt.AltModifier);
            tryCompare(launcher, "state", "visible");
            tryCompare(launcher, "focus", true)
        }

        function test_lockedOutLauncherAddsMarginsToMaximized() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            var appContainer = findChild(shell, "appContainer");
            var launcher = findChild(shell, "launcher");

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("music-app");
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);
            var appDelegate = findChild(appContainer, "appDelegate_" + appSurfaceId);
            appDelegate.maximize();
            tryCompare(appDelegate, "visuallyMaximized", true);
            waitForRendering(shell);

            GSettingsController.setAutohideLauncher(true);
            waitForRendering(shell)
            var hiddenSize = appDelegate.width;

            GSettingsController.setAutohideLauncher(false);
            waitForRendering(shell)
            var shownSize = appDelegate.width;

            compare(shownSize + launcher.panelWidth, hiddenSize);
        }

        function test_fullscreenAppHidesLockedOutLauncher() {
            loadShell("desktop");
            shell.usageScenario = "desktop";

            var launcher = findChild(shell, "launcher");
            var launcherPanel = findChild(launcher, "launcherPanel");

            GSettingsController.setAutohideLauncher(false);
            waitForRendering(shell)

            tryCompare(launcher, "lockedVisible", true);

            var surfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("gmail-webapp");

            waitUntilAppWindowIsFullyLoaded(surfaceId);

            // Sanity check: ensure the fake app we chose creates a surface the way
            // we expect it to.
            compare(app.surfaceList.get(0).shellChrome, Mir.NormalChrome);

            compare(launcher.lockedVisible, true);

            app.surfaceList.get(0).state = Mir.FullscreenState;

            tryCompare(launcher, "lockedVisible", false);
        }


        function test_inputEventsOnEdgesEndUpInAppSurface_data() {
            return [
                { tag: "phone", repeaterName: "spreadRepeater" },
                { tag: "tablet", repeaterName: "spreadRepeater" },
                { tag: "desktop", repeaterName: "appRepeater" },
            ]
        }

        function test_inputEventsOnEdgesEndUpInAppSurface(data) {
            loadShell(data.tag);
            shell.usageScenario = data.tag;
            waitForRendering(shell);
            swipeAwayGreeter();

            // Let's open a fullscreen app
            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("camera-app");
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            var appRepeater = findChild(shell, data.repeaterName);
            var topmostAppDelegate = appRepeater.itemAt(0);
            verify(topmostAppDelegate);

            var topmostSurfaceItem = findChild(topmostAppDelegate, "surfaceItem");
            verify(topmostSurfaceItem);

            mouseClick(shell, 1, shell.height / 2);
            compare(topmostSurfaceItem.mousePressCount, 1);
            compare(topmostSurfaceItem.mouseReleaseCount, 1);

            mouseClick(shell, shell.width - 1, shell.height / 2);
            compare(topmostSurfaceItem.mousePressCount, 2);
            compare(topmostSurfaceItem.mouseReleaseCount, 2);

            tap(shell, 1, shell.height / 2);
            compare(topmostSurfaceItem.touchPressCount, 1);
            compare(topmostSurfaceItem.touchReleaseCount, 1);

            tap(shell, shell.width - 1, shell.height / 2);
            compare(topmostSurfaceItem.touchPressCount, 2);
            compare(topmostSurfaceItem.touchReleaseCount, 2);
        }

        function test_switchKeymap() {
            // start with phone shell
            loadShell("phone");
            shell.usageScenario = "phone";
            waitForRendering(shell);
            swipeAwayGreeter();

            // configure keymaps
            AccountsService.keymaps = ["sk", "cz+qwerty", "fr"] // "configure" the keymaps for user

            // start some app
            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("dialer-app");
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);
            var appSurface = app.surfaceList.get(0);

            // verify the initial keymap of the newly started app is the first one from the list
            tryCompare(appSurface, "keymap", "sk");

            // switch to next keymap, should go to "cz+qwerty"
            keyClick(Qt.Key_Space, Qt.MetaModifier);
            tryCompare(appSurface, "keymap", "cz+qwerty");

            // switch to next keymap, should go to "fr"
            keyClick(Qt.Key_Space, Qt.MetaModifier);
            tryCompare(appSurface, "keymap", "fr");

            // go to e.g. desktop stage
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);

            // start a second app, should get the last configured keyboard, "fr"
            var app2SurfaceId = topLevelSurfaceList.nextId;
            var app2 = ApplicationManager.startApplication("calendar-app");
            waitUntilAppWindowIsFullyLoaded(app2SurfaceId);
            var app2Surface = app2.surfaceList.get(0);
            tryCompare(app2Surface, "keymap", "fr");

            // focus our first app, make sure it also has the "fr" keymap
            ApplicationManager.requestFocusApplication("dialer-app");
            tryCompare(appSurface, "keymap", "fr");

            // switch to previous keymap, should be "cz+qwerty"
            keyClick(Qt.Key_Space, Qt.MetaModifier|Qt.ShiftModifier);
            tryCompare(appSurface, "keymap", "cz+qwerty");

            // go next twice to "sk", past the end
            keyClick(Qt.Key_Space, Qt.MetaModifier);
            keyClick(Qt.Key_Space, Qt.MetaModifier);
            tryCompare(appSurface, "keymap", "sk");

            // go back once to past the beginning, to "fr"
            keyClick(Qt.Key_Space, Qt.MetaModifier|Qt.ShiftModifier);
            tryCompare(appSurface, "keymap", "fr");

            // switch to app2, should also get "fr"
            ApplicationManager.requestFocusApplication("calendar-app");
            tryCompare(app2Surface, "keymap", "fr");
        }

        function test_dragPanelToRestoreMaximizedWindow() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            var panel = findChild(shell, "windowControlArea");
            verify(panel);

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("dialer-app")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            // start dialer, maximize it
            var appContainer = findChild(shell, "appContainer");
            var appDelegate = findChild(appContainer, "appDelegate_" + appSurfaceId);
            verify(appDelegate);
            appDelegate.maximize();
            tryCompare(appDelegate, "state", "maximized");

            mousePress(panel);
            mouseMove(shell, shell.width/2, shell.height/2);
            mouseRelease(shell);

            tryCompare(appDelegate, "state", "normal");
        }

        function test_fullShellModeHasNoInitialGreeter() {
            setLightDMMockMode("single-pin");
            shellLoader.mode = "full-shell";
            loadShell("phone");
            shell.usageScenario = "phone";
            waitForRendering(shell);

            var greeter = findChild(shell, "greeter");
            verify(!greeter.shown);
            verify(!greeter.locked);

            showGreeter();

            verify(greeter.shown);
            verify(greeter.locked);
        }
    }
}
