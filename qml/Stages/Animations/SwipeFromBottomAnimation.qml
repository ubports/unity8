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
import Ubuntu.Components 1.1

BaseSessionAnimation {
    id: animation

    outChanges: [ AnchorChanges {
            target: container;
            anchors.top: container.parent.bottom
            anchors.right: container.parent.right
            anchors.left: container.parent.left
        }
    ]
    outAnimations: [
        SequentialAnimation {
            PropertyAction { target: container.parent; property: "clip"; value: true }
            AnchorAnimation { easing: UbuntuAnimation.StandardEasing; duration: UbuntuAnimation.BriskDuration }
            PropertyAction { target: container.parent; property: "clip"; value: false }
            ScriptAction { script: { container.session.release(); } }
        }
    ]

    inChanges: [
        AnchorChanges {
            target: container;
            anchors.top: container.parent.top
            anchors.bottom: container.parent.bottom
        } ]
    inAnimations: [
        SequentialAnimation {
            PropertyAction { target: container.parent; property: "clip"; value: true }
            AnchorAnimation { easing: UbuntuAnimation.StandardEasing; duration: UbuntuAnimation.BriskDuration }
            PropertyAction { target: container.parent; property: "clip"; value: false }
        }
    ]
}
