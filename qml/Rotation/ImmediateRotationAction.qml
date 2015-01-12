/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.3

ScriptAction { script: {
    d.transitioning = true;
    shell.orientationAngle = d.requestedOrientationAngle;
    shell.transformRotationAngle = d.requestedOrientationAngle;

    // Making bindings as orientedShell's dimensions might wiggle during startup.
    if (d.requestedOrientationAngle === 90 || d.requestedOrientationAngle === 270) {
        shell.width = Qt.binding(function() { return orientedShell.height; });
        shell.height = Qt.binding(function() { return orientedShell.width; });
    } else {
        shell.width = Qt.binding(function() { return orientedShell.width; });
        shell.height = Qt.binding(function() { return orientedShell.height; });
    }

    shell.x = Qt.binding(function() { return (orientedShell.width - shell.width) / 2; });
    shell.y = Qt.binding(function() { return (orientedShell.height - shell.height) / 2; });
    shell.transformOriginX = Qt.binding(function() { return shell.width / 2; });
    shell.transformOriginY = Qt.binding(function() { return shell.height / 2; });

    shell.updateFocusedAppOrientation();
    d.transitioning = false;
} }
