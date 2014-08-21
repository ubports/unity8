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

/* This is the base case for surface animations, used when adding/removing * child surfaces.
 * The class is meant to be overridden and changes/animations provided for state changes.
 * NB. It is important to release the surface at the end of the "out" animation.
 *
 * Example - Simple fade in/out
 *
 * BaseSurfaceAnimation {
 *     outChanges: [ PropertyChanges { target: animation.surface; opacity: 0.0 } ]
 *     outAnimations: [
           SequentialAnimation {
 *             NumberAnimation { target: animation.surface; property: "opacity"; duration: 300 }
 *             ScriptAction { script: { if (animation.parent.removing) animation.surface.release(); } }
 *         }
 *     ]
 *
 *     inChanges: [ PropertyChanges { target: animation.surface; opacity: 1.0 } ]
 *     inAnimations: [ NumberAnimation { target: animation.surface; property: "opacity"; duration: 300 } ]
 * }
 */
Item {
    id: base
    property Item session: null

    // changes applied when state changes to "in"
    property list<QtObject> outChanges
    // transition animations when changing state to "in"
    property list<QtObject> outAnimations

    // changes applied when state changes to "out"
    property list<QtObject> inChanges
    // transition animations when changing state to "out"
    property list<QtObject> inAnimations

    function start() {
        // "prep" state forces outChanges without transition animations.
        state = "prep"
        state = "in";
    }
    function end() {
        state = "out";
    }

    states: [
        State {
            name: "baseAnimation"
            PropertyChanges { target: base.session; anchors.fill: undefined }
        },

        State {
            name: "prep"
            extend: "baseAnimation"
            changes: outChanges
        },
        State {
            name: "out"
            extend: "prep"
        },
        State {
            name: "in"
            extend: "baseAnimation"
            changes: inChanges
        }
    ]

    transitions: [
        Transition {
            to:  "out"
            animations: outAnimations
        },
        Transition {
            to: "in"
            animations: inAnimations
        }
    ]
}
