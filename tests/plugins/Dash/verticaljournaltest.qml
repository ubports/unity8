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

import QtQuick 2.4
import Dash 0.1

Item {

    VerticalJournal {
        id: vj
        objectName: "vj"
        anchors.fill: parent
        columnWidth: 150
        columnSpacing: 10
        rowSpacing: 10
        cacheBuffer: Math.max(0, (height + displayMarginEnd + displayMarginBeginning) / 2)

        delegate: Rectangle {
            property real randomValue: Math.random()
            width: 150
            color: randomValue < 0.3 ? "green" : randomValue < 0.6 ? "blue" : "red";
            height: modelHeight
            border.width: 3

            Text {
                text: index + "\ny: " + parent.y + "\nheight: " + parent.height
                x: 10
                y: 10
            }
        }
    }
}
