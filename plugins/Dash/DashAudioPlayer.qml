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

pragma Singleton
import QtQuick 2.4
import QtMultimedia 5.0
import Dash 0.1

QtObject {
    readonly property real progress: audio.position / audio.duration
    readonly property bool playing: audio.playbackState === Audio.PlayingState
    readonly property bool paused: audio.playbackState === Audio.PausedState
    readonly property bool stopped: audio.playbackState === Audio.StoppedState
    readonly property alias position: audio.position

    function isCurrentSource(source) {
        return source != "" && AudioUrlComparer.compare(source, audio.source);
    }

    function playSource(newSource) {
        stop();
        // Make sure we change the source, even if two items point to the same uri location
        audio.source = "";
        audio.source = newSource;
        play();
    }

    function stop() {
        audio.stop();
    }

    function play() {
        audio.play();
    }

    function pause() {
        audio.pause();
    }

    property QtObject d: Audio {
        id: audio
        objectName: "audio"

        onErrorStringChanged: console.warn("Dash Audio player error:", errorString)
    }

    function lengthToString(s) {
        if (typeof(s) !== "number" || s < 0) return "";

        var sec = "" + s % 60;
        if (sec.length == 1) sec = "0" + sec;
        var hour = Math.floor(s / 3600);
        if (hour < 1) {
            return Math.floor(s / 60) + ":" + sec;
        } else {
            var min = "" + Math.floor(s / 60) % 60;
            if (min.length == 1) min = "0" + min;
            return hour + ":" + min + ":" + sec;
        }
    }
}
