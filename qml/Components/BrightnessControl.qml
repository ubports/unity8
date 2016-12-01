/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import QMenuModel 0.1
import GlobalShortcut 1.0

QtObject {
    objectName: "brightnessControl"

    property GlobalShortcut brightnessUp: GlobalShortcut {
        shortcut: Qt.Key_MonBrightnessUp
        onTriggered: stepUp();
    }

    property GlobalShortcut brightnessDown: GlobalShortcut {
        shortcut: Qt.Key_MonBrightnessDown
        onTriggered: stepDown();
    }

    function stepUp() {
        actionGroup.brightness.updateState(MathUtils.clamp(actionGroup.brightness.state + 0.1, 0.01, 1.0));
    }

    function stepDown() {
        actionGroup.brightness.updateState(MathUtils.clamp(actionGroup.brightness.state - 0.1, 0.01, 1.0));
    }

    property QDBusActionGroup actionGroup: QDBusActionGroup {
        busType: DBus.SessionBus
        busName: "com.canonical.indicator.power"
        objectPath: "/com/canonical/indicator/power"

        property variant brightness: action("brightness")

        Component.onCompleted: {
            actionGroup.start();
        }
    }
}
