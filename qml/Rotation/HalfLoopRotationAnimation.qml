/*
 * Copyright (C) 2015 Canonical, Ltd.
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

SequentialAnimation {
    id: root

    // set from outside
    property int fromAngle
    property int toAngle
    property var info
    property var shell

    readonly property bool flipShellDimensions: toAngle == 90 || toAngle == 270

    ScriptAction { script: {
        info.transitioning = true;
        shell.orientationAngle = root.toAngle;
        shell.x = (orientedShell.width - shell.width) / 2
        shell.y = (orientedShell.height - shell.height) / 2;
        shell.transformOriginX = shell.width / 2;
        shell.transformOriginY = shell.height / 2;
        shell.updateFocusedAppOrientation();
    } }
    NumberAnimation {
        target: shell
        property: "transformRotationAngle"
        from: root.fromAngle; to: root.toAngle
        duration: rotationDuration; easing.type: rotationEasing
    }
    ScriptAction { script: { info.transitioning = false; } }
}
