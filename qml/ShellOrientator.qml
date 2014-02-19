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

import QtQuick 2.0
import QtQuick.Window 2.0
import Unity.Application 0.1

Item {
    id: orientator

    // this is only here to select the width / height of the window if not running fullscreen
    property bool tablet: false
    width: tablet ? units.gu(160) : applicationArguments.hasGeometry() ? applicationArguments.width() : units.gu(40)
    height: tablet ? units.gu(100) : applicationArguments.hasGeometry() ? applicationArguments.height() : units.gu(71)

    Item {
        anchors.fill: parent
        rotation: Screen.angleBetween(nativeOrientation, Screen.primaryOrientation)
        Shell {
            x: (rotation != 0) ? 0 : (parent.width - parent.height) / 2
            y: (rotation != 0) ? 0 : -(parent.width - parent.height) / 2
            width: (rotation != 0) ? parent.width : parent.height
            height: (rotation != 0) ? parent.height : parent.width
        }
    }

    OSKController {
        anchors.fill: parent // as needs to know the geometry of the shell
    }
}
