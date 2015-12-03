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

    implicitHeight: progressBarImage.height

    property url source
    readonly property double progress: AudioUrlComparer.compare(source, DashAudioPlayer.currentSource) ? DashAudioPlayer.progress : 0

    Image {
        id: progressBarImage
        anchors { left: parent.left; right: parent.right }
        height: units.dp(6)
        source: "graphics/music_progress_bg.png"
        sourceSize.width: width
        sourceSize.height: height
    }

    UbuntuShape {
        id: progressBarFill
        objectName: "progressBarFill"

        readonly property int maxWidth: progressBarImage.width

        anchors {
            left: progressBarImage.left
            right: progressBarImage.right
            verticalCenter: progressBarImage.verticalCenter
            rightMargin: maxWidth - (maxWidth * root.progress)
        }
        height: units.dp(2)
        backgroundColor: UbuntuColors.orange
    }
}
