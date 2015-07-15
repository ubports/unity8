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

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root

    property alias color: circle.color

    // Will make whole arrow darker
    property real darkenBy: 0

    property alias chevronOpacity: chevron.opacity

    ////

    Rectangle {
        id: circle
        anchors.fill: parent
        radius: width / 2
    }

    Image {
        id: chevron
        anchors.centerIn: parent
        source: Qt.resolvedUrl("graphics/chevron.png")
        fillMode: Image.PreserveAspectFit
        sourceSize.width: 152
        sourceSize.height: 152
        width: parent.width / 2
        height: parent.height / 2
    }

    Rectangle {
        id: darkCircle
        anchors.fill: parent
        radius: width / 2
        color: "black"
        opacity: root.darkenBy
    }
}
