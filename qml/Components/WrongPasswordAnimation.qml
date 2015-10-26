/*
 * Copyright (C) 2013 Canonical, Ltd.
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

    property var target

    NumberAnimation {
        target: root.target
        property: "anchors.horizontalCenterOffset"
        duration: 50
        easing.type: Easing.InQuad
        to: units.gu(1)
    }
    NumberAnimation {
        target: root.target
        property: "anchors.horizontalCenterOffset"
        duration: 100
        easing.type: Easing.InOutQuad
        to: -units.gu(1)
    }
    NumberAnimation {
        target: root.target
        easing.type: Easing.OutElastic
        properties: "anchors.horizontalCenterOffset"
        to: 0
        duration: 400
        easing.overshoot: units.gu(1)
    }
}
