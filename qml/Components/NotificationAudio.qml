/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import QtMultimedia 5.6

Item {
    id: root
    property string source: ""
    readonly property var playbackState: priv.audio ? priv.audio.playbackState : 0

    function play() {
        if (!priv.audio) {
            console.info("NotificationAudio: creating player");
            priv.audio = priv.audioComponent.createObject(root);
        }
        if (priv.audio) {
            priv.audio.play();
        }
    }
    function stop() {
        if (priv.audio) {
            priv.audio.stop();
        }
    }

    QtObject {
        id: priv
        property Audio audio: null
        property Component audioComponent: Component {
            Audio {
                source: root.source
                audioRole: MediaPlayer.NotificationRole
                /* Remove player in case of error so it gets recreated next time
                 * we need it. Happens if backend media player restarted, for
                 * instance. qtmultimedia should probably handle this
                 * transparently (LP: #1616425).
                 */
                onError: {
                    console.warn("NotificationAudio: error event (" +
                                  priv.audio.errorString + "), destroying");
                    priv.audio.destroy();
                }
            }
        }
    }
}
