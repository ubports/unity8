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

import QtQuick 2.0
import Unity.Application 0.1
import Ubuntu.Components 0.1

// TODO: try to share this code with that from the unity8 shell

Item {
    id: inputMethodRoot

    Connections {
        target: SurfaceManager
        onSurfaceCreated: {
            if (surface.type == MirSurfaceItem.InputMethod) {
                inputMethodRoot.surface = surface;
            }
        }

        onSurfaceDestroyed: {
            if (inputMethodRoot.surface == surface) {
                inputMethodRoot.surface = null;
                surface.parent = null;
            }
            if (!surface.parent) {
                // there's no one displaying it. delete it right away
                surface.release();
            }
        }
    }

    property var surface: null

    property int transitionDuration: UbuntuAnimation.FastDuration

    state: {
        if (surface && surface.state != MirSurfaceItem.Minimized) {
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
                y: inputMethodRoot.parent.height / 2.0
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

    Connections {
        target: surface
        ignoreUnknownSignals: true // don't wanna spam the log when surface is null
        onStateChanged: {
            if (state == MirSurfaceItem.Minimized) {
                inputMethodRoot.hide();
            } else if (state == MirSurfaceItem.Maximized) {
                inputMethodRoot.show();
            }
        }
    }

    onSurfaceChanged: {
        if (surface) {
            surface.parent = inputMethodRoot;
            surface.anchors.fill = inputMethodRoot;
        }
    }

    Component.onDestruction: {
        if (surface) {
            surface.parent = null;
            surface.release();
            surface = null;
        }
    }
}
