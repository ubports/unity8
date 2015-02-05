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
import Unity.Test 0.1 as UT
import Powerd 0.1

import "../../qml"

Row {
    id: root
    spacing: 0

    Component.onCompleted: {
        // must set the mock mode before loading the Shell
        LightDM.Greeter.mockMode = "full";
        LightDM.Users.mockMode = "full";
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

    Loader {
        id: shellLoader

        active: false
        width: units.gu(100)
        height: units.gu(80)

        property bool itemDestroyed: false
        sourceComponent: Component {
            Shell {
                property string indicatorProfile: "phone"

                Component.onDestruction: {
                    shellLoader.itemDestroyed = true
                }
            }
        }
    }

    Rectangle {
        color: "white"
        width: units.gu(20)
        height: shellLoader.height

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
            Button {
                text: "Demo edges"
                onClicked: {
                    AccountsService.demoEdges = true
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
        name: "TabletShell"
        when: windowShown

        property Item shell: shellLoader.status === Loader.Ready ? shellLoader.item : null

        function init() {
            tryCompare(shell, "enabled", true); // will be enabled when greeter is all ready
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
                var account = findChild(greeter, "username"+next)
                mouseClick(account, 1, 1)
                tryCompare(userlist, "currentIndex", next)
                tryCompare(userlist, "movingInternally", false)
            }
        }

        function selectUser(name) {
            // Find index of user with the right name
            var greeter = findChild(shell, "greeter")
            for (var i = 0; i < greeter.model.count; i++) {
                if (greeter.model.data(i, LightDM.UserRoles.NameRole) == name) {
                    break
                }
            }
            if (i == greeter.model.count) {
                fail("Didn't find name")
                return -1
            }
            selectIndex(i)
            return i
        }

        function clickPasswordInput(isButton) {
            var greeter = findChild(shell, "greeter")
            tryCompare(greeter, "showProgress", 1)

            var passwordMouseArea = findChild(shell, "passwordMouseArea")
            tryCompare(passwordMouseArea, "enabled", isButton)

            var passwordInput = findChild(shell, "passwordInput")
            mouseClick(passwordInput)
        }

        function confirmLoggedIn(loggedIn) {
            var greeterWrapper = findChild(shell, "greeterWrapper")
            tryCompare(greeterWrapper, "showProgress", loggedIn ? 0 : 1)
            tryCompare(sessionSpy, "count", loggedIn ? 1 : 0)
        }

        function swipeFromLeftEdge(swipeLength) {
            var touchStartX = 2
            var touchStartY = shell.height / 2
            touchFlick(shell, touchStartX, touchStartY, swipeLength, touchStartY)
        }

        function test_noLockscreen() {
            selectUser("has-password")
            var lockscreen = findChild(shell, "lockscreen")
            tryCompare(lockscreen, "shown", false)
        }

        function test_showAndHideGreeterDBusCalls() {
            var greeter = findChild(shell, "greeter")
            LightDM.Greeter.hideGreeter()
            tryCompare(greeter, "showProgress", 0)
            LightDM.Greeter.showGreeter()
            tryCompare(greeter, "showProgress", 1)
        }

        function test_login_data() {
            return [
                {tag: "auth error", user: "auth-error", loggedIn: false, password: ""},
                {tag: "with password", user: "has-password", loggedIn: true, password: "password"},
                {tag: "without password", user: "no-password", loggedIn: true, password: ""},
            ]
        }

        function test_login(data) {
            selectUser(data.user)

            clickPasswordInput(data.password === "")

            if (data.password !== "") {
                typeString(data.password)
                keyClick(Qt.Key_Enter)
            }

            confirmLoggedIn(data.loggedIn)
        }

        function test_appLaunchDuringGreeter_data() {
            return [
                {tag: "auth error", user: "auth-error", loggedIn: false, passwordFocus: false},
                {tag: "without password", user: "no-password", loggedIn: true, passwordFocus: false},
                {tag: "with password", user: "has-password", loggedIn: false, passwordFocus: true},
            ]
        }

        function test_appLaunchDuringGreeter(data) {
            selectUser(data.user)

            var greeter = findChild(shell, "greeter")
            var app = ApplicationManager.startApplication("dialer-app")

            confirmLoggedIn(data.loggedIn)

            if (data.passwordFocus) {
                var passwordInput = findChild(greeter, "passwordInput")
                tryCompare(passwordInput, "focus", true)
            }
        }

        function test_leftEdgeDrag_data() {
            return [
                {tag: "without password", user: "no-password", loggedIn: true, demo: false},
                {tag: "with password", user: "has-password", loggedIn: false, demo: false},
                {tag: "with demo", user: "has-password", loggedIn: true, demo: true},
            ]
        }

        function test_leftEdgeDrag(data) {
            selectUser(data.user)

            AccountsService.demoEdges = data.demo
            var edgeDemo = findChild(shell, "edgeDemo")
            tryCompare(edgeDemo, "running", data.demo)

            swipeFromLeftEdge(shell.width * 0.75)
            wait(500) // to give time to handle dash() signal from Launcher
            confirmLoggedIn(data.loggedIn)
        }
    }
}
