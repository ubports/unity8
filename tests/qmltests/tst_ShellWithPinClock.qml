/*
 * Copyright (C) 2022 UBports Foundation
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


Item {
    id: root
    width: units.gu(40)
    height: units.gu(71)

    Component.onCompleted: {
        AccountsService.pinCodePromptManager = "ClockPinPrompt.qml"

        var component = Qt.createComponent("tst_ShellWithPin.qml")
        var rootTest = component.createObject(root)
        rootTest.init()
    }
}
