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

BaseSurfaceAnimation {
    id: animation

    property Rectangle darkenItem: Rectangle {
        parent: animation.surface.parent
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.0)
    }

    outChanges: [ PropertyChanges { target: animation.surface; opacity: 0.0 } ]
    outAnimations: [
        SequentialAnimation {
            UbuntuNumberAnimation { target: animation.surface; property: "opacity"; duration: UbuntuAnimation.FastDuration }
            ColorAnimation { target: darkenItem; duration: UbuntuAnimation.FastDuration }
            ScriptAction { script: { if (animation.parent.removing) animation.surface.release(); } }
        }
    ]

    inChanges: [
        PropertyChanges { target: darkenItem; color: Qt.rgba(0,0,0,0.7) },
        PropertyChanges { target: animation.surface; opacity: 1.0 }
    ]
    inAnimations: [
        SequentialAnimation {
            ColorAnimation { target: darkenItem; duration: UbuntuAnimation.FastDuration }
            UbuntuNumberAnimation { target: animation.surface; property: "opacity"; duration: UbuntuAnimation.FastDuration }
        }
    ]
}
