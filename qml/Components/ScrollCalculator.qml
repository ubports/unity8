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

Item {
    id: scrollArea

    property real thresholdAreaWidth: units.gu(1)
    property bool showDebugRectangles: false
    property int direction: Qt.LeftToRight
    property real baseScrollAmount:  units.dp(2)
    property real maximumScrollAmount: units.dp(6)

    property real lateralPosition: -1
    readonly property bool areaActive: lateralPosition >= 0
    onAreaActiveChanged: {
        if (areaActive) {
            handleEnter();
        } else {
            handleExit();
        }
    }

    // from 0 to 1
    property real forceScrollingPercentage: 0.4
    signal scroll(real scrollAmount)

    width: 200
    height: 200
    rotation: direction == Qt.LeftToRight ? 0 : 180

    function handleEnter() {
        d.threasholdAreaX = -scrollArea.thresholdAreaWidth;
        scrollTimer.restart();
    }
    onLateralPositionChanged: {
        if (scrollArea.areaActive) {

            if (lateralPosition > width * (1 - forceScrollingPercentage)) {
                d.threasholdAreaX = width * (1 - forceScrollingPercentage);
                if (!scrollTimer.running) scrollTimer.restart();
            } else if (lateralPosition > d.threasholdAreaX + scrollArea.thresholdAreaWidth) {
                d.threasholdAreaX = lateralPosition - scrollArea.thresholdAreaWidth;
                if (!scrollTimer.running) scrollTimer.restart();
            } else if (lateralPosition < d.threasholdAreaX) {
                d.threasholdAreaX = lateralPosition;
                scrollTimer.stop();
            }

            d.progression = lateralPosition / width;
        }
    }

    function handleExit() {
        d.threasholdAreaX = -scrollArea.thresholdAreaWidth;
        scrollTimer.stop();
    }

    Timer {
        id: scrollTimer
        interval: 5
        repeat: true
        onTriggered: {
            scrollArea.scroll(scrollArea.baseScrollAmount + scrollArea.maximumScrollAmount * d.progression);
        }
    }

    QtObject {
        id: d

        property real progression: 0
        property real threasholdAreaX: -scrollArea.thresholdAreaWidth

        Behavior on progression {
            SmoothedAnimation { velocity: 2.0 }
        }
    }
}
