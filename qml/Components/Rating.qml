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

/*! Rating widget bar. */

StyledItem {
    id: root
    implicitHeight: units.gu(2)

    //! True if it accepts user input.
    property bool interactive: true

    //! Maximum rating.
    property real maximumValue: 5

    //! Number of rating icons.
    property int size: 5

    //! Current rating.
    property real value: -1

    readonly property real effectiveValue: MathUtils.clamp(size * value / maximumValue, 0, maximumValue)

    style: RatingStyle {}

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        onClicked: root.value = Math.ceil(mouse.x / averageIconWidth) * root.maximumValue / root.size

        readonly property int averageIconWidth: width / root.size
    }
}
