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
import QtMultimedia 5.6
import Dash 0.1

QtObject {
    readonly property real progress: audio.position / audio.duration
    readonly property bool playing: audio.playbackState === Audio.PlayingState
    readonly property bool paused: audio.playbackState === Audio.PausedState
    readonly property bool stopped: audio.playbackState === Audio.StoppedState
    readonly property alias position: audio.position
    readonly property url currentSource: audio.playlist.currentItemSource

    function playSource(newSource, newPlaylist) {
        stop();
        audio.playlist.clear();
        if (newPlaylist) {
            // Look for newSource in newPlaylist
            var sourceIndex = -1;
            for (var i in newPlaylist) {
                if (AudioUrlComparer.compare(newSource, newPlaylist[i])) {
                    sourceIndex = i;
                    break;
                }
            }
            var urls = [];
            if (sourceIndex === -1 && newSource != "") {
                // If the playing song is not in the playlist, add it
                urls.push(newSource);
                sourceIndex = 0;
            }
            for (var i in newPlaylist) {
                urls.push(newPlaylist[i]);
            }
            audio.playlist.addItems(urls);
            audio.playlist.currentIndex = sourceIndex;
        } else {
            audio.playlist.addItem(newSource);
            audio.playlist.currentIndex = 0;
        }
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

    property QtObject audio: Audio {
        id: audio
        objectName: "audio"
        playlist: Playlist {
            objectName: "playlist"
        }

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
