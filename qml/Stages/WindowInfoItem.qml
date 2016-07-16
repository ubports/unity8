import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root
    property alias title: titleLabel.text
    property alias iconSource: icon.source

    property real iconHeight: (height - titleLabel.height) * 0.65
    property real iconMargin: (height - titleLabel.height) * 0.25
    property real labelMargin: (height - titleLabel.height) * 0.1

    UbuntuShape {
        id: iconShape
        anchors {
            top: parent.top
            topMargin: iconMargin
            left: parent.left
        }
        width:  units.gu(8) / units.gu(7.5) * height
        height: iconHeight
        borderSource: "undefined"
        source: Image {
            id: icon
            sourceSize.width: iconShape.width
            sourceSize.height: iconShape.height
        }
    }

    Label {
        id: titleLabel
        anchors {
            left: iconShape.left
            top: iconShape.bottom
            topMargin: labelMargin
        }
        fontSize: 'small'
        color: 'white'
    }
}
