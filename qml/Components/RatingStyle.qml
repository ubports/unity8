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

Row {
    anchors.fill: parent

    Repeater {
        id: repeater
        model: styledItem.size

        property int indexHalfValue: {
            var integerPart = Math.floor(styledItem.effectiveValue);
            var fractionalPart = styledItem.effectiveValue - integerPart;

            if (fractionalPart < 0.5) return -1;
            else return integerPart;
        }
        property url urlIconEmpty: styledItem.urlIconEmpty || "graphics/icon_star_empty.png"
        property url urlIconFull: styledItem.urlIconFull || "graphics/icon_star_full.png"
        property url urlIconHalf: styledItem.urlIconHalf || "graphics/icon_star_half.png"

        Image {
            opacity: styledItem.value < 0 ? 0.4 : 1 // Let's make the stars look inactive for a not-set value
            source: {
                if (index === repeater.indexHalfValue) return repeater.urlIconHalf;
                else if (index < styledItem.effectiveValue) return repeater.urlIconFull;
                else return repeater.urlIconEmpty;
            }
        }
    }
}
