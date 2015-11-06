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

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: scrollArea

    readonly property bool areaActive: lateralPosition >= 0
    property real stopScrollThreshold: units.gu(2)
    property int direction: Qt.LeftToRight
    property real baseScrollAmount: units.dp(3)
    property real maximumScrollAmount: units.dp(8)
    property real lateralPosition: -1
    property real forceScrollingPercentage: 0.4

    signal scroll(real scrollAmount)

    width: units.gu(5)
    rotation: direction === Qt.LeftToRight ? 0 : 180

    onAreaActiveChanged: areaActive ? handleEnter() : handleExit()

    function handleEnter() {
        d.thresholdAreaX = -scrollArea.stopScrollThreshold;
        scrollTimer.restart();
    }

    function handleExit() {
        d.thresholdAreaX = -scrollArea.stopScrollThreshold;
        scrollTimer.stop();
    }

    onLateralPositionChanged: {
        if (scrollArea.areaActive) {
            if (lateralPosition > width * (1 - forceScrollingPercentage)) {
                d.thresholdAreaX = width * (1 - forceScrollingPercentage);
                if (!scrollTimer.running) scrollTimer.restart();
            } else if (lateralPosition > d.thresholdAreaX + scrollArea.stopScrollThreshold) {
                d.thresholdAreaX = lateralPosition - scrollArea.stopScrollThreshold;
                if (!scrollTimer.running) scrollTimer.restart();
            } else if (lateralPosition < d.thresholdAreaX) {
                d.thresholdAreaX = lateralPosition;
                scrollTimer.stop();
            }

            d.progression = lateralPosition / width;
        }
    }

    Timer {
        id: scrollTimer
        interval: 16
        repeat: true

        onTriggered: {
            var scrollAmount = scrollArea.baseScrollAmount + scrollArea.maximumScrollAmount * d.progression;
            scrollArea.scroll(scrollAmount);
        }
    }

    QtObject {
        id: d
        property real progression: 0
        property real thresholdAreaX: -scrollArea.stopScrollThreshold
    }
}
