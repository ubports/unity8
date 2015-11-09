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

Item {
    id: root
    property string source: ""
    readonly property var playbackState: priv.audio ? priv.audio.playbackState : 0

    function play() {
        priv.audio.play();
    }
    function stop() {
        priv.audio.stop();
    }

    QtObject {
        id: priv
        property var audio: {
            try {
                return Qt.createQmlObject("import QtMultimedia 5.6; Audio { source: root.source; audioRole: MediaPlayer.NotificationRole }", priv)
            } catch(err) {
                console.log("Upstream audioRole enum not available, falling back to old role name.");
                return Qt.createQmlObject("import QtMultimedia 5.0; Audio { source: root.source; audioRole: MediaPlayer.alert }", priv)
            }
        }
    }
}
