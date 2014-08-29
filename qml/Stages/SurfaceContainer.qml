/*
 * Copyright 2014 Canonical Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 1.1
import "Animations"

Item {
    id: root
    objectName: "surfaceContainer"
    property Item surface: null

    onSurfaceChanged: {
        if (surface) {
            surface.parent = root;
        }
    }
    Binding {
        target: surface
        property: "anchors.fill"; value: root
    }

    states: [
        State {
            name: "zombie"
            when: surface && !surface.live
        }
    ]
    transitions: [
        Transition {
            from: ""; to: "zombie"
            SequentialAnimation {
                UbuntuNumberAnimation { target: surface; property: "opacity"; to: 0.0
                                        duration: UbuntuAnimation.BriskDuration }
                PropertyAction { target: surface; property: "visible"; value: false }
                ScriptAction { script: { if (root.surface) { root.surface.release(); } } }
            }
        }
    ]
}
