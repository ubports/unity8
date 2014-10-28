
import QtQuick 2.3
import Ubuntu.Components 1.1
import Dash 0.1

Rectangle {
    width: 500
    height: 300

    color: "red"

    CroppedImageMinimumSourceSize {
        x: 100
        y: 100
        width: 100
        height: 100
        source: Qt.resolvedUrl("../../qmltests/Dash/artwork/music-player-design.png")
    }
}

