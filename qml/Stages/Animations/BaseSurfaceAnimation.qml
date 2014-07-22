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

Item {
    id: base
    property Item surface: null
    property Item surfaceArea: null

    property list<QtObject> outChanges
    property list<QtObject> outAnimations

    property list<QtObject> inChanges
    property list<QtObject> inAnimations

    function start() {
        state = "prep"
        state = "in";
    }
    function end() {
        state = "out";
    }

    states: [
        State {
            name: "baseAnimation"
            PropertyChanges { target: base.surface; anchors.fill: undefined }
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
