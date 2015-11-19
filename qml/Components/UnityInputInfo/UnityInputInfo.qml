/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

pragma Singleton

import QtQuick 2.4
import Unity.InputInfo 0.1
// Workaround https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1473471
import Ubuntu.Components 1.3

Item {
    id: root
    readonly property alias mice: priv.miceCount
    readonly property alias keyboards: priv.keyboardCount

    property alias inputInfo: inputInfo

    QtObject {
        id: priv

        property var mice: []
        property var keyboards: []

        property int miceCount: 0
        property int keyboardCount: 0

        function addMouse(devicePath) {
            mice.push(devicePath);
            miceCount++;
        }

        function addKeyboard(devicePath) {
            keyboards.push(devicePath);
            keyboardCount++;
        }

        function removeDevice(devicePath) {
            for (var i = 0; i < priv.mice.length; i++) {
                if (priv.mice[i] == devicePath) {
                    priv.mice.splice(i, 1);
                    priv.miceCount--;
                }
            }
            for (var i = 0; i < priv.keyboards.length; i++) {
                if (priv.keyboards[i] == devicePath) {
                    priv.keyboards.splice(i, 1);
                    priv.keyboardCount--;
                }
            }
        }
    }

    InputDeviceInfo {
        id: inputInfo
        objectName: "inputDeviceInfo"

        onNewDevice: {
            var device = inputInfo.get(inputInfo.indexOf(devicePath));
            if (device === null) {
                return;
            }

            var hasMouse = (device.types & InputInfo.Mouse) == InputInfo.Mouse
            var hasTouchpad = (device.types & InputInfo.TouchPad) == InputInfo.TouchPad
            var hasKeyboard = (device.types & InputInfo.Keyboard) == InputInfo.Keyboard

            if (hasMouse || hasTouchpad) {
                priv.addMouse(devicePath);
            } else if (hasKeyboard) {
                // Only accepting keyboards that do not claim to be a mouse too
                // This will be a bit buggy for real hybrid devices, but doesn't
                // fall for Microsoft mice that claim to be Keyboards too.
                priv.addKeyboard(devicePath)
            }
        }
        onDeviceRemoved: {
            priv.removeDevice(devicePath)
        }
    }
}
