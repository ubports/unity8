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
    property var container
    objectName: "sessionAnimation"

    // changes applied when state changes to "from"
    property list<QtObject> fromChanges
    // transition animations when changing state to "from"
    property list<QtObject> fromAnimations

    // changes applied when state changes to "to"
    property list<QtObject> toChanges
    // transition animations when changing state to "to"
    property list<QtObject> toAnimations

    function start() {
        // "prep" state forces toChanges without transition animations.
        state = "prep"
        state = "to";
    }
    function end() {
        state = "from";
    }

    signal completed()

    states: [
        State {
            name: "baseAnimation"
            PropertyChanges { target: container; anchors.fill: undefined }
        },

        State {
            name: "prep"
            extend: "baseAnimation"
            changes: fromChanges
        },
        State {
            name: "from"
            extend: "prep"
        },
        State {
            name: "in"
            extend: "baseAnimation"
            changes: toChanges
        }
    ]

    transitions: [
        Transition {
            to:  "from"
            animations: fromAnimations
        },
        Transition {
            to: "to"
            animations: toAnimations
        }
    ]
}
