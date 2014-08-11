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

BaseSurfaceAnimation {
    id: animation

    outAnimations: [
        SequentialAnimation {
            PropertyAction { target: animation.parent; property: "clip"; value: true }
            PropertyAction { target: animation.surface; property: "visible"; value: true }
            AnchorAnimation { easing.type: Easing.InOutQuad; duration: 400 }
            PropertyAction { target: animation.parent; property: "clip"; value: false }
            ScriptAction { script: { if (animation.parent.removing) animation.surface.release(); } }
        }
    ]

    inChanges: [
        AnchorChanges {
            target: animation.surface;
            anchors.top: undefined
            anchors.right: undefined
            anchors.bottom: animation.parent.top
            anchors.left: undefined
        }
    ]
    inAnimations: [
        SequentialAnimation {
            PropertyAction { target: animation.parent; property: "clip"; value: true }
            AnchorAnimation { easing.type: Easing.InOutQuad; duration: 400 }
            PropertyAction { target: animation.surface; property: "visible"; value: false}
            PropertyAction { target: animation.parent; property: "clip"; value: false }
        }
    ]
}
