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
import Ubuntu.Components 1.1

Image {
    // Valid values are: down, up, right, left
    property string direction

    readonly property real offset: units.gu(6)

    ////

    visible: direction !== ""
    source: Qt.resolvedUrl("graphics/arrow-down.png")

    rotation: {
        if (direction === "up") {
            return 180;
        } else if (direction === "left") {
            return 90;
        } else if (direction === "right") {
            return -90;
        } else {
            return 0;
        }
    }

    height: units.gu(9)
    sourceSize.height: height
}
