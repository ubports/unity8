/*
 * Copyright 2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.4
import Ubuntu.Components 1.3

StateGroup {
    id: root
    property var container
    property var surfaceItem

    states: [
        State {
            name: "blank"
            when: !root.surfaceItem.surface
        },
        State {
            name: "ready"
            when: root.surfaceItem.surface && root.surfaceItem.live
        },
        State {
            name: "zombie"
            when: root.surfaceItem.surface && !root.surfaceItem.live
        }
    ]
    transitions: [
        Transition {
            from: "*"; to: "zombie"
            // Slide downwards until it's out of view, through the bottom of the window
            SequentialAnimation {
                // clip so we don't go out of parent's bounds during spread
                PropertyAction { target: root.container.parent; property: "clip"; value: true }
                UbuntuNumberAnimation { target: root.surfaceItem; property: "y"; to: root.container.height
                                        duration: UbuntuAnimation.BriskDuration }
                PropertyAction { target: root.surfaceItem; property: "visible"; value: false }
                PropertyAction { target: container.parent; property: "clip"; value: false }
                ScriptAction { script: {
                    // Unity.Application can't destroy a zombie MirSurface if it's still being
                    // referenced by a MirSurfaceItem.
                    root.surfaceItem.surface = null;
                } }
            }
        },
        Transition {
            from: "*"; to: "ready"
            // Slide upwards into view, from the bottom of the window
            SequentialAnimation {
                // clip so we don't go out of parent's bounds during spread
                PropertyAction { target: root.container.parent; property: "clip"; value: true }
                ScriptAction { script: {
                    root.surfaceItem.y = root.container.height;
                    root.surfaceItem.visible = true;
                } }
                UbuntuNumberAnimation {
                    target: root.surfaceItem; property: "y"; to: 0
                    duration: UbuntuAnimation.BriskDuration
                }
                PropertyAction { target: container.parent; property: "clip"; value: false }
            }
        },
        Transition {
            from: "*"; to: "blank"
            ScriptAction { script: {
                root.surfaceItem.visible = false;
            } }
        }
    ]
}
