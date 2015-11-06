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

Item {
    id: root
    anchors { left: parent.left; top: parent.top; margins: units.gu(1) }

    // Information about the transformed item
    property int itemIndex: 0
    property real itemHeight: units.gu(10)

    // Information about the environment
    property int totalItems: 0
    property Item flickable: null
    property int sceneHeight: units.gu(20)

    // Spread properties
    property real spreadHeight: sceneHeight * 0.4
    property int spreadBottomOffset: sceneHeight * 0.18
    property int foldingAreaWidth: flickableWidth * 0.2
    property int maxVisibleItems: 7
    property int margins: flickableWidth * 0.05
    property real stackScale: 0.1
    property int leftEndFoldedAngle: 70
    property int rightEndFoldedAngle: 65
    property int unfoldedAngle: 30
    property int stackWidth: flickableWidth * 0.01


    // Internal
    readonly property int flickableWidth: flickable ? flickable.width : 0
    readonly property int flickableContentWidth: flickable ? flickable.contentWidth: 0
    readonly property real flickableProgress: flickable ? flickable.contentX / (flickable.contentWidth -  flickableWidth) : 0

    readonly property int contentWidth: flickableWidth - root.margins * 2

    readonly property int distance: (flickableContentWidth - (margins * 2) - (foldingAreaWidth * 2)) / (totalItems - 2)
    readonly property int startPos: margins + foldingAreaWidth + (itemIndex - 1) * distance
    readonly property int linearX: startPos - flickableProgress * (flickableContentWidth - flickableWidth)

    readonly property int leftFoldingAreaX: margins + foldingAreaWidth
    readonly property int rightFoldingAreaX: flickableWidth - foldingAreaWidth - margins

    readonly property real leftFoldingAreaProgress: linearAnimation(leftFoldingAreaX, margins, 0, 1, linearX)
    readonly property real rightFoldingAreaProgress: linearAnimation(rightFoldingAreaX, flickableWidth - margins, 0, 1, linearX)

    readonly property real limitedLeftProgress: Math.min(2, leftFoldingAreaProgress)
    readonly property real limitedRightProgress: Math.min(2, rightFoldingAreaProgress)

    readonly property real middleSectionProgress: (linearX - margins - foldingAreaWidth) / (flickableWidth - (margins + foldingAreaWidth) * 2)

    // Output
    readonly property int animatedX: {
        if (leftFoldingAreaProgress > 4) { // Stop it at the edge
            return margins;
        }
        if (leftFoldingAreaProgress > 2) { // move it slowly through the stack
            return linearAnimation(2, 4, margins + stackWidth, margins, leftFoldingAreaProgress)
        }
        if (leftFoldingAreaProgress > 1 && itemIndex == 0) {
            // The leftmost runs faster... make it stop before the stack and wait for others
            return margins + stackWidth;
        }

        if (leftFoldingAreaProgress > 0) { // slow it down in a curve
            if (itemIndex == 0) { // except if it's the leftmost. that one goes straigt
                return linearAnimation(0, 1, leftFoldingAreaX, margins + stackWidth, leftFoldingAreaProgress)
            }
            return linearAnimation(0, 1, leftFoldingAreaX, margins + stackWidth, leftEasing.value)
        }
        // same for the right side stack... mostly... don't need to treat the rightmost special...
        if (rightFoldingAreaProgress > 4) {
            return flickableWidth - margins
        }
        if (rightFoldingAreaProgress > 2) {
            return linearAnimation(2, 4, flickableWidth - margins - stackWidth, flickableWidth - margins, rightFoldingAreaProgress)
        }

        if (rightFoldingAreaProgress > 0) {
            return linearAnimation(0, 1, rightFoldingAreaX, flickableWidth - margins - stackWidth, rightEasing.value);
        }

        return linearX
    }

    readonly property int animatedY: sceneHeight - itemHeight - spreadBottomOffset

    readonly property real animatedAngle: {
        if (limitedLeftProgress > 0) {
            // Leftmost is special...
            if (index == 0) {
                if (limitedLeftProgress < 1) {
                    return unfoldedAngle;
                } else {
                    return linearAnimation(1, 2, unfoldedAngle, leftEndFoldedAngle, limitedLeftProgress)
                }
            }
            return linearAnimation(0, 2, unfoldedAngle, leftEndFoldedAngle, limitedLeftProgress)
        } else if (limitedRightProgress > 0) {
            return linearAnimation(0, 1, unfoldedAngle, rightEndFoldedAngle, rightEasing.value)
        } else {
            return unfoldedAngle
        }
    }

    readonly property real scale: limitedLeftProgress > 0 ?
                                     linearAnimation(0, 1, 1, 1 + stackScale, leftEasing.value)
                                   : limitedRightProgress > 0 ?
                                          linearAnimation(0, 1, 1, 1 + stackScale, rightEasing.value)
                                        : 0.95 + Math.abs(middleSectionProgress - 0.5) * 0.1

    readonly property real closeIconOffset: (scale - 1) * (-root.spreadHeight / 2)

    readonly property real tileInfoOpacity: leftFoldingAreaProgress > 0 ?
                                                      linearAnimation(1, 1.5, 1, 0, leftFoldingAreaProgress)
                                                    : rightFoldingAreaProgress > 0 ?
                                                          linearAnimation(1, 1.5, 1, 0, rightFoldingAreaProgress)
                                                        : 1

    readonly property bool itemVisible: itemIndex == totalItems - 1 ? true : leftFoldingAreaProgress < 5 && rightFoldingAreaProgress < 5
    readonly property real shadowOpacity: itemIndex == totalItems -1 ?
                                              1
                                            : leftFoldingAreaProgress > 3 ?
                                                  linearAnimation(3, 3.5, 1, 0, leftFoldingAreaProgress)
                                                : rightFoldingAreaProgress > 3 ?
                                                      linearAnimation(3, 3.5, 1, 0, rightFoldingAreaProgress)
                                                    : 1


    // Helpers
    function linearAnimation(startProgress, endProgress, startValue, endValue, progress) {
        // progress : progressDiff = value : valueDiff => value = progress * valueDiff / progressDiff
        return (progress - startProgress) * (endValue - startValue) / (endProgress - startProgress) + startValue;
    }

    EasingCurve {
        id: leftEasing
        type: EasingCurve.OutSine
        progress: limitedLeftProgress / 2 // OutSine starts with twice the speed. slow it down.
    }

    EasingCurve {
        id: rightEasing
        type: EasingCurve.OutSine
        progress: limitedRightProgress / 2 // OutSine starts with twice the speed. slow it down.
    }
}
