/*
 * Copyright 2015 Canonical Ltd.
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
import GlobalShortcut 1.0

Rectangle {
    property var shortcut: globalShortcut
    property var inactiveShortcut: inactiveGlobalShortcut

    width: 100
    height: 100

    GlobalShortcut {
        id: globalShortcut
        objectName: "globalShortcut"
        shortcut: Qt.Key_VolumeMute
    }

    GlobalShortcut {
        id: inactiveGlobalShortcut
        objectName: "inactiveGlobalShortcut"
        shortcut: Qt.ControlModifier|Qt.AltModifier|Qt.Key_L
        active: false
    }
}
