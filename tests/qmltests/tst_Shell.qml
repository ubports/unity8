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
import LightDMController 0.1
import LightDM.FullLightDM 0.1 as LightDM
import SessionBroadcast 0.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
import Unity.ApplicationMenu 0.1
import Unity.Connectivity 0.1
import Unity.Indicators 0.1
import Unity.Notifications 1.0
import Unity.Launcher 0.1
import Unity.Test 0.1
import Powerd 0.1
import Wizard 0.1 as Wizard
import Utils 0.1
import Unity.Indicators 0.1 as Indicators

import "../../qml"
import "../../qml/Components"
import "../../qml/Components/PanelState"
import "Stage"

Rectangle {
    id: root
    color: "grey"
    width: units.gu(100) + controls.width
    height: units.gu(71)

    Component.onCompleted: {
        // must set the mock mode before loading the Shell
        LightDMController.userMode = "single";
        shellLoader.active = true;
    }

    ApplicationMenuDataLoader {
        id: appMenuData
    }

    property var shell: shellLoader.item ? shellLoader.item : null
    onShellChanged: {
        if (shell) {
            topLevelSurfaceList = testCase.findInvisibleChild(shell, "topLevelSurfaceList");
            appMenuData.surfaceManager = testCase.findInvisibleChild(shell, "surfaceManager");
        } else {
            topLevelSurfaceList = null;
            appMenuData.surfaceManager = null;
        }
    }

    property var topLevelSurfaceList: null

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
                    objectName: "shell"
                    usageScenario: usageScenarioSelector.model[usageScenarioSelector.selectedIndex]
                    nativeWidth: width
                    nativeHeight: height
                    orientation: shellLoader.shellOrientation
                    orientations: Orientations {
                        native_: shellLoader.nativeOrientation
                        primary: shellLoader.primaryOrientation
                    }
                    mode: shellLoader.mode
                    hasTouchscreen: true
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
                    Button {
                        text: "Print focused"
                        activeFocusOnPress: false
                        onClicked: {
                            var childs = new Array(0);
                            childs.push(shellLoader.item)
                            while (childs.length > 0) {
                                if (childs[0].activeFocus && childs[0].focus && childs[0].objectName != "shell") {
                                    console.log("Active focus is on item:", childs[0]);
                                    return;
                                }
                                for (var i in childs[0].children) {
                                    childs.push(childs[0].children[i])
                                }
                                childs.splice(0, 1);
                            }
                            console.log("No active focused item found within shell.")
                        }
                    }
                }
                Label {
                    text: "LightDM mock mode"
                }

                ListItem.ItemSelector {
                    anchors { left: parent.left; right: parent.right }
                    activeFocusOnPress: false
                    model: ["single", "single-passphrase", "single-pin", "full"]
                    onSelectedIndexChanged: {
                        testCase.tearDown();
                        LightDMController.userMode = model[selectedIndex];
                        shellLoader.active = true;
                    }
                }
                Label {
                    text: "Size"
                }

                ListItem.ItemSelector {
                    id: sizeSelector
                    anchors { left: parent.left; right: parent.right }
                    activeFocusOnPress: false
                    model: ["phone", "tablet", "desktop"]
                    onSelectedIndexChanged: {
                        shellLoader.state = model[selectedIndex];
                    }
                }
                Label {
                    text: "Usage scenario"
                }

                ListItem.ItemSelector {
                    id: usageScenarioSelector
                    anchors { left: parent.left; right: parent.right }
                    activeFocusOnPress: false
                    model: ["phone", "tablet", "desktop"]
                }
                MouseTouchEmulationCheckbox {
                    id: mouseEmulation
                    checked: true
                }
                Label {
                    text: "Ctrl key as"
                }

                ListItem.ItemSelector {
                    id: ctrlModifier
                    anchors { left: parent.left; right: parent.right }
                    activeFocusOnPress: false
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
                    activeFocusOnPress: false
                    onClicked: {
                        for (var i = 0; i < ApplicationManager.availableApplications.length; i++) {
                            var appId = ApplicationManager.availableApplications[i];
                            ApplicationManager.startApplication(appId)
                        }
                    }
                }

                Repeater {
                    id: appCheckBoxRepeater
                    model: ApplicationManager.availableApplications
                    ApplicationCheckBox {
                        appId: modelData
                    }
                }

                Label { text: "Focused Application"; font.bold: true }

                Row {
                    CheckBox {
                        id: fullscreenAppCheck
                        activeFocusOnPress: false
                        activeFocusOnTab: false

                        onTriggered: {
                            if (!topLevelSurfaceList.focusedWindow) return;
                            if (topLevelSurfaceList.focusedWindow.state == Mir.FullscreenState) {
                                topLevelSurfaceList.focusedWindow.requestState(Mir.RestoredState);
                            } else {
                                topLevelSurfaceList.focusedWindow.requestState(Mir.FullscreenState);
                            }
                        }

                        Binding {
                            target: fullscreenAppCheck
                            when: topLevelSurfaceList && topLevelSurfaceList.focusedWindow
                            property: "checked"
                            value: topLevelSurfaceList.focusedWindow.state === Mir.FullscreenState
                        }
                    }
                    Label {
                        text: "Fullscreen"
                    }
                }

                Row {
                    CheckBox {
                        id: chromeAppCheck
                        activeFocusOnPress: false
                        activeFocusOnTab: false

                        onTriggered: {
                            if (!topLevelSurfaceList.focusedWindow || !topLevelSurfaceList.focusedWindow.surface) return;
                            var surface = topLevelSurfaceList.focusedWindow.surface;
                            if (surface.shellChrome == Mir.LowChrome) {
                                surface.setShellChrome(Mir.NormalChrome);
                            } else {
                                surface.setShellChrome(Mir.LowChrome);
                            }
                        }

                        Binding {
                            target: chromeAppCheck
                            when: topLevelSurfaceList && topLevelSurfaceList.focusedWindow !== null && topLevelSurfaceList.focusedWindow.surface !== null
                            property: "checked"
                            value: topLevelSurfaceList.focusedWindow.surface &&
                                   topLevelSurfaceList.focusedWindow.surface.shellChrome === Mir.LowChrome
                        }
                    }
                    Label {
                        text: "Low Chrome"
                    }
                }

                Button {
                    text: "Toggle input method"
                    width: parent.width
                    activeFocusOnPress: false
                    onClicked: {
                        testCase.ensureInputMethodSurface();
                        var inputMethod = root.topLevelSurfaceList.inputMethodSurface;
                        if (inputMethod.visible) {
                            inputMethod.requestState(Mir.HiddenState);
                        } else {
                            inputMethod.requestState(Mir.RestoredState);
                        }
                    }
                }

                Label {
                    text: "Shell Mode"
                }
                ListItem.ItemSelector {
                    id: shellModeSelector
                    anchors { left: parent.left; right: parent.right }
                    activeFocusOnPress: false
                    model: ["full-greeter", "greeter", "shell"]
                    property bool guard: false
                    onSelectedIndexChanged: {
                        if (guard) return;
                        guard = true;
                        testCase.tearDown();
                        shellLoader.mode = model[selectedIndex];
                        shellLoader.active = true;
                        guard = false;
                    }
                    Connections {
                        target: shellLoader
                        onModeChanged: {
                            if (shellModeSelector.guard) {
                                return;
                            }
                            shellModeSelector.guard = true;
                            for (var i = 0; i < 3; i++) {
                                if (shellModeSelector.model[i] === shellLoader.mode) {
                                    shellModeSelector.selectedIndex = i;
                                    return;
                                }
                            }
                            shellModeSelector.guard = false;
                        }
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
        id: broadcastUrlSpy
        target: SessionBroadcast
        signalName: "startUrl"
    }

    SignalSpy {
        id: broadcastHomeSpy
        target: SessionBroadcast
        signalName: "showHome"
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

    StageTestCase {
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
            waitForRendering(shell);
            mouseEmulation.checked = true;
            tryCompare(shell, "waitingOnGreeter", false); // make sure greeter didn't leave us in disabled state
            tearDown();
            WindowStateStorage.clear();
        }

        function loadShell(formFactor) {
            shellLoader.state = formFactor;
            shellLoader.active = true;
            tryCompare(shellLoader, "status", Loader.Ready);
            removeTimeConstraintsFromSwipeAreas(shellLoader.item);
            tryCompare(shell, "waitingOnGreeter", false); // reset by greeter when ready

            sessionSpy.target = findChild(shell, "greeter")
            dashCommunicatorSpy.target = findInvisibleChild(shell, "dashCommunicator");

            var launcher = findChild(shell, "launcher");
            launcherShowDashHomeSpy.target = launcher;

            var panel = findChild(launcher, "launcherPanel");
            verify(!!panel);

            panel.dismissTimer = fakeDismissTimer;

            waitForGreeterToStabilize();

            // from StageTestCase
            topLevelSurfaceList = findInvisibleChild(shell, "topLevelSurfaceList");
            verify(topLevelSurfaceList);
            stage = findChild(shell, "stage");
        }

        function loadDesktopShellWithApps() {
            loadShell("desktop");
            waitForRendering(shell)
            shell.usageScenario = "desktop"
            waitForRendering(shell)
            var app0 = ApplicationManager.startApplication("unity8-dash")
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

            var loginList = findChild(greeter, "loginList", 0 /* timeout */);
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

            LightDMController.reset();
            setLightDMMockMode("single"); // these tests default to "single"

            AccountsService.demoEdges = false;
            AccountsService.demoEdgesCompleted = [];
            AccountsService.backgroundFile = "";
            Wizard.System.wizardEnabled = false;
            shellLoader.mode = "full-greeter";

            // kill all (fake) running apps
            killApps();

            unlockAllModemsSpy.clear()
            LightDM.Greeter.authenticate(""); // reset greeter

            sessionSpy.clear();
            broadcastUrlSpy.clear();
            broadcastHomeSpy.clear();

            GSettingsController.setLifecycleExemptAppids([]);
            GSettingsController.setPictureUri("");
        }

        function ensureInputMethodSurface() {
            var surfaceManager = findInvisibleChild(shell, "surfaceManager");
            verify(surfaceManager);
            surfaceManager.createInputMethodSurface();

            tryCompareFunction(function() { return root.topLevelSurfaceList.inputMethodSurface !== null }, true);
        }

        function test_snapDecisionDismissalReturnsFocus() {
            loadShell("phone");
            swipeAwayGreeter();
            var notifications = findChild(shell, "notificationList");
            var appDelegate = startApplication("camera-app");

            var appSurface = appDelegate.surface;
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
                icon: Qt.resolvedUrl("../graphics/avatars/funky.png"),
                secondaryIcon: Qt.resolvedUrl("../graphics/applicationIcons/facebook.png"),
                actions: [{ id: "ok_id", label: "Ok"},
                    { id: "cancel_id", label: "Cancel"},
                    { id: "notreally_id", label: "Not really"},
                    { id: "noway_id", label: "messages:No way"},
                    { id: "nada_id", label: "messages:Nada"}]
            }

            mockNotificationsModel.append(n)
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

        function test_greeterStartsCorrectSession() {
            loadShell("desktop");
            setLightDMMockMode("full");

            LightDMController.sessionMode = "full"
            LightDMController.numSessions = LightDMController.numAvailableSessions;
            var greeter = findChild(shell, "greeter");
            var view = findChild(greeter, "WideView");
            verify(view, "This test requires WideView to be loaded");

            var loginList = findChild(view, "loginList");

            compare(view.sessionToStart, greeter.sessionToStart());

            // Ensure another session can actually be selected
            compare(LightDMController.numSessions > 1, true);
            loginList.currentSession = LightDM.Sessions.data(1, LightDM.SessionRoles.KeyRole);

            compare(view.sessionToStart, greeter.sessionToStart());

        }


        function swipeAwayGreeter() {
            var greeter = findChild(shell, "greeter");

            if (!greeter.shown) {
                console.log("Greeter not shown. Not swiping.");
                return;
            }

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
                var key = Qt.Key_Down;
                if (userlist.currentIndex > i) {
                    next = userlist.currentIndex - 1
                    key = Qt.Key_Up;
                }
                keyPress(key);
                tryCompare(userlist, "currentIndex", next)
            }
            tryCompare(userlist, "movingInternally", false);
            tryCompare(shell, "waitingOnGreeter", false); // wait for PAM to settle
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

            var promptButton = findChild(greeter, "promptButton");
            tryCompare(promptButton, "visible", isButton);

            var promptField = findChild(greeter, "promptField");
            tryCompare(promptField, "visible", !isButton);

            mouseClick(promptButton);
        }

        function confirmLoggedIn(loggedIn) {
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "shown", loggedIn ? false : true);
            verify(loggedIn ? sessionSpy.count > 0 : sessionSpy.count === 0);
        }

        function setLightDMMockMode(mode) {
            LightDMController.userMode = mode;
        }

        function test_showInputMethod() {
            loadShell("phone");
            swipeAwayGreeter();
            ensureInputMethodSurface();

            var item = findChild(shell, "inputMethod");
            var surface = topLevelSurfaceList.inputMethodSurface;

            surface.requestState(Mir.MinimizedState);
            tryCompare(item, "visible", false);

            surface.requestState(Mir.RestoredState);
            tryCompare(item, "visible", true);

            surface.requestState(Mir.MinimizedState);
            tryCompare(item, "visible", false);

            surface.requestState(Mir.MaximizedState);
            tryCompare(item, "visible", true);

            surface.requestState(Mir.MinimizedState);
            tryCompare(item, "visible", false);
        }

        function test_surfaceLosesActiveFocusWhilePanelIsOpen() {
            loadShell("phone");
            swipeAwayGreeter();
            var appDelegate = startApplication("dialer-app");
            var appSurface = appDelegate.surface;
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

            var appDelegate = startApplication("webbrowser-app");

            tryCompare(appDelegate.surface, "activeFocus", true);
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
            launcher.pushEdge(EdgeBarrierSettings.pushThreshold * .8);

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
            swipeFromLeftEdge(units.gu(15));

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

        function test_greeterShownAgainHidesIndicators() {
            // Regression test for https://launchpad.net/bugs/1595569

            loadShell("phone");
            showIndicators();
            showGreeter();

            var indicators = findChild(shell, "indicators");
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

            tryCompare(topLevelSurfaceList, "count", 0);
            compare(wizard.shown, true);

            // And make sure we stop when some surface shows app
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

        function test_customBackground() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);

            var wallpaperResolver = findInvisibleChild(shell, "wallpaperResolver");
            var greeter = findChild(shell, "greeter");
            verify(!greeter.hasCustomBackground);
            compare(wallpaperResolver.background, wallpaperResolver.defaultBackground);

            AccountsService.backgroundFile = Qt.resolvedUrl("../graphics/applicationIcons/dash.png");
            tryCompare(greeter, "hasCustomBackground", true);
            compare(wallpaperResolver.background, AccountsService.backgroundFile);
        }

        function test_cachedBackground() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);

            var greeter = findChild(shell, "greeter");
            verify(!greeter.hasCustomBackground);
            compare(greeter.background.toString().indexOf("image://unity8imagecache/file:///"), 0);
            verify(greeter.background.toString().indexOf("?name=wallpaper") > 0);
        }

        function test_tapOnRightEdgeReachesApplicationSurface() {
            loadShell("phone");
            swipeAwayGreeter();

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("unity8-dash")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            var topmostSpreadDelegate = findChild(shell, "appDelegate_" + topLevelSurfaceList.idAt(0));
            verify(topmostSpreadDelegate);

            waitUntilFocusedApplicationIsShowingItsSurface();

            var topmostSurfaceItem = findChild(topmostSpreadDelegate, "surfaceItem");
            verify(topmostSurfaceItem);

            var rightEdgeDragArea = findChild(shell, "rightEdgeDragArea");
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

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("unity8-dash")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            var topmostSpreadDelegate = findChild(shell, "appDelegate_" + topLevelSurfaceList.idAt(0));
            var topmostSurfaceItem = findChild(topmostSpreadDelegate, "surfaceItem");
            var rightEdgeDragArea = findChild(shell, "rightEdgeDragArea");

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
            var spreadDelegate = findChild(shell, "appDelegate_" + topLevelSurfaceList.idAt(0));
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
            tryCompare(stage, "state", "spread");
        }

        function test_physicalHomeKeyPressDoesNothingWithActiveGreeter() {
            loadShell("phone");

            var windowInputMonitor = findInvisibleChild(shell, "windowInputMonitor");
            var coverPage = findChild(shell, "coverPage");

            windowInputMonitor.homeKeyActivated();
            verify(coverPage.shown);
        }

        function test_physicalHomeKeyPressOpensDrawer() {
            loadShell("phone");
            swipeAwayGreeter();

            var windowInputMonitor = findInvisibleChild(shell, "windowInputMonitor");
            windowInputMonitor.homeKeyActivated();

            var launcher = findChild(shell, "launcher");
            tryCompare(launcher, "drawerShown", true);
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
                var passwordInput = findChild(greeter, "promptField");
                tryCompare(passwordInput, "focus", true)
            }
        }

        function test_manualLoginFlow() {
            LightDMController.showManualLoginHint = true;
            setLightDMMockMode("full");
            loadShell("desktop");

            var i = selectUser("*other");
            var greeter = findChild(shell, "greeter");
            var username = findChild(greeter, "username" + i);
            var promptField = findChild(greeter, "promptField");
            var promptHint = findChild(greeter, "promptHint");

            compare(username.text, "Login");
            compare(promptHint.text, "Username");

            tryCompare(promptField, "activeFocus", true);
            typeString("has-password");
            keyClick(Qt.Key_Enter);

            promptHint = findChild(greeter, "promptHint");
            tryCompare(username, "text", "has-password");
            tryCompare(promptHint, "text", "Passphrase");

            typeString("password");
            keyClick(Qt.Key_Enter);

            confirmLoggedIn(true);
        }

        function test_terminalShortcut() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            // not running, should start
            keyClick(Qt.Key_T, Qt.ControlModifier|Qt.AltModifier);
            tryCompare(ApplicationManager, "focusedApplicationId", "ubuntu-terminal-app");

            // start something else
            ApplicationManager.startApplication("dialer-app");
            tryCompare(ApplicationManager, "focusedApplicationId", "dialer-app");

            // terminal running in background, should get focused
            keyClick(Qt.Key_T, Qt.ControlModifier|Qt.AltModifier);
            tryCompare(ApplicationManager, "focusedApplicationId", "ubuntu-terminal-app");
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

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("unity8-dash")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

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

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("unity8-dash")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

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

            var stage = findChild(shell, "stage");
            verify(stage !== null)

            var spread = findChild(shell, "spreadItem");
            verify(spread !== null)

            // remember the focused appId
            var focused = ApplicationManager.get(ApplicationManager.findApplication(ApplicationManager.focusedApplicationId));

            tryCompare(stage, "state", "windowed")

            // Just press Alt, make sure the spread comes up
            keyPress(Qt.Key_Alt);
            keyClick(Qt.Key_Tab);
            tryCompare(stage, "state", "spread")
            tryCompare(spread, "highlightedIndex", 1)
            waitForRendering(shell)

            // Now press and hold Tab, make sure the highlight moves all the way but stops at the last one
            // We can't simulate a pressed key with keyPress() currently, so let's inject the events
            // at API level. Jump for 10 times, verify that it's still at the last one and didn't wrap around.
            for (var i = 0; i < 10; i++) {
                spread.selectNext(true); // true == isAutoRepeat
                wait(0); // Trigger the event loop to make sure all the things happen
            }
            tryCompare(spread, "highlightedIndex", 6)

            // Now release it once, and verify that it does wrap around with an additional Tab press
            keyRelease(Qt.Key_Tab);
            keyClick(Qt.Key_Tab);
            tryCompare(spread, "highlightedIndex", 0)

            // Release control, check if spread disappears
            keyRelease(Qt.Key_Alt)
            tryCompare(stage, "state", "windowed")

            // Make sure that after wrapping around once, we have the same one focused as at the beginning
            var focusedAppSurface = focused.surfaceList.get(0);
            verify(focusedAppSurface);
            tryCompare(focusedAppSurface, "activeFocus", true)
        }

        function test_altBackTabNavigation() {
            loadDesktopShellWithApps();

            var spreadItem = findChild(shell, "spreadItem");
            verify(spreadItem !== null);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);
            tryCompare(spreadItem, "highlightedIndex", 1);

            keyClick(Qt.Key_Tab);
            tryCompare(spreadItem, "highlightedIndex", 2);

            keyClick(Qt.Key_Tab);
            tryCompare(spreadItem, "highlightedIndex", 3);

            keyClick(Qt.Key_Tab);
            tryCompare(spreadItem, "highlightedIndex", 4);

            keyClick(Qt.Key_Backtab);
            tryCompare(spreadItem, "highlightedIndex", 3);

            keyClick(Qt.Key_Backtab);
            tryCompare(spreadItem, "highlightedIndex", 2);

            keyClick(Qt.Key_Backtab);
            tryCompare(spreadItem, "highlightedIndex", 1);

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

            var appRepeater = findInvisibleChild(shell, "appRepeater");
            verify(appRepeater !== null);

            var spreadItem = findChild(shell, "spreadItem");
            verify(spreadItem !== null);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);

            var surfaceId = topLevelSurfaceList.idAt(2);
            var spreadDelegate2 = appRepeater.itemAt(2);
            var closeMouseArea = findChild(spreadDelegate2, "closeMouseArea");

            // Move the mosue over tile 2 and verify the close button becomes visible
            var x = 0;
            var y = shell.height * .5;
            mouseMove(shell, x, y)
            while (spreadItem.highlightedIndex !== 2 && x <= 4000) {
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
            var spreadItem = findChild(stage, "spreadItem");
//            waitForRendering(spread)

            var appRepeater = findInvisibleChild(shell, "appRepeater");
            verify(appRepeater !== null);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);

            var surface = topLevelSurfaceList.surfaceAt(2);
            var spreadDelegate2 = appRepeater.itemAt(2);
            var decoratedWindow = findChild(spreadDelegate2, "decoratedWindow");

            tryCompare(stage, "state", "spread");

            // Move the mouse over tile 2 and verify the highlight becomes visible
            var x = 0;
            var y = shell.height * (data.tileInfo ? .9 : 0.5)
            mouseMove(shell, x, y)
            while (spreadItem.highlightedIndex !== 2 && x <= 4000) {
                x+=10;
                mouseMove(shell, x, y)
                wait(0); // spin the loop so bindings get evaluated
            }
            tryCompare(decoratedWindow, "showHighlight", true);

            // Click the tile
            mouseClick(decoratedWindow, units.gu(2), decoratedWindow.height / 2)

            // Verify that we left the spread and app2 is the focused one now
            tryCompare(stage, "state", "windowed");
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

        function test_focusAppFromLauncherExitsSpread_data() {
            return [
                {tag: "autohide launcher", launcherLocked: false },
                {tag: "locked launcher", launcherLocked: true }
            ]
        }

        function test_focusAppFromLauncherExitsSpread(data) {
            loadDesktopShellWithApps()
            var launcher = findChild(shell, "launcher");
            var stage = findChild(shell, "stage");
            var app1 = findChild(launcher, "launcherDelegate0");

            GSettingsController.setAutohideLauncher(!data.launcherLocked);
            waitForRendering(shell);

            keyPress(Qt.Key_Alt)
            keyClick(Qt.Key_Tab);

            tryCompare(stage, "state", "spread")

            if (!data.launcherLocked) {
                revealLauncherByEdgePushWithMouse();
                tryCompare(launcher, "x", 0);
                mouseMove(app1, app1.width / 2, app1.height / 2)
                waitForRendering(shell)
            }

            mouseClick(app1, app1.width / 2, app1.height / 2)
            if (!data.launcherLocked) {
                tryCompare(launcher, "state", "")
            }
            tryCompare(stage, "state", "windowed")

            tryCompare(ApplicationManager, "focusedApplicationId", "dialer-app")

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
            tryCompare(PanelState, "decorationsVisible", false)

            mouseClick(maximizeButton, maximizeButton.width / 2, maximizeButton.height / 2);
            tryCompare(appDelegate, "state", "maximized");
            tryCompare(PanelState, "decorationsVisible", true)

            ApplicationManager.stopApplication(application.appId);
            tryCompare(PanelState, "decorationsVisible", false)

            // wait until all zombie surfaces are gone. As MirSurfaceItems hold references over them.
            // They won't be gone until those surface items are destroyed.
            tryCompareFunction(function() { return application.surfaceList.count }, 0);

            ApplicationManager.startApplication(application.appId);
            tryCompare(PanelState, "decorationsVisible", true)
        }

        function test_newAppHasValidGeometry() {
            loadDesktopShellWithApps();
            var appRepeater = findChild(shell, "appRepeater");
            var appDelegate = appRepeater.itemAt(0);

            // Make sure windows are at 0,0 or greater and they have a size that's > 0
            compare(appDelegate.normalX >= 0, true)
            compare(appDelegate.normalY >= 0, true)
            compare(appDelegate.normalWidth > 0, true)
            compare(appDelegate.normalHeight > 0, true)
        }

        // bug http://pad.lv/1431566
        function test_switchToStagedHidesPanelButtons() {
            loadDesktopShellWithApps();
            var appRepeater = findChild(shell, "appRepeater")
            var appDelegate = appRepeater.itemAt(0);
            var panelButtons = findChild(shell, "panelWindowControlButtons")
            verify(panelButtons)

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
            if (data.usageScenario === "tablet") {
                var app1Delegate = findChild(shell, "appDelegate_" + app1SurfaceId);
                compare(app1Delegate.stage, ApplicationInfoInterface.MainStage);

                var app2Delegate = findChild(shell, "appDelegate_" + app2SurfaceId);
                compare(app2Delegate.stage, ApplicationInfoInterface.MainStage);
            }
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
            if (data.usageScenario === "tablet") {
                var app1Delegate = findChild(shell, "appDelegate_" + app1SurfaceId);
                compare(app1Delegate.stage, ApplicationInfoInterface.MainStage);

                var app2Delegate = findChild(shell, "appDelegate_" + app2SurfaceId);
                compare(app2Delegate.stage, ApplicationInfoInterface.MainStage);
            }

            var app1Surface = app1.surfaceList.get(0);
            verify(app1Surface);

            verify(!app1Surface.activeFocus);

            // Make sure app1 is exempt with a requested suspend
            verify(app1.exemptFromLifecycle);
            compare(app1.requestedState, ApplicationInfoInterface.RequestedSuspended);
        }

        function test_switchToStagedForcesLegacyAppClosing_data() {
            return [
                {tag: "forceClose", replug: false, tabletMode: false, screenSize: Qt.size(units.gu(20), units.gu(40)) },
                {tag: "replug", replug: true, tabletMode: false, screenSize: Qt.size(units.gu(20), units.gu(40)) },
                {tag: "forceClose+tablet", replug: false, tabletMode: true, screenSize: Qt.size(units.gu(90), units.gu(65)) },
                {tag: "replug+tablet", replug: true, tabletMode: true, screenSize: Qt.size(units.gu(90), units.gu(65)) }
            ];
        }

        function test_switchToStagedForcesLegacyAppClosing(data) {
            loadShell("desktop")
            shell.usageScenario = "desktop"
            waitForRendering(shell);

            // setup some screen size
            var dialogs = findChild(root, "dialogs");
            verify(dialogs);
            dialogs.screenSize = data.screenSize;

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

            // The popup must appear now, unless in "tablet" mode
            popup = findChild(root, "modeSwitchWarningDialog");
            compare(popup !== null, !data.tabletMode);

            if (data.replug || data.tabletMode) {
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

            if (data.replug || data.tabletMode) {
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
            waitForRendering(shell);
            GSettingsController.setAutohideLauncher(!data.launcherLocked);
            waitForRendering(shell);

            var stage = findChild(shell, "stage");
            var launcher = findChild(shell, "launcher");
            var launcherPanel = findChild(launcher, "launcherPanel");
            var firstAppInLauncher = LauncherModel.get(0).appId;
            compare(launcher.state, data.launcherLocked ? "visible": "");
            compare(launcherPanel.highlightIndex, -2);

            // Use Super + Tab Tab to cycle to the first entry in the launcher
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
            tryCompare(launcher, "state", "drawer");
            tryCompare(launcherPanel, "highlightIndex", -2);
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
            var launcherPanel = findChild(launcher, "launcherPanel");

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("music-app");
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);
            var appDelegate = findChild(appContainer, "appDelegate_" + appSurfaceId);
            appDelegate.maximize();
            tryCompare(appDelegate, "visuallyMaximized", true);
            waitForRendering(shell);

            GSettingsController.setAutohideLauncher(true);
            tryCompare(launcherPanel, "x", -launcher.panelWidth)
            waitForRendering(shell)
            var hiddenSize = appDelegate.width;

            GSettingsController.setAutohideLauncher(false);
            tryCompare(launcherPanel, "x", 0)
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

            app.surfaceList.get(0).requestState(Mir.FullscreenState);

            tryCompare(launcher, "lockedVisible", false);
        }


        function test_inputEventsOnEdgesEndUpInAppSurface_data() {
            return [
                { tag: "phone" },
                { tag: "tablet" },
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

            var appRepeater = findChild(shell, "appRepeater");
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

        function test_background_data() {
            return [
                {tag: "color",
                 accounts: Qt.resolvedUrl("data:image/svg+xml,<svg><rect width='100%' height='100%' fill='#dd4814'/></svg>"),
                 gsettings: "",
                 output: Qt.resolvedUrl("data:image/svg+xml,<svg><rect width='100%' height='100%' fill='#dd4814'/></svg>")},

                {tag: "empty", accounts: "", gsettings: "", output: "defaultBackground"},

                {tag: "as-specified",
                 accounts: Qt.resolvedUrl("../data/unity/backgrounds/blue.png"),
                 gsettings: "",
                 output: Qt.resolvedUrl("../data/unity/backgrounds/blue.png")},

                {tag: "gs-specified",
                 accounts: "",
                 gsettings: Qt.resolvedUrl("../data/unity/backgrounds/red.png"),
                 output: Qt.resolvedUrl("../data/unity/backgrounds/red.png")},

                {tag: "both-specified",
                 accounts: Qt.resolvedUrl("../data/unity/backgrounds/blue.png"),
                 gsettings: Qt.resolvedUrl("../data/unity/backgrounds/red.png"),
                 output: Qt.resolvedUrl("../data/unity/backgrounds/blue.png")},

                {tag: "invalid-as",
                 accounts: Qt.resolvedUrl("../data/unity/backgrounds/nope.png"),
                 gsettings: Qt.resolvedUrl("../data/unity/backgrounds/red.png"),
                 output: Qt.resolvedUrl("../data/unity/backgrounds/red.png")},

                {tag: "invalid-both",
                 accounts: Qt.resolvedUrl("../data/unity/backgrounds/nope.png"),
                 gsettings: Qt.resolvedUrl("../data/unity/backgrounds/stillnope.png"),
                 output: "defaultBackground"},
            ]
        }
        function test_background(data) {
            loadShell("phone");
            shell.usageScenario = "phone";
            waitForRendering(shell);

            AccountsService.backgroundFile = data.accounts;
            GSettingsController.setPictureUri(data.gsettings);

            var wallpaperResolver = findChild(shell, "wallpaperResolver");
            if (data.output === "defaultBackground") {
                tryCompare(wallpaperResolver, "background", wallpaperResolver.defaultBackground);
                verify(!wallpaperResolver.hasCustomBackground);
            } else {
                tryCompare(wallpaperResolver, "background", data.output);
                verify(wallpaperResolver.hasCustomBackground);
            }
        }

        function test_greeterModeBroadcastsApp() {
            setLightDMMockMode("single-pin");
            shellLoader.mode = "greeter";
            loadShell("phone");
            shell.usageScenario = "phone";
            waitForRendering(shell);

            dragLauncherIntoView();
            var appIcon = findChild(shell, "launcherDelegate0")
            tap(appIcon);

            tryCompare(broadcastUrlSpy, "count", 1);
            compare(broadcastUrlSpy.signalArguments[0][0], "application:///" + appIcon.appId + ".desktop");
            compare(ApplicationManager.count, 0); // confirm no app is open, we didn't start new app

            var coverPage = findChild(shell, "coverPage");
            tryCompare(coverPage, "showProgress", 0);
        }

        function test_greeterModeBroadcastsHome() {
            setLightDMMockMode("single-pin");
            shellLoader.mode = "greeter";
            loadShell("phone");
            shell.usageScenario = "phone";
            waitForRendering(shell);

            var gallerySurfaceId = topLevelSurfaceList.nextId;
            var galleryApp = ApplicationManager.startApplication("gallery-app");
            waitUntilAppWindowIsFullyLoaded(gallerySurfaceId);
            compare(topLevelSurfaceList.applicationAt(0).appId, "gallery-app");

            dragLauncherIntoView();
            tap(findChild(shell, "buttonShowDashHome"));

            tryCompare(broadcastHomeSpy, "count", 1);
            compare(topLevelSurfaceList.applicationAt(0).appId, "gallery-app"); // confirm we didn't raise dash

            var coverPage = findChild(shell, "coverPage");
            tryCompare(coverPage, "showProgress", 0);
        }

        function test_greeterModeDispatchesURL() {
            setLightDMMockMode("single-pin");
            shellLoader.mode = "greeter";
            loadShell("phone");
            shell.usageScenario = "phone";
            waitForRendering(shell);

            var urlDispatcher = findInvisibleChild(shell, "urlDispatcher");
            verify(urlDispatcher.active);
            urlDispatcher.urlRequested("test:"); // force signal emission

            tryCompare(broadcastUrlSpy, "count", 1);
            compare(broadcastUrlSpy.signalArguments[0][0], "test:");
            compare(ApplicationManager.count, 0); // confirm no app is open, we didn't start new app

            var coverPage = findChild(shell, "coverPage");
            tryCompare(coverPage, "showProgress", 0);
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

            // try to create a prompt surface, verify it also has the same keymap
            app.createPromptSurface();
            var promptSurface = app.promptSurfaceList.get(0);
            verify(promptSurface);
            tryCompare(appSurface, "keymap", promptSurface.keymap);
            // ... and that the controller's surface keymap is also the same
            tryCompare(topLevelSurfaceList.focusedWindow.surface, "keymap", "sk");
            app.promptSurfaceList.get(0).close();

            // switch to next keymap, should go to "cz+qwerty"
            keyClick(Qt.Key_Space, Qt.MetaModifier);
            tryCompare(appSurface, "keymap", "cz+qwerty");

            // switch to next keymap, should go to "fr"
            keyClick(Qt.Key_Space, Qt.MetaModifier);
            tryCompare(appSurface, "keymap", "fr");

            // go to e.g. desktop stage
            shellLoader.state = "desktop";
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

        function test_dragPanelToRestoreMaximizedWindow_data() {
            return [
                        { tag: "with mouse", mouse: true },
                        { tag: "with touch", mouse: false }
                    ]
        }

        function test_dragPanelToRestoreMaximizedWindow(data) {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            var panel = findChild(shell, "windowControlArea");
            verify(panel);

            // start dialer, maximize it
            var appDelegate = startApplication("dialer-app");
            verify(appDelegate);

            var maximizeButton = findChild(appDelegate, "maximizeWindowButton");
            if (data.mouse) {
                mouseClick(maximizeButton);
            } else {
                tap(maximizeButton);
            }

            waitUntilTransitionsEnd(appDelegate);
            tryCompare(appDelegate, "state", "maximized");

            if (data.mouse) {
                mouseMove(panel, panel.width/2, panel.panelHeight/2); // to reveal the menus
                var menuBarLoader = findInvisibleChild(panel, "menuBarLoader");
                verify(menuBarLoader);
                tryCompare(menuBarLoader.item, "visible", true);
                mouseDrag(panel, panel.width/2, panel.height/2, 0, shell.height/3, Qt.LeftButton, Qt.NoModifier, 500);
            } else {
                touchFlick(panel, panel.width/2, panel.panelHeight/2, panel.width/2, shell.height/3);
            }

            tryCompare(appDelegate, "state", "restored");
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

        function test_closeFocusedDelegate_data() {
            return [
                        { tag: "phone" },
                        { tag: "tablet" },
                        { tag: "desktop" }
                    ]
        }

        function test_closeFocusedDelegate(data) {
            loadShell(data.tag);
            shell.usageScenario = data.tag;
            waitForRendering(shell);
            swipeAwayGreeter();

            var app2SurfaceId = topLevelSurfaceList.nextId;
            var app2 = ApplicationManager.startApplication("calendar-app");
            waitUntilAppWindowIsFullyLoaded(app2SurfaceId);

            var app1SurfaceId = topLevelSurfaceList.nextId;
            var app1 = ApplicationManager.startApplication("dialer-app")
            waitUntilAppWindowIsFullyLoaded(app1SurfaceId);

            var countBeforeClose = topLevelSurfaceList.count;

            keyClick(Qt.Key_F4, Qt.AltModifier);

            tryCompare(topLevelSurfaceList, "count", countBeforeClose - 1);
            tryCompareFunction(function() { return ApplicationManager.focusedApplicationId; }, "calendar-app");
        }

        function test_rightEdgePushWithOpenIndicators() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            var stage = findChild(shell, "stage");
            var cursor = findChild(shell, "cursor");
            var indicators = findChild(shell, "indicators");

            // Open indicators
            var touchX = shell.width - units.gu(5);
            touchFlick(shell,
                    touchX /* fromX */, indicators.minimizedPanelHeight * 0.5 /* fromY */,
                    touchX /* toX */, shell.height * 0.9 /* toY */,
                    true /* beginTouch */, true /* endTouch */);
            tryCompare(indicators, "fullyOpened", true);

            // push the right edge
            mouseMove(shell, shell.width -  1, units.gu(10));
            for (var i = 0; i < units.gu(10); i++) {
                cursor.pushedRightBoundary(1, 0);
            }
            tryCompare(stage, "rightEdgePushProgress", 1);
            tryCompare(stage, "state", "spread");
            tryCompare(indicators, "fullyOpened", false);

            mouseMove(shell, shell.width - units.gu(5), units.gu(10));

            tryCompare(stage, "rightEdgePushProgress", 0);
        }

        function test_rightEdgePushOnGreeter() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);

            var stage = findChild(shell, "stage");
            var cursor = findChild(shell, "cursor");

            // push the right edge, but verify it doesn't emit any progress
            mouseMove(shell, shell.width -  1, units.gu(10));
            for (var i = 0; i < units.gu(10); i++) {
                cursor.pushedRightBoundary(1, 0);
                compare(stage.rightEdgePushProgress, 0);
            }
            compare(stage.rightEdgePushProgress, 0);
        }

        function test_oskDisplacesWindow_data() {
            return [
                {tag: "no need to displace", windowHeight: units.gu(10), windowY: units.gu(5), targetDisplacement: units.gu(5), oskEnabled: true},
                {tag: "displace to top", windowHeight: units.gu(50), windowY: units.gu(10), targetDisplacement: PanelState.panelHeight, oskEnabled: true},
                {tag: "osk not on this screen", windowHeight: units.gu(40), windowY: units.gu(10), targetDisplacement: units.gu(10), oskEnabled: false},
            ]
        }

        function test_oskDisplacesWindow(data) {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();
            ensureInputMethodSurface();
            shell.oskEnabled = data.oskEnabled;

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("unity8-dash")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            var oldOSKState = topLevelSurfaceList.inputMethodSurface.state;
            topLevelSurfaceList.inputMethodSurface.requestState(Mir.RestoredState);
            var appRepeater = findChild(shell, "appRepeater");
            var dashAppDelegate = appRepeater.itemAt(0);
            verify(dashAppDelegate);

            dashAppDelegate.windowedHeight = data.windowHeight;
            dashAppDelegate.windowedY = data.windowY;
            topLevelSurfaceList.inputMethodSurface.setInputBounds(Qt.rect(0, 0, 0, 0));
            var initialY = dashAppDelegate.y;
            print("intial", initialY, "panel", PanelState.panelHeight);
            verify(initialY > PanelState.panelHeight);

            topLevelSurfaceList.inputMethodSurface.setInputBounds(Qt.rect(0, root.height / 2, root.width, root.height / 2));
            tryCompare(dashAppDelegate, "y", data.targetDisplacement);

            topLevelSurfaceList.inputMethodSurface.setInputBounds(Qt.rect(0, 0, 0, 0));
            tryCompare(dashAppDelegate, "y", initialY);
            topLevelSurfaceList.inputMethodSurface.requestState(oldOSKState);
        }

        function test_cursorHidingWithFullscreenApp() {
            loadShell("phone");
            shell.usageScenario = "phone";
            waitForRendering(shell);
            swipeAwayGreeter();

            // load some fullscreen app
            var cameraSurfaceId = topLevelSurfaceList.nextId;
            var cameraApp = ApplicationManager.startApplication("camera-app");
            waitUntilAppWindowIsFullyLoaded(cameraSurfaceId);

            var cursor = findChild(shell, "cursor");
            verify(cursor);
            tryCompare(cursor, "opacity", 1);

            // let the timer kick in and verify the cursor got hidden
            wait(3000);
            tryCompare(cursor, "opacity", 0);

            // simulate moving the mouse, check the cursor is visible again
            cursor.mouseMoved();
            tryCompare(cursor, "opacity", 1);

            // let the timer kick in again and verify the cursor got hidden
            wait(3000);
            tryCompare(cursor, "opacity", 0);
        }

        function test_launcherEnabledSetting_data() {
            return [
                {tag: "launcher enabled", enabled: true},
                {tag: "launcher disabled", enabled: false}
            ]
        }

        function test_launcherEnabledSetting(data) {
            loadShell("phone");

            GSettingsController.setEnableLauncher(data.enabled);

            var launcher = findChild(shell, "launcher");
            compare(launcher.available, data.enabled);

            GSettingsController.setEnableLauncher(true);
        }

        function test_indicatorMenuEnabledSetting_data() {
            return [
                {tag: "indicator menu enabled", enabled: true},
                {tag: "indicator menu disabled", enabled: false}
            ]
        }

        function test_indicatorMenuEnabledSetting(data) {
            loadShell("phone");

            GSettingsController.setEnableIndicatorMenu(data.enabled);

            var panel = findChild(shell, "panel");
            compare(panel.indicators.available, data.enabled);

            GSettingsController.setEnableIndicatorMenu(true);
        }

        function test_spreadDisabled_WithSwipe_data() {
            return [
                { tag: "enabled", spreadEnabled: true },
                { tag: "disabled", spreadEnabled: false }
            ];
        }

        function test_spreadDisabled_WithSwipe(data) {
            loadShell("phone");
            swipeAwayGreeter();
            var stage = findChild(shell, "stage");
            stage.spreadEnabled = data.spreadEnabled;

            // Try swiping
            touchFlick(shell, shell.width - 2, shell.height / 2, units.gu(1), shell.height / 2);
            tryCompare(stage, "state", data.spreadEnabled ? "spread" : "staged");
        }

        function test_spreadDisabled_WithEdgePush_data() {
            return [
                { tag: "enabled", spreadEnabled: true },
                { tag: "disabled", spreadEnabled: false }
            ];
        }

        function test_spreadDisabled_WithEdgePush(data) {
            loadShell("phone");
            swipeAwayGreeter();
            var stage = findChild(shell, "stage");
            stage.spreadEnabled = data.spreadEnabled;

            // Try by edge push
            var cursor = findChild(shell, "cursor");
            mouseMove(stage, stage.width -  1, units.gu(10));
            for (var i = 0; i < units.gu(10); i++) {
                cursor.pushedRightBoundary(1, 0);
            }
            mouseMove(stage, stage.width - units.gu(5), units.gu(10));
            tryCompare(stage, "state", data.spreadEnabled ? "spread" : "staged");
        }

        function test_spreadDisabled_WithAltTab_data() {
            return [
                { tag: "enabled", spreadEnabled: true },
                { tag: "disabled", spreadEnabled: false }
            ];
        }

        function test_spreadDisabled_WithAltTab(data) {
            loadShell("phone");
            swipeAwayGreeter();
            var stage = findChild(shell, "stage");
            stage.spreadEnabled = data.spreadEnabled;

            // Try by alt+tab
            keyPress(Qt.Key_Alt);
            keyClick(Qt.Key_Tab);
            tryCompare(stage, "state", data.spreadEnabled ? "spread" : "staged");
            keyRelease(Qt.Key_Alt);
        }

        function test_spreadDisabled_WithSuperW_data() {
            return [
                { tag: "enabled", spreadEnabled: true },
                { tag: "disabled", spreadEnabled: false }
            ];
        }

        function test_spreadDisabled_WithSuperW(data) {
            loadShell("phone");
            swipeAwayGreeter();
            var stage = findChild(shell, "stage");
            stage.spreadEnabled = data.spreadEnabled;

            // Try by Super+W
            keyPress(Qt.Key_W, Qt.MetaModifier, 200);
            tryCompare(stage, "state", data.spreadEnabled ? "spread" : "staged");
            keyRelease(Qt.Key_W, Qt.MetaModifier)
        }

        function test_launcherWindowResizeInteraction()
        {
            loadShell("desktop");
            waitForRendering(shell)
            shell.usageScenario = "desktop"
            waitForRendering(shell)
            swipeAwayGreeter();

            var app1SurfaceId = topLevelSurfaceList.nextId;
            var app1 = ApplicationManager.startApplication("dialer-app")
            waitUntilAppWindowIsFullyLoaded(app1SurfaceId);

            var launcherDelegate1 = findChild(shell, "launcherDelegate1");
            mouseClick(launcherDelegate1, launcherDelegate1.width / 2, launcherDelegate1.height / 2, Qt.RightButton);

            var appDelegate = findChild(shell, "appDelegate_" + app1SurfaceId);
            mouseMove(shell, appDelegate.mapToItem(shell, 0, 0).x, launcherDelegate1.mapToItem(shell, 0, 0).y);

            expectFail("", "Cursor should not change while launcher menu is open");
            tryCompare(Mir, "cursorName", "left_side");
        }

        function test_panelTitleShowsWhenGreeterNotShown_data() {
            return [
                {tag: "phone" },
                {tag: "tablet" },
                {tag: "desktop" }
            ]
        }

        function test_panelTitleShowsWhenGreeterNotShown(data) {
            loadShell(data.tag);

            var panel = findChild(shell, "panel"); verify(panel);
            var panelTitle = findChild(panel, "panelTitle"); verify(panelTitle);
            compare(panelTitle.visible, false, "Panel title should not be visible when greeter is shown");

            swipeAwayGreeter();

            tryCompare(panelTitle, "visible", true, undefined, "Panel title should be visible when greeter not shown");
        }

        function test_fourFingerTapOpensDrawer_data() {
            return [
                        { tag: "1 finger", touchIds: [0], shown: false },
                        { tag: "2 finger", touchIds: [0, 1], shown: false },
                        { tag: "3 finger", touchIds: [0, 1, 2], shown: false },
                        { tag: "4 finger", touchIds: [0, 1, 2, 3], shown: true }
                    ];
        }

        function test_fourFingerTapOpensDrawer(data) {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            var stage = findChild(shell, "stage");
            var drawer = findChild(shell, "drawer")
            verify(stage && drawer);

            multiTouchTap(data.touchIds, stage);

            if (data.shown) { // if shown, try to also hide it by clicking outside
                tryCompareFunction(function() { return drawer.visible; }, true);
                mouseClick(stage, stage.width-10, stage.height/2, undefined, undefined, 100);
            }
            tryCompareFunction(function() { return drawer.visible; }, false);
        }

        function test_restoreFromFullscreen() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("dialer-app")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            // start dialer
            var appContainer = findChild(shell, "appContainer");
            var appDelegate = findChild(appContainer, "appDelegate_" + appSurfaceId);
            verify(appDelegate);
            tryCompare(appDelegate, "state", "normal");

            // now maximize to right
            appDelegate.requestMaximizeRight();
            tryCompare(appDelegate, "state", "maximizedRight");

            // switch to fullscreen
            app.surfaceList.get(0).requestState(Mir.FullscreenState);
            tryCompare(appDelegate, "state", "fullscreen");

            // restore, should go back to maximizedRight, not restored
            appDelegate.requestRestore();
            tryCompare(appDelegate, "state", "maximizedRight");
        }


        function test_closeAppsInSpreadWithQ() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("unity8-dash")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            appSurfaceId = topLevelSurfaceList.nextId;
            app = ApplicationManager.startApplication("dialer-app")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            appSurfaceId = topLevelSurfaceList.nextId;
            app = ApplicationManager.startApplication("calendar-app")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            keyPress(Qt.Key_Alt);
            keyClick(Qt.Key_Tab);

            var stage = findChild(shell, "stage");
            var spread = findChild(stage, "spreadItem");
            var appRepeater = findChild(stage, "appRepeater");

            tryCompare(stage, "state", "spread");

            tryCompare(ApplicationManager, "count", 3);
            tryCompareFunction(function() {return appRepeater.itemAt(spread.highlightedIndex).appId == "dialer-app"}, true);

            // Close one app with Q while in spread
            keyClick(Qt.Key_Q);

            tryCompare(ApplicationManager, "count", 2);

            // Now the dash should be highlighted
            tryCompareFunction(function() {return appRepeater.itemAt(spread.highlightedIndex).appId == "unity8-dash"}, true);

            keyClick(Qt.Key_Tab);
            tryCompareFunction(function() {return appRepeater.itemAt(spread.highlightedIndex).appId == "calendar-app"}, true);

            // close it
            keyClick(Qt.Key_Q);
            tryCompare(ApplicationManager, "count", 1);

            keyRelease(Qt.Key_Alt);

            // Now start the apps again
            appSurfaceId = topLevelSurfaceList.nextId;
            app = ApplicationManager.startApplication("dialer-app");
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            appSurfaceId = topLevelSurfaceList.nextId;
            app = ApplicationManager.startApplication("calendar-app");
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            // First focus the dash so it'll be the leftmost in the spread
            ApplicationManager.requestFocusApplication("unity8-dash");

            keyPress(Qt.Key_Alt);
            keyClick(Qt.Key_Tab);
            tryCompare(stage, "state", "spread");

            // Move to the last one
            keyClick(Qt.Key_Tab);

            // Close the last one, make sure the highlight fixes itself to stick within the list
            tryCompare(spread, "highlightedIndex", ApplicationManager.count - 1);
            var oldHighlighted = spread.highlightedIndex;

            keyClick(Qt.Key_Q);
            tryCompare(spread, "highlightedIndex", oldHighlighted - 1);

            keyRelease(Qt.Key_Alt);

        }

        function test_altTabToMinimizedApp() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("dialer-app")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            // start dialer
            var appContainer = findChild(shell, "appContainer");
            var appDelegate = findChild(appContainer, "appDelegate_" + appSurfaceId);
            verify(appDelegate);
            tryCompare(appDelegate, "state", "normal");

            // minimize dialer
            appDelegate.requestMinimize();
            tryCompare(appDelegate, "state", "minimized");

            // try to bring dialer back from minimized by doing alt-tab
            keyClick(Qt.Key_Tab, Qt.AltModifier);
            tryCompare(appDelegate, "visible", true);
            tryCompare(appDelegate, "focus", true);
            tryCompare(topLevelSurfaceList.focusedWindow, "surface", appDelegate.surface);
            tryCompare(topLevelSurfaceList.applicationAt(0), "appId", "dialer-app");
        }

        function test_touchMenuPosition_data() {
            return [
                        { tag: "launcher locked", lockLauncher: true },
                        { tag: "launcher not locked", lockLauncher: false }
                    ];
        }

        function test_touchMenuPosition(data) {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            var panel = findChild(shell, "panel");
            var launcher = testCase.findChild(shell, "launcher");
            launcher.lockedVisible = data.lockLauncher;
            if (data.lockLauncher) {
                compare(panel.applicationMenus.x, launcher.panelWidth);
            } else {
                compare(panel.applicationMenus.x, 0);
            }
        }

        function test_touchMenuHidesOnLauncherAppDrawer_data() {
            return [
                        { tag: "launcher locked", lockLauncher: true },
                        { tag: "launcher not locked", lockLauncher: false }
                    ];
        }

        function test_touchMenuHidesOnLauncherAppDrawer(data) {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            var panel = findChild(shell, "panel");
            var launcher = testCase.findChild(shell, "launcher");
            launcher.lockedVisible = data.lockLauncher;

            waitForRendering(panel.applicationMenus);

            if (data.lockLauncher) {
                panel.applicationMenus.show();
                tryCompare(panel.applicationMenus, "fullyOpened", true);
                launcher.openDrawer();
            } else {
                tryCompare(launcher, "shown", false);
                panel.applicationMenus.show();
                tryCompare(panel.applicationMenus, "fullyOpened", true);
                launcher.switchToNextState("visible");
            }
            tryCompare(panel.applicationMenus, "fullyClosed", true);
        }

        function test_doubleClickPanelRestoresWindow() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            // start dialer
            var appDelegate = startApplication("dialer-app")
            verify(appDelegate);
            tryCompare(appDelegate, "state", "normal");

            // maximize dialer
            var decoration = findChild(appDelegate, "appWindowDecoration");
            verify(decoration);
            mouseDoubleClickSequence(decoration);
            tryCompare(appDelegate, "state", "maximized");

            // double click the panel
            var panel = findChild(shell, "panel");
            verify(panel);
            mouseDoubleClickSequence(panel, panel.width/2, PanelState.panelHeight/2, Qt.LeftButton, Qt.NoModifier, 300);
            tryCompare(appDelegate, "state", "restored");
        }

        function test_noMenusWithActiveCall() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            // start music-app, maximize it
            var appDelegate = startApplication("music-app")
            verify(appDelegate);
            appDelegate.requestMaximize();

            // move the mouse over panel to reveal the menus
            var panel = findChild(shell, "panel");
            verify(panel);
            mouseMove(panel, panel.width/2, panel.panelHeight/2); // to reveal the menus
            var menuBarLoader = findInvisibleChild(panel, "menuBarLoader");
            verify(menuBarLoader);
            tryCompare(menuBarLoader.item, "visible", true);

            // place a phone call
            callManager.foregroundCall = phoneCall;

            // menu bar should be hidden
            tryCompare(menuBarLoader, "active", false);
            tryCompare(menuBarLoader, "item", null);

            // remove call
            callManager.foregroundCall = null;

            // menu bar should be revealed
            tryCompare(menuBarLoader, "active", true);
            tryCompare(menuBarLoader.item, "visible", true);
        }

        function test_enforceFocusOnStageOnAltTab() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            var appSurfaceId = topLevelSurfaceList.nextId;
            var app = ApplicationManager.startApplication("unity8-dash")
            waitUntilAppWindowIsFullyLoaded(appSurfaceId);

            var appDelegate = startApplication("music-app")
            verify(appDelegate);
            waitForRendering(shell);

            var launcher = findChild(shell, "launcher");
            launcher.focus = true;

            var stage = findChild(shell, "stage");

            var spreadItem = findChild(shell, "spreadItem");

            compare(spreadItem.highlightedIndex, -1);

            keyPress(Qt.Key_Alt);
            keyClick(Qt.Key_Tab);

            tryCompare(spreadItem, "highlightedIndex", 1);
            tryCompare(stage, "focus", true);

            keyClick(Qt.Key_Tab);

            tryCompare(spreadItem, "highlightedIndex", 0);

            keyRelease(Qt.Key_Alt);
        }

        function test_maximizedWindowMenuThenAltTab_data() {
            return [
                { tag: "show spread", showSpread: true },
                { tag: "do not show spread", showSpread: false },
            ];
        }

        function test_maximizedWindowMenuThenAltTab(data) {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            var appDelegate = startApplication("gmail-webapp");
            var appDelegate2 = startApplication("dialer-app");

            tryCompare(appDelegate2.surface, "activeFocus", true);

            var maximizeButton = findChild(appDelegate2, "maximizeWindowButton");
            mouseClick(maximizeButton);
            tryCompare(appDelegate2, "state", "maximized");

            var panel = findChild(shell, "panel");
            var panelMouse = findChild(panel, "windowControlArea");
            mouseMove(panelMouse);
            var panelMenu = findChild(panel, "menuBar");
            var menuBarLoader = findChild(panel, "menuBarLoader");
            mouseMove(panelMenu);
            var panelMenuItem = findChild(panelMenu, "menuBar-item0");
            tryCompare(panelMenuItem, "visible", true);
            Util.waitForBehaviors(shell);
            mouseClick(panelMenuItem);
            var panelMenuItemItem = findChild(panelMenu, "menuBar-item0-menu-item0-actionItem");
            mouseMove(panelMenuItemItem, panelMenuItemItem.width/2, panelMenuItemItem.height/2);
            verify(panelMenuItemItem.activeFocus);
            verify(panelMenuItem.__popup);

            keyPress(Qt.Key_Alt);
            keyClick(Qt.Key_Tab);
            if (data.showSpread) {
                tryCompare(stage, "spreadShown", true);
            }
            tryCompareFunction(function() { return menuBarLoader.active === false; }, true);
            keyRelease(Qt.Key_Alt)

            tryCompare(appDelegate.surface, "activeFocus", true);

            keyPress(Qt.Key_Alt);
            keyClick(Qt.Key_Tab);
            keyRelease(Qt.Key_Alt)

            tryCompare(appDelegate2.surface, "activeFocus", true);
        }

        function test_maximizedWindowAndMenuInPanel() {
            loadShell("desktop");
            shell.usageScenario = "desktop";
            waitForRendering(shell);
            swipeAwayGreeter();

            // start music-app, maximize it
            var appDelegate = startApplication("music-app")
            verify(appDelegate);
            appDelegate.requestMaximize();
            tryCompare(appDelegate, "state", "maximized");

            // move the mouse over panel to reveal the menus
            var panel = findChild(shell, "panel");
            verify(panel);
            mouseMove(panel, panel.width/2, panel.panelHeight/2); // to reveal the menus
            var menuBar = findChild(panel, "menuBar");
            verify(menuBar);
            tryCompare(menuBar, "visible", true);

            // check that the menu popup appears
            var priv = findInvisibleChild(menuBar, "d");
            var menuItem0 = findChild(menuBar, "menuBar-item0");
            verify(menuItem0);
            mouseMove(menuItem0, menuItem0.width/2, menuItem0.height/2, 200);
            tryCompare(menuItem0, "visible", true);
            mouseClick(menuItem0);
            tryCompare(priv, "currentItem", menuItem0);
            tryCompare(priv.currentItem, "popupVisible", true);
        }
    }
}
