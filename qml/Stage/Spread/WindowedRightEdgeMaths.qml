/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import Unity.Application 0.1
import "MathUtils.js" as MathUtils

QtObject {
    id: root

    // Input
    property int itemIndex: 0
    property int normalZ: 0
    property int startWidth: 0
    property int startHeight: 0
    property int startX: 0
    property int targetX: 0
    property int startY: 0
    property int targetY: 0
    property real targetAngle: 0
    property int targetHeight: 0
    property real targetScale: 0
    property real swipeProgress: 0
    property real pushProgress: 0

    // Config
    property real breakPoint: 0.4

    // internal
    readonly property real progress: {
        if (pushProgress > 0) {
            // we don't do the full animation when pushing, just a little bit
            return MathUtils.linearAnimation(0, 1, 0, breakPoint + .1, pushProgress)
        } else {
            return swipeProgress;
        }
    }

    // Output

    readonly property real scaleToPreviewProgress: {
        return progress < breakPoint ? 0 : MathUtils.clamp(MathUtils.linearAnimation(breakPoint, 1, 0, 1, progress), 0, 1)
    }
    readonly property int animatedWidth: {
        return progress < breakPoint ? root.startWidth : MathUtils.linearAnimation(breakPoint, 1, root.startWidth, targetHeight, progress)
    }

    readonly property int animatedHeight: {
        return progress < breakPoint ? root.startHeight : MathUtils.linearAnimation(breakPoint, 1, root.startHeight, targetHeight, progress)
    }

    readonly property int animatedX: {
        if (progress < breakPoint) {
            return startX;
        }
        return MathUtils.linearAnimation(breakPoint, 1, startX, targetX, progress)
    }

    readonly property int animatedY: progress < breakPoint ? startY : MathUtils.linearAnimation(breakPoint, 1, startY, targetY, progress)

    readonly property real animatedAngle: progress < breakPoint ? 0 : MathUtils.linearAnimation(breakPoint, 1, 0, targetAngle, progress);

    readonly property real decorationHeight: progress < breakPoint ? 1 : MathUtils.linearAnimation(breakPoint, 1, 1, 0, progress);

    readonly property int animatedZ: {
        if (progress < breakPoint + (1 - breakPoint) / 2) {
            if (swipeProgress > 0) {
                return itemIndex == 1 ? normalZ + 2 : normalZ
            }
            if (pushProgress > 0) {
                return normalZ;
            }
        }
        return itemIndex
    }

    readonly property real opacityMask: (swipeProgress > 0 && itemIndex == 1) ? MathUtils.linearAnimation(0, breakPoint, 0, 1, progress) : 1

    readonly property real animatedScale: progress < breakPoint ? 1 : MathUtils.linearAnimation(breakPoint, 1, 1, targetScale, progress)

//    readonly property bool itemVisible: true //animatedX < sceneWidth
}
