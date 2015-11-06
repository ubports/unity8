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
import Dash 0.1

Item {

    OrganicGrid {
        id: vj
        objectName: "grid"
        anchors.fill: parent
        columnSpacing: 10
        rowSpacing: 10
        smallDelegateSize: Qt.size(90, 90)
        bigDelegateSize: Qt.size(180, 180)
        cacheBuffer: Math.max(0, (height + displayMarginEnd + displayMarginBeginning) / 2)

        delegate: Rectangle {
            property real randomValue: Math.random()
            color: randomValue < 0.3 ? "green" : randomValue < 0.6 ? "blue" : "red";
            border.width: 3

            Text {
                text: index
                x: 10
                y: 10
            }
        }
    }
}
