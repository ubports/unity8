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

Item {
    id: root

    Image {
        id: closeIcon
        anchors.centerIn: parent
        source: "graphics/close_btn.png"

        state: (root.enabled) ? "shown" : "hidden"

        states: [
            State {
                name: "shown"
                PropertyChanges {
                    target: closeIcon
                    height: root.height
                    width: root.width
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: closeIcon
                    height: 0
                    width: 0
                }
            }

        ]
        transitions: [
            Transition {
                to: "shown"
                NumberAnimation {
                    properties: "width, height"; duration: 300
                    easing { type: Easing.OutBack; overshoot: 5 }
                }
            },
            Transition {
                to: "hidden"
                NumberAnimation { properties: "width, height"; duration: 250; }
            }
        ]
    }
}
