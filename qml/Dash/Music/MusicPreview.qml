/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import ".."
import "../Generic"
import "../../Components"
import "../Previews"

GenericPreview {
    id: root

    previewImages: previewImageComponent
    header: headerComponent
    description: descriptionComponent

    Component {
        id: previewImageComponent
        LazyImage {
            height: units.gu(22)
            scaleTo: "height"
            source: previewData ? previewData.image : ""
            initialHeight: height
            initialWidth: height
        }
    }

    Component {
        id: headerComponent
        Header {
            title: previewData.title
            subtitle: previewData.subtitle
        }
    }

    Component {
        id: descriptionComponent

        Item {
            height: childrenRect.height
            Audio {
                id: audioPlayer
                objectName: "audioPlayer"
                property real progress: audioPlayer.position / audioPlayer.duration

                property Item playingItem

                Component.onDestruction: {
                    audioPlayer.stop();
                }

                onErrorStringChanged: console.warn("Audio player error:", errorString)

            }

            Connections {
                target: root
                onIsCurrentChanged: {
                    if (!root.isCurrent) {
                        audioPlayer.stop();
                    }
                }
            }

            Column {
                anchors { left: parent.left; right: parent.right }
                visible: trackRepeater.count > 0

                ThinDivider {
                    objectName: "topDivider"
                    anchors { left: parent.left; right: parent.right }
                }

                Repeater {
                    id: trackRepeater
                    objectName: "trackRepeater"

                    model: previewData.tracks

                    delegate: AudioPlayer {
                        id: trackItem
                        objectName: "trackItem" + index
                        anchors { left: parent.left; right: parent.right }
                        height: units.gu(5)

                        isPlayingItem: audioPlayer.playingItem == trackItem
                        playbackState: audioPlayer.playbackState
                        progress: audioPlayer.progress
                        title: model.title
                        length: model.length

                        onPlay: {
                            audioPlayer.stop();
                            // Make sure we change the source, even if two items point to the same uri location
                            audioPlayer.source = "";
                            audioPlayer.source = model.uri;
                            audioPlayer.playingItem = trackItem;
                            audioPlayer.play();
                        }

                        onPause: {
                            audioPlayer.stop()
                        }
                    }
                }
            }
        }
    }
}
