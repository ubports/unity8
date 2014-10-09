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
import Ubuntu.Gestures 0.1

Item {
    id: root
    property real trackedValue: 0
    property bool stopLateralChanges: false
    property real velocityThreashold: 0.4

    signal velocityThreasholdTriggered

    function reset() {
        stopLateralChanges = false;
        calc.reset();
    }

    onTrackedValueChanged: {
        calc.trackedPosition = trackedValue;
        velocityTimer.start();
    }

    AxisVelocityCalculator {
        id: calc
        onTrackedPositionChanged: {
            var velocity = Math.abs(calc.calculate());
            stopLateralChanges = velocity > velocityThreashold;
        }
    }

    Timer {
        id: velocityTimer
        interval: 50
        onTriggered: {
            calc.trackedPosition = trackedValue;
            root.stopLateralChanges = Math.abs(calc.calculate()) > velocityThreashold;
            if (root.stopLateralChanges) {
                velocityTimer.start();
            } else {
                velocityThreasholdTriggered();
            }
        }
    }
}
