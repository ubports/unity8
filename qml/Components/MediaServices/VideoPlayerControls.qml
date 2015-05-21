import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.0

MediaServicesControls {
    id: root
    readonly property alias mediaPlayer: _mediaPlayer
    property bool interacting: false

    QtObject {
        id: priv

        function formatTime(position) {
            var pos = (position/1000).toFixed(0)

            var m = Math.floor(pos/60);
            var ss = pos % 60;
            if (ss >= 10) {
                return m + ":" + ss;
            } else {
                return m + ":0" + ss;
            }
        }
    }

    component: Item {
        Connections {
            target: mediaPlayer
            onPositionChanged: {
                if (slider.valueGuard) return;

                slider.valueGuard = true;
                slider.value = mediaPlayer.position;
                slider.valueGuard = false;
                if (!slider.pressed) {
                    positionLabel.text = priv.formatTime(mediaPlayer.position);
                }
            }
        }

        Binding {
            target: root
            property: "interacting"
            value: slider.pressed
        }

        Label {
            id: positionLabel
            anchors {
                left: parent.left
                bottom: parent.bottom
                bottomMargin: -units.dp(3)
            }
            verticalAlignment: Text.AlignBottom
            fontSize: "x-small"
            color: "#F3F3E7"

            text: priv.formatTime(mediaPlayer.position)
        }

        Slider {
            id: slider
            property bool valueGuard: false

            anchors {
                left: parent.left
                right: parent.right
            }
            height: units.gu(2)
            live: true
            enabled: mediaPlayer.seekable && mediaPlayer.duration > 0
            minimumValue: 0
            maximumValue:  mediaPlayer.duration > 0 ? mediaPlayer.duration : 1
            value: mediaPlayer.position
            theme: ThemeSettings {
                palette: Palette {
                    normal.base: "#F3F3E7"
                }
            }

            onValueChanged: {
                if (!pressed) return;
                if (slider.valueGuard) return;

                slider.valueGuard = true;
                mediaPlayer.seek(value);
                slider.valueGuard = false;
            }

            property bool wasPlaying: mediaPlayer.playbackState === MediaPlayer.PlayingState
            onPressedChanged: {
                if (pressed) {
                    wasPlaying = mediaPlayer.playbackState === MediaPlayer.PlayingState
                    mediaPlayer.pause();
                } else {

                    positionLabel.text = priv.formatTime(mediaPlayer.position);
                    if (wasPlaying) {
                        mediaPlayer.play();
                    }
                }
            }

            function formatValue(value) {
                return priv.formatTime(value);
            }
        }

        Label {
            anchors {
                right: parent.right
                bottom: parent.bottom
                bottomMargin: -units.dp(3)
            }
            verticalAlignment: Text.AlignBottom
            fontSize: "x-small"
            color: "#F3F3E7"

            text: priv.formatTime(mediaPlayer.duration)
        }
    }

    MediaPlayer {
        id: _mediaPlayer
        objectName: "mediaPlayer"
    }
}
