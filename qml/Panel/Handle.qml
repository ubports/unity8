import QtQuick 2.0
import Ubuntu.Components 0.1

Rectangle {
    id: handle
    color: "#333333"
    height: units.gu(2)
    property bool active: false

    Row {
        id: dots
        width: childrenRect.width
        height: children.height
        anchors.centerIn: parent
        spacing: units.gu(0.5)
        Repeater {
            model: 3
            delegate: Rectangle {
                id: dot
                width: units.gu(0.33)
                height: width
                color: handle.active ? "#de4814" : "#717171"
                radius: units.dp(1)
            }
        }
    }
}
