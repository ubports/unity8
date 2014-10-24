
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
        source: Qt.resolvedUrl("../../qmltests/Dash/artwork/avatar.png")
    }

    CroppedImageMinimumSourceSize {
        x: 300
        y: 100
        width: 100
        height: 100
        source: "http://assets.ubuntu.com/sites/ubuntu/latest/u/img/homepage/1410/1410-wallpaper.jpg"
    }
}

