/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Rectangle {
    id: __backgroundItem

    anchors.fill: parent
    color: "#333130"
    Label {
        id: __backgroundText

        property int slidingMargin: units.gu(3)

        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        text: "Clear"
        fontSize: "medium"
        color: "#e8e1d0"
        font.bold: true
    }

    states: [
        State {
            name: "SwipingRight"
            PropertyChanges {
                target: __backgroundText
                anchors.rightMargin: __backgroundText.slidingMargin
                anchors.leftMargin: 0
                horizontalAlignment: Text.AlignRight

            }
        },
        State {
            name: "SwipingLeft"
            PropertyChanges {
                target: __backgroundText
                anchors.rightMargin: 0
                anchors.leftMargin: __backgroundText.slidingMargin
                horizontalAlignment: Text.AlignLeft
            }
        }
    ]
}
