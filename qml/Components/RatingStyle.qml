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
import Ubuntu.Components 0.1

Row {
    anchors.fill: parent

    Repeater {
        model: styledItem.size

        Image {
            opacity: styledItem.value < 0 ? 0.4 : 1 // Let's make the stars look inactive for a not-set value
            source: index < styledItem.effectiveValue ? "graphics/icon_star_on.png" : "graphics/icon_star_off.png"
        }
    }
}
