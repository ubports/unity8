/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

Rectangle {
    id: delegate
    property real amplitude: 0
    property int totalCount
    property int ballIndex
    width: {
        var t = amplitude / 0.6
        t = -t * (t - 2)
        return units.gu(0.25) + units.gu(5) * t
    }
    visible: amplitude != 0
    height: width
    color: "#DD4814"
    radius: width * 0.5
    antialiasing: true
    opacity: {
        // TODO This formula has hardocded values everywhere :D
        var t
        var dampenAfterThisIndex = 7
        if (ballIndex < dampenAfterThisIndex) {
            t = (totalCount - ballIndex) / totalCount
            return Math.pow(t, 4);
        } else {
            t = (totalCount - dampenAfterThisIndex) / totalCount
            t = Math.pow(t, 4);
            t = t * 0.7;
            return 0.09 + t * (totalCount - ballIndex) / (totalCount - dampenAfterThisIndex)
        }
    }

    property double orbitRadius: ((parent.width - units.gu(6)) / 2)
    x: -(width / 2) + (parent.width / 2) + orbitRadius * Math.sin((ballIndex / totalCount) * (2  * Math.PI))
    y: -(height / 2) + (parent.height / 2) - orbitRadius * Math.cos((ballIndex / totalCount) * (2  * Math.PI))
}
