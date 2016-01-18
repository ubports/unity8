/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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

/*! \brief Preview widget for audio tracks.

    This widget shows tracks contained in widgetData["tracks"], each of which should be of the form:

    \code{.json}
    {
      "source" "uri://to/file",
      "title": "Title",
      "subtitle": "Subtitle", // optional
      "length": 125 // in seconds
    }
    \endcode
 */

PreviewWidget {
    id: root
    implicitHeight: childrenRect.height

    Column {
        anchors { left: parent.left; right: parent.right }
        visible: trackRepeater.count > 0

        Repeater {
            id: trackRepeater
            objectName: "trackRepeater"
            model: root.widgetData["tracks"]

            delegate: Item {
                id: trackItem
                objectName: "trackItem" + index

                readonly property url sourceUrl: modelData["source"]
                readonly property bool isPlayingItem: AudioUrlComparer.compare(sourceUrl, DashAudioPlayer.currentSource)

                anchors { left: parent.left; right: parent.right }
                height: units.gu(5)

                Row {
                    id: trackRow

                    readonly property int column1Width: units.gu(3)
                    readonly property int column2Width: width - (2 * spacing) - column1Width - column3Width
                    readonly property int column3Width: units.gu(4)

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    spacing: units.gu(1)

                    Button {
                        objectName: "playButton"
                        width: trackRow.column1Width
                        height: width
                        iconSource: DashAudioPlayer.playing && trackItem.isPlayingItem ? "image://theme/media-playback-pause" : "image://theme/media-playback-start"

                        // Can't be "transparent" or "#00xxxxxx" as the button optimizes away the surrounding shape
                        // FIXME when this is resolved: https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1251685
                        color: "#01000000"

                        onClicked: {
                            if (trackItem.isPlayingItem) {
                                if (DashAudioPlayer.playing) {
                                    DashAudioPlayer.pause();
                                } else if (DashAudioPlayer.paused) {
                                    DashAudioPlayer.play();
                                }
                            } else {
                                DashAudioPlayer.playSource(sourceUrl);
                            }
                        }
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.column2Width
                        height: trackSubtitleLabel.visible ? trackTitleLabel.height + trackSubtitleLabel.height : trackTitleLabel.height

                        Label {
                            id: trackTitleLabel
                            objectName: "trackTitleLabel"
                            anchors { top: parent.top; left: parent.left; right: parent.right }
                            opacity: 0.9
                            color: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
                            fontSize: "small"
                            horizontalAlignment: Text.AlignLeft
                            text: modelData["title"]
                            elide: Text.ElideRight
                        }

                        Label {
                            id: trackSubtitleLabel
                            objectName: "trackSubtitleLabel"
                            anchors { top: trackTitleLabel.bottom; left: parent.left; right: parent.right }
                            visible: text !== ""
                            opacity: 0.9
                            color: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
                            font.weight: Font.Light
                            fontSize: "small"
                            horizontalAlignment: Text.AlignLeft
                            text: modelData["subtitle"] || ""
                            elide: Text.ElideRight
                        }

                        AudioProgressBar {
                            anchors { left: parent.left; top: parent.bottom; right: parent.right }
                            visible: !DashAudioPlayer.stopped && trackItem.isPlayingItem && modelData["length"] > 0
                            source: sourceUrl
                        }
                    }

                    Label {
                        id: timeLabel
                        objectName: "timeLabel"
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.column3Width
                        opacity: 0.9
                        color: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
                        fontSize: "small"
                        horizontalAlignment: Text.AlignRight
                        text: DashAudioPlayer.lengthToString(modelData["length"])
                    }
                }
            }
        }
    }
}
