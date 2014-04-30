/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *   Michael Terry <michael.terry@canonical.com>
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
import Unity.Application 0.1
import Unity.Test 0.1 as UT
import Powerd 0.1
import LightDM 0.1 as LightDM

import "../../qml"

Item {
    width: shell.width
    height: shell.height

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

    GreeterShell {
        id: shell
        defaultBackground: Qt.resolvedUrl("../../qml/graphics/phone_background.jpg")
    }

    UT.UnityTestCase {
        name: "GreeterShell"
        when: windowShown

        function test_wallpaper_data() {
            return [
                {tag: "both", accounts: "../tests/data/unity/backgrounds/blue.png", gsettings: "../tests/data/unity/backgrounds/red.png", expected: "blue.png"},
                {tag: "accounts", accounts: "../tests/data/unity/backgrounds/blue.png", gsettings: "", expected: "blue.png"},
                {tag: "gsettings", accounts: "", gsettings: "../tests/data/unity/backgrounds/red.png", expected: "red.png"},
                {tag: "none", accounts: "", gsettings: "", expected: shell.defaultBackground},
                {tag: "invalid-both", accounts: "invalid", gsettings: "invalid", expected: shell.defaultBackground},
                {tag: "invalid-accounts", accounts: "invalid", gsettings: "../tests/data/unity/backgrounds/red.png", expected: shell.defaultBackground},
                {tag: "invalid-gsettings", accounts: "../tests/data/unity/backgrounds/blue.png", gsettings: "invalid", expected: "blue.png"},
            ]
        }

        function test_wallpaper(data) {
            var greeterBackground = findChild(shell, "greeterBackground")
            GSettingsController.setPictureUri(data.gsettings)
            AccountsService.backgroundFile = data.accounts
            verify(greeterBackground.source.toString().indexOf(data.expected) !== -1)
            tryCompare(greeterBackground, "status", Image.Ready)
        }

        function test_dispatchURLHidesGreeter() {
            var greeter = findChild(shell, "greeter")
            greeter.showNow()
            tryCompare(greeter, "showProgress", 1)
            LightDM.URLDispatcher.dispatchURL("application:///notes-app")
            tryCompare(greeter, "showProgress", 0)
        }
    }
}
