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
//        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: parent.left
        spacing: units.gu(1)

        Repeater {
            model: Screens

            delegate: Item {
                height: root.height - units.gu(6)
                width: workspaces.width

                UbuntuShape {
                    id: header
                    anchors { left: parent.left; top: parent.top; right: parent.right }
                    height: units.gu(7)
                    backgroundColor: "white"

                    Column {
                        anchors.fill: parent
                        anchors.margins: units.gu(1)

                        Label {
                            text: model.screen.name
                            color: "black"
                        }

                        Label {
                            text: model.screen.outputType === Screens.LVDS ? "Built-in" : "Clone"
                            color: "black"
                            fontSize: "x-small"
                        }

                        Label {
                            text: model.screen.physicalSize.width + "x" + model.screen.physicalSize.height
                            color: "black"
                            fontSize: "x-small"
                        }
                    }
                }


                Workspaces {
                    id: workspaces
                    height: parent.height - header.height - units.gu(2)
                    width: Math.min(implicitWidth, units.gu(80), root.width)
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    screen: model.screen
                    background: root.background
                }
            }
        }
    }
}
