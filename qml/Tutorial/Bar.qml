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

import QtGraphicalEffects 1.0
import QtQuick 2.3
import Ubuntu.Components 1.1
import "../Components"

Item {
    id: root

    // Valid values are: down, up, right, left
    property string direction

    property bool animating: true

    readonly property real offset: edgeHint.size / 4

    ////

    visible: direction !== ""
    implicitHeight: direction === "down" || direction === "up" ? hintAnimation.maxGlow : 0
    implicitWidth: direction === "left" || direction === "right" ? hintAnimation.maxGlow : 0

    LinearGradient {
        id: edgeHint
        property int size: 1
        cached: false
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: UbuntuColors.orange
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
        anchors.fill: parent
        start: {
            if (root.direction == "left") {
                return Qt.point(width, 0);
            } else if (root.direction == "right") {
                return Qt.point(0, 0);
            } else if (root.direction == "down") {
                return Qt.point(0, 0);
            } else {
                return Qt.point(0, height);
            }
        }
        end: {
            if (root.direction == "left") {
                return Qt.point(width - size, 0);
            } else if (root.direction == "right") {
                return Qt.point(size, 0);
            } else if (root.direction == "down") {
                return Qt.point(0, size);
            } else {
                return Qt.point(0, height - size);
            }
        }
    }

    SequentialAnimation {
        id: hintAnimation
        loops: Animation.Infinite
        running: root.animating && root.visible
        property double maxGlow: units.gu(4)
        property int duration: UbuntuAnimation.SleepyDuration

        StandardAnimation {
            target: edgeHint
            property: "size"
            to: hintAnimation.maxGlow
            duration: hintAnimation.duration
        }

        // Undo the above
        StandardAnimation {
            target: edgeHint
            property: "size"
            to: 1
            duration: hintAnimation.duration
        }
    }
}
