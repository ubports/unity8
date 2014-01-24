import QtQuick 2.0

Item {
    id: root

    signal clicked()

    Image {
        id: dropShadow
        anchors.fill: appImage
        anchors.margins: -units.gu(2)
        source: "graphics/dropshadow.png"
    }
    Image {
        id: appImage
        anchors { left: parent.left; bottom: parent.bottom }
        source: model.screenshot
        scale: 1
    }
    MouseArea {
        anchors.fill: appImage
        onClicked: root.clicked()
    }
}
