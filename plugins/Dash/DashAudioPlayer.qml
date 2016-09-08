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
    id: root
    readonly property real progress: priv.audio ? priv.audio.position / priv.audio.duration : 0.0
    readonly property bool playing: priv.audio ? priv.audio.playbackState === Audio.PlayingState : false
    readonly property bool paused: priv.audio ? priv.audio.playbackState === Audio.PausedState : false
    readonly property bool stopped: priv.audio ? priv.audio.playbackState === Audio.StoppedState : true
    readonly property int position: priv.audio ? priv.audio.position : 0
    readonly property url currentSource: priv.audio ? priv.audio.playlist.currentItemSource : ""
    readonly property Playlist playlist: priv.audio ? priv.audio.playlist : null

    function playSource(newSource, newPlaylist) {
        if (!priv.audio) {
            console.info("DashAudioPlayer: creating player");
            priv.audio = priv.audioComponent.createObject(root);
        }
        stop();
        priv.audio.playlist.clear();
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
            priv.audio.playlist.addItems(urls);
            priv.audio.playlist.currentIndex = sourceIndex;
        } else {
            priv.audio.playlist.addItem(newSource);
            priv.audio.playlist.currentIndex = 0;
        }
        play();
    }

    function stop() {
        if (priv.audio) {
            priv.audio.stop();
        }
    }

    function play() {
        if (priv.audio) {
            priv.audio.play();
        }
    }

    function pause() {
        if (priv.audio) {
            priv.audio.pause();
        }
    }

    property QtObject priv: QtObject {
        id: priv
        property Audio audio: null
        property Component audioComponent: Component {
            Audio {
                playlist: Playlist {
                    objectName: "playlist"
                }
                /* Remove player in case of error so it gets recreated next time
                 * we need it. Happens if backend media player restarted, for
                 * instance. qtmultimedia should probably handle this
                 * transparently (LP: #1616425).
                 */
                onError: {
                    console.warn("DashAudioPlayer: error event (" +
                                  priv.audio.errorString + "), destroying");
                    priv.audio.destroy();
                }
            }
        }
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
