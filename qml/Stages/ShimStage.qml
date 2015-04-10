import QtQuick 2.3
import Ubuntu.Components 0.1

Rectangle {
    id: shimStage

    anchors.fill: parent
    color: UbuntuColors.lightAubergine

    Text {
        id: greeterModeText

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: units.gu(10)
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        text: "Shel is in \"greeter\" mode"
    }

    Text {
        anchors.centerIn: parent
        color: UbuntuColors.orange
        font.pointSize: units.gu(8)
        horizontalAlignment: Text.AlignHCenter
        text: "Shim \nStage"
    }
}
