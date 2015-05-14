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

import QtQuick 2.0
import QtMultimedia 5.0
import Ubuntu.Components 0.1
import Ubuntu.Thumbnailer 0.1
import "../../Components"

Item {
    id: root

    property url screenshot: image.source
    property alias mediaPlayer: videoOutput.source
    property int orientation: Qt.PortraitOrientation
    property bool fixedHeight: false

    implicitHeight: {
        if (parent && orientation == Qt.LandscapeOrientation) {
            return parent.height;
        }
        return content.height;
    }

    signal clicked
    signal positionChanged

    Rectangle {
        anchors.fill: root
//        anchors.leftMargin: units.gu(2)
//        anchors.rightMargin: units.gu(2)
        color: "#1B1B1B"
        opacity: 0.85
        visible: mediaPlayer.playbackState !== MediaPlayer.StoppedState
    }

    Item {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: root.orientation == Qt.LandscapeOrientation || fixedHeight ? root.height : childrenRect.height;

        LazyImage {
            id: image
            objectName: "screenshot"
            anchors {
                left: parent.left
                right: parent.right
            }
            anchors.verticalCenter: parent.verticalCenter
            scaleTo: "width"
            initialHeight: width * 10 / 16
            visible: mediaPlayer.playbackState === MediaPlayer.StoppedState
        }

        VideoOutput {
            id: videoOutput
            anchors {
                left: parent.left
                right: parent.right
            }
            anchors.verticalCenter: parent.verticalCenter
            height: {
                if (root.orientation == Qt.LandscapeOrientation || fixedHeight) {
                    return root.height;
                }
                return (mediaPlayer.metaData.resolution.height / mediaPlayer.metaData.resolution.width ) * width;
            }

            source: mediaPlayer
            visible: mediaPlayer.playbackState !== MediaPlayer.StoppedState
        }

//        Loader {
//            id: shaderLoader
//            anchors.fill: videoOutput
//            sourceComponent: fixedHeight ? shaderComponent : undefined

//            Component {
//                id: shaderComponent

//                Item {
//                    ShaderEffect {
//                        id: leftVideo
//                        property variant source: ShaderEffectSource {
//                            sourceItem: videoOutput
//                            hideSource: true
//                            sourceRect: Qt.rect(0, 0, units.gu(2), videoOutput.height)
//                        }
//                        anchors {
//                            top: parent.top
//                            bottom: parent.bottom
//                            left: parent.left
//                        }
//                        width: units.gu(2)
//                        visible: mediaPlayer.playbackState !== MediaPlayer.StoppedState

//                        property real itemOpacity: 0.5

//                        fragmentShader: "
//                            varying highp vec2 qt_TexCoord0;
//                            uniform sampler2D source;
//                            uniform lowp float itemOpacity;
//                            void main(void)
//                            {
//                                highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
//                                sourceColor *= itemOpacity;
//                                gl_FragColor = sourceColor;
//                            }
//                        "
//                    }

//                    ShaderEffect {
//                        id: middleVideo
//                        property variant source: ShaderEffectSource {
//                            sourceItem: videoOutput
//                            hideSource: true
//                            sourceRect: Qt.rect(units.gu(2), 0, videoOutput.width - units.gu(4), videoOutput.height)
//                        }
//                        anchors {
//                            top: parent.top
//                            bottom: parent.bottom
//                            left: leftVideo.right
//                            right: rightVideo.left
//                        }
//                        visible: mediaPlayer.playbackState !== MediaPlayer.StoppedState

//                        property real itemOpacity: 1

//                        fragmentShader: "
//                            varying highp vec2 qt_TexCoord0;
//                            uniform sampler2D source;
//                            uniform lowp float itemOpacity;
//                            void main(void)
//                            {
//                                highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
//                                sourceColor *= itemOpacity;
//                                gl_FragColor = sourceColor;
//                            }
//                        "
//                    }

//                    ShaderEffect {
//                        id: rightVideo
//                        property variant source: ShaderEffectSource {
//                            sourceItem: videoOutput
//                            hideSource: true
//                            sourceRect: Qt.rect(videoOutput.width - units.gu(2), 0, units.gu(2), videoOutput.height)
//                        }
//                        anchors {
//                            top: parent.top
//                            bottom: parent.bottom
//                            right: parent.right
//                        }
//                        width: units.gu(2)
//                        visible: mediaPlayer.playbackState !== MediaPlayer.StoppedState

//                        property real itemOpacity: 0.5

//                        fragmentShader: "
//                            varying highp vec2 qt_TexCoord0;
//                            uniform sampler2D source;
//                            uniform lowp float itemOpacity;
//                            void main(void)
//                            {
//                                highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
//                                sourceColor *= itemOpacity;
//                                gl_FragColor = sourceColor;
//                            }
//                        "
//                    }
//                }
//            }
//        }
    }

    Rectangle {
        id: playButton
        readonly property bool bigButton: parent.width > units.gu(40)
        anchors.centerIn: content
        width: bigButton ? units.gu(10) : units.gu(8)
        height: width
        visible: mediaPlayer.playbackState !== MediaPlayer.PlayingState
        color: "#1B1B1B"
        opacity: 0.85
        radius: width/2

        Behavior on width { UbuntuNumberAnimation {} }

        Icon {
            name: "media-playback-start"
            anchors.fill: parent
            anchors.margins: units.gu(1)
            color: "#F3F3E7"
        }
    }

    ActivityIndicator {
        anchors.centerIn: content
        running: mediaPlayer.status === MediaPlayer.Stalled ||
                 (mediaPlayer.playbackState === MediaPlayer.PlayingState && (mediaPlayer.status === MediaPlayer.Loading || mediaPlayer.status === MediaPlayer.Loaded))
    }

    MouseArea {
        id: contentMouseArea
        anchors.fill: content
        hoverEnabled: mediaPlayer.playbackState !== MediaPlayer.StoppedState

        onClicked: root.clicked()
        onPositionChanged: root.positionChanged()
    }
}
