/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import QtMultimedia 5.0
import Ubuntu.Components 1.3
import Ubuntu.Thumbnailer 0.1
import "../../Components"

Item {
    id: root

    property alias screenshot: image.source
    property alias mediaPlayer: videoOutput.source
    property int orientation: Qt.PortraitOrientation
    property bool fixedHeight: false
    property var maximumEmbeddedHeight

    property alias playButtonBackgroundColor: playButton.color
    property alias playButtonIconColor: playButtonIcon.color

    implicitHeight: {
        if (parent && orientation === Qt.LandscapeOrientation) {
            return parent.height;
        }
        return content.height;
    }

    signal clicked
    signal positionChanged

    Item {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: {
            if (root.orientation === Qt.LandscapeOrientation || fixedHeight) {
                return root.height;
            }
            var proposedHeight = videoOutput.height;
            if (maximumEmbeddedHeight !== undefined && maximumEmbeddedHeight < proposedHeight) {
                return maximumEmbeddedHeight;
            }
            return proposedHeight;
        }
        clip: image.height > videoOutput.height

        LazyImage {
            id: image
            objectName: "screenshot"
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            scaleTo: "width"
            lastScaledDimension: playButton.height + units.gu(2)
            initialHeight: lastScaledDimension
            useUbuntuShape: false

            visible: !mediaPlayer || mediaPlayer.playbackState === MediaPlayer.StoppedState
        }

        VideoOutput {
            id: videoOutput
            anchors.centerIn: parent

            width: root.width
            height: {
                if (fixedHeight) {
                    return root.height;
                }
                var proposedHeight = mediaPlayer && mediaPlayer.metaData.resolution !== undefined ?
                            (mediaPlayer.metaData.resolution.height / mediaPlayer.metaData.resolution.width) * width :
                            image.height;
                if (maximumEmbeddedHeight !== undefined && maximumEmbeddedHeight < proposedHeight) {
                    return maximumEmbeddedHeight;
                }
                return proposedHeight;
            }

            source: mediaPlayer
            visible: mediaPlayer && mediaPlayer.playbackState !== MediaPlayer.StoppedState || false

            Connections {
                target: mediaPlayer
                onError: {
                    if (error !== MediaPlayer.NoError) {
                        errorTimer.restart();
                    }
                }
            }
        }
    }

    Rectangle {
        id: playButton
        readonly property bool bigButton: parent.width > units.gu(40)
        anchors.centerIn: content
        width: bigButton ? units.gu(10) : units.gu(8)
        height: width
        visible: mediaPlayer && mediaPlayer.playbackState !== MediaPlayer.PlayingState || false
        opacity: 0.85
        radius: width/2

        Behavior on width { UbuntuNumberAnimation {} }

        Icon {
            id: playButtonIcon
            anchors.fill: parent
            anchors.margins: units.gu(1)
            name: errorTimer.running ? "dialog-warning-symbolic" : "media-playback-start"
        }
    }

    ActivityIndicator {
        anchors.centerIn: content
        running: {
            if (!mediaPlayer) return false;
            return mediaPlayer.status === MediaPlayer.Stalled ||
                 (mediaPlayer.playbackState === MediaPlayer.PlayingState && mediaPlayer.status === MediaPlayer.Loading);
        }
    }

    MouseArea {
        id: contentMouseArea
        anchors.fill: content
        enabled: !errorTimer.running
        hoverEnabled: mediaPlayer && mediaPlayer.playbackState !== MediaPlayer.StoppedState || false

        onClicked: root.clicked()
        onPositionChanged: root.positionChanged()
    }

    Timer {
        id: errorTimer
        interval: 2000
    }
}
