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

Rectangle {
    width: units.gu(4)
    height: width
    radius: height / 2
    color: theme.palette.normal.background
    opacity: 0.95

    // to be set from outside
    property Item resizeTarget

    Image {
        source: "graphics/arrows.png"
        anchors.centerIn: parent
        width: units.gu(2)
        height: width
        fillMode: Image.PreserveAspectFit
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -units.gu(1.5)
        hoverEnabled: true

        Mouse.enabled: resizeTarget
        Mouse.forwardTo: resizeTarget
    }
}
