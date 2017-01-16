import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Screens 0.1
import Unity.Application 0.1
import ".."

Item {
    id: root
    property string background

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gu(1)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: units.gu(1)

        Repeater {
            model: Screens

            delegate: WorkspacePreview {
                height: root.height - units.gu(6)
                background: root.background
            }
        }
    }
}
