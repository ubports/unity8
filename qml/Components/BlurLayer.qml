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
import QtGraphicalEffects 1.0

Item {
    id: root

    property alias source: fastBlur.source
    property real brightness: 1
    property real blurRadius: 0

    FastBlur {
        id: fastBlur
        anchors.fill: parent
        visible: radius > 0
        radius: Math.max(root.blurRadius, 0)
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 1 - root.brightness
    }
}
