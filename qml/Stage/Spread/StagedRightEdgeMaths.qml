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
    property real progress: 0
    property int sceneWidth: 0
    property int sideStageWidth: 0
    property int sceneHeight: 0
    property int targetX: 0
    property int startY: 0
    property int targetY: 0
    property real startAngle: 30
    property real targetAngle: 0
    property int targetHeight: 0
    property real startScale: 1.3
    property real targetScale: 0
    property real breakPoint: units.gu(15) / sceneWidth

    property bool isMainStageApp: false
    property bool isSideStageApp: false
    property bool sideStageOpen: false
    property int nextInStack: 0
    property int shuffledZ: 0


    // Config
    property int tileDistance: units.gu(10)

    // Output

    readonly property real scaleToPreviewProgress: {
        return progress < breakPoint ? 0 : MathUtils.clamp(MathUtils.linearAnimation(breakPoint, 1, 0, 1, progress), 0, 1)
    }
    readonly property int animatedWidth: {
        return progress < breakPoint ? root.sceneHeight : MathUtils.linearAnimation(breakPoint, 1, root.sceneWidth, targetHeight, progress)
    }

    readonly property int animatedHeight: {
        return progress < breakPoint ? root.sceneHeight : MathUtils.linearAnimation(breakPoint, 1, root.sceneHeight, targetHeight, progress)
    }


    readonly property int animatedX: {
        var nextStage = appRepeater.itemAt(nextInStack) ? appRepeater.itemAt(nextInStack).stage : ApplicationInfoInterface.MainStage;

        var startX = 0;
        if (isMainStageApp) {
            if (progress < breakPoint) {
                if (nextStage == ApplicationInfoInterface.MainStage) {
                    return MathUtils.linearAnimation(0, breakPoint, 0, -units.gu(4), progress);
                } else {
                    return 0;
                }
            } else {
                if (nextStage == ApplicationInfoInterface.MainStage) {
                    return MathUtils.linearAnimation(breakPoint, 1, -units.gu(4), targetX, progress);
                } else {
                    return MathUtils.linearAnimation(breakPoint, 1, 0, targetX, progress);
                }
            }
        } else if (isSideStageApp) {
            startX = sceneWidth - sideStageWidth;
        } else if (itemIndex == nextInStack && itemIndex <= 2 && priv.sideStageDelegate && nextStage == ApplicationInfoInterface.MainStage) {
            startX = sceneWidth - sideStageWidth;
        } else {
            var stageCount = (priv.mainStageDelegate ? 1 : 0) + (priv.sideStageDelegate ? 1 : 0)
            startX = sceneWidth + Math.max(0, itemIndex - stageCount - 1) * tileDistance;
        }

        if (itemIndex == nextInStack) {
            if (progress < breakPoint) {
                return MathUtils.linearAnimation(0, breakPoint, startX, startX * (1 - breakPoint), progress)
            }
            return MathUtils.linearAnimation(breakPoint, 1, startX * (1 - breakPoint), targetX, progress)
        }

        if (progress < breakPoint) {
            return startX;
        }

        return MathUtils.linearAnimation(breakPoint, 1, startX, targetX, progress)

    }

    readonly property int animatedY: progress < breakPoint ? startY : MathUtils.linearAnimation(breakPoint, 1, startY, targetY, progress)

    readonly property int animatedZ: {
        if (progress < breakPoint + (1 - breakPoint) / 2) {
            return shuffledZ
        }
        return itemIndex;
    }

    readonly property real animatedAngle: {
        var nextStage = appRepeater.itemAt(nextInStack) ? appRepeater.itemAt(nextInStack).stage : ApplicationInfoInterface.MainStage;

        var startAngle = 0;
        if (isMainStageApp) {
            startAngle = 0;
        } else if (isSideStageApp) {
            startAngle = 0;
        } else {
            if (stage == ApplicationInfoInterface.SideStage && itemIndex == nextInStack && !sideStageOpen) {
                startAngle = 0;
            } else {
                startAngle = root.startAngle;
            }
        }

        if ((itemIndex == nextInStack)
                || (isMainStageApp && nextStage === ApplicationInfoInterface.MainStage)
                || (isSideStageApp && nextStage === ApplicationInfoInterface.SideStage)) {
            return MathUtils.linearAnimation(0, 1, startAngle, targetAngle, progress);
        }

        if (progress < breakPoint) {
            return 0;
        }
        return MathUtils.linearAnimation(breakPoint, 1, startAngle, targetAngle, progress);
    }

    readonly property real animatedScale: {
        var pullingInSideStage = itemIndex == nextInStack && stage == ApplicationInfoInterface.SideStage && !sideStageOpen;

        var startScale = 1;
        if (isMainStageApp) {
            startScale = 1;
        } else if (isSideStageApp) {
            startScale = 1;
        } else {
            if (pullingInSideStage) {
                startScale = 1
            } else {
                startScale = root.startScale;
            }
        }

        if (progress < breakPoint) {
            if (itemIndex == nextInStack && (sideStageOpen || stage == ApplicationInfoInterface.MainStage)) {
                return MathUtils.linearAnimation(0, 1, startScale, targetScale, progress);
            }
            return startScale;
        }
        if (itemIndex == nextInStack) {
            return MathUtils.linearAnimation(0, 1, startScale, targetScale, progress)
        }

        return MathUtils.linearAnimation(breakPoint, 1, startScale, targetScale, progress)
    }

    readonly property bool itemVisible: true //animatedX < sceneWidth
}
