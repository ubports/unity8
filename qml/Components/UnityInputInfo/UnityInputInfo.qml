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

import QtQuick 2.3
import Unity.InputInfo 0.1
// Workaround https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1473471
import Ubuntu.Components 1.2

Item {
    id: root
    readonly property alias mice: miceModel.count
    readonly property alias keyboards: keyboardModel.count

    InputDeviceModel {
        id: miceModel
        deviceFilter: InputInfo.Mouse
    }
    InputDeviceModel {
        id: keyboardModel
        deviceFilter: InputInfo.Keyboard
    }
}
