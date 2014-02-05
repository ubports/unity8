import QtQuick 2.0

Item {
    id: root

    signal clicked()

    property real topMarginProgress

    QtObject {
        id: priv
        property real heightDifference: root.height - appImage.implicitHeight
    }

    Image {
        id: dropShadow
        anchors.fill: appImage
        anchors.margins: -units.gu(2)
        source: "graphics/dropshadow.png"
        opacity: .4
    }
    Image {
        id: appImage
        anchors { left: parent.left; bottom: parent.bottom; top: parent.top; topMargin: priv.heightDifference * Math.max(0, 1 - root.topMarginProgress) }
        source: model.screenshot
        scale: 1
    }
    MouseArea {
        anchors.fill: appImage
        onClicked: root.clicked()
    }
}
