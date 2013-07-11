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

import QtQuick 2.0
import Ubuntu.Components 0.1
import "../../Components"

BaseCarouselDelegate {
    id: item

    UbuntuShape {
        anchors.fill: parent
        radius: "medium"
        borderSource: ""
        image: Image {
            asynchronous: true
            sourceSize { width: item.width; height: item.height }
            source: model ? model.icon : ""
        }
    }

    BorderImage {
        anchors.centerIn: parent
        opacity: 0.6
        source: "../../Components/graphics/non-selected.sci"
        width: parent.width + units.gu(1.5)
        height: parent.height + units.gu(1.5)
    }
}
