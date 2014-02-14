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

Row {
    id: root
    property int rating
    property int maximumRating: 5
    property int starCount: 5
    height: childrenRect.height
    width: childrenRect.width

    readonly property int effectiveRating: Math.max(0, Math.min(root.starCount * root.rating / root.maximumRating, root.maximumRating))

    Repeater {
        model: root.effectiveRating
        Image {
            source: "graphics/icon_star_on.png"
        }
    }
    Repeater {
        model: root.starCount - root.effectiveRating
        Image {
            source: "graphics/icon_star_off.png"
        }
    }
}
