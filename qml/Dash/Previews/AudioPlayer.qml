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
import QtMultimedia 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1

Item {
    id: trackItem
    implicitHeight: units.gu(5)

    property bool isPlayingItem
    property int playbackState
    property real progress: 0
    property string title
    property string length

    signal play()

    signal pause()

    Row {
        id: trackRow
        width: parent.width
        spacing: units.gu(1)
        property int column1Width: units.gu(3)
        property int column2Width: width - (2 * spacing) - column1Width - column3Width
        property int column3Width: units.gu(4)
        anchors.verticalCenter: parent.verticalCenter

        Button {
            objectName: "playButton"
            width: trackRow.column1Width
            height: width
            iconSource: trackItem.playbackState == Audio.PlayingState && trackItem.isPlayingItem ? "image://theme/media-playback-pause" : "image://theme/media-playback-start"

            // Can't be "transparent" or "#00xxxxxx" as the button optimizes away the surrounding shape
            // FIXME when this is resolved: https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1251685
            color: "#01000000"

            onClicked: {
                if (trackItem.isPlayingItem) {
                    if (trackItem.playbackState == Audio.PlayingState) {
                        trackItem.pause();
                    } else if (audioPlayer.playbackState == Audio.PausedState){
                        trackItem.play();
                    }
                } else {
                    trackItem.play();
                }
            }
        }

        Label {
            objectName: "trackTitleLabel"
            fontSize: "small"
            opacity: 0.9
            color: "white"
            horizontalAlignment: Text.AlignLeft
            anchors.verticalCenter: parent.verticalCenter
            width: parent.column2Width
            text: title
            style: Text.Raised
            styleColor: "black"
            elide: Text.ElideRight

            UbuntuShape {
                id: progressBarFill
                objectName: "progressBarFill"
                color: UbuntuColors.orange
                anchors.left: progressBarImage.left
                anchors.right: progressBarImage.right
                anchors.verticalCenter: progressBarImage.verticalCenter
                height: units.dp(2)
                anchors.margins: units.dp(2)
                anchors.rightMargin: maxWidth - (maxWidth * progress) + units.dp(2)
                visible: progressBarImage.visible

                property int maxWidth: progressBarImage.width - units.dp(4)
            }

            Image {
                id: progressBarImage
                anchors { left: parent.left; top: parent.bottom; right: parent.right }
                height: units.dp(6)
                visible: trackItem.playbackState != Audio.StoppedState && trackItem.isPlayingItem && length.length > 0
                source: "graphics/music_progress_bg.png"
            }
        }

        Label {
            id: valueLabel
            objectName: "timeLabel"
            fontSize: "small"
            opacity: 0.9
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            width: parent.column3Width
            text: length
            style: Text.Raised
            styleColor: "black"
        }
    }

    ThinDivider {
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
    }
}
