/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import Utils 0.1
import "MathUtils.js" as MathUtils

Item {
    id: root
    anchors { left: parent.left; top: parent.top; margins: units.gu(1) }

    // Information about the environment
    property Item flickable: null
    property Spread spread: null
    property int itemIndex: 0

    // Internal
    property real spreadPosition: itemIndex/spread.visibleItemCount - flickable.contentX/spread.spreadWidth // 0 -> left stack, 1 -> right stack
    property real leftStackingProgress: MathUtils.clamp(MathUtils.map(spreadPosition, 0, -spread.stackItemCount/spread.visibleItemCount  , 0, 1), 0, 1)
    property real rightStackingProgress: MathUtils.clamp(MathUtils.map(spreadPosition, 1, 1 + spread.stackItemCount/spread.visibleItemCount  , 0, 1), 0, 1)
    property real stackingX: (MathUtils.easeOutCubic(rightStackingProgress) - MathUtils.easeOutCubic(leftStackingProgress)) * spread.stackWidth



    // Output
    readonly property int targetX: spread.leftStackXPos +
                                     spread.spreadWidth * spread.curve.getYFromX(spreadPosition + spread.centeringOffset) +
                                     stackingX

    readonly property int targetY: spread.contentTopMargin

    readonly property real targetAngle: MathUtils.clamp(
                            MathUtils.map(targetX, spread.leftStackXPos, spread.rightStackXPos, spread.dynamicLeftRotationAngle, spread.dynamicRightRotationAngle),
                            Math.min(spread.dynamicLeftRotationAngle, spread.dynamicRightRotationAngle), Math.max(spread.dynamicLeftRotationAngle, spread.dynamicRightRotationAngle))


    readonly property real targetScale: MathUtils.clamp(
                            MathUtils.map(spreadPosition, 0, 1, spread.leftStackScale, spread.rightStackScale),
                                      spread.leftStackScale, spread.rightStackScale)

    readonly property real shadowOpacity: 0.2 * (1  - rightStackingProgress) * (1 - leftStackingProgress)


    readonly property real closeIconOffset: (scale - 1) * (-root.spreadHeight / 2)

    readonly property real tileInfoOpacity: Math.min(MathUtils.clamp(MathUtils.map(leftStackingProgress, 0 , 1/(spread.stackItemCount*3), 1, 0), 0 , 1),
                                                     MathUtils.clamp(MathUtils.map(spreadPosition, 0.9 , 1, 1, 0), 0 , 1)) /** MathUtils.map(curvedSwitcherProgress, 0.7, 0.9, 0, 1)*/

    readonly property bool itemVisible: {
        var leftStackHidden = spreadPosition < -(spread.stackItemCount + 1)/spread.visibleItemCount
        // don't hide the rightmost
        var rightStackHidden = (spreadPosition > 1 + (spread.stackItemCount)/spread.visibleItemCount) && itemIndex !== spread.totalItemCount - 1
        return !leftStackHidden && !rightStackHidden
    }

}
