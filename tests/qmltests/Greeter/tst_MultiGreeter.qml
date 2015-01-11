/*
 * Copyright 2013 Canonical Ltd.
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
import ".."
import "../../../qml/Greeter"
import Ubuntu.Components 0.1
import LightDM 0.1 as LightDM
import Unity.Test 0.1 as UT

Item {
    width: units.gu(120)
    height: units.gu(80)

    Greeter {
        id: greeter
        anchors.fill: parent
        tabletMode: true
    }

    Component {
        id: greeterComponent
        Greeter {
            SignalSpy {
                objectName: "selectedSpy"
                target: parent
                signalName: "selected"
            }
        }
    }

    SignalSpy {
        id: unlockSpy
        target: greeter
        signalName: "unlocked"
    }

    SignalSpy {
        id: selectionSpy
        target: greeter
        signalName: "selected"
    }

    SignalSpy {
        id: tappedSpy
        target: greeter
        signalName: "tapped"
    }

    UT.UnityTestCase {
        name: "MultiGreeter"
        when: windowShown

        function select_index(i) {
            // We could be anywhere in list; find target index to know which direction
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

        function select_user(name) {
            // We could be anywhere in list; find target index to know which direction
            for (var i = 0; i < LightDM.Users.count; i++) {
                if (LightDM.Users.data(i, LightDM.UserRoles.NameRole) == name) {
                    break
                }
            }
            if (i == LightDM.Users.count) {
                fail("Didn't find name")
                return -1
            }
            select_index(i)
            return i
        }

        function test_properties() {
            compare(greeter.multiUser, true)
            compare(greeter.narrowMode, false)
        }

        function test_cycle_data() {
            var data = new Array()
            for (var i = 0; i < LightDM.Users.count; i++) {
                data[i] = {tag: LightDM.Users.data(i, LightDM.UserRoles.NameRole), uid: i }
            }
            return data
        }

        function test_cycle(data) {
            selectionSpy.clear();
            var userList = findChild(greeter, "userList")
            var waitForSignal = data.uid != 0 && userList.currentIndex != data.uid
            select_index(data.uid)
            tryCompare(userList, "currentIndex", data.uid)
            tryCompare(greeter, "locked", data.tag !== "no-password")
            if (waitForSignal) {
                selectionSpy.wait()
                tryCompare(selectionSpy, "count", 1)
            }
        }

        function test_unlock_password() {
            select_user("no-password") // to guarantee a selected signal
            unlockSpy.clear()
            select_user("has-password")
            var passwordInput = findChild(greeter, "passwordInput")
            tryCompare(passwordInput, "opacity", 1)
            mouseClick(passwordInput, 1, 1)
            compare(unlockSpy.count, 0)
            typeString("password")
            keyClick(Qt.Key_Enter)
            unlockSpy.wait()
        }

        function test_unlock_wrong_password() {
            select_user("no-password") // to guarantee a selected signal
            unlockSpy.clear()
            select_user("has-password")
            wait(0) // spin event loop to start any pending animations
            var passwordInput = findChild(greeter, "passwordInput")
            tryCompare(passwordInput, "opacity", 1) // wait for opacity animation to be finished
            mouseClick(passwordInput, 1, 1)
            compare(unlockSpy.count, 0)
            typeString("wr0ng p4ssw0rd")
            keyClick(Qt.Key_Enter)
            compare(unlockSpy.count, 0)
        }

        function test_unlock_no_password() {
            unlockSpy.clear()
            select_user("no-password")
            var passwordInput = findChild(greeter, "passwordInput")
            tryCompare(passwordInput, "opacity", 1)
            mouseClick(passwordInput, 1, 1)
            unlockSpy.wait()
            compare(unlockSpy.count, 1)
        }

        function test_empty_name() {
            for (var i = 0; i < LightDM.Users.count; i++) {
                if (LightDM.Users.data(i, LightDM.UserRoles.NameRole) == "empty-name") {
                    compare(LightDM.Users.data(i, LightDM.UserRoles.RealNameRole), LightDM.Users.data(i, LightDM.UserRoles.NameRole))
                    return
                }
            }
            fail("Didn't find empty-name")
        }

        function test_auth_error() {
            select_user("auth-error")
            var passwordInput = findChild(greeter, "passwordInput")
            tryCompare(passwordInput, "placeholderText", "Retry")
        }

        function test_different_prompt() {
            select_user("different-prompt")
            var passwordInput = findChild(greeter, "passwordInput")
            tryCompare(passwordInput, "placeholderText", "Secret word")
        }

        function test_no_response() {
            unlockSpy.clear()
            select_user("no-response")
            var passwordInput = findChild(greeter, "passwordInput")
            tryCompare(passwordInput, "opacity", 1)
            mouseClick(passwordInput, 1, 1)
            compare(unlockSpy.count, 0)
            typeString("password")
            keyClick(Qt.Key_Enter)
            tryCompare(passwordInput, "enabled", false)
            keyClick(Qt.Key_Escape)
            tryCompare(passwordInput, "enabled", true)
            compare(unlockSpy.count, 0)
        }

        function test_two_factor_correct() {
            unlockSpy.clear()
            select_user("two-factor")
            var passwordInput = findChild(greeter, "passwordInput")
            tryCompare(passwordInput, "opacity", 1)
            tryCompare(passwordInput, "echoMode", TextInput.Password)
            tryCompare(passwordInput, "placeholderText", "Password")
            mouseClick(passwordInput, 1, 1)
            compare(unlockSpy.count, 0)
            typeString("password")
            keyClick(Qt.Key_Enter)
            tryCompare(passwordInput, "echoMode", TextInput.Normal)
            tryCompare(passwordInput, "placeholderText", "otp")
            tryCompare(passwordInput, "enabled", true)
            typeString("otp")
            keyClick(Qt.Key_Enter)
            unlockSpy.wait()
        }

        function test_two_factor_wrong1() {
            unlockSpy.clear()
            select_user("two-factor")
            var passwordInput = findChild(greeter, "passwordInput")
            tryCompare(passwordInput, "opacity", 1)
            tryCompare(passwordInput, "placeholderText", "Password")
            mouseClick(passwordInput, 1, 1)
            compare(unlockSpy.count, 0)
            typeString("wr0ng p4ssw0rd")
            keyClick(Qt.Key_Enter)
            tryCompare(passwordInput, "placeholderText", "Password")
            tryCompare(passwordInput, "enabled", true)
            compare(unlockSpy.count, 0)
        }

        function test_two_factor_wrong2() {
            unlockSpy.clear()
            select_user("two-factor")
            var passwordInput = findChild(greeter, "passwordInput")
            tryCompare(passwordInput, "opacity", 1)
            tryCompare(passwordInput, "placeholderText", "Password")
            mouseClick(passwordInput, 1, 1)
            compare(unlockSpy.count, 0)
            typeString("password")
            keyClick(Qt.Key_Enter)
            tryCompare(passwordInput, "placeholderText", "otp")
            tryCompare(passwordInput, "enabled", true)
            typeString("wr0ng p4ssw0rd")
            keyClick(Qt.Key_Enter)
            tryCompare(passwordInput, "placeholderText", "Password")
            tryCompare(passwordInput, "enabled", true)
            compare(unlockSpy.count, 0)
        }

        function test_unicode() {
            var index = select_user("unicode")
            var label = findChild(greeter, "username"+index)
            tryCompare(label, "text", "가나다라마")
        }

        function test_long_name() {
            var index = select_user("long-name")
            var label = findChild(greeter, "username"+index)
            tryCompare(label, "truncated", true)
        }

        function test_info_prompt() {
            select_user("info-prompt")
            var label = findChild(greeter, "infoLabel")
            tryCompare(label, "text", "Welcome to Unity Greeter")
            tryCompare(label, "opacity", 1)
            tryCompare(label, "clip", true)
            tryCompareFunction(function() {return label.contentWidth > label.width;}, false) // c.f. wide-info-prompt
            var passwordInput = findChild(greeter, "passwordInput")
            mouseClick(passwordInput, 1, 1)
            keyClick(Qt.Key_Escape)
        }

        function test_info_prompt_escape() {
            select_user("info-prompt")
            var passwordInput = findChild(greeter, "passwordInput")
            mouseClick(passwordInput, 1, 1)
            keyClick(Qt.Key_Escape)
            var label = findChild(greeter, "infoLabel")
            tryCompare(label, "text", "Welcome to Unity Greeter")
            tryCompare(label, "opacity", 1)
        }

        function test_wide_info_prompt() {
            select_user("wide-info-prompt")
            var label = findChild(greeter, "infoLabel")
            tryCompare(label, "clip", true)
            tryCompareFunction(function() {return label.contentWidth > label.width;}, true)
        }

        function test_html_info_prompt() {
            select_user("html-info-prompt")
            var label = findChild(greeter, "infoLabel")
            tryCompare(label, "text", "&lt;b&gt;&amp;&lt;/b&gt;")
        }

        function test_long_info_prompt() {
            select_user("long-info-prompt")
            var label = findChild(greeter, "infoLabel")
            tryCompare(label, "text", "Welcome to Unity Greeter<br><br>We like to annoy you with super ridiculously long messages.<br>Like this one<br><br>This is the last line of a multiple line message.")
            tryCompare(label, "textFormat", Text.StyledText) // for parsing above correctly
            tryCompare(label, "clip", true)
            tryCompareFunction(function() {return label.contentWidth > label.width;}, true)
        }

        function test_multi_info_prompt() {
            select_user("multi-info-prompt")
            var label = findChild(greeter, "infoLabel")
            tryCompare(label, "text", "Welcome to Unity Greeter<br><font color=\"#df382c\">This is an error</font><br>You should have seen three messages")
            tryCompare(label, "textFormat", Text.StyledText) // for parsing above correctly
        }

        function test_bg_color() {
            var index = select_user("color-background")
            compare(LightDM.Users.data(index, LightDM.UserRoles.BackgroundPathRole), "data:image/svg+xml,<svg><rect width='100%' height='100%' fill='#dd4814'/></svg>")
        }

        function test_bg_none() {
            var index = select_user("no-background")
            compare(LightDM.Users.data(index, LightDM.UserRoles.BackgroundPathRole), "")
        }

        function test_tappedSignal_data() {
            return [
                {tag: "left", posX: units.gu(2)},
                {tag: "right", posX: greeter.width - units.gu(2)}
            ]
        }

        function test_tappedSignal(data) {
            select_user("no-password");
            tappedSpy.clear();
            tap(greeter, data.posX, greeter.height - units.gu(1))
            tryCompare(tappedSpy, "count", 1)
        }

        function test_teaseLockedUnlocked_data() {
            return [
                {tag: "unlocked", locked: false, narrow: false},
                {tag: "locked", locked: true, narrow: false},
            ];
        }

        function test_teaseLockedUnlocked(data) {
            tappedSpy.clear()
            greeter.locked = data.locked;

            tap(greeter, greeter.width - units.gu(5), greeter.height - units.gu(1));

            if (!data.locked || data.narrow) {
                tappedSpy.wait()
                tryCompare(tappedSpy, "count", 1);
            } else {
                // waiting 100ms to make sure nothing happens
                wait(100);
                compare(tappedSpy.count, 0, "Greeter teasing not disabled even though it's locked.");
            }

            // Reset value
            greeter.locked = false;
        }

        function test_dbus_set_active_entry() {
            select_user("no-password") // to guarantee a selected signal
            selectionSpy.clear()
            LightDM.Greeter.requestAuthenticationUser("has-password")

            selectionSpy.wait()
            tryCompare(selectionSpy, "count", 1)

            var userlist = findChild(greeter, "userList")
            compare(LightDM.Users.data(userlist.currentIndex, LightDM.UserRoles.NameRole), "has-password")
        }

        function test_initial_selected_signal() {
            var greeterObj = greeterComponent.createObject(this)
            var spy = findChild(greeterObj, "selectedSpy")
            spy.wait()
            tryCompare(spy, "count", 1)
            greeterObj.destroy()
        }
    }
}
