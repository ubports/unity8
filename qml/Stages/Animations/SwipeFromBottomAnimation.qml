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

    outChanges: [ AnchorChanges { target: surfaceContainer; anchors.top: sessionContainer.bottom } ]
    outAnimations: [
        SequentialAnimation {
            PropertyAction { target: sessionContainer; property: "clip"; value: true }
            AnchorAnimation { easing: UbuntuAnimation.StandardEasing; duration: UbuntuAnimation.BriskDuration }
            PropertyAction { target: surfaceContainer; property: "visible"; value: !sessionContainer.removing }
            PropertyAction { target: sessionContainer; property: "clip"; value: false }
            ScriptAction { script: { sessionContainer.session.release(); } }
        }
    ]

    inChanges: [
        AnchorChanges {
            target: surfaceContainer;
            anchors.top: animation.parent.top
            anchors.right: undefined
            anchors.bottom: undefined
            anchors.left: undefined
        } ]
    inAnimations: [
        SequentialAnimation {
            PropertyAction { target: sessionContainer; property: "clip"; value: true }
            AnchorAnimation { easing: UbuntuAnimation.StandardEasing; duration: UbuntuAnimation.BriskDuration }
            PropertyAction { target: sessionContainer; property: "clip"; value: false }
        }
    ]
}
