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

Item {
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

    /*!
      Number of rating stars.
     */
    property int starCount: 5

    readonly property int effectiveRating: MathUtils.clamp(starCount * rating / maximumRating, 0, maximumRating)

    Row {
        id: row
        anchors.centerIn: parent
        height: childrenRect.height
        width: childrenRect.width

        Repeater {
            id: repeater

            property int averageDelegateWidth: row.width / root.starCount

            model: root.starCount

            Image {
                objectName: "ratingStar" + index
                source: index < root.effectiveRating ? "graphics/icon_star_on.png" : "graphics/icon_star_off.png"
            }
        }
    }

    MouseArea {
        anchors.fill: row
        enabled: root.interactive
        onClicked: root.rating = Math.ceil(mouse.x / repeater.averageDelegateWidth) * root.maximumRating / root.starCount
    }
}
