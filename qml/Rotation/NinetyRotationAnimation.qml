/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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

    property int fromAngle
    property int toAngle
    property var info
    property var shell

    readonly property real fromY: fromAngle === 0 || fromAngle === 90 ? 0 : orientedShell.height - orientedShell.width;
    readonly property real toY: toAngle === 0 || toAngle === 90 ? 0 : orientedShell.height - orientedShell.width;
    readonly property bool flipShellDimensions: toAngle == 90 || toAngle == 270

    ScriptAction { script: {
        info.transitioning = true;

        shell.orientationAngle = root.toAngle;
        shell.x = 0;
        shell.width = flipShellDimensions ? orientedShell.height : orientedShell.width;
        shell.height = flipShellDimensions ? orientedShell.width : orientedShell.height;
        shell.transformOriginX = orientedShell.width / 2;
        shell.transformOriginY = orientedShell.width / 2;
        shell.updateFocusedAppOrientation();
        shellCover.visible = true;

        shellSnapshot.transformOriginX = shell.transformOriginX;
        shellSnapshot.transformOriginY = shell.transformOriginY;
        shellSnapshot.transformRotationAngle = shell.transformRotationAngle;
        shellSnapshot.visible = true;
    } }
    ParallelAnimation {
        NumberAnimation {
            target: shellCover; property: "opacity"; from: 1; to: 0;
            duration: rotationDuration; easing.type: rotationEasing
        }
        RotationAnimation {
            target: shell; property: "transformRotationAngle";
            from: root.fromAngle; to: root.toAngle
            direction: RotationAnimation.Shortest
            duration: rotationDuration; easing.type: rotationEasing
        }
        NumberAnimation {
            target: shell; property: "y"
            from: root.fromY; to: root.toY
            duration: rotationDuration; easing.type: rotationEasing
        }

        NumberAnimation {
            target: shellSnapshot; property: "opacity"; from: 1; to: 0;
            duration: rotationDuration; easing.type: rotationEasing
        }
        RotationAnimation {
            target: shellSnapshot; property: "transformRotationAngle";
            from: root.fromAngle; to: root.toAngle
            direction: RotationAnimation.Shortest
            duration: rotationDuration; easing.type: rotationEasing
        }
        NumberAnimation {
            target: shellSnapshot; property: "y"
            from: root.fromY; to: root.toY
            duration: rotationDuration; easing.type: rotationEasing
        }
    }
    UpdateShellTransformations { shell: root.shell; rotationAngle: root.toAngle }
    ScriptAction { script: {
        shellSnapshot.visible = false;
        shellSnapshot.discard();
        shellCover.visible = false;
        info.transitioning = false;
    } }
}
