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

import QtQuick 2.2
import Ubuntu.Components 0.1

Item {
    id: waitingDots

    // center in parent; waitingDots has no size therefore anchors.centerIn cannot be used
    x: parent.width / 2
    y: parent.height / 2

    property var dots: [dot1, dot2, dot3]
    property var vertices: [[-units.gu(1), -units.gu(1)],
                            [units.gu(1),  -units.gu(1)],
                            [0,             units.gu(1)]]
    property int shift: 0

    function cycle () {
        var n = vertices.length;
        shift = (shift + 1) % n;

        for (var i=0; i<n; i++) {
            dots[i].x = vertices[(i+shift) % n][0];
            dots[i].y = vertices[(i+shift) % n][1];
        }
    }

    Timer {
        interval: 800
        running: waitingDots.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: waitingDots.cycle()
    }


    Dot {
        id: dot1
        x: vertices[0][0]
        y: vertices[0][1]
        Behavior on x {XAnimator {duration: UbuntuAnimation.BriskDuration; easing: UbuntuAnimation.StandardEasing}}
        Behavior on y {YAnimator {duration: UbuntuAnimation.BriskDuration; easing: UbuntuAnimation.StandardEasing}}
    }

    Dot {
        id: dot2
        x: vertices[1][0]
        y: vertices[1][1]
        Behavior on x {XAnimator {duration: UbuntuAnimation.BriskDuration; easing: UbuntuAnimation.StandardEasing}}
        Behavior on y {YAnimator {duration: UbuntuAnimation.BriskDuration; easing: UbuntuAnimation.StandardEasing}}

    }

    Dot {
        id: dot3
        x: vertices[2][0]
        y: vertices[2][1]
        Behavior on x {XAnimator {duration: UbuntuAnimation.BriskDuration; easing: UbuntuAnimation.StandardEasing}}
        Behavior on y {YAnimator {duration: UbuntuAnimation.BriskDuration; easing: UbuntuAnimation.StandardEasing}}
    }
}
