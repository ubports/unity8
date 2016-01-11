/*
 * Copyright 2015 Canonical Ltd.
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
import Dash 0.1

Item {
    id: root

    implicitHeight: positionLabel.y + positionLabel.height
    visible: AudioUrlComparer.compare(source, DashAudioPlayer.currentSource)

    property int duration: 0
    property alias source: progress.source
    property color color: theme.palette.normal.baseText
    readonly property int position: root.visible ? DashAudioPlayer.position / 1000 : 0

    AudioProgressBar {
        id: progress
        anchors { left: parent.left; right: parent.right }
    }

    Label {
        id: positionLabel
        anchors {
            left: parent.left
            top: progress.bottom
        }
        verticalAlignment: Text.AlignBottom
        fontSize: "x-small"
        text: DashAudioPlayer.lengthToString(root.position)
        color: root.color
    }

    Label {
        anchors {
            right: parent.right
            top: progress.bottom
        }
        verticalAlignment: Text.AlignBottom
        fontSize: "x-small"
        text: DashAudioPlayer.lengthToString(duration)
        color: root.color
    }
}
