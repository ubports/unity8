/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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
import HudClient 0.1

Item {
    id: voiceInput

    readonly property int totalSpots: 30
    readonly property int totalIdles: 7

    property real __newPeak: 0

    VolumePeakDetector {
        id: peakDetector
        desiredInterval: peakMover.interval
        onNewPeak: {
            __newPeak = volume
        }
    }

    Timer {
        id: peakMover
        interval: 10
        repeat: true
        onTriggered: {
            moveBalls()
            voiceAmplitudes.itemAt(0).amplitude = __newPeak
        }
    }

    Repeater {
        id: fixedPositionSoundAmplitudes
        model: totalSpots
        delegate: SoundAmplitudeDelegate {
            totalCount: fixedPositionSoundAmplitudes.count
            ballIndex: index
            opacity: 1
            visible: true
        }
    }

    Repeater {
        id: voiceAmplitudes
        model: totalSpots
        delegate: SoundAmplitudeDelegate {
            totalCount: voiceAmplitudes.count
            ballIndex: index
        }
    }

    Repeater {
        id: idleAmplitudes
        model: totalSpots
        delegate: SoundAmplitudeDelegate {
            totalCount: idleAmplitudes.count
            ballIndex: index
            amplitude: 0.05
            visible: idleAmplitudes.enabled
        }
    }

    function setDetectorEnabled(enabled) {
        idleAmplitudes.enabled = false
        if (enabled) {
            peakMover.start()
        } else {
            peakDetector.enabled = false
            peakMover.stop()
        }
    }

    function moveBalls() {
        var i = 0
        var amplitude = voiceAmplitudes.itemAt(0).amplitude
        for (var i = 1; i < totalSpots; ++i) {
            var item = voiceAmplitudes.itemAt(i)
            var tempAmplitude = item.amplitude
            item.amplitude = amplitude
            amplitude = tempAmplitude
        }
    }

    property int __firstIdle
    property int __idleCount

    Timer {
        id: idleBallsTimer
        interval: 40
        onTriggered: moveAndAddIdleBalls()
    }

    function moveAndAddIdleBalls() {
        // Check if we are doing the real thing
        if (!idleAmplitudes.enabled) {
            return
        }

        for (var i = 0; i < __idleCount; ++i) {
            var index = __firstIdle - i
            var item = idleAmplitudes.itemAt(index % totalSpots)
            var nextItem = idleAmplitudes.itemAt((index + 1) % totalSpots)
            nextItem.opacity = item.opacity
        }
        __firstIdle++
        idleAmplitudes.itemAt((__firstIdle - __idleCount) % totalSpots).opacity = 0

        if (__idleCount < totalIdles) {
            idleAmplitudes.itemAt(0).opacity = 1 - (__idleCount / totalIdles)
            __idleCount++
        }
        idleBallsTimer.start()
    }

    function startIdle() {
        // On the device the peak detector takes quite a lot to start up
        // so enable it as soon as we know we are going to do voice capture
        peakDetector.enabled = true
        for (var i = 0; i < totalSpots; ++i) {
            idleAmplitudes.itemAt(i).opacity = 0
        }
        for (var i = 0; i < totalSpots; ++i) {
            voiceAmplitudes.itemAt(i).amplitude = 0
        }

        idleAmplitudes.enabled = true
        idleAmplitudes.itemAt(0).opacity = 1
        __idleCount = 1
        __firstIdle = 0
        idleBallsTimer.start()
    }
}
