/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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
import Unity.Test 0.1
import Powerd 0.1
import Utils 0.1

import "../../qml"

Item {
    id: root
    width: units.gu(140)
    height: units.gu(90)

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    Component.onCompleted: {
        // must set the mock mode before loading the Shell
        LightDM.Greeter.mockMode = "full";
        LightDM.Users.mockMode = "full";

        // ensures apps which are tested decorations are in view.
        WindowStateStorage.geometry = {
            'unity8-dash': Qt.rect(0, units.gu(3), units.gu(50), units.gu(40)),
            'dialer-app': Qt.rect(units.gu(51), units.gu(3), units.gu(50), units.gu(40)),
            'camera-app': Qt.rect(0, units.gu(44), units.gu(50), units.gu(40)),
        }

        shellLoader.active = true;
    }

    QtObject {
        id: applicationArguments

        function hasGeometry() {
            return false
        }

        function width() {
            return 0
        }

        function height() {
            return 0
        }
    }

    Row {
        anchors.fill: parent
        Loader {
            id: shellLoader

            active: false
            width: units.gu(110)
            height: parent.height

            property bool itemDestroyed: false
            sourceComponent: Component {
                Shell {
                    usageMode: "Windowed"
                    property string indicatorProfile: "desktop"

                    Component.onDestruction: {
                        shellLoader.itemDestroyed = true
                    }
                }
            }
        }

        Rectangle {
            color: "white"
            width: units.gu(30)
            height: parent.height

            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                spacing: units.gu(1)
                Button {
                    text: "Show Greeter"
                    onClicked: {
                        if (shellLoader.status !== Loader.Ready)
                            return

                        var greeter = testCase.findChild(shellLoader.item, "greeter")
                        if (!greeter.shown) {
                            greeter.show()
                        }
                    }
                }

                Repeater {
                    id: apps
                    model: ApplicationManager.availableApplications()
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: childrenRect.height

                    Row {
                        id: appColumn
                        enabled: modelData != "unity8-dash"
                        property var application: null

                        Component.onCompleted: {
                            application = ApplicationManager.findApplication(modelData);
                        }

                        Connections {
                            target: ApplicationManager
                            onCountChanged: {
                                appColumn.application = ApplicationManager.findApplication(modelData);
                            }
                        }

                        CheckBox {
                            id: appCheckBox
                            onTriggered: {
                                if (checked) ApplicationManager.startApplication(modelData);
                                else ApplicationManager.stopApplication(modelData);
                            }
                            Binding {
                                target: appCheckBox
                                property: "checked"
                                value: appColumn.application != null
                            }
                        }

                        Label {
                            text: appColumn.application ? appColumn.application.name : modelData
                            color: "black"
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

    UnityTestCase {
        id: testCase
        name: "DesktopShell"
        when: windowShown

        property Item shell: shellLoader.status === Loader.Ready ? shellLoader.item : null

        function init() {
            tryCompare(shell, "enabled", true); // will be enabled when greeter is all ready
            var userList = findChild(shell, "userList");
            tryCompare(userList, "movingInternally", false);
            sessionSpy.clear()
            sessionSpy.target = findChild(shell, "greeter")
            dashCommunicatorSpy.target = findInvisibleChild(shell, "dashCommunicator")
        }

        function cleanup() {
            tryCompare(shell, "enabled", true); // make sure greeter didn't leave us in disabled state

            shellLoader.itemDestroyed = false

            shellLoader.active = false

            tryCompare(shellLoader, "status", Loader.Null)
            tryCompare(shellLoader, "item", null)
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // item might still be alive. So if we set Loader.active back to true
            // again right now we will get the very same Shell instance back. So no reload
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(shellLoader, "itemDestroyed", true)

            // kill all (fake) running apps
            killApps()

            unlockAllModemsSpy.clear()
            AccountsService.demoEdges = false
            LightDM.Greeter.authenticate(""); // reset greeter

            // reload our test subject to get it in a fresh state once again
            shellLoader.active = true

            tryCompare(shellLoader, "status", Loader.Ready)
            removeTimeConstraintsFromDirectionalDragAreas(shellLoader.item)
        }

        function killApps() {
            while (ApplicationManager.count > 1) {
                var appIndex = ApplicationManager.get(0).appId == "unity8-dash" ? 1 : 0
                ApplicationManager.stopApplication(ApplicationManager.get(appIndex).appId)
            }
            compare(ApplicationManager.count, 1)
        }

        function selectIndex(i) {
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
            selectIndex(i)
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

        function swipeFromLeftEdge(swipeLength) {
            var touchStartX = 2
            var touchStartY = shell.height / 2
            touchFlick(shell, touchStartX, touchStartY, swipeLength, touchStartY)
        }

        function waitUntilAppSurfaceShowsUp(appId) {
            var appWindow = findChild(shell, "appWindow_" + appId);
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function startApplication(appId) {
            var app = ApplicationManager.findApplication(appId);
            if (!app) {
                app = ApplicationManager.startApplication(appId);
            }
            verify(app);
            waitUntilAppSurfaceShowsUp(appId);
            verify(app.session.surface);
            return app;
        }

        function test_appFocusSwitch_data() {
            return [
                {tag: "dash", apps: [ "unity8-dash", "dialer-app", "camera-app" ], focusfrom: 0, focusTo: 1 },
                {tag: "dash", apps: [ "unity8-dash", "dialer-app", "camera-app" ], focusfrom: 1, focusTo: 0 },
            ]
        }

        function test_appFocusSwitch(data) {
            selectUser("no-password");
            clickPasswordInput(true)
            confirmLoggedIn(true);

            var i;
            for (i = 0; i < data.apps.length; i++) {
                startApplication(data.apps[i]);
            }

            ApplicationManager.requestFocusApplication(data.apps[data.focusfrom]);
            tryCompare(ApplicationManager.findApplication(data.apps[data.focusfrom]).session.surface, "activeFocus", true);

            ApplicationManager.requestFocusApplication(data.apps[data.focusTo]);
            tryCompare(ApplicationManager.findApplication(data.apps[data.focusTo]).session.surface, "activeFocus", true);
        }

        function test_decorationPressFocusesApplication_data() {
            return [
                {tag: "dash", apps: [ "unity8-dash", "dialer-app", "camera-app" ], focusfrom: 0, focusTo: 1 },
                {tag: "dash", apps: [ "unity8-dash", "dialer-app", "camera-app" ], focusfrom: 1, focusTo: 0 },
            ]
        }

        function test_decorationPressFocusesApplication(data) {
            selectUser("no-password");
            clickPasswordInput(true)
            confirmLoggedIn(true);

            var i;
            for (i = 0; i < data.apps.length; i++) {
                startApplication(data.apps[i]);
            }

            var fromAppDecoration = findChild(shell, "appWindowDecoration_" + data.apps[data.focusfrom]);
            verify(fromAppDecoration);
            mouseClick(fromAppDecoration);
            tryCompare(ApplicationManager.findApplication(data.apps[data.focusfrom]).session.surface, "activeFocus", true);

            var toAppDecoration = findChild(shell, "appWindowDecoration_" + data.apps[data.focusTo]);
            verify(toAppDecoration);
            mouseClick(toAppDecoration);
            tryCompare(ApplicationManager.findApplication(data.apps[data.focusTo]).session.surface, "activeFocus", true);
        }
    }
}
