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

Row {
    id: root

    /*!
      True if it accepts user input.
     */
    property bool interactive: true

    /*!
      Current rating.
     */
    property int rating

    /*!
      Maximum rating.
     */
    property int maximumRating: 5

    readonly property int starCount: 5
    readonly property int effectiveRating: Math.max(0, Math.min(starCount * rating / maximumRating, maximumRating))

    height: childrenRect.height
    width: childrenRect.width

    Repeater {
        model: root.starCount

        Image {
            objectName: "ratingStar" + index
            source: index < root.effectiveRating ? "graphics/icon_star_on.png" : "graphics/icon_star_off.png"

            MouseArea {
                anchors.fill: parent
                enabled: root.interactive
                onClicked: root.rating = (index + 1) * root.maximumRating / root.starCount
            }
        }
    }
}
