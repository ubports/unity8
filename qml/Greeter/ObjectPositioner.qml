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
import Ubuntu.Components 1.3

Item {
    property int count
    property int index
    property real radius
    property real halfSize
    property real posOffset

    property real slice: (2 * Math.PI / count) * index;

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    x: (radius - halfSize * posOffset) * Math.sin(slice) + radius - halfSize
    y: (radius - halfSize * posOffset) * -Math.cos(slice) + radius - halfSize

    rotation: Math.atan2(radius-(y+halfSize), radius-(x+halfSize)) * 180 / Math.PI - 90
}
