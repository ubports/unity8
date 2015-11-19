/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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
import Unity.Application 0.1
import Ubuntu.Components 1.3
import Ubuntu.Gestures 0.1

Item {
    id: root

    Connections {
        target: SurfaceManager
        onSurfaceCreated: {
            if (surface.type == Mir.InputMethodType) {
                surfaceItem.surface = surface;
            }
        }
    }

    property int transitionDuration: UbuntuAnimation.FastDuration

    MirSurfaceItem {
        id: surfaceItem
        anchors.fill: parent

        consumesInput: true

        surfaceWidth: width
        surfaceHeight: height

        onLiveChanged: {
            if (surface !== null && !live) {
                surface = null;
            }
        }
    }

    TouchGate {
        x: UbuntuKeyboardInfo.x
        y: UbuntuKeyboardInfo.y
        width: UbuntuKeyboardInfo.width
        height: UbuntuKeyboardInfo.height

        targetItem: surfaceItem
    }

    state: {
        if (surfaceItem.surface && surfaceItem.surfaceState != Mir.MinimizedState) {
            return "shown";
        } else {
            return "hidden";
        }
    }

    states: [
        State {
            name: "shown"
            PropertyChanges {
                target: root
                visible: true
                y: 0
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: root
                visible: false
                // half-way down because the vkb occupies only the lower half of the surface
                // TODO: consider keyboard rotation
                y: root.parent.height / 2.0
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"; to: "*"
            PropertyAction { property: "visible"; value: true }
            UbuntuNumberAnimation { property: "y"; duration: transitionDuration }
        }
    ]
}
