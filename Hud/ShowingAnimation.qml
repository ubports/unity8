/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Ubuntu.Components 0.1
import "../Components"

Item {
    id: root
    property real yOffsetAtAnimationStart: units.gu(2)
    property real progress: 0
    property int animationDuration: 200
    default property alias __itemsToAnimate: container.children

    property bool showing: progress > 0

    height: childrenRect.height

    Item {
        id: container
        anchors {
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height
    }

    NumberAnimation {id: opacityAnimation; target: container; property: "opacity"; from: 0; to: 1; duration: animationDuration}
    NumberAnimation {id: yAnimation; target: container; property: "y"; from: yOffsetAtAnimationStart; to: 0; duration: animationDuration}

    // FIXME This would much more sense in a ParallelAnimation and just
    // one AnimationController but that goes something crazy and rendering never stops
    AnimationController {
        animation: opacityAnimation
        progress: root.progress
    }
    AnimationController {
        animation: yAnimation
        progress: root.progress
    }
}
